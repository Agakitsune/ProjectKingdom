extends CharacterBody2D
class_name Player

@export_range(0, 100, 1.0, "or_greater") var health := 20

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var whip: Area2D = %Whip
@onready var whip_shape: CollisionShape2D = %WhipShape

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

var actual_zone: Zone

var _stair: Stair
var _use_stair := false
var _stair_index := 0

var _stair_tween: Tween

var _health := health
var _hurt := false
var _invicible := false

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if _health <= 0:
		return
	
	if _hurt:
		return
	
	if event.is_action_pressed("attack"):
		if Input.is_action_pressed("down") and is_on_floor():
			animation_player.play("crouch_attack")
		else:
			animation_player.play("attack")
		whip_shape.disabled = false
	elif event.is_action_pressed("up"):
		if _stair and not _use_stair and _stair._player_ratio(self) < 0.5 and not _stair.lock_up:
			_stair._player_use(self, is_on_floor())
			_use_stair = true
			var start := _stair.sample(_stair_index * 22.67).x
			var flat := absf(global_position.x - start)
			var time := flat / SPEED
			_stair_tween = create_tween()
			_stair_tween.tween_property(
				self, "position",
				_stair.sample(_stair_index * 22.67)
				- Vector2(0, 32),
				time
			).set_trans(Tween.TRANS_LINEAR)
			_stair_tween.tween_callback(
				func(): animation_player.play("stair_up")
			)
			
			sprite_2d.flip_h = _stair.flip_h
			whip.scale.x = -1.0 if sprite_2d.flip_h else 1.0
	elif event.is_action_pressed("down"):
		if _stair and not _use_stair and _stair._player_ratio(self) > 0.5 and not _stair.lock_down:
			_stair._player_use(self, is_on_floor())
			_use_stair = true
			var start := _stair.sample(_stair_index * 22.67).x
			var flat := absf(global_position.x - start)
			var time := flat / SPEED
			_stair_tween = create_tween()
			_stair_tween.tween_property(
				self, "position",
				_stair.sample(_stair_index * 22.67)
				- Vector2(0, 32),
				time
			).set_trans(Tween.TRANS_LINEAR)
			_stair_tween.tween_callback(
				func(): animation_player.play("stair_down")
			)
			
			sprite_2d.flip_h = not _stair.flip_h
			whip.scale.x = -1.0 if sprite_2d.flip_h else 1.0


func _physics_process(delta: float) -> void:
	if _health <= 0:
		velocity.y = move_toward(
			velocity.y,
			0.0,
			delta * 24.0
		)
		velocity.x = move_toward(
			velocity.x,
			0.0,
			delta * 4.0
		)
		
		if velocity.length() <= 0.01:
			print("ZA WARUDO")
			pass # TODO: Reset the current zone
		
		move_and_slide()
		return
	
	if _hurt:
		velocity += get_gravity() * delta
		
		move_and_slide()
		
		if is_on_floor():
			velocity.x = 0
			var timer := get_tree().create_timer(0.5).timeout.connect(
				func():
					(sprite_2d.material as ShaderMaterial).set_shader_parameter("active", true)
					_hurt = false
			)
			var invi := get_tree().create_timer(1.5).timeout.connect(
				func():
					(sprite_2d.material as ShaderMaterial).set_shader_parameter("active", false)
					_invicible = false
			)
		return
	
	if _use_stair:
		if not (_stair_tween and _stair_tween.is_running()):
			if Input.is_action_pressed("up") and not _stair.lock_up:
				animation_player.play("stair_up")
				_stair_index += 1
				if _stair_index >= _stair.length * 2:
					_stair_tween = create_tween()
					_stair_tween.tween_property(
						self, "position",
						_stair.sample(_stair_index * 22.67)
						- Vector2(0, 32),
						0.2
					).set_trans(Tween.TRANS_LINEAR)
					_stair_tween.tween_callback(
						func():
							_use_stair = false
							animation_player.play("idle")
					)
				else:
					_stair_tween = create_tween()
					_stair_tween.tween_property(
						self, "position",
						_stair.sample(_stair_index * 22.67)
						- Vector2(0, 32),
						0.2
					).set_trans(Tween.TRANS_LINEAR)
				
				sprite_2d.flip_h = _stair.flip_h
				whip.scale.x = -1.0 if sprite_2d.flip_h else 1.0
			elif Input.is_action_pressed("down") and not _stair.lock_down:
				animation_player.play("stair_down")
				_stair_index -= 1
				if _stair_index < 0:
					_use_stair = false
					animation_player.play("idle")
				else:
					_stair_tween = create_tween()
					_stair_tween.tween_property(
						self, "position",
						_stair.sample(_stair_index * 22.67)
						- Vector2(0, 32),
						0.2
					).set_trans(Tween.TRANS_LINEAR)
				
				sprite_2d.flip_h = not _stair.flip_h
				whip.scale.x = -1.0 if sprite_2d.flip_h else 1.0
		return
	
	var not_attack := not animation_player.current_animation.contains("attack")
	
	if Input.is_action_pressed("down") and is_on_floor():
		if not_attack:
			animation_player.play("crouch")
	elif not_attack:
		animation_player.play("idle")
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("left", "right")
	if direction:
		if is_on_floor():
			if animation_player.current_animation != "attack":
				animation_player.play("walk")
				sprite_2d.flip_h = direction < 0.0
				whip.scale.x = -1.0 if sprite_2d.flip_h else 1.0
				velocity.x = direction * SPEED
			else:
				velocity.x = 0
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = 0

	move_and_slide()


func damage(x: int, direction: int):
	if _invicible:
		return
	
	_health -= x
	
	if _health <= 0:
		animation_player.play("death")
		velocity.y = -30
		velocity.x = direction * 10
	else:
		_invicible = true
		_hurt = true
		velocity.y = -300
		velocity.x = direction * 100
		animation_player.play("hurt")


func _set_offset(x: float):
	if sprite_2d.flip_h:
		sprite_2d.offset.x = -x
	else:
		sprite_2d.offset.x = x


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		animation_player.play("idle")
		whip_shape.disabled = true
	elif anim_name == "crouch_attack":
		animation_player.play("crouch")
		whip_shape.disabled = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	body._damage()


func _on_stair_collider_body_entered(body: Node2D) -> void:
	_stair = body.get_parent() as Stair
	
	var input := Input.is_action_pressed("up")
	var airborne := not is_on_floor()
	
	if airborne:
		if input and velocity.y >= 50.0:
			_stair._player_use(self, false)
			
			position = _stair.sample(_stair_index * 22.67) - Vector2(0, 32)
			_use_stair = true
			
			_stair_tween = create_tween()
			_stair_tween.tween_property(
				self, "position",
				position,
				0.2
			).set_trans(Tween.TRANS_LINEAR)
			
			if sprite_2d.flip_h:
				if _stair.flip_h:
					animation_player.play("stair_up")
				else:
					animation_player.play("stair_down")
			else:
				if _stair.flip_h:
					animation_player.play("stair_down")
				else:
					animation_player.play("stair_up")
		else:
			_stair = null


func _on_stair_collider_body_exited(body: Node2D) -> void:
	if not _use_stair:
		_stair = null
