@tool
extends Resource
class_name Door

@export_enum("Left", "Top", "Right", "Bottom") var side := 0
@export_range(0, 640, 1.0, "or_greater") var min: int = 0
@export_range(0, 640, 1.0, "or_greater") var max: int = 0
@export var lock := true
@export var stair_lock_up := false
@export var stair_lock_down := false

@export var next : int  # Because Godot is kinda cringe
@export var stairs : PackedInt32Array

func _init() -> void:
	next = -1
