@tool
extends Marker2D
class_name Zone

const ARTEFACT := preload("uid://2a7uiidb7g4m")

@export_range(640, 1000, 1.0, "or_greater") var width := 640.0:
	set = _set_width
@export_range(360, 1000, 1.0, "or_greater") var height := 360.0:
	set = _set_height

@export var shrink_left := 0.0:
	set = _set_left
@export var shrink_right := 0.0:
	set = _set_right

@export_category("Boss Room")
@export var bossroom := false
@export var respawn: Marker2D = null

@onready var collision_shape_2d: CollisionShape2D = $Zone/CollisionShape2D

var _zone: Rect2
var _doors: Array[Door]
var _spawners: Array[EnemySpawner]
var _respawn: Array[Marker2D]
var _boss: Boosdoor

var _active_respawn: Marker2D

signal boss_triggered(b: Node2D)
signal boss_summoned()

func _ready() -> void:
	_zone.size = Vector2(width, height)
	_zone.position = global_position - _zone.size / 2.0
	
	for c in get_children():
		if c is EnemySpawner:
			_spawners.push_back(c)
		elif c is Door:
			_doors.push_back(c)
		elif c is Boosdoor:
			_boss = c
			_boss.closed.connect(_on_bossdoor_closed)
		elif c is Marker2D:
			_respawn.push_back(c)
	
	if bossroom:
		_active_respawn = respawn
	else:
		_active_respawn = _respawn[0]
	
	_update_shape()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_spawners = []
		_respawn = []
		for c in get_children():
			if c is EnemySpawner:
				_spawners.push_back(c)
			elif c is Door:
				continue
			elif c is Marker2D:
				_respawn.push_back(c)
		
		queue_redraw()


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	var size := Vector2(width, height)
	var up_left := -size / 2.0
	var down_right := size / 2.0
	
	var r := Rect2(
		up_left,
		size
	)
	r = r.grow(1.0)
	
	draw_rect(r, Color.YELLOW, false, 1.0, false)
	
	var c := Control.new()
	var font := c.get_theme_default_font()
	c.free()
	
	draw_string(font, r.position - Vector2(0, 4), self.name, 0, -1, 16, Color.YELLOW)
	
	if bossroom:
		if respawn:
			draw_dashed_line(
				Vector2.ZERO,
				to_local(respawn.global_position),
				Color.DARK_GOLDENROD,
				2.0,
				15.0
			)
	else:
		for res in _respawn:
			var s := to_local(res.global_position)
			var rr: Rect2
			rr.position = s - Vector2(16, 64)
			rr.end = s + Vector2(16, 0)
			draw_rect(rr, Color.DARK_ORANGE, false)
			draw_string(font, rr.position - Vector2(0, 4), "Respawn " + self.name, 0, -1, 8)
	
	for s in _spawners:
		var local := to_local(s.global_position)
		
		draw_dashed_line(
			Vector2.ZERO,
			local,
			Color.TURQUOISE,
			2.0,
			15.0
		)


func reset():
	collision_shape_2d.set_deferred("disabled", true)
	
	for d in _doors:
		for st in d.stairs:
			st.lock_up = false
			st.lock_down = false


func lock():
	collision_shape_2d.set_deferred("disabled", false)


func is_inside(p: Vector2) -> bool:
	return _zone.has_point(p)


func fetch_door(p: Vector2) -> Door:
	var s := 0
	
	if p.x < _zone.position.x:
		s = 0
	elif p.y < _zone.position.y:
		s = 1
	elif p.x > _zone.end.x:
		s = 0
	elif p.y > _zone.end.y:
		s = 1
	else:
		return null # Is inside
	
	for d in _doors:
		if d.side != s:
			continue
		if d.is_inside(p):
			if d.lock_zone:
				lock()
			for st in d.stairs:
				st.lock_up = d.lock_stair == 0
				st.lock_down = d.lock_stair == 1
			return d
	
	return null


func snap_into(c: Camera2D) -> Vector2:
	var cam_rect := c.get_viewport_rect()
	var cam_size := cam_rect.size / 2.0
	
	var reduced_rect := _zone.grow_individual(
		-cam_size.x,
		-cam_size.y,
		-cam_size.x,
		-cam_size.y,
	)
	
	return c.get_screen_center_position().clamp(
		reduced_rect.position,
		reduced_rect.end
	)


func snapv_into(v: Vector2) -> Vector2:
	var cam_rect := get_viewport_rect()
	var cam_size := cam_rect.size / 2.0
	
	var reduced_rect := _zone.grow_individual(
		-cam_size.x,
		-cam_size.y,
		-cam_size.x,
		-cam_size.y,
	)
	
	return v.clamp(
		reduced_rect.position,
		reduced_rect.end
	)


func setup_limit(c: Camera2D):
	c.limit_left = _zone.position.x
	c.limit_top = _zone.position.y
	c.limit_right = _zone.end.x
	c.limit_bottom = _zone.end.y


func _on_bossdoor_closed():
	if not bossroom:
		return
	
	var boss := _spawners[0].get_child(0)
	boss.defeated.connect(_on_boss_defeated)
	
	boss_triggered.emit(boss)


func _on_boss_defeated():
	var artefact := ARTEFACT.instantiate()
	
	add_child.call_deferred(artefact)
	artefact.position.y = -64


func _set_width(x: float):
	width = x
	
	if Engine.is_editor_hint():
		_update_shape()


func _set_height(x: float):
	height = x
	
	if Engine.is_editor_hint():
		_update_shape()


func _set_left(x: float):
	shrink_left = x
	
	if Engine.is_editor_hint():
		_update_shape()


func _set_right(x: float):
	shrink_right = x
	
	if Engine.is_editor_hint():
		_update_shape()


func _update_shape():
	var r := Rect2(
		-width / 2.0,
		-height / 2.0,
		width,
		height
	)
	
	r = r.grow_side(SIDE_LEFT, -shrink_left)
	r = r.grow_side(SIDE_RIGHT, -shrink_right)
	
	collision_shape_2d.position = r.get_center()
	(collision_shape_2d.shape as RectangleShape2D).size = r.size
