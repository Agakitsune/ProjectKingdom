extends PlayerState
class_name PlayerMagicAttackState

var _active := false
var _fast_cast := false
var _previous: StringName

func _on_enter(previous: StringName):
	_active = true
	_previous = previous
	_fast_cast = previous != "Magic"
	player.animation_player.play("magic_attack")

func _on_exit(next: StringName):
	_active = false
	pass

func _on_input(event: InputEvent):
	if event.is_action_pressed("attack") and not _fast_cast:
		player.animation_player.play("magic_attack")

func _on_process(delta: float):
	var direction := Input.get_axis("left", "right")
	
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	
		player.velocity.x = direction * player.SPEED * player.AIR_MUL
	else:
		player.velocity.x = direction * player.SPEED
	
	player.move_and_slide()


func _cast():
	player.cast()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if _active:
		if _fast_cast:
			change_state.emit(_previous)
		else:
			change_state.emit("Magic")
