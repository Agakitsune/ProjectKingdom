extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var color_rect: ColorRect = $ColorRect
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var label: Label = $Label

signal done

var _done := false


func _ready() -> void:
	set_process_input(false)


func start():
	set_process_input(true)
	texture_rect.position.y = -153
	color_rect.modulate = Color.BLACK
	label.visible_ratio = 0.0
	
	if _done:
		return
	
	audio_stream_player.play()
	
	var tween := create_tween()
	tween.tween_property(
		color_rect,
		"modulate",
		Color(0, 0, 0, 0),
		1.0
	)
	tween.parallel().tween_property(
		texture_rect,
		"position",
		Vector2(0, 0),
		20.0
	)
	tween.parallel().tween_property(
		label,
		"visible_ratio",
		1.0,
		20.0
	)
	tween.tween_property(
		label,
		"visible_ratio",
		0.0,
		1.0
	)
	tween.tween_interval(5.0)
	tween.tween_property(
		color_rect,
		"modulate",
		Color(0, 0, 0, 1),
		1.0
	)
	tween.tween_callback(
		func():
			if not _done:
				_done = true
				audio_stream_player.stop()
				done.emit()
	)


func reset():
	_done = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("start"):
		var tween := create_tween()
		tween.tween_property(
			color_rect,
			"modulate",
			Color(0, 0, 0, 1),
			0.5
		)
		tween.tween_callback(
			func():
				if not _done:
					_done = true
					audio_stream_player.stop()
					done.emit()
		)
