@tool
extends Node2D

@export var stage: PackedScene:
	set = _set_stage

@onready var camera: Camera2D = %Camera
@onready var camera_control: Marker2D = %CameraControl

@onready var player: Player = $Player

var _camera_tween : Tween
var _stage: Stage

func _ready() -> void:
	if _stage:
		remove_child(_stage)
	
	_stage = stage.instantiate()
	
	add_child(_stage)
	
	_stage.spawn_in(player)
	_stage.zone_loaded.connect(_on_zone_loaded)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	print(player.global_position)
	
	if not (_camera_tween and _camera_tween.is_running()):
		camera_control.global_position = player.global_position
		camera_control.global_position = _stage.snapv_into(camera_control.global_position)
	
	_stage.update(player)


func _on_zone_loaded(next: Zone):
	var next_pos := next.snap_into(camera)
	var time := camera.get_screen_center_position().distance_to(next_pos) / 450.0
	
	camera.limit_enabled = false
	
	_camera_tween = create_tween()
	_camera_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	get_tree().paused = true
	
	_camera_tween.tween_property(
		camera_control, "global_position", next_pos, time
	).set_trans(Tween.TRANS_LINEAR)
	_camera_tween.tween_callback(
		func():
			next.setup_limit(camera)
			camera.limit_enabled = true
			_stage.set_current(next)
			get_tree().paused = false
	)


func _set_stage(x: PackedScene):
	stage = x
	
	if _stage:
		remove_child(_stage)
	if x:
		_stage = stage.instantiate()
	
		add_child(_stage)


func _on_player_dead() -> void:
	if player._lives > 0:
		_stage.reset_screen(player, camera)
		player._lives -= 1
	else:
		_stage.reset(player, camera)
