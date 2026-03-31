extends PlayerState
class_name PlayerDamageState

var _direction: int
var _floored := false

func _on_enter(previous: StringName):
	if previous == "Stair":
		pass # 
	if _direction:
		player.animation_player.play("big_hurt")
		player.velocity.y = -200
		player.velocity.x = _direction * 100
		_floored = false
	else:
		player.animation_player.play("small_hurt")
		_floored = false

func _on_exit(next: StringName):
	pass

func _on_input(event: InputEvent):
	pass

func _on_process(delta: float):
	player.velocity += player.get_gravity() * delta
	player.move_and_slide()
	
	if player.is_on_floor() and not _floored:
		_floored = true
		player.velocity.x = 0.0
		player.animation_player.play("big_hurt_recovery")
		await player.animation_player.animation_finished
		_on_timeout()

func _on_timeout():
	player.timer.start()
	(player.sprite_2d.material as ShaderMaterial).set_shader_parameter("active", true)
	
	var direction := Input.get_axis("left", "right")
	if direction:
		change_state.emit("Walk")
	else:
		change_state.emit("Idle")
	

func _on_player_damage_taken(direction: int) -> void:
	_direction = direction
