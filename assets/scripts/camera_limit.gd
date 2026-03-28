@tool
extends Marker2D
class_name CameraLimit

@export var size: Vector2


func _process(delta: float) -> void:
	_update()


func _draw() -> void:
	var r := Rect2(
		Vector2.ZERO, size
	)
	draw_rect(r, Color.YELLOW, false, 0.5, true)


func _update():
	queue_redraw()
