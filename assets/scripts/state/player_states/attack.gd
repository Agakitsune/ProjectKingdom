extends PlayerState
class_name PlayerAttackState

var _active := false

func _on_enter(previous: StringName):
	_active = true
	
	if not player.is_on_floor():
		if player.sprite_2d.flip_h:
			player.animation_player.play("jump_attack_l")
		else:
			player.animation_player.play("jump_attack_r")
	else:
		if player.sprite_2d.flip_h:
			player.animation_player.play("attack_l")
		else:
			player.animation_player.play("attack_r")

func _on_exit(next: StringName):
	_active = false
	pass

func _on_input(event: InputEvent):
	pass

func _on_process(delta: float):
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	
	player.move_and_slide()
	
	if player.is_on_floor():
		player.velocity.x = 0.0
		if player.animation_player.current_animation.contains("jump"):
			var t := player.animation_player.current_animation_position
			player.animation_player.current_animation = player.animation_player.current_animation.substr(5)
			player.animation_player.seek(t, true)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if _active:
		if not player.is_on_floor():
			change_state.emit("Fall")
			return
		var direction := Input.get_axis("left", "right")
		if direction:
			change_state.emit("Walk")
		elif Input.is_action_pressed("up"):
			change_state.emit("Magic")
		else:
			change_state.emit("Idle")
