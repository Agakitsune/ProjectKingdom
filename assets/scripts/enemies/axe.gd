extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var flip := false
var velocity: Vector2

var _marked := false

signal destroyed

func _ready() -> void:
	velocity.x = 200 if flip else -200
	
	sprite_2d.flip_h = flip


func _physics_process(delta: float) -> void:
	if flip:
		sprite_2d.rotate(delta * 16.0)
	else:
		sprite_2d.rotate(delta * -16.0)
	
	velocity.x += (-100 if flip else 100) * delta
	
	position += velocity * delta
	
	var cam := get_canvas_transform().affine_inverse() * get_viewport_rect()
	
	if flip:
		if global_position.x >= (cam.end.x + 32.0):
			destroyed.emit()
			queue_free()
	else:
		if global_position.x <= (cam.position.x - 32.0):
			destroyed.emit()
			queue_free()


func _damage(x: float):
	destroyed.emit()
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	var n := global_position.direction_to(body.global_position)
	
	body.damage(2, -1 if n.x < 0 else 1)
	
