extends Node2D

@export var frames: SpriteFrames
@export var item: int

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

const ITEM = preload("res://assets/scenes/item.tscn")

func _ready() -> void:
	sprite_2d.sprite_frames = frames
	sprite_2d.play("default")


func _drop():
	var item = ITEM.instantiate()
	item._item = self.item
	
	get_parent().add_child.call_deferred(item)
	item.set_deferred("global_position", global_position)


func _damage(x: float):
	_drop()
	
	sprite_2d.play("death")
	await sprite_2d.animation_finished
	
	queue_free()
