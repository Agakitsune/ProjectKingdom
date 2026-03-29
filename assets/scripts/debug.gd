extends Control

var stage: Stage
var offset: Vector2

var _rooms: Array[Rect2]
var _anchors: PackedVector2Array
var _respawn: Array[Marker2D]
var _selected := -1

signal teleport(z: Zone, a: Marker2D)

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if visible:
		queue_redraw()
	
	var center := get_viewport_rect().get_center() + offset
	
	_selected = -1
	
	for i in range(_anchors.size()):
		var tmp := center + _anchors[i]
		if tmp.distance_to(get_viewport().get_mouse_position()) <= 4.0:
			_selected = i
		
	if Input.is_action_just_pressed("attack"):
		if _selected != -1:
			teleport.emit(
				_respawn[_selected].get_parent(),
				_respawn[_selected]
			)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	var center := get_viewport_rect().get_center() + offset
	
	if event.is_action_pressed("debug"):
		hide()
		get_tree().paused = false
		print("fah")
	elif event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			offset += event.relative


func _draw() -> void:
	var center := get_viewport_rect().get_center() + offset
	
	for r in _rooms:
		var tmp := r
		tmp.position += center
		draw_rect(tmp, Color.WHITE, false, 1.0, false)
	
	for i in range(_anchors.size()):
		var r: Rect2
		var o: Rect2
		r.size = Vector2(4, 4)
		r.position = center + _anchors[i] - Vector2(2, 2)
		
		if _selected == i:
			r = r.grow(1.0)
		
		draw_rect(r, Color.YELLOW, true, -1.0, false)


func set_stage(st: Stage):
	stage = st
	
	_rooms = []
	_anchors = []
	
	for c in stage.get_children():
		if c is Zone:
			var rect: Rect2
			var pos := stage.to_local(c.global_position) / 8.0
			rect.size = Vector2(
				c.width,
				c.height
			) / 8.0
			rect.position = pos - rect.size / 2.0
			
			_rooms.push_back(rect)
			
			for s: Marker2D in c._respawn:
				var p := stage.to_local(s.global_position) / 8.0
				
				_anchors.push_back(p)
				_respawn.push_back(s)
