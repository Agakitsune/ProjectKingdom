extends Node
class_name StateMachine

@export var base: State

var _states: Dictionary[StringName, State]
var _current: State

func _ready() -> void:
	if get_parent() is Player:
		for c in get_children():
			if c is PlayerState:
				_states[c.name] = c
				c.change_state.connect(load_state)
				c.player = get_parent()
				c.machine = self
	else:
		for c in get_children():
			if c is State:
				_states[c.name] = c
				c.change_state.connect(load_state)
				c.machine = self
	
	await get_parent().ready
	
	base._on_enter("")
	_current = base


func _input(event: InputEvent) -> void:
	_current._on_input(event)


func _physics_process(delta: float) -> void:
	_current._on_process(delta)


func test_state(n: StringName, ...args: Array) -> bool:
	if n not in _states:
		return false
	
	var call : Array = [n]
	var next := _states[n]

	call.append_array(args)
	return next.callv("_condition", call)


func load_state(n: StringName, args: Array = []):
	if n not in _states:
		return
	
	if n == _current.name:
		return
	
	var next := _states[n]
	print("Load ", n)
	_current._on_exit(n)
	next._on_enter(_current.name)
	_current = next
