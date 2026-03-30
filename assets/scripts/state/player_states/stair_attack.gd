extends PlayerState
class_name PlayerStairAttackState

var _active := false

func _on_enter(previous: StringName):
	_active = true
	var up := player.sprite_2d.region_rect.position.y < 112.0
	if up:
		if player.sprite_2d.flip_h:
			player.animation_player.play("stair_attack_up_l")
		else:
			player.animation_player.play("stair_attack_up_r")
	else:
		if player.sprite_2d.flip_h:
			player.animation_player.play("stair_attack_down_l")
		else:
			player.animation_player.play("stair_attack_down_r")
	#player.whip.scale.x = -1.0 if player.sprite_2d.flip_h else 1.0
	#player.sprite_2d.offset.x = -32.0 if player.sprite_2d.flip_h else 32.0
	#if up:
		#player.sprite_2d.offset.x += -8.0 if player.sprite_2d.flip_h else 8.0
	#else:
		#player.sprite_2d.offset.x += 8.0 if player.sprite_2d.flip_h else -8.0
	#player.whip_shape.disabled = false

func _on_exit(next: StringName):
	_active = false
	#player.whip_shape.set_deferred("disabled", true)
	pass

func _on_input(event: InputEvent):
	pass

func _on_process(delta: float):
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if _active:
		change_state.emit("Stair")
