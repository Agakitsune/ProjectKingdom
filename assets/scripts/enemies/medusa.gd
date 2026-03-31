extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var _time := 0.0
var _flip := true

func _ready() -> void:
	velocity.x = 50.0 if _flip else -50
	sprite_2d.flip_h = _flip

func _physics_process(delta: float) -> void:
	if not sprite_2d.visible:
		return
	
	_time += delta
	velocity.y = cos(_time * 2.0) * -1
	
	if velocity.y < -0.5:
		sprite_2d.region_rect.position.x = 0
	elif velocity.y < 0.0:
		sprite_2d.region_rect.position.x = 32
	elif velocity.y < 0.5:
		sprite_2d.region_rect.position.x = 64
	else:
		sprite_2d.region_rect.position.x = 96
	
	velocity.y *= 75.0
	
	#global_position.y = _base + cos(_time * 2.0) * 30.0
	#position.x += velocity.x * delta
	
	move_and_slide()

func _damage(x: float, cross := true):
	collision_shape_2d.set_deferred("disabled", true)
	sprite_2d.visible = false
	animated_sprite_2d.visible = true
	animated_sprite_2d.play("default")
	await animated_sprite_2d.animation_finished
	queue_free()
	#if health > 0:
		#health -= 1
		#if health == 0:
			#defeated.emit() # Play some animation and shit
	#
	#var mat := gpu_particles_2d.process_material as ParticleProcessMaterial
	#mat.direction.x = 1.0 if sprite_2d.flip_h else -1.0
	#gpu_particles_2d.restart()


func _on_area_2d_body_entered(body: Node2D) -> void:
	var n := global_position.direction_to(body.global_position)
	
	body.damage(5, -1 if n.x < 0 else 1)
