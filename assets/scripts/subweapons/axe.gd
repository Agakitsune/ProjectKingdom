extends Node2D

@export var flip := false
@export var texture := "res://icon.svg"
@export var spell_name := "axe"

@onready var sprite_2d: Sprite2D = $Sprite2D

var velocity: Vector2

var _grav: Vector2

func _ready() -> void:
	velocity.x = -180 if flip else 180
	velocity.y = -500
	
	sprite_2d.flip_h = flip
	
	_grav = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
	_grav *= ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta: float) -> void:
	if flip:
		sprite_2d.rotate(delta * -8.0)
	else:
		sprite_2d.rotate(delta * 8.0)
	
	velocity += _grav * delta
	
	position += velocity * delta
	
	var cam := get_canvas_transform().affine_inverse() * get_viewport_rect()
	
	if position.y >= cam.end.y + 32.0:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	body._damage()
