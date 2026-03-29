@tool
extends CharacterBody2D

const AXE := preload("uid://cj8joxyajkynw")

@onready var timer: Timer = $Timer
@onready var sprite_2d: Sprite2D = $Sprite2D

var player: Player

var _up := true
var _side := false
var _anchor: float
var _next: float
var _stop := false

var _health := 3

func _ready() -> void:
	_anchor = global_position.x
	_pick_next()
	
	timer.start()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()


func _draw() -> void:
	var end := Vector2(-60, 0)
	var start := Vector2(60, 0)
	
	draw_line(
		end,
		end + Vector2(0, 20),
		Color.YELLOW
	)
	draw_line(
		start,
		start + Vector2(0, 20),
		Color.YELLOW
	)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if player:
		var t := global_position.direction_to(player.global_position)
		sprite_2d.flip_h = t.x > 0.0
	
	var dir := 0.0
	
	if _side:
		if global_position.x > _next:
			_pick_next()
			dir = -10.0
		else:
			dir = 10.0
	else:
		if global_position.x < _next:
			_pick_next()
			dir = 10.0
		else:
			dir = -10.0
	
	velocity.x = dir
	
	if not _stop:
		move_and_slide()


func _damage():
	_health -= 1
	if _health <= 0:
		queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Area2D: # Is axe
		_stop = false
		timer.start()
		body.queue_free()
	else:
		var n := global_position.direction_to(body.global_position)
		
		body.damage(4, -1 if n.x < 0 else 1)


func _pick_next():
	_next = _anchor + (-60 if _side else 60)
	_side = not _side


func _on_timer_timeout() -> void:
	_stop = true
	var a: Node2D = AXE.instantiate()
	
	a.destroyed.connect(_on_axe_destroyed)
	
	a.flip = sprite_2d.flip_h
	
	get_parent().add_child(a)
	
	a.global_position.x = global_position.x
	
	if _up:
		a.global_position.y = global_position.y - 8
	else:
		a.global_position.y = global_position.y + 16
	_up = not _up


func _on_axe_destroyed():
	if _health > 0:
		_stop = false
		timer.start()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area._marked:
		_stop = false
		timer.start()
		area.queue_free()


func _on_area_2d_area_exited(area: Area2D) -> void:
	area._marked = true
