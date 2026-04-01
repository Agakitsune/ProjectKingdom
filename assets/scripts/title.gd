extends Control

@onready var texture_rect: TextureRect = $MarginContainer/VBoxContainer/TextureRect
@onready var label: Label = $MarginContainer/VBoxContainer/Label

var _time := 0.0
var _accel := 4.0

signal done

func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("start"):
		_accel = 128.0
		
		var tween := create_tween()
		tween.tween_property(
			texture_rect,
			"modulate",
			Color.TRANSPARENT,
			1.0
		)
		tween.parallel().tween_property(
			label,
			"modulate",
			Color.TRANSPARENT,
			1.0
		)
		tween.tween_callback(
			func():
				done.emit()
		)


func _reset():
	_accel = 4.0


func _process(delta: float) -> void:
	_time += delta
	label.visible = cos(_time * _accel) >= 0.0
