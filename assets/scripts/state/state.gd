@abstract
extends Node
class_name State

var machine : StateMachine

signal change_state(n: StringName)

func _condition(previous: StringName, ...args: Array) -> bool:
	return true

@abstract
func _on_enter(previous: StringName)

@abstract
func _on_exit(next: StringName)

@abstract
func _on_input(event: InputEvent)

@abstract
func _on_process(delta: float)
