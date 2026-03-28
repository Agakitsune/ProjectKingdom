extends PlayerState
class_name PlayerWalkState

func _on_enter(previous: StringName):
	player.animation_player.play("walk")

func _on_exit(next: StringName):
	pass

func _on_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		change_state.emit("Jump")
	elif event.is_action_pressed("attack"):
		if Input.is_action_pressed("up"):
			pass # Magic wooooo
		else:
			change_state.emit("Attack")
	elif event.is_action_pressed("up"):
		if machine.test_state("Stair", true):
			change_state.emit("Stair")
	elif event.is_action_pressed("down"):
		if machine.test_state("Stair", false):
			change_state.emit("Stair")
		else:
			change_state.emit("Crouch")

func _on_process(delta: float):
	var direction := Input.get_axis("left", "right")
	
	if not direction:
		change_state.emit("Idle")
		return
	
	player.sprite_2d.flip_h = direction < 0.0
	
	player.velocity.x = direction * player.SPEED
	player.velocity += player.get_gravity() * delta
	
	player.move_and_slide()
	
	if not player.is_on_floor():
		change_state.emit("Fall")
