class_name Chest
extends Interactable
## Kiste mit Beute. Gibt einmalig Item und/oder Packets, öffnet dann dauerhaft.
##
## Die Einmaligkeit hängt vollständig an `flag_id` + `one_shot` aus der
## Basisklasse — eine geöffnete Kiste bleibt es über Szenenwechsel und
## Speicherstände hinweg, weil `_ready()` in Interactable den offenen Zustand
## anhand des Flags wiederherstellt.

const LID_OPEN_ROTATION_X: float = -100.0
const LID_TWEEN_DURATION: float = 0.35

@export var item_id: String = ""
@export var item_count: int = 1
@export var packets: int = 0

@onready var _lid: Node3D = $Lid


func _perform_interaction(_interactor: Node3D) -> void:
	if not item_id.is_empty() and item_count > 0:
		GameState.add_item(item_id, item_count)
	if packets > 0:
		GameState.add_packets(packets)
	_open_lid_animated()
	EventBus.toast_requested.emit(_build_toast_message())


func _restore_consumed_state() -> void:
	if _lid != null:
		_lid.rotation_degrees.x = LID_OPEN_ROTATION_X


func _open_lid_animated() -> void:
	if _lid == null:
		return
	var tween: Tween = create_tween()
	tween.tween_property(_lid, "rotation_degrees:x", LID_OPEN_ROTATION_X, LID_TWEEN_DURATION)


func _build_toast_message() -> String:
	if not item_id.is_empty() and item_count > 0:
		return "%s erhalten" % _humanize_item_id(item_id)
	if packets > 0:
		return "%d Packets erhalten" % packets
	return "Kiste geöffnet"


## Verwandelt eine Item-ID wie "sword_ed25519" in einen lesbaren Text für den
## Toast. Keine echte Lokalisierung — die liegt in der UI, die dieses Script
## nicht anfassen darf.
func _humanize_item_id(id: String) -> String:
	var words: PackedStringArray = id.replace("_", " ").split(" ")
	if words.is_empty():
		return id
	words[0] = words[0].capitalize()
	return " ".join(words)
