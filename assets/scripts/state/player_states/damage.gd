extends PlayerState
class_name PlayerDamageState

var _direction: int
var _floored := false

func _on_enter(previous: StringName):
	player.animation_player.play("hurt")
	player.velocity.y = -300
	player.velocity.x = _direction * 100
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
		get_tree().create_timer(0.5, true, true).timeout.connect(_on_timeout)

func _on_timeout():
	var direction := Input.get_axis("left", "right")
	if direction:
		change_state.emit("Walk")
	else:
		change_state.emit("Idle")
	

func _on_player_damage_taken(direction: int) -> void:
	_direction = direction
	pass # Replace with function body.
