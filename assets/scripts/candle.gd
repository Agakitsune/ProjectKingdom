extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
const DROPED_SPELL = preload("res://assets/scenes/droped_spell.tscn")

var player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("candle")
	player = get_parent().get_node("Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_random_weapon():
	var keys = player.weapons_list.keys()
	
	var new_index = player.current_spell_id
	
	while new_index == player.current_spell_id:
		new_index = randi() % keys.size()
	
	var selected_key = keys[new_index]
	return [new_index, selected_key, player.weapons_list[selected_key]]

func create_drop_spell():
	var drop = DROPED_SPELL.instantiate()
	var randomizer = get_random_weapon()
	print(global_position)
	get_parent().add_child(drop)
	drop.player = player
	drop.setup(randomizer[1], randomizer[2], randomizer[0])
	drop.global_position = global_position
	print(drop.position)

func _on_area_2d_area_entered(area: Area2D) -> void:
	call_deferred("create_drop_spell")
	call_deferred("queue_free")
