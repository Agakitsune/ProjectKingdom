@tool
extends Marker2D
class_name Door

@export_category("State")
@export_enum("Vertical", "Horizontal") var side: int = 0
@export_range(0, 128, 1.0, "or_greater") var size: int = 0

@export_category("Locks")
@export var lock_zone := true

@export_enum("Up", "Down") var lock_stair := 0

@export_category("World")
@export var next_zone: Zone
@export var stairs: Array[Stair]
@export var respawn: Marker2D = null

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()


func _draw() -> void:
	var mid: Vector2
	
	var c := Control.new()
	var font := c.get_theme_default_font()
	c.free()
	
	match side:
		0:
			draw_line(
				Vector2.ZERO,
				Vector2.ZERO + Vector2(0, size),
				Color.CHARTREUSE,
				1.0,
				false
			)
			mid = Vector2(0, size / 2.0)
		1:
			draw_line(
				Vector2.ZERO,
				Vector2.ZERO + Vector2(size, 0),
				Color.CHARTREUSE,
				1.0,
				false
			)
			mid = Vector2(size / 2.0, 0)
	
	draw_colored_polygon(
		[
			mid - Vector2(10.0, 0.0),
			mid - Vector2(0.0, 10.0),
			mid + Vector2(10.0, 0.0),
			mid + Vector2(0.0, 10.0)
		],
		Color.CHARTREUSE
	)
	if next_zone:
		var s := font.get_string_size(
			next_zone.name,
			0,
			0,
			12
		)
		draw_string(
			font,
			mid + Vector2(-s.x / 2.0, 0),
			next_zone.name,
			HORIZONTAL_ALIGNMENT_CENTER,
			0,
			12
		)
		draw_string_outline(
			font,
			mid + Vector2(-s.x / 2.0, 0),
			next_zone.name,
			HORIZONTAL_ALIGNMENT_CENTER,
			0,
			12,
			1,
			Color.BLACK
		)
	
	if respawn:
		draw_dashed_line(
			mid,
			to_local(respawn.global_position),
			Color.SALMON,
			1.0,
			5.0
		)
	
	for st in stairs:
		draw_dashed_line(mid, to_local(st.global_position), Color.BROWN, 1.0, 5.0)


func is_inside(p: Vector2) -> bool:
	match side:
		0:
			return p.y >= global_position.y and p.y <= global_position.y + size
		1:
			return p.x >= global_position.x and p.x <= global_position.x + size
	return false
