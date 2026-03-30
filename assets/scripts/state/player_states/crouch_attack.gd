extends PlayerState
class_name PlayerCrouchAttackState

var _active := false

func _on_enter(previous: StringName):
	_active = true
	if player.sprite_2d.flip_h:
		player.animation_player.play("crouch_attack_l")
	else:
		player.animation_player.play("crouch_attack_r")

func _on_exit(next: StringName):
	_active = false

func _on_input(event: InputEvent):
	pass

func _on_process(delta: float):
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if _active:
		change_state.emit("Crouch")
