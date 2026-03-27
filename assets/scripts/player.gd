extends CharacterBody2D
class_name Player

@onready var camera: Camera2D = $Camera2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D
@onready var whip_shape: CollisionShape2D = $Area2D/CollisionShape2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		animation_player.play("attack")
		whip_shape.disabled = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		if is_on_floor():
			if animation_player.current_animation != "attack":
				sprite_2d.flip_h = direction < 0.0
				area_2d.scale.x = -1.0 if sprite_2d.flip_h else 1.0
				velocity.x = direction * SPEED
			else:
				velocity.x = 0
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = 0

	move_and_slide()


func _set_offset(x: float):
	if sprite_2d.flip_h:
		sprite_2d.offset.x = -x
	else:
		sprite_2d.offset.x = x


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play("idle")
	whip_shape.disabled = true
