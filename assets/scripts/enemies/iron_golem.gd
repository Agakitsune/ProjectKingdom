extends CharacterBody2D
class_name IronGolem

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2
@onready var super_timer: Timer = $Super
@onready var invi: Timer = $Invi

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var gpu_particles_2d_2: GPUParticles2D = $GPUParticles2D2
@onready var gpu_particles_2d_3: GPUParticles2D = $GPUParticles2D3
@onready var gpu_particles_2d_4: GPUParticles2D = $GPUParticles2D4
@onready var gpu_particles_2d_7: GPUParticles2D = $GPUParticles2D7

@export var player: Player
@export var health := 300.0

var _t := 0.0

var _advance := true
var _attack := false
var _invicible := false

var _heal := false
var _heal_cooldown := 1

var _super := false
var _super_timeout := false
var _super_cooldown := 2


signal defeated
signal summoned
signal stepped
signal earthquaked

func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if _heal and health > 0.0:
			health = minf(health + 0.2, 300.0)
	
	if animation_player.current_animation != "walk":
		return
	
	if _advance:
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		if player:
			var t := player.global_position.x - global_position.x
			sprite_2d.flip_h = t > 0.0
			velocity.x = roundf(clampf(t, -1.0, 1.0)) * 8.0
		
		velocity.x *= 6.0 if _super else 3.0
		
		move_and_slide()


func copy_from_base(d: CharacterBody2D):
	health = d.health
	
	for c in d.earthquaked.get_connections():
		earthquaked.connect(c["callable"])
	for c in d.stepped.get_connections():
		stepped.connect(c["callable"])


func summon():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	animation_player.play("summon")
	await animation_player.animation_finished
	
	summoned.emit()
	
	process_mode = Node.PROCESS_MODE_INHERIT
	
	set_physics_process(true)
	animation_player.play("walk", -1, 5.0 if _super else 3.0)
	timer.start()


func on_step():
	stepped.emit()


func advance(b: bool):
	_advance = b


func end_cycle():
	if _super_cooldown == 0:
		_super_cooldown = 2
		
		super_timer.start()
		
		animation_player_2.play("super")
		_super = true
	
	if _attack:
		if not _super:
			_super_cooldown -= 1
		_t = animation_player.current_animation_position
		if sprite_2d.flip_h:
			animation_player.play("attack_2", -1, 2.0 if _super else 1.0)
		else:
			animation_player.play("attack", -1, 2.0 if _super else 1.0)


func shift():
	if sprite_2d.flip_h:
		position.x += 29
	else:
		position.x -= 29


func earthquake():
	earthquaked.emit()


func _damage(x: float = 1.0, cross := true):
	if health <= 0:
		return
	
	if _invicible and cross:
		return
	
	health -= x
	
	if cross:
		_invicible = true
		invi.start()
	
	if health <= 0:
		animation_player_2.play("dead")
		animation_player.play("death")
	else:
		animation_player_2.play("hurt")
		await animation_player_2.animation_finished
		if _super:
			animation_player_2.play("super")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if health <= 0:
		return
	
	var n := global_position.direction_to(body.global_position)
	
	body.damage(10, -1 if n.x < 0 else 1)


func _on_timer_timeout() -> void:
	_attack = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("attack"):
		if _super:
			#_heal_cooldown -= 1
			#if _heal_cooldown <= 0:
			#_heal_cooldown = 2
			_heal = true
			gpu_particles_2d_7.emitting = true
			await get_tree().create_timer(4.0).timeout
			_heal = false
			gpu_particles_2d_7.emitting = false
		
		if health <= 0.0:
			return
		
		if _super_timeout:
			_super = false
			_super_timeout = false
			animation_player_2.play("RESET")
		
		animation_player.play("walk", -1, 5.0 if _super else 3.0)
		animation_player.seek(_t, true)
		timer.start()
		_attack = false
	elif anim_name == "death":
		defeated.emit() # Play some animation and shit
		queue_free()


func _on_invi_timeout() -> void:
	_invicible = false


func _on_super_timeout() -> void:
	_super_timeout = true
