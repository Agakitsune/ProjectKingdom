@tool
extends Marker2D
class_name Zone

@export_range(640, 1000, 1.0, "or_greater") var width := 640.0:
	set = _set_width
@export_range(360, 1000, 1.0, "or_greater") var height := 360.0:
	set = _set_height

@export var shrink_left := 0.0:
	set = _set_left
@export var shrink_right := 0.0:
	set = _set_right

@export var doors: Array[Door]
@export var zones: Array[Zone]
@export var stairs: Array[Stair]

@onready var collision_shape_2d: CollisionShape2D = $Zone/CollisionShape2D

var _zone: Rect2

func _ready() -> void:
	_zone.size = Vector2(width, height)
	_zone.position = global_position - _zone.size / 2.0
	
	_update_shape()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
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
	
	if Engine.is_editor_hint():
		for d in doors:
			var start: Vector2
			var end: Vector2
			var normal: Vector2
			
			if d == null:
				continue
			
			match d.side:
				SIDE_LEFT:
					normal.x = -1.0
					start.x = up_left.x
					start.y = up_left.y + d.min
					end.x = up_left.x
					end.y = up_left.y + d.max
				SIDE_TOP:
					normal.y = -1.0
					start.x = up_left.x + d.min
					start.y = up_left.y
					end.x = up_left.x + d.max
					end.y = up_left.y
				SIDE_RIGHT:
					normal.x = 1.0
					start.x = down_right.x
					start.y = up_left.y + d.min
					end.x = down_right.x
					end.y = up_left.y + d.max
				SIDE_BOTTOM:
					normal.y = 1.0
					start.x = up_left.x + d.min
					start.y = down_right.y
					end.x = up_left.x + d.max
					end.y = down_right.y
			
			var vec := (end - start).normalized()
			var mid := (end - start) / 2.0
			
			for idx in d.stairs:
				var p := to_local(stairs[idx].global_position)
				draw_dashed_line(start + mid, p, Color.BROWN, 1.0, 5.0, true, false)
			
			draw_string(font, start - Vector2(4, 4), zones[d.next].name, 0, -1, 12)
			draw_line(start, end, Color.CHARTREUSE, 2.0, false)
			draw_colored_polygon(
				[
					start + mid + normal * 10.0,
					start + mid + vec * 10.0,
					start + mid - vec * 10.0,
				],
				Color.CHARTREUSE,
			)


func lock():
	collision_shape_2d.set_deferred("disabled", false)


func is_inside(p: Vector2) -> bool:
	return _zone.has_point(p)


func load_zone(p: Vector2) -> Zone:
	var s := SIDE_LEFT
	
	if p.x < _zone.position.x:
		s = SIDE_LEFT
	elif p.y < _zone.position.y:
		s = SIDE_TOP
	elif p.x > _zone.end.x:
		s = SIDE_RIGHT
	elif p.y > _zone.end.y:
		s = SIDE_BOTTOM
	else:
		return null # Is inside
	
	for d in doors:
		if d.side != s:
			continue
		match d.side:
			SIDE_LEFT:
				var start := _zone.position.y + d.min
				var end := _zone.position.y + d.max
				if p.y >= start and p.y <= end:
					if d.lock:
						lock()
					for st in stairs:
						st.lock_up = d.stair_lock_up
						st.lock_down = d.stair_lock_down
					return zones[d.next]
			SIDE_TOP:
				var start := _zone.position.x + d.min
				var end := _zone.position.x + d.max
				if p.x >= start and p.x <= end:
					if d.lock:
						lock()
					for st in stairs:
						st.lock_up = d.stair_lock_up
						st.lock_down = d.stair_lock_down
					return zones[d.next]
			SIDE_RIGHT:
				var start := _zone.position.y + d.min
				var end := _zone.position.y + d.max
				if p.y >= start and p.y <= end:
					if d.lock:
						lock()
					for st in stairs:
						st.lock_up = d.stair_lock_up
						st.lock_down = d.stair_lock_down
					return zones[d.next]
			SIDE_BOTTOM:
				var start := _zone.position.x + d.min
				var end := _zone.position.x + d.max
				if p.x >= start and p.x <= end:
					if d.lock:
						lock()
					for st in stairs:
						st.lock_up = d.stair_lock_up
						st.lock_down = d.stair_lock_down
					return zones[d.next]
	
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
