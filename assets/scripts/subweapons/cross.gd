extends Node2D

@export var flip := false
@export var spell_name := "cross"

@onready var sprite_2d: Sprite2D = $Sprite2D

var velocity: Vector2
var cross_rotation: float 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if flip:
		velocity.x = -350
		cross_rotation = -4.5
	else:
		cross_rotation = 4.5
		velocity.x = 350

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta
	if flip:
		sprite_2d.rotate(cross_rotation)
		cross_rotation += 1 * delta
		velocity.x += 400 * delta
	else:
		sprite_2d.rotate(cross_rotation)
		cross_rotation -= 1 * delta
		velocity.x -= 400 * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != Player:
		body._damage(10)
