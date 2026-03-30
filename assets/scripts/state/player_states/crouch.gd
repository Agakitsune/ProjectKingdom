extends PlayerState
class_name PlayerCrouchState

func _on_enter(previous: StringName):
	if previous != "CrouchAttack":
		player.animation_player.play("crouch")

func _on_exit(next: StringName):
	pass

func _on_input(event: InputEvent):
	if event.is_action_pressed("attack"):
		change_state.emit("CrouchAttack")
	pass

func _on_process(delta: float):
	var direction := Input.get_axis("left", "right")
	
	if direction:
		player.sprite_2d.flip_h = direction < 0.0
	
	if not Input.is_action_pressed("down"):
		if direction:
			player.animation_player.play_backwards("fast_up")
			await player.animation_player.animation_finished
			change_state.emit("Walk")
		else:
			player.animation_player.play_backwards("crouch")
			await player.animation_player.animation_finished
			change_state.emit("Idle")
