@tool
extends Marker2D
class_name CameraLimit

@export var size: Vector2:
	set(s):
		size = s
		if Engine.is_editor_hint():
			queue_redraw()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _draw() -> void:
	var r := Rect2(
		Vector2.ZERO, size
	)
	draw_rect(r, Color.YELLOW, false, 0.5, true)
