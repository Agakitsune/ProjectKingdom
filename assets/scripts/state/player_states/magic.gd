extends PlayerState
class_name PlayerMagicState

func _on_enter(previous: StringName):
	player.animation_player.play("magic")

func _on_exit(next: StringName):
	pass

func _on_input(event: InputEvent):
	if event.is_action_pressed("attack"):
		if player.can_cast():
			change_state.emit("MagicAttack")
		else:
			change_state.emit("Attack")

func _on_process(delta: float):
	var direction := Input.get_axis("left", "right")
	
	#if not player.is_on_floor():
		#player.velocity += player.get_gravity() * delta
	if direction:
		change_state.emit("Walk")
		#player.sprite_2d.flip_h = direction < 0.0
		return
	
	#player.velocity.x = direction * player.SPEED
	#player.move_and_slide()
	
	if not Input.is_action_pressed("up"):
		change_state.emit("Idle")
