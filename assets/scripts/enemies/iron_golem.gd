extends CharacterBody2D
class_name IronGolem

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var gpu_particles_2d_2: GPUParticles2D = $GPUParticles2D2
@onready var gpu_particles_2d_3: GPUParticles2D = $GPUParticles2D3
@onready var gpu_particles_2d_4: GPUParticles2D = $GPUParticles2D4

@export var player: Player
@export var health := 40

var _advance := true
var _attack := false

signal defeated
signal summoned
signal earthquaked

func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if animation_player.current_animation != "walk":
		return
	
	if _advance:
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		if player:
			var t := player.global_position.x - global_position.x
			sprite_2d.flip_h = t > 0.0
			velocity.x = roundf(clampf(t, -1.0, 1.0)) * 8.0
		
		move_and_slide()


func copy_from_base(d: CharacterBody2D):
	health = d.health
	
	for c in d.earthquaked.get_connections():
		earthquaked.connect(c["callable"])


func summon():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	animation_player.play("summon")
	await animation_player.animation_finished
	
	summoned.emit()
	
	process_mode = Node.PROCESS_MODE_INHERIT
	
	set_physics_process(true)
	animation_player.play("walk")
	timer.start()


func advance(b: bool):
	_advance = b


func end_cycle():
	if _attack:
		if sprite_2d.flip_h:
			animation_player.play("attack_2")
		else:
			animation_player.play("attack")


func shift():
	if sprite_2d.flip_h:
		position.x += 29
	else:
		position.x -= 29


func earthquake():
	earthquaked.emit()


func _damage(x: float = 1.0):
	if health > 0:
		health -= x
		if health == 0:
			animation_player.play("death")


func _on_area_2d_body_entered(body: Node2D) -> void:
	var n := global_position.direction_to(body.global_position)
	
	body.damage(3, -1 if n.x < 0 else 1)


func _on_timer_timeout() -> void:
	_attack = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("attack"):
		animation_player.play("walk")
		timer.start()
		_attack = false
	elif anim_name == "death":
		defeated.emit() # Play some animation and shit
		queue_free()
