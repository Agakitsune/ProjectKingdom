extends Control

@onready var color_rect: ColorRect = $ColorRect
@onready var texture_rect: TextureRect = $TextureRect

signal done

func _show_stage():
	var tex := (texture_rect.texture as AtlasTexture)
	
	tex.region.size.x = 64
	tex.region.position.y = 0
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(
		color_rect,
		"scale",
		Vector2(1, 1),
		0.5
	)
	tween.parallel().tween_property(
		texture_rect,
		"scale",
		Vector2(1, 1),
		0.5
	)
	tween.tween_interval(1.0)
	tween.tween_property(
		color_rect,
		"scale",
		Vector2(1, 0),
		0.5
	)
	tween.parallel().tween_property(
		texture_rect,
		"scale",
		Vector2(1, 0),
		0.5
	)
	tween.tween_callback(
		func():
			done.emit()
	)


func _show_clear():
	var tex := (texture_rect.texture as AtlasTexture)
	
	tex.region.size.x = 112
	tex.region.position.y = 16
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(
		color_rect,
		"scale",
		Vector2(1, 1),
		0.5
	)
	tween.parallel().tween_property(
		texture_rect,
		"scale",
		Vector2(1, 1),
		0.5
	)
	tween.tween_callback(
		func():
			done.emit()
	)
	#tween.tween_interval(0.5)
	#tween.tween_property(
		#color_rect,
		#"scale",
		#Vector2(1, 0),
		#0.5
	#)
	#tween.parallel().tween_property(
		#texture_rect,
		#"scale",
		#Vector2(1, 0),
		#0.5
	#)

func _hide_clear():
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(
		color_rect,
		"scale",
		Vector2(1, 0),
		0.5
	)
	tween.parallel().tween_property(
		texture_rect,
		"scale",
		Vector2(1, 0),
		0.5
	)
	tween.tween_callback(
		func():
			done.emit()
	)
