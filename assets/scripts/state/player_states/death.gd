extends PlayerState
class_name PlayerDeathState

var _direction: int
#var _floored := false

func _on_enter(previous: StringName):
	player.animation_player.play("death")
	player.velocity.y = -30
	player.velocity.x = _direction * 10

func _on_exit(next: StringName):
	pass

func _on_input(event: InputEvent):
	pass

func _on_process(delta: float):
	var vel := player.velocity
	vel.y = move_toward(
		vel.y,
		0.0,
		delta * 24.0
	)
	vel.x = move_toward(
		vel.x,
		0.0,
		delta * 4.0
	)
	
	if not player.animation_player.is_playing():
		player.dead.emit()
		return
	
	player.velocity = vel
	
	player.move_and_slide()

#func _on_timeout():
	#var direction := Input.get_axis("left", "right")
	#if direction:
		#change_state.emit("Walk")
	#else:
		#change_state.emit("Idle")
	

func _on_player_damage_taken(direction: int) -> void:
	_direction = direction
	pass # Replace with function body.
