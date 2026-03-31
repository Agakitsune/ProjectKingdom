extends CharacterBody2D
class_name Player

@export_range(0, 100, 1.0, "or_greater") var health := 100
@export_range(0, 9, 1.0) var lives := 2

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var whip: Area2D = %Whip
@onready var whip_shape: CollisionShape2D = %WhipShape
@onready var state_machine: StateMachine = $StateMachine
@onready var timer: Timer = $Timer

const SPELLS = [
	preload("uid://hdt3j1bmgc4"),
	preload("uid://lj87mmhoh7q3"),
	preload("uid://kmhyq2t6ljpr"),
	preload("uid://dmvs8g87wfdnx")
]

const SPEED := 40.0
const JUMP_VELOCITY := -300.0
const AIR_MUL := 2.0

var actual_zone: Zone

var _lives := lives
var _score := 0
var _heart := 10

var _stair: Stair

var _health := health
var _invicible := false

var _spell: Spell

signal damage_taken(direction: int)

signal update()

signal dead()
signal stage_cleared()

func _ready() -> void:
	_lives = lives
	
	await get_parent().ready
	
	update.emit()

func _input(event: InputEvent) -> void:
	pass


func _physics_process(delta: float) -> void:
	var cam := get_canvas_transform().affine_inverse() * get_viewport_rect()
	
	if position.y >= cam.end.y + 128.0:
		state_machine.load_state("Death")


func reset(hard := false):
	if hard:
		_lives = lives
	_heart = 10
	_health = health
	
	update.emit()
	
	state_machine.load_state("Idle")


func damage(x: int, direction: int):
	if _invicible:
		return
	
	_health -= x
	update.emit()
	
	if _health <= 0:
		damage_taken.emit(direction)
		state_machine.load_state("Death")
	else:
		damage_taken.emit(direction)
		state_machine.load_state("Damage")
		_invicible = true

func can_cast() -> bool:
	if _spell and _spell.consumption <= _heart:
		return true
	return false

func cast():
	if _spell:
		_heart -= _spell.consumption
		update.emit()
		
		var instance: Node2D = _spell.scene.instantiate()
		
		instance.flip = sprite_2d.flip_h
		get_parent().add_child(instance)
		
		instance.global_position = global_position

func load_spell(idx: int):
	_spell = SPELLS[idx]
	
	update.emit()
	

func stage_clear():
	get_tree().paused = true
	
	stage_cleared.emit()

func _set_offset(x: float):
	if sprite_2d.flip_h:
		sprite_2d.offset.x = -x
	else:
		sprite_2d.offset.x = x


func _on_area_2d_body_entered(body: Node2D) -> void:
	body._damage(5.0, false)


func _on_whip_area_entered(area: Area2D) -> void:
	area._damage(2.0)


func _on_stair_collider_body_entered(body: Node2D) -> void:
	_stair = body.get_parent() as Stair


func _on_stair_collider_body_exited(body: Node2D) -> void:
	_stair = null


func _on_timer_timeout() -> void:
	_invicible = false
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("active", false)
