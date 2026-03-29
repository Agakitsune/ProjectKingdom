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
		if Input.is_action_pressed("up") and player.can_cast():
			change_state.emit("MagicAttack")
		else:
			change_state.emit("Attack")
	elif event.is_action_pressed("up"):
		if machine.test_state("Stair", true):
			change_state.emit("Stair")
	elif event.is_action_pressed("down"):
		if machine.test_state("Stair", false):
			change_state.emit("Stair")

func _on_process(delta: float):
	var direction := signf(Input.get_axis("left", "right"))
	
	if not direction:
		if Input.is_action_pressed("down"):
			change_state.emit("Crouch")
		elif Input.is_action_pressed("up"):
			change_state.emit("Magic")
		else:
			change_state.emit("Idle")
		return
	
	player.sprite_2d.flip_h = direction < 0.0
	
	player.velocity.x = direction * player.SPEED
	player.velocity += player.get_gravity() * delta
	
	player.move_and_slide()
	
	if not player.is_on_floor():
		change_state.emit("Fall")


func _on_stair_collider_area_entered(area: Area2D) -> void:
	if Input.is_action_pressed("up"):
		machine.test_state("Stair", true)
		change_state.emit("Stair")
	elif Input.is_action_pressed("down"):
		machine.test_state("Stair", false)
		change_state.emit("Stair")
