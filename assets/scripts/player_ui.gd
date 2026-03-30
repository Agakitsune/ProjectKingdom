extends Control

@onready var health_container: HBoxContainer = $HealthContainer
@onready var sprite_2d: Sprite2D = $Panel/Sprite2D

var sprite_list = []
var max_health = 20
var current_health = 10
var weapons_list
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(max_health):
		var health_sprite = Sprite2D.new()
		health_sprite.texture = load("res://assets/textures/health_point.png")
		health_sprite.position.x = 18 * i
		sprite_list.append(health_sprite)
		health_container.add_child(health_sprite)

func set_spell_texture(texture):
	sprite_2d.texture = load(texture)

func update_health():
	for i in range(max_health):
		if i < current_health:
			sprite_list[i].texture = load("res://assets/textures/health_point.png")
		else:
			sprite_list[i].texture = load("res://assets/textures/empty_health_point.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_health()
