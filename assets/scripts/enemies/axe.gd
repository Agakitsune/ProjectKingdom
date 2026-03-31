extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var flip := false
var velocity: Vector2

var _marked := false

signal destroyed

func _ready() -> void:
	velocity.x = 150 if flip else -150
	
	sprite_2d.flip_h = flip


func _physics_process(delta: float) -> void:
	if not sprite_2d.visible:
		return
	
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


func _damage(x: float, cross := true):
	sprite_2d.visible = false
	animated_sprite_2d.visible = true
	animated_sprite_2d.play("default")
	destroyed.emit()
	await animated_sprite_2d.animation_finished
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	var n := global_position.direction_to(body.global_position)
	
	body.damage(10, -1 if n.x < 0 else 1)
	
