extends Node2D
class_name Stage

@export var start: Zone
var _current: Zone

signal zone_loaded(next: Zone)

func snapv_into(p: Vector2) -> Vector2:
	return _current.snapv_into(p)


func update(player: Player):
	if not _current:
		return
	if not _current.is_inside(player.global_position):
		var next := _current.fetch_door(player.global_position)
		if next:
			zone_loaded.emit(next.next_zone)
			
			if next.respawn:
				next.next_zone._active_respawn = next.respawn
			else:
				next.next_zone._active_respawn = next.next_zone._respawn[0]
			
			for s in next.next_zone._spawners:
				s.spawn(player)


func spawn_in(p: Player):
	p.global_position = start._active_respawn.global_position - Vector2(0, 32)
	
	for s in start._spawners:
		s.spawn(p)
	
	_current = start


func set_current(z: Zone):
	for s in _current._spawners:
		s.destroy()
	
	_current = z


func reset_screen(p: Player, c: Camera2D):
	_current.setup_limit(c)
	p.global_position = _current._active_respawn.global_position - Vector2(0, 32)
	
	p.reset()
	
	for s in _current._spawners:
		s.destroy()
		s.spawn(p)


func reset(p: Player, c: Camera2D):
	start.setup_limit(c)
	p.global_position = start._active_respawn.global_position - Vector2(0, 32)
	
	p.reset(true)
	
	set_current(start)
	
	for z in get_children():
		if z is Zone:
			z.reset()
