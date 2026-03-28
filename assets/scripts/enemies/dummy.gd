extends CharacterBody2D

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var player: Player
@export var damage := 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_inside_tree():
		var t := global_position.direction_to(player.global_position)
		sprite_2d.flip_h = t.x < 0.0

	move_and_slide()


func _damage():
	var mat := gpu_particles_2d.process_material as ParticleProcessMaterial
	mat.direction.x = 1.0 if sprite_2d.flip_h else -1.0
	gpu_particles_2d.restart()


func _on_area_2d_body_entered(body: Node2D) -> void:
	var n := global_position.direction_to(body.global_position)
	
	if damage > 0:
		body.damage(damage, -1 if n.x < 0 else 1)
