extends Node2D

@export var flip := false

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


func _on_area_2d_body_entered(body: Node2D) -> void:
	body._damage()
