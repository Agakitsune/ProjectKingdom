extends CharacterBody2D

const BONE := preload("uid://bqqa27e48uboy")

@onready var cooldown: Timer = $Cooldown
@onready var interval: Timer = $Interval
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var s := 5

var player: Player

var _shoot := false
var _a := false

func _ready() -> void:
	cooldown.start()


func _physics_process(delta: float) -> void:
	if not sprite_2d.visible:
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var t := global_position.direction_to(player.global_position)
	sprite_2d.flip_h = t.x > 0.0
	
	move_and_slide()
	
	if is_on_floor() and _shoot and not _a:
		_a = true
		velocity.x = 0
		s = 3
		animation_player.play("attack")
		return
	
	var diff := global_position - player.global_position
	if absf(diff.x) <= 128.0:
		if cooldown.is_stopped() and not _shoot:
			cooldown.start()
	else:
		if not cooldown.is_stopped():
			cooldown.stop()
	
	#animation_player.play("idle")


func _damage(x: float, cross := true):
	if not sprite_2d.visible:
		return
	
	collision_shape_2d.set_deferred("disabled", true)
	sprite_2d.visible = false
	cooldown.stop()
	gpu_particles_2d.restart()
	await gpu_particles_2d.finished
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if collision_shape_2d.disabled:
		return
	
	var n := global_position.direction_to(body.global_position)
	
	body.damage(8, -1 if n.x < 0 else 1)


func _on_cooldown_timeout() -> void:
	_shoot = true


func _throw():
	var b := BONE.instantiate()
	
	var diff := global_position - player.global_position
	var x := minf(absf(diff.x), 96.0)
	var y := maxf(diff.y, 1.0)
	
	if absf(diff.y) > 64.0:
		return
	
	var a := -400.0 * x
	
	b.force = -(a + sqrt(a * a - 2 * 980 * x * x * y)) / (2.0 * y)
	b.force += randf_range(-5.0, 5.0)
	b.flip = not sprite_2d.flip_h
	
	get_parent().add_child(b)
	b.global_position = self.global_position
	s -= 1
	
	if s > 0:
		animation_player.play("attack")
	else:
		_shoot = false
		_a = true
		animation_player.play("idle")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		_throw()
