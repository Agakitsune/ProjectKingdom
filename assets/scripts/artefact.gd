extends CharacterBody2D


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta * delta
	
	var collide := move_and_collide(velocity)
	
	if collide:
		velocity.y *= -0.5
		position += collide.get_travel()
		if collide.get_travel().length() <= 0.01:
			set_physics_process(false)


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.stage_clear()
	queue_free()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	set_physics_process(true)
