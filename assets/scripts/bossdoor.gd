extends Node2D
class_name Boosdoor

@onready var character_body_2d: CharacterBody2D = $CharacterBody2D
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

var _tween: Tween

var _time := 0.0

signal closed()

func open():
	if (_tween and _tween.is_running()):
		_tween.kill()
	
	var t := (character_body_2d.position.y + 64) / 64.0
	
	_tween = create_tween()
	_tween.tween_callback(
		func():
			gpu_particles_2d.emitting = true
	)
	_tween.tween_property(
		character_body_2d,
		"position",
		Vector2(0, -64),
		t * 2.0
	).set_trans(Tween.TRANS_SINE)
	_tween.tween_callback(
		func():
			gpu_particles_2d.emitting = false
	)

func close():
	if (_tween and _tween.is_running()):
		_tween.kill()
	
	var t := absf(character_body_2d.position.y) / 64.0
	
	_tween = create_tween()
	_tween.tween_callback(
		func():
			gpu_particles_2d.emitting = true
	)
	_tween.tween_property(
		character_body_2d,
		"position",
		Vector2(0, 0),
		t * 2.0
	).set_trans(Tween.TRANS_SINE)
	_tween.tween_callback(
		func():
			closed.emit()
			gpu_particles_2d.emitting = false
	)


func _on_area_2d_body_entered(body: Node2D) -> void:
	open()


func _on_area_2d_body_exited(body: Node2D) -> void:
	close()
