@tool
extends CharacterBody2D

@export var small := false:
	set = _set_small

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var collision_shape_2d_2: CollisionShape2D = $Area2D/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _idle := true
var _fall := false
var _time := 0.0
var _sign := 0.0

signal fell

func _ready() -> void:
	collision_shape_2d.disabled = true
	collision_shape_2d_2.disabled = true
	
	collision_shape_2d.shape.size = Vector2(16, 16) if small else Vector2(32, 32)
	collision_shape_2d_2.shape.size = collision_shape_2d.shape.size - Vector2(8, 8)
	
	(sprite_2d.texture as AtlasTexture).region.position.x = 32 if small else 0
	(sprite_2d.texture as AtlasTexture).region.size = collision_shape_2d.shape.size
	
	_sign = -1 if randi_range(0, 1) else 1
	
	_time += randf() * 750.0


func _physics_process(delta: float) -> void:
	if _idle:
		_time += delta
		if _fall:
			position.y = cos(_time * 256.0) * 2.0
		else:
			position.y = cos(_time * 4.0) * 4.0
		
		sprite_2d.rotate(delta * 4.0 * _sign)
		
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta * delta
	
	var collide := move_and_collide(velocity, true)
	
	if collide:
		if collide.get_normal().y == 1.0:
			position += velocity
		else:
			velocity.y *= -0.5
			velocity.x = randf_range(-1, 1)
			position += collide.get_travel()
			
			get_tree().create_timer(
				0.5
			).timeout.connect(
				func():
					queue_free()
			)
	else:
		position += velocity


func _set_small(b: bool):
	small = b
	
	if collision_shape_2d:
		collision_shape_2d.shape.size = Vector2(16, 16) if small else Vector2(32, 32)
		collision_shape_2d_2.shape.size = collision_shape_2d.shape.size - Vector2(8, 8)
		
		(sprite_2d.texture as AtlasTexture).region.position.x = 32 if small else 0
		(sprite_2d.texture as AtlasTexture).region.size = collision_shape_2d.shape.size


func start_fall():
	_fall = true
	(sprite_2d.texture as AtlasTexture).region.position.y += 32


func fall():
	_idle = false
	fell.emit()


func _damage(x: float = 1.0, w := true):
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	var n := global_position.direction_to(body.global_position)
	
	body.damage(8, -1 if n.x < 0 else 1)
