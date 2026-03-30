extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var velocity = Vector2(0, 300)
var spell_name
var id
var player
var _spell
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup(spell_name, spell, id):
	sprite_2d.texture = load(spell.texture)
	_spell = spell

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	velocity = Vector2.ZERO

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	player.playerUi.set_spell_texture(_spell.texture)
	player._spell = load(_spell.id)
	queue_free()
