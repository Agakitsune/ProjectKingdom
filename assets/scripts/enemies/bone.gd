extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var flip := false
var force := 0.0
var velocity: Vector2

var _grav: Vector2

func _ready() -> void:
	velocity.x = -force if flip else force
	velocity.y = -400
	
	_grav = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
	_grav *= ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta: float) -> void:
	if not sprite_2d.visible:
		return
	
	if flip:
		sprite_2d.rotate(delta * -32.0)
	else:
		sprite_2d.rotate(delta * 32.0)
	
	velocity += _grav * delta
	
	position += velocity * delta
	
	var cam := get_canvas_transform().affine_inverse() * get_viewport_rect()
	
	if position.y >= cam.end.y + 32.0:
		queue_free()


func _damage(x: float, cross := true):
	sprite_2d.visible = false
	animated_sprite_2d.visible = true
	animated_sprite_2d.play("default")
	await animated_sprite_2d.animation_finished
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not sprite_2d.visible:
		return
	
	var n := global_position.direction_to(body.global_position)
	
	body.damage(6, -1 if n.x < 0 else 1)
	
