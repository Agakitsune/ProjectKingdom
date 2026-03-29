@tool
extends Marker2D
class_name Border

@export var height := 0.0:
	set = _set_height

@export var from: CameraLimit
@export var to: CameraLimit

@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	(collision_shape_2d.shape as RectangleShape2D).size.y = height


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if from:
		var start := to_local(from.position) + from.size / 2.0
		var end := Vector2.ZERO
		var vec := start - end
		var mid := vec / 2.0
		var norm := vec.normalized()
		var angle := vec.angle() + deg_to_rad(135.0)
		
		draw_line(start, end, Color.CORNFLOWER_BLUE, 0.5, true)
		draw_line(mid, mid + norm.rotated(angle) * 20.0, Color.CORNFLOWER_BLUE)
		draw_line(mid, mid + norm.rotated(-angle) * 20.0, Color.CORNFLOWER_BLUE)
	if to:
		var start := to_local(to.position) + to.size / 2.0
		var end := Vector2.ZERO
		var vec := start - end
		var mid := vec / 2.0
		var norm := vec.normalized()
		var angle := vec.angle() - deg_to_rad(90.0)
		
		draw_line(start, end, Color.CORNFLOWER_BLUE, 0.5, true)
		draw_line(mid, mid + norm.rotated(angle) * 20.0, Color.CORNFLOWER_BLUE)
		draw_line(mid, mid + norm.rotated(-angle) * 20.0, Color.CORNFLOWER_BLUE)


func _set_height(h: float):
	height = h
	
	if Engine.is_editor_hint():
		(collision_shape_2d.shape as RectangleShape2D).size.y = height


func _on_area_2d_body_entered(body: Node2D) -> void:
	var p := body as Player
	p._use_limit(to)
	collision_shape_2d.set_deferred("disabled", false)
