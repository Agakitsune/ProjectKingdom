extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var player: Player

var _time := 0.0
var _flip := true
var _flying := false

var _tween : Tween

func _ready() -> void:
	if _flying:
		velocity.x = 70.0 if _flip else -70
		sprite_2d.flip_h = _flip


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()


func _draw() -> void:
	draw_line(
		Vector2(-5, 70),
		Vector2(5, 70),
		Color.YELLOW,
	)


func _physics_process(delta: float) -> void:
	if _flying:
		#animation_player.play("fly")
		_time += delta
		velocity.y = sin(_time * 5.0) * -65.0

		move_and_slide()
	else:
		var a := global_position.x - player.global_position.x
		var d := player.global_position.y - global_position.y
		
		if absf(a) >= 128.0:
			return
		
		if d <= 70.0:
			if not _tween:
				_tween = create_tween()
				
				_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
				
				animation_player.play("fall")
				
				_tween.tween_property(
					self, "global_position",
					global_position + Vector2(20 if a < 0.0 else -20, d),
					d / 70.0
				).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
				_tween.tween_callback(
					func():
						_flying = true
						sprite_2d.flip_h = a < 0.0
						#sprite_2d.region_rect.position.x = 16
						velocity.x = 70.0 if sprite_2d.flip_h else -70
						animation_player.play("fly")
				)

func _damage(x: float, cross := true):
	collision_shape_2d.set_deferred("disabled", true)
	if sprite_2d.flip_h:
		animation_player.play("death_R")
	else:
		animation_player.play("death_L")
	
	set_physics_process(false)
	await animation_player.animation_finished
	
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	var n := global_position.direction_to(body.global_position)
	
	body.damage(2, -1 if n.x < 0 else 1)
