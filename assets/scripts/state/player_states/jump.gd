extends PlayerState
class_name PlayerJumpState

func _on_enter(previous: StringName):
	player.velocity.y = player.JUMP_VELOCITY
	pass
	#player.animation_player.play("jump")

func _on_exit(next: StringName):
	pass

func _on_input(event: InputEvent):
	if event.is_action_pressed("attack"):
		change_state.emit("Attack")
	pass

func _on_process(delta: float):
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	
	if player.velocity.y >= 0.0:
		change_state.emit("Fall")
		return
	
	var direction := Input.get_axis("left", "right")
	
	player.velocity.x = direction * player.SPEED
	player.move_and_slide()
