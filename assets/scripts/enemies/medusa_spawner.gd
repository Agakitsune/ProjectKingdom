@tool
extends Node2D

@export_range(32, 1000, 1.0, "or_greater") var width := 10.0:
	set = _set_width
@export_range(32, 1000, 1.0, "or_greater") var height := 10.0:
	set = _set_height

@export_range(0.001, 150.0) var timeout := 2.0

@export var flip := false

@onready var timer: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

const MEDUSA := preload("uid://c7ho38asdgsaf")

var player: Player

func _ready() -> void:
	if not Engine.is_editor_hint():
		timer.wait_time = timeout
		timer.start()
	
	(collision_shape_2d.shape as RectangleShape2D).size = Vector2(
		width, height
	)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()


func _draw() -> void:
	var n := Vector2(25, 0) if flip else Vector2(-25, 0)
	
	draw_colored_polygon(
		[
			n,
			Vector2(0, 25),
			Vector2(0, -25)
		],
		Color.GOLDENROD
	)

func copy_from_base(d: Node2D):
	timeout = d.timeout
	width = d.width
	height = d.height
	flip = d.flip
	
	_update_shape()

func _on_timer_timeout() -> void:
	var medusa := MEDUSA.instantiate()
	
	medusa._flip = flip
	
	add_child(medusa)
	
	var cam := get_canvas_transform().affine_inverse() * get_viewport_rect()
	
	if flip:
		medusa.global_position.x = cam.position.x - 64
	else:
		medusa.global_position.x = cam.end.x + 64
	medusa.global_position.y = player.global_position.y + randf_range(-32, 32.0)

func _set_width(x: float):
	width = x
	
	if Engine.is_editor_hint():
		_update_shape()

func _set_height(x: float):
	height = x
	
	if Engine.is_editor_hint():
		_update_shape()


#func _set_left(x: float):
	#shrink_left = x
	#
	#if Engine.is_editor_hint():
		#_update_shape()
#
#
#func _set_right(x: float):
	#shrink_right = x
	#
	#if Engine.is_editor_hint():
		#_update_shape()


func _update_shape():
	(collision_shape_2d.shape as RectangleShape2D).size = Vector2(width, height)


func _on_area_2d_area_entered(area: Area2D) -> void:
	timer.wait_time = timeout
	timer.start()


func _on_area_2d_body_exited(body: Node2D) -> void:
	timer.stop()
