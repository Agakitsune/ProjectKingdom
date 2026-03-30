extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var _time := 0.0
var _flip := true

func _ready() -> void:
	velocity.x = 50.0 if _flip else -50
	sprite_2d.flip_h = _flip

func _physics_process(delta: float) -> void:
	_time += delta
	velocity.y = cos(_time * 2.0) * 75.0

	move_and_slide()

func _damage(x: float):
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
	
	body.damage(4, -1 if n.x < 0 else 1)
