extends Node2D

@export var flip := false
@export var spell_name := "dagger"

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var velocity: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if flip:
		velocity.x = -700
	else:
		velocity.x = 700

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	body._damage(1.0)
	
	sprite_2d.visible = false
	animated_sprite_2d.visible = true
	animated_sprite_2d.play("default")
	set_process(false)
	
	await animated_sprite_2d.animation_finished
	
	queue_free()
