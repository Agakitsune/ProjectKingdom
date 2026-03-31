extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D

#var velocity = Vector2(0, 300)
#var spell_name
#var id
#var player
#var _spell

var _item := 0

func _ready() -> void:
	(sprite_2d.texture as AtlasTexture).region.position.x = _item * 16


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	match _item:
		5:
			body._heart += 5
			body.update.emit()
		4:
			body._heart += 1
			body.update.emit()
		3, 2, 1, 0:
			body.load_spell(_item)
	
	queue_free()
