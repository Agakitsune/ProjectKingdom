extends Node2D

@onready var camera: Camera2D = %Camera
@onready var camera_control: Marker2D = %CameraControl

@onready var player: Player = $Player

@onready var zone: Zone = $Zone

var _camera_tween : Tween

func _ready() -> void:
	zone.setup_limit(camera)


func _process(delta: float) -> void:
	if not (_camera_tween and _camera_tween.is_running()):
		camera_control.global_position = player.global_position
		camera_control.global_position = zone.snapv_into(camera_control.global_position)
	
	if not zone.is_inside(player.global_position):
		var next := zone.load_zone(player.global_position)
		if next:
			var next_pos := next.snap_into(camera)
			var time := camera.get_screen_center_position().distance_to(next_pos) / 450.0
			
			camera.limit_enabled = false
			
			_camera_tween = create_tween()
			_camera_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			
			get_tree().paused = true
			
			_camera_tween.tween_property(
				camera_control, "global_position", next_pos, time
			).set_trans(Tween.TRANS_LINEAR)
			_camera_tween.tween_callback(
				func():
					next.setup_limit(camera)
					camera.limit_enabled = true
					zone = next
					get_tree().paused = false
			)
