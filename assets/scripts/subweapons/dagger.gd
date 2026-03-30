extends Node2D

@export var flip := false
@export var spell_name := "dagger"

var velocity: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if flip:
		velocity.x = -500
	else:
		velocity.x = 500

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta
