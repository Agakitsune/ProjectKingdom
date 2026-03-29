extends Node2D
var radius = 50
var ray_count = 50
var velocity = Vector2(0,0)
var gravity := 2000.0
var lifetime = 0.0
var collided = false
var points = []
var particles = []
const POISON_PARTICLE = preload("res://assets/scenes/poison_particle.tscn")

#@onready var character_body_2d: CharacterBody2D = $CharacterBody2D
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var path_2d: Path2D = $Path2D
@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup(pos, enrientation):
	sprite_2d.global_position = Vector2(pos.x + 10, pos.y - 20)
	velocity = Vector2(100 * enrientation,-200)

func set_points(pos):
	points.clear()
	pos.y -= 10
	var space = get_world_2d().direct_space_state
	var had_collision = false

	for i in range(ray_count):
		var angle = (TAU / ray_count) * i
		var offset = Vector2(cos(angle), sin(angle)) * radius
		
		var from = pos
		var to = from + offset
		
		var query = PhysicsRayQueryParameters2D.create(from, to)
		query.collision_mask = 2
		
		var result = space.intersect_ray(query)

		if result and result.position.y > pos.y:
			points.append(result.position)
			had_collision = true
		else:
			if had_collision:
				break

	var curve = Curve2D.new()
	for p in points:
		curve.add_point(path_2d.to_local(p))

	path_2d.curve = curve
	call_deferred("set_particles")

func set_particles():
	for child in path_2d.get_children():
		if child is PathFollow2D:
			child.queue_free()

	for i in range(30):
		var follow = PathFollow2D.new()
		path_2d.add_child(follow)
		if i / 30.0 > 0:
			follow.progress_ratio = i / 30.0
		var particle = POISON_PARTICLE.instantiate()
		particles.append(particle)
		follow.add_child(particle)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not collided:
		velocity.y += gravity * delta * 0.4
		position += velocity * delta
	else:
		lifetime += delta
		if lifetime > 2:
			for particle in particles:
				particle.get_children()[0].emitting = false
		if lifetime > 2.5:
			queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	set_points(sprite_2d.global_position)
	sprite_2d.queue_free()
	collided = true
