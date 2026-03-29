extends PlayerState
class_name PlayerFallState

func _on_enter(previous: StringName):
	pass
	#player.animation_player.play("fall")

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
	
	var direction := signf(Input.get_axis("left", "right"))
	
	player.velocity.x = direction * player.SPEED
	player.move_and_slide()
	
	if player.is_on_floor():
		if direction:
			change_state.emit("Walk")
		else:
			change_state.emit("Idle")


func _on_stair_collider_area_entered(area: Area2D) -> void:
	if Input.is_action_pressed("up"):
		machine.test_state("Stair", true)
		change_state.emit("Stair")
