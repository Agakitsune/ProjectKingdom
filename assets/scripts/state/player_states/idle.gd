extends PlayerState
class_name PlayerIdleState

func _on_enter(previous: StringName):
	player.animation_player.play("idle")

func _on_exit(next: StringName):
	pass

func _on_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		change_state.emit("Jump")
	elif event.is_action_pressed("attack"):
		change_state.emit("Attack")
	elif event.is_action_pressed("down"):
		if machine.test_state("Stair", false):
			change_state.emit("Stair")
		else:
			change_state.emit("Crouch")
	elif event.is_action_pressed("up"):
		if machine.test_state("Stair", true):
			change_state.emit("Stair")
		else:
			pass # TODO: Arm for special attack
	

func _on_process(delta: float):
	var direction := Input.get_axis("left", "right")
	
	if direction:
		change_state.emit("Walk")
		player.sprite_2d.flip_h = direction < 0.0

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	pass # Replace with function body.
