extends CharacterBody2D

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var invi: Timer = $In

@export var player: Player
@export var damage := 0
@export var health := -1

var _invicible := false

signal defeated
signal summoned

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_inside_tree():
		if player:
			var t := global_position.direction_to(player.global_position)
			sprite_2d.flip_h = t.x < 0.0

	move_and_slide()


func copy_from_base(d: CharacterBody2D):
	damage = d.damage
	health = d.health


func summon():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	animation_player.play("summon")
	await animation_player.animation_finished
	summoned.emit()
	
	process_mode = Node.PROCESS_MODE_INHERIT


func _damage(x: float, cross := true):
	if _invicible:
		return
	_invicible = true
	invi.start()
	if health > 0:
		health -= x
		if health == 0:
			defeated.emit() # Play some animation and shit
	
	var mat := gpu_particles_2d.process_material as ParticleProcessMaterial
	mat.direction.x = 1.0 if sprite_2d.flip_h else -1.0
	gpu_particles_2d.restart()


func _on_area_2d_body_entered(body: Node2D) -> void:
	var n := global_position.direction_to(body.global_position)
	
	if damage > 0:
		body.damage(damage, -1 if n.x < 0 else 1)


func _on_in_timeout() -> void:
	_invicible = false
	pass # Replace with function body.
