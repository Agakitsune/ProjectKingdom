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
@onready var text: Control = $CanvasLayer/Text
@onready var intro: Control = $CanvasLayer/Intro
@onready var title: Control = $CanvasLayer/Title

var _camera_tween : Tween
var _stage: Stage

var _accum := 0.0
var _time := 0

var _shake := 0.0

var _boss: Node2D

var _loaded := false
var _cleared := false

@onready var aquarius_start: AudioStreamPlayer = $AquariusStart
@onready var aquarius_loop: AudioStreamPlayer = $AquariusLoop
@onready var blood: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	if _stage:
		remove_child(_stage)
	
	get_tree().paused = true
	
	#_load_stage()


func _load_stage():
	if _stage:
		remove_child(_stage)
	
	_stage = stage.instantiate()
	
	_time = _stage.time
	player_ui._update_time(_time)
	
	add_child(_stage)
	
	_stage.spawn_in(player)
	_stage.zone_loaded.connect(_on_zone_loaded)
	_stage.boss_triggered.connect(_on_boss_trigger)
	_stage.camera_shake.connect(_on_camera_shake)
	_stage.floor_damage.connect(_on_floor)
	_stage.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	debug.set_stage(_stage)
	
	_stage.reset(player, camera)
	
	camera_control.global_position = player.global_position
	camera_control.global_position = _stage.snapv_into(camera_control.global_position)
	
	Global.world = self
	Global.stage = _stage
	
	_loaded = true
	
	aquarius_start.play()
	
	get_tree().paused = true
	
	text._show_stage()
	
	await text.done
	
	get_tree().paused = false


func _physics_process(delta: float) -> void:
	if not _loaded:
		return
	
	if Engine.is_editor_hint():
		return
	
	camera.offset.y = randf_range(-_shake, _shake)
	
	_accum += delta
	if not _cleared and _accum >= 1.0:
		_accum -= 1.0
		_time -= 1
		
		player_ui._update_time(maxi(_time, 0))
		
		if _time <= 0:
			player.damage(99999, 0)
	
	if not (_camera_tween and _camera_tween.is_running()):
		camera_control.global_position = player.global_position
		camera_control.global_position = _stage.snapv_into(camera_control.global_position)
		
		
	if _boss:
		player_ui.set_boss_health(_boss.health)
	
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
	if next.name == "Zone6":
		var f := func(x):
			AudioServer.set_bus_volume_linear(
				AudioServer.get_bus_index("A"),
				x
			)
		var t := create_tween()
		t.tween_method(
			f,
			1.0,
			0.0,
			4.0
		)
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
	
	_boss = b
	b.defeated.connect(_on_defeat)
	
	_camera_tween = create_tween()
	_camera_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	get_tree().paused = true
	
	_camera_tween.tween_property(
		camera_control, "global_position", b.global_position, time
	).set_trans(Tween.TRANS_SINE)
	_camera_tween.tween_property(
		camera_control, "global_position", b.global_position, time
	).set_trans(Tween.TRANS_SINE)
	_camera_tween.tween_callback(
		func():
			blood.play()
			b.summon()
	)
	
	_camera_tween.tween_method(
		_update_boss,
		0.0,
		b.health,
		2.0
	).set_trans(Tween.TRANS_LINEAR)
	
	_camera_tween.tween_property(
		camera_control, "global_position", player.global_position, time
	).set_trans(Tween.TRANS_SINE)
	_camera_tween.tween_callback(
		func():
			get_tree().paused = false
	)


func _update_boss(x: float):
	player_ui.set_boss_health(x)


func _on_defeat():
	var f := func(x):
		AudioServer.set_bus_volume_linear(
			AudioServer.get_bus_index("B"),
			x
		)
		
		
	var t := create_tween()
	t.tween_method(
		f,
		1.0,
		0.0,
		4.0
	)


func _on_camera_shake(duration: float, amp: float):
	_shake = amp
	create_tween().tween_property(
		self,
		"_shake",
		0.0,
		duration
	)


func _on_floor(x: int):
	if player.is_on_floor():
		player.damage(x, 0)


func _set_stage(x: PackedScene):
	stage = x
	
	if _stage:
		remove_child(_stage)
	if x:
		_stage = stage.instantiate()
		
		add_child(_stage)
		
		if Global:
			Global.stage = _stage


func _on_player_dead() -> void:
	if _time <= 0:
		_time = _stage.time
	
	if player._lives > 0:
		_stage.reset_screen(player, camera)
		player._lives -= 1
	else:
		_stage.reset(player, camera)


func _on_player_stage_cleared() -> void:
	get_tree().paused = true
	
	text._show_clear()
	
	await text.done
	
	await get_tree().create_timer(0.5).timeout
	# Do the score thing
	
	var f := func(x):
		var s: int = player._score + x * 10
		player_ui._update_time(_time - x)
		player_ui._update_score(player._score + s)
	
	var t := create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_method(
		f, 0, _time, 1.0
	)
	t.tween_callback(
		func():
			player._score += _time * 10
			_time = 0
	)
	
	await t.finished
	
	text._hide_clear()
	#
	await text.done
	
	_cleared = true
	
	_loaded = false
	title.reset()
	intro.reset()
	title.show()
	intro.show()
	
	blood.stop()
	aquarius_loop.stop()
	
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("A"),
		1.0
	)
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("B"),
		1.0
	)
	#
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/scenes/world.tscn")
	pass


func _on_player_update() -> void:
	player_ui._update_player(player)


func _on_title_done() -> void:
	title.hide()
	intro.start()


func _on_intro_done() -> void:
	intro.hide()
	_load_stage()


func _on_aquarius_start_finished() -> void:
	aquarius_loop.play()
	pass # Replace with function body.


func _on_aquarius_loop_finished() -> void:
	aquarius_loop.play()
	pass # Replace with function body.
