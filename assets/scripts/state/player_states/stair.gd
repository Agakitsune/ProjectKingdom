extends PlayerState
class_name PlayerStairState

var _up := false
var _stair : Stair
var _stair_tween: Tween
var _stair_index := 0

func _condition(previous: StringName, ...args: Array) -> bool:
	if not args[0] is bool:
		return false
	_up = args[0] as bool
	
	if not player._stair:
		return false
	
	_stair = player._stair
	var grounded := player.is_on_floor()
	var ratio := _stair._player_ratio(player)
	
	if not grounded: # Fall on stair
		return true
	
	if _up:
		if ratio > 0.5:
			return false
		
		if _stair.lock_up:
			return false
	else:
		if ratio < 0.5:
			return false
		
		if _stair.lock_down:
			return false
	
	return true

func _on_enter(previous: StringName):
	if previous == "StairAttack":
		if player.sprite_2d.region_rect.position.y == 192.0:
			player.animation_player.play("stair_up")
			player.sprite_2d.offset.x = -8.0 if player.sprite_2d.flip_h else 8.0
		else:
			player.animation_player.play("stair_down")
			player.sprite_2d.offset.x = 8.0 if player.sprite_2d.flip_h else -8.0
		return # Skip because already on stair
	
	var grounded := player.is_on_floor()
	var start := _stair.sample(0 if _up else (_stair.length * 2 * 22.67))
	var flat := absf(player.global_position.x - start.x)
	var time := flat / player.SPEED
	
	_stair_index = _stair._player_use(player, grounded)
	
	_stair_tween = create_tween()
	if grounded:
		_stair_tween.tween_property(
			player, "position",
			start
			- Vector2(0, 32),
			time
		).set_trans(Tween.TRANS_LINEAR)
		_stair_tween.tween_callback(
			func():
				if _up:
					player.sprite_2d.flip_h = _stair.flip_h
					player.sprite_2d.offset.x = -8.0 if player.sprite_2d.flip_h else 8.0
				else:
					player.sprite_2d.flip_h = not _stair.flip_h
					player.sprite_2d.offset.x = 8.0 if player.sprite_2d.flip_h else -8.0
		)
		if _stair_index > 0:
			_stair_tween.tween_property(
				player, "position",
				_stair.sample(_stair_index * 22.67)
				- Vector2(0, 32),
				0.2
			).set_trans(Tween.TRANS_LINEAR)
	else:
		_up = player.sprite_2d.flip_h == _stair.flip_h
		if _up:
			player.sprite_2d.offset.x = -8.0 if player.sprite_2d.flip_h else 8.0
		else:
			player.sprite_2d.offset.x = 8.0 if player.sprite_2d.flip_h else -8.0
		player.position = _stair.sample(_stair_index * 22.67) - Vector2(0, 32)
		_stair_tween.tween_interval(0.2)
	
	if _up:
		player.animation_player.play("stair_up")
	else:
		player.animation_player.play("stair_down")

func _on_exit(next: StringName):
	pass

func _on_input(event: InputEvent):
	if Input.is_action_pressed("jump"):
		change_state.emit("Jump")
	elif Input.is_action_pressed("attack"):
		change_state.emit("StairAttack")

func _on_process(delta: float):
	if not (_stair_tween and _stair_tween.is_running()):
		if Input.is_action_pressed("up") and not _stair.lock_up:
			player.animation_player.play("stair_up")
			_stair_index += 1
			if _stair_index >= _stair.length * 2:
				_stair_tween = create_tween()
				_stair_tween.tween_property(
					player, "position",
					_stair.sample(_stair_index * 22.67)
					- Vector2(0, 32),
					0.2
				).set_trans(Tween.TRANS_LINEAR)
				_stair_tween.tween_callback(
					func():
						change_state.emit("Idle")
				)
			else:
				_stair_tween = create_tween()
				_stair_tween.tween_property(
					player, "position",
					_stair.sample(_stair_index * 22.67)
					- Vector2(0, 32),
					0.2
				).set_trans(Tween.TRANS_LINEAR)
			player.sprite_2d.flip_h = _stair.flip_h
			player.sprite_2d.offset.x = -8.0 if player.sprite_2d.flip_h else 8.0
		elif Input.is_action_pressed("down") and not _stair.lock_down:
			player.animation_player.play("stair_down")
			_stair_index -= 1
			if _stair_index < 0:
				change_state.emit("Idle")
			else:
				_stair_tween = create_tween()
				_stair_tween.tween_property(
					player, "position",
					_stair.sample(_stair_index * 22.67)
					- Vector2(0, 32),
					0.2
				).set_trans(Tween.TRANS_LINEAR)
			player.sprite_2d.flip_h = not _stair.flip_h
			player.sprite_2d.offset.x = 8.0 if player.sprite_2d.flip_h else -8.0

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	pass # Replace with function body.
