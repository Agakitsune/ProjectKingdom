extends Control

@onready var health: TextureProgressBar = %Health
@onready var boss: TextureProgressBar = %Boss
@onready var heart: HBoxContainer = %Heart
@onready var subweapon: TextureRect = %Subweapon
@onready var lives: HBoxContainer = %Lives
@onready var time: HBoxContainer = %Time
@onready var score: HBoxContainer = %Score

func _ready() -> void:
	boss.value = 0.0


func set_boss_health(x: float):
	boss.value = x


func _update_player(p: Player) -> void:
	health.value = p._health
	_update_lives(p._lives)
	_update_heart(p._heart)
	if p._spell:
		_update_subweapon(p._spell.idx + 1)
	else:
		_update_subweapon(0)
	_update_score(p._score)


func _update_subweapon(x: int) -> void:
	var a := subweapon.texture as AtlasTexture
	
	a.region.position.x = 16 * x


func _update_heart(x: int) -> void:
	var c := heart.get_children()
	
	for i in range(3):
		var k := x % 10
		var tex := (c[2 - i] as TextureRect).texture as AtlasTexture
		x = x / 10
		
		tex.region.position = _get_number(k)


func _update_time(x: int) -> void:
	var m := x / 60
	var s := x % 60
	
	var md := m / 10
	var mu := m % 10
	
	var sd := s / 10
	var su := s % 10
	
	var a := (time.get_children()[0] as TextureRect).texture as AtlasTexture
	var b := (time.get_children()[1] as TextureRect).texture as AtlasTexture
	var c := (time.get_children()[3] as TextureRect).texture as AtlasTexture
	var d := (time.get_children()[4] as TextureRect).texture as AtlasTexture
	
	a.region.position = _get_number(md)
	b.region.position = _get_number(mu)
	c.region.position = _get_number(sd)
	d.region.position = _get_number(su)


func _update_score(x: int) -> void:
	var c := score.get_children()
	
	for i in range(6):
		var k := x % 10
		var tex := (c[5 - i] as TextureRect).texture as AtlasTexture
		x = x / 10
		
		tex.region.position = _get_number(k)
	


func _update_lives(x: int) -> void:
	var d := x / 10
	var u := x % 10
	
	var a := (lives.get_children()[0] as TextureRect).texture as AtlasTexture
	var b := (lives.get_children()[1] as TextureRect).texture as AtlasTexture
	
	a.region.position = _get_number(d)
	b.region.position = _get_number(u)


func _get_number(x: int) -> Vector2:
	return Vector2(
		77 + (x % 5) * 7,
		16 + (x / 5) * 8
	)

#@onready var health_container: HBoxContainer = $HealthContainer
#@onready var sprite_2d: Sprite2D = $Panel/Sprite2D
#
#var sprite_list = []
#var max_health = 10
#var current_health = 3
#var weapons_list
#var player
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#for i in range(max_health):
		#var health_sprite = Sprite2D.new()
		#health_sprite.texture = load("res://assets/textures/health_point.png")
		#health_sprite.position.x = 18 * i
		#sprite_list.append(health_sprite)
		#health_container.add_child(health_sprite)
#
#func set_spell_texture(texture):
	#sprite_2d.texture = load(texture)
#
#func update_health():
	#for i in range(max_health):
		#if i < current_health:
			#sprite_list[i].texture = load("res://assets/textures/health_point.png")
		#else:
			#sprite_list[i].texture = load("res://assets/textures/empty_health_point.png")
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#update_health()
