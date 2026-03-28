extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

const POISON_POTION = preload("res://assets/scenes/poison_potion.tscn")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("spell"):
		var spell = POISON_POTION.instantiate()
		get_parent().add_child(spell)
		spell.setup(position, -1)
