extends CharacterBody2D

const BONE := preload("uid://bqqa27e48uboy")

@onready var cooldown: Timer = $Cooldown
@onready var interval: Timer = $Interval
@onready var sprite_2d: Sprite2D = $Sprite2D

var s := 5

var player: Player

var _shoot := false

func _ready() -> void:
	cooldown.start()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if player:
		var t := global_position.direction_to(player.global_position)
		sprite_2d.flip_h = t.x > 0.0
	
	move_and_slide()
	
	if _shoot:
		print(interval.is_stopped())
		if interval.is_stopped():
			velocity.x = 0
			interval.start()
			s = 5
		return
	
	if is_on_floor():
		velocity.y = randf_range(-50, -100)
		velocity.x = randf_range(-100, 100)


func _damage():
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	var n := global_position.direction_to(body.global_position)
	
	body.damage(4, -1 if n.x < 0 else 1)


func _on_cooldown_timeout() -> void:
	_shoot = true


func _on_interval_timeout() -> void:
	var b := BONE.instantiate()
	
	var diff := global_position - player.global_position
	var x := minf(absf(diff.x), 200.0)
	var y := maxf(diff.y, 1.0)
	
	var a := -500.0 * x
	
	b.force = -(a + sqrt(a * a - 2 * 980 * x * x * y)) / (2.0 * y)
	b.force += randf_range(-1.0, 1.0)
	b.flip = not sprite_2d.flip_h
	
	get_parent().add_child(b)
	b.global_position = self.global_position
	s -= 1
	
	if s > 0:
		interval.start()
	else:
		_shoot = false
		cooldown.start()
