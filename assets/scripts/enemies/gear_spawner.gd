@tool
extends Marker2D

const GEAR := preload("uid://csmofqalgn2je")

@export_range(0, 1000, 1.0, "or_greater") var range: float = 0.0

var _spawn_points: PackedVector2Array
var _gears: Array[Node2D]

func _ready() -> void:
	for x in range(0, range, 24):
		if x == 0:
			continue
		
		var g := GEAR.instantiate()
		var p := Vector2(x, 0)
		
		_spawn_points.push_back(
			p
		)
		_gears.push_back(g)
		
		g.position = p
		g.small = randi_range(0, 1) as bool
		
		add_child(g)


func copy_from_base(d: Marker2D):
	range = d.range


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()


func _draw() -> void:
	var rect: Rect2
	
	rect.size.x = range
	rect.size.y = 8.0
	
	draw_rect(
		rect,
		Color.CRIMSON,
	)


func random_fall():
	var selected: PackedInt32Array
	
	while selected.size() < 10:
		var idx := randi_range(0, _gears.size() - 1)
		
		if not idx in selected:
			selected.push_back(idx)
	
	for idx in selected:
		_gears[idx].fell.connect(
			func():
				_replace_gear(idx)
		)
		_gears[idx].animation_player.play("fall")
		_gears[idx] = null


func _replace_gear(idx: int):
	var g := GEAR.instantiate()
	var p := _spawn_points[idx]
	
	_gears[idx] = g
	
	g.position = p
	g.small = randi_range(0, 1) as bool
	
	add_child(g)
