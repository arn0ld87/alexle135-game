class_name LockedDoor
extends Interactable
## Verschlossene Tür. Öffnet sich mit passendem Schlüssel oder über ein
## extern gesetztes Flag (z.B. von einem Hebel).
##
## `DoorBody` ist der physische Blocker (StaticBody3D, Layer "world"). Beim
## Öffnen verliert er seine Kollisionsebene, damit der Player durchgehen kann.

const DOOR_SLIDE_OFFSET: Vector3 = Vector3(0.0, 0.0, 1.2)
const DOOR_OPEN_DURATION: float = 0.5

@export var required_key_id: String = "key_generic"
@export var consume_key: bool = true
## Alternative Öffnung ohne Schlüssel, z.B. über einen Hebel.
@export var required_flag_id: String = ""

@onready var _door_body: StaticBody3D = $DoorBody

var _opened: bool = false


func can_interact() -> bool:
	if _opened:
		return true
	if not required_flag_id.is_empty() and GameState.get_flag(required_flag_id):
		return true
	return GameState.has_item(required_key_id)


func get_prompt() -> String:
	if _opened:
		return prompt_text
	if can_interact():
		return "Tür aufschliessen"
	return "Verschlossen — Schlüssel fehlt"


func is_open() -> bool:
	return _opened


func _perform_interaction(_interactor: Node3D) -> void:
	if _opened:
		return
	if consume_key and GameState.has_item(required_key_id):
		GameState.consume_item(required_key_id)
	_opened = true
	_open_door_animated()


func _restore_consumed_state() -> void:
	_opened = true
	if _door_body != null:
		_door_body.position += DOOR_SLIDE_OFFSET
		_door_body.collision_layer = 0


func _open_door_animated() -> void:
	if _door_body == null:
		return
	var tween: Tween = create_tween()
	tween.tween_property(_door_body, "position", _door_body.position + DOOR_SLIDE_OFFSET,
		DOOR_OPEN_DURATION)
	_door_body.collision_layer = 0
