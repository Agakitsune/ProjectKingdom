extends PlayerState
class_name PlayerJumpState

func _on_enter(previous: StringName):
	if previous != "MagicAttack":
		player.velocity.y = player.JUMP_VELOCITY

func _on_exit(next: StringName):
	pass

func _on_input(event: InputEvent):
	if event.is_action_pressed("attack"):
		if Input.is_action_pressed("up"):
			change_state.emit("MagicAttack")
		else:
			change_state.emit("Attack")

func _on_process(delta: float):
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	
	if player.velocity.y >= 0.0:
		change_state.emit("Fall")
		return
	
	var direction := signf(Input.get_axis("left", "right"))
	
	player.velocity.x = direction * player.SPEED
	player.move_and_slide()
