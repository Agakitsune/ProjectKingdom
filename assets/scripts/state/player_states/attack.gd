extends PlayerState
class_name PlayerAttackState

var _active := false

func _on_enter(previous: StringName):
	_active = true
	player.animation_player.play("attack")
	player.whip.scale.x = -1.0 if player.sprite_2d.flip_h else 1.0
	player.sprite_2d.offset.x = -32.0 if player.sprite_2d.flip_h else 32.0
	player.whip_shape.disabled = false

func _on_exit(next: StringName):
	_active = false
	player.whip_shape.set_deferred("disabled", true)
	pass

func _on_input(event: InputEvent):
	pass

func _on_process(delta: float):
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	
	player.move_and_slide()
	
	if player.is_on_floor():
		player.velocity.x = 0.0


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if _active:
		if not player.is_on_floor():
			change_state.emit("Fall")
			return
		var direction := Input.get_axis("left", "right")
		if direction:
			change_state.emit("Walk")
		else:
			change_state.emit("Idle")
