@tool
extends Marker2D
class_name Stair

@onready var path_2d: Path2D = $Path2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

@export var flip_h := false:
	set = _set_flip_h
@export var length := 0:
	set = _set_length

var lock_up := false
var lock_down := false

func _ready() -> void:
	_update_shape()

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	for x in range(length + 1):
		var p := path_2d.curve.sample_baked(x * 11.31)
		draw_circle(p, 1.0, Color.RED)

func sample(f: float) -> Vector2:
	return path_2d.curve.sample_baked(f) + global_position

func _get_flip() -> Vector2:
	return Vector2(
		-8 if flip_h else 8,
		-8
	)

func _set_flip_h(f: bool):
	flip_h = f
	
	if not Engine.is_editor_hint():
		return
	
	_update_shape()

func _set_length(l: int):
	length = l
	
	if not Engine.is_editor_hint():
		return
	
	_update_shape()

func _update_shape():
	var p := _get_flip() * length
	var s := _get_flip() * (length + 0.2)
	
	path_2d.curve.set_point_position(
		1, p
	)
	var seg := collision_shape_2d.shape as SegmentShape2D
	seg.b = s

func _player_ratio(p: Player) -> float:
	var flat := length * 8.0
	var play := absf(p.global_position.x - global_position.x)
	var ratio := play / flat
	
	return ratio

func _player_use(p: Player, grounded := true) -> int:
	var ratio = _player_ratio(p)
	
	if grounded:
		if ratio <= 0.5:
			return 0
		else:
			return length - 1
	else:
		if ratio >= 1.0:
			return 0
		if ratio <= 0.0:
			return 0
		
		var len := length
		ratio *= len
		ratio = roundf(ratio)
		
		return ratio as int
	
	return 0
