extends PlayerState
class_name PlayerStairMagicAttackState

var _active := false
var _fast_cast := false
var _previous: StringName

func _on_enter(previous: StringName):
	_active = true
	
	var up := player.sprite_2d.region_rect.position.y < 112.0
	if up:
		#if player.sprite_2d.flip_h:
		if player.sprite_2d.flip_h:
			player.animation_player.play("stair_magic_attack_up_l")
		else:
			player.animation_player.play("stair_magic_attack_up_r")
	else:
		player.animation_player.play("stair_magic_attack_down")
		#if player.sprite_2d.flip_h:
		#else:
			#player.animation_player.play("stair_magic_attack_down_r")
	
	await player.animation_player.animation_finished
	
	change_state.emit("Stair")
	
	#_previous = previous
	#_fast_cast = previous != "Magic"
	#player.animation_player.play("magic_attack")

func _on_exit(next: StringName):
	_active = false
	pass

func _on_input(event: InputEvent):
	pass
	#if event.is_action_pressed("attack") and not _fast_cast:
		#pllayer.animation_player.play("magic_attack")

func _on_process(delta: float):
	pass
	#var direction := Input.get_axis("left", "right")
	#
	#if not player.is_on_floor():
		#player.velocity += player.get_gravity() * delta
	#
	#player.velocity.x = direction * player.SPEED
	#player.move_and_slide()


func _cast():
	player.cast()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
	#if _active:
		##if _fast_cast:
			##change_state.emit(_previous)
		#else:
			#change_state.emit("Stair")
