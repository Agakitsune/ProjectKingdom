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

const CROSS = preload("res://assets/scenes/subweapons/cross.tscn")
const DAGGER = preload("res://assets/scenes/subweapons/dagger.tscn")
const POISON_POTION = preload("res://assets/scenes/subweapons/poison_potion.tscn")

const SPEED := 40.0
const JUMP_VELOCITY := -300.0
const AIR_MUL := 2.0

const weapons_list = {
	"dagger": {
		"texture": "res://assets/textures/Dagger.png",
		"id": "uid://hdt3j1bmgc4",
	},
	"poison_potion": {
		"texture": "res://assets/textures/poison_potion.png",
		"id": "uid://kmhyq2t6ljpr",
	},
	"axe": {
		"texture": "res://assets/textures/tmp_axe.png",
		"id": "uid://lj87mmhoh7q3",
	},
	"cross": {
		"texture": "res://assets/textures/Cross.png",
		"id": "uid://dmvs8g87wfdnx",
	},
}

#var playerUi
var actual_zone: Zone

var _lives := lives
var _score := 0
var _heart := 0

var _stair: Stair

var _health := health
var _invicible := false

var _spell: Spell

signal damage_taken(direction: int)

signal update()

signal dead()
signal stage_cleared()

func _ready() -> void:
	#playerUi = get_parent().get_node("CanvasLayer/PlayerUi")
	#playerUi.player = self
	#playerUi.weapons_list = weapons_list
	#playerUi.set_spell_texture("res://assets/textures/tmp_axe.png")
	_lives = lives
	_spell = preload("uid://lj87mmhoh7q3")
	
	await get_parent().ready
	
	update.emit()
	#playerUi.set_spell_texture(weapons_list[_spell.scene.spell_name].texture)

func _input(event: InputEvent) -> void:
	pass


func _physics_process(delta: float) -> void:
	var cam := get_canvas_transform().affine_inverse() * get_viewport_rect()
	
	if position.y >= cam.end.y + 128.0:
		state_machine.load_state("Death")


func reset(hard := false):
	if hard:
		_lives = lives
	_health = health
	
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

func stage_clear():
	get_tree().paused = true
	
	stage_cleared.emit()

func _set_offset(x: float):
	if sprite_2d.flip_h:
		sprite_2d.offset.x = -x
	else:
		sprite_2d.offset.x = x


#func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#if anim_name == "attack":
		#animation_player.play("idle")
		#whip_shape.disabled = true
	#elif anim_name == "crouch_attack":
		#animation_player.play("crouch")
		#whip_shape.disabled = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	body._damage(2.0)


func _on_whip_area_entered(area: Area2D) -> void:
	area._damage(2.0)


func _on_stair_collider_body_entered(body: Node2D) -> void:
	_stair = body.get_parent() as Stair


func _on_stair_collider_body_exited(body: Node2D) -> void:
	_stair = null


func _on_timer_timeout() -> void:
	_invicible = false
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("active", false)
