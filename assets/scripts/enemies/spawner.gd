@tool
extends Marker2D
class_name EnemySpawner

@export var scene: PackedScene:
	set = _set_scene

var _base: Node2D
var _instance: Node2D

func _ready() -> void:
	if Engine.is_editor_hint():
		if _instance:
			_instance.owner = get_tree().edited_scene_root
	else:
		for c in get_children():
			if c.scene_file_path == scene.resource_path:
				_base = c
				remove_child(c)


func spawn(p: Player):
	destroy()
	
	_instance = scene.instantiate()
	add_child(_instance)
	
	if "player" in _instance:
		_instance.player = p
	
	if _instance.has_method("copy_from_base"):
		_instance.copy_from_base(_base)


func destroy():
	if _instance:
		remove_child(_instance)
		_instance.queue_free()


func _set_scene(s: PackedScene):
	scene = s
	
	if Engine.is_editor_hint():
		destroy()
		if scene:
			if get_tree().edited_scene_root:
				_instance = scene.instantiate()
				add_child(_instance)
				
				_instance.owner = get_tree().edited_scene_root
