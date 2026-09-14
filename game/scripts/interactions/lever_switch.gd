class_name LeverSwitch
extends Interactable
## Hebel, der ein Weltflag setzt.
##
## Bei `toggle = false` verhält er sich wie eine Kiste: einmalig, gesperrt
## über das geerbte `flag_id`/`one_shot`. Bei `toggle = true` ist er beliebig
## oft umlegbar — dafür wird `one_shot` in `_ready()` auf false gesetzt und
## `target_flag_id` selbst trägt den aktuellen An/Aus-Zustand.

const LEVER_TILT_DEGREES: float = 45.0
const LEVER_TWEEN_DURATION: float = 0.25

## Flag, das der Hebel setzt, z.B. um eine Tür anderswo zu entriegeln.
@export var target_flag_id: String = ""
## Wenn true, umschaltbar statt einmalig.
@export var toggle: bool = false

@onready var _lever: Node3D = $Lever


func _ready() -> void:
	one_shot = not toggle
	super._ready()
	if toggle and is_switched_on() and _lever != null:
		_lever.rotation_degrees.x = LEVER_TILT_DEGREES


func can_interact() -> bool:
	if toggle:
		return true
	return super.can_interact()


func is_switched_on() -> bool:
	if toggle:
		return not target_flag_id.is_empty() and GameState.get_flag(target_flag_id)
	return is_consumed()


func _perform_interaction(_interactor: Node3D) -> void:
	if target_flag_id.is_empty():
		return
	if toggle:
		var new_state: bool = not GameState.get_flag(target_flag_id)
		GameState.set_flag(target_flag_id, new_state)
		_animate_lever(new_state)
	else:
		GameState.set_flag(target_flag_id)
		_animate_lever(true)


func _restore_consumed_state() -> void:
	if _lever != null:
		_lever.rotation_degrees.x = LEVER_TILT_DEGREES


func _animate_lever(is_on: bool) -> void:
	if _lever == null:
		return
	var target_degrees: float = LEVER_TILT_DEGREES if is_on else 0.0
	var tween: Tween = create_tween()
	tween.tween_property(_lever, "rotation_degrees:x", target_degrees, LEVER_TWEEN_DURATION)
