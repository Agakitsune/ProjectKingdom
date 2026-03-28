extends PlayerState
class_name PlayerCrouchState

func _on_enter(previous: StringName):
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
			change_state.emit("Walk")
		else:
			change_state.emit("Idle")
