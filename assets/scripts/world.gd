extends Node2D

@onready var player: Player = $Player
@onready var marker_2d: Marker2D = $Marker2D
@onready var marker_2d_2: Marker2D = $Marker2D2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.camera.limit_top = marker_2d.position.y
	#player.camera.limit_left = marker_2d.position.x
	player.camera.limit_bottom = marker_2d_2.position.y
	#player.camera.limit_right = marker_2d_2.position.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
