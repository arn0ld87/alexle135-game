class_name PressurePlate
extends Interactable
## Druckplatte: reagiert auf Gewicht (Spieler oder schiebbare Objekte), nicht
## auf Tastendruck. `can_interact()` bleibt deshalb immer false, damit kein
## Interaktions-Prompt erscheint — die InteractRange des Players soll diese
## Platte ignorieren.

const PLATE_LOWER_OFFSET: float = 0.06
const PLATE_TWEEN_DURATION: float = 0.2

@export var target_flag_id: String = ""
## Wenn true, ist das Flag nur gesetzt, solange Gewicht auf der Platte liegt.
## Wenn false, bleibt es nach dem ersten Druck dauerhaft gesetzt.
@export var requires_continuous_weight: bool = true

@onready var _plate: Node3D = $Plate

var _weight_count: int = 0
var _base_plate_y: float = 0.0
var _locked: bool = false


func _ready() -> void:
	super._ready()
	# Muss selbst suchen: player (2) und schiebbare Objekte liegen typischerweise
	# auf der world-Ebene (1).
	collision_mask = 3
	monitoring = true
	if _plate != null:
		_base_plate_y = _plate.position.y
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Nicht-kontinuierliche Platten bleiben über einen Speicherstand hinweg
	# gedrückt, wenn ihr Flag schon gesetzt ist.
	if not requires_continuous_weight and not target_flag_id.is_empty() \
			and GameState.get_flag(target_flag_id):
		_locked = true
		if _plate != null:
			_plate.position.y = _base_plate_y - PLATE_LOWER_OFFSET


func can_interact() -> bool:
	return false


func is_pressed() -> bool:
	if requires_continuous_weight:
		return _weight_count > 0
	return _locked


func _on_body_entered(body: Node3D) -> void:
	if not _is_relevant_body(body):
		return
	_weight_count += 1
	if _weight_count == 1:
		_set_pressed(true)


func _on_body_exited(body: Node3D) -> void:
	if not _is_relevant_body(body):
		return
	_weight_count = maxi(0, _weight_count - 1)
	if _weight_count == 0 and requires_continuous_weight:
		_set_pressed(false)


func _is_relevant_body(body: Node3D) -> bool:
	return body.is_in_group("player") or body.is_in_group("pushable")


func _set_pressed(value: bool) -> void:
	if value:
		_locked = true
	if not target_flag_id.is_empty():
		GameState.set_flag(target_flag_id, value)
	_animate_plate(value)


func _animate_plate(is_down: bool) -> void:
	if _plate == null:
		return
	var target_y: float = _base_plate_y - PLATE_LOWER_OFFSET if is_down else _base_plate_y
	var tween: Tween = create_tween()
	tween.tween_property(_plate, "position:y", target_y, PLATE_TWEEN_DURATION)
