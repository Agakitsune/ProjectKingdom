@tool
extends Node2D

@export var stage: PackedScene:
	set = _set_stage

@onready var camera: Camera2D = %Camera
@onready var camera_control: Marker2D = %CameraControl

@onready var player: Player = $Player

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var debug: Control = $CanvasLayer/Debug
@onready var player_ui: Control = $CanvasLayer/PlayerUi

var _camera_tween : Tween
var _stage: Stage

var _accum := 0.0
var _time := 0

func _ready() -> void:
	if _stage:
		remove_child(_stage)
	
	_stage = stage.instantiate()
	
	_time = _stage.time
	player_ui._update_time(_time)
	
	add_child(_stage)
	
	_stage.spawn_in(player)
	_stage.zone_loaded.connect(_on_zone_loaded)
	_stage.boss_triggered.connect(_on_boss_trigger)
	_stage.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	debug.set_stage(_stage)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_accum += delta
	if _accum >= 1.0:
		_accum -= 1.0
		_time -= 1
		
		player_ui._update_time(_time)
		
		if _time <= 0:
			player.damage(99999, 0)
	
	if not (_camera_tween and _camera_tween.is_running()):
		camera_control.global_position = player.global_position
		camera_control.global_position = _stage.snapv_into(camera_control.global_position)
	
	set_process_input(true)
	
	_stage.update(player)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		set_process_input(false)
		debug.show()
		get_tree().paused = true


func _on_zone_loaded(next: Zone):
	var next_pos := next.snap_into(camera)
	var time := camera.get_screen_center_position().distance_to(next_pos) / 650.0
	
	camera.limit_enabled = false
	
	_camera_tween = create_tween()
	_camera_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	get_tree().paused = true
	
	_camera_tween.tween_property(
		camera_control, "global_position", next_pos, time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_camera_tween.tween_callback(
		func():
			next.setup_limit(camera)
			camera.limit_enabled = true
			_stage.set_current(next)
			get_tree().paused = false
	)


func _on_debug_teleport(zone: Zone, anchor: Marker2D):
	_stage.force_load(zone, anchor)
	_stage.reset_screen(player, camera)
	camera_control.global_position = player.global_position
	camera_control.global_position = _stage.snapv_into(camera_control.global_position)


func _on_boss_trigger(b: Node2D):
	var next_pos := b.global_position
	var time := camera.get_screen_center_position().distance_to(next_pos) / 650.0
	
	_camera_tween = create_tween()
	_camera_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	get_tree().paused = true
	
	_camera_tween.tween_property(
		camera_control, "global_position", b.global_position, time
	).set_trans(Tween.TRANS_SINE)
	_camera_tween.tween_callback(
		func():
			b.summon()
	)
	
	await b.summoned
	
	_camera_tween = create_tween()
	_camera_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	_camera_tween.tween_property(
		camera_control, "global_position", player.global_position, time
	).set_trans(Tween.TRANS_SINE)
	_camera_tween.tween_callback(
		func():
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


func _on_player_stage_cleared() -> void:
	pass


func _on_player_update() -> void:
	player_ui._update_player(player)
