extends Node2D

@export var flip := false
@export var spell_name := "cross"

@onready var sprite_2d: Sprite2D = $Sprite2D

var velocity: Vector2
var cross_rotation: float 

var _enemy: Array[Node2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if flip:
		velocity.x = -250
		cross_rotation = -4.5
	else:
		cross_rotation = 4.5
		velocity.x = 250

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta
	if flip:
		sprite_2d.rotate(delta * -16.0)
		#cross_rotation += 0.25 * delta
		velocity.x += 400 * delta
	else:
		sprite_2d.rotate(delta * 16.0)
		#cross_rotation -= 0.25 * delta
		velocity.x -= 400 * delta
	
	for e in _enemy:
		e._damage(10)
	
	var cam := get_canvas_transform().affine_inverse() * get_viewport_rect()
	
	if flip:
		if position.x >= cam.end.x + 1000.0:
			queue_free()
	else:
		if position.x <= cam.position.x - 1000.0:
			queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("_damage"):
		_enemy.append(body)
	#else:
		#queue_free()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body in _enemy:
		_enemy.erase(body)
