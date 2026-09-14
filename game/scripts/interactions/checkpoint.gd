class_name Checkpoint
extends Interactable
## Automatischer Speicherpunkt. Reagiert auf Berührung, nicht auf Tastendruck
## — `can_interact()` bleibt deshalb immer false, kein Prompt.
##
## `checkpoint_id` geht an GameState.set_checkpoint (der "aktuelle
## Respawnpunkt", wird bei jedem erneuten Betreten aktualisiert). Das
## geerbte `flag_id` ist unabhängig davon die dauerhafte Markierung "diese
## Säule wurde schon einmal erreicht" — nur die steuert, ob die Säule leuchtet.

const LIT_COLOR: Color = Color(0x4d / 255.0, 0xa3 / 255.0, 0xff / 255.0)

@export var checkpoint_id: String = ""
@export var autosave: bool = true
@export var save_slot: int = 0

@onready var _pillar: MeshInstance3D = $Pillar


func _ready() -> void:
	super._ready()
	# Muss den Player selbst erkennen, kein Tastendruck nötig.
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body_entered)


func can_interact() -> bool:
	return false


func is_active() -> bool:
	return is_consumed()


func _restore_consumed_state() -> void:
	_light_pillar()


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_activate()


## Aktualisiert den Respawnpunkt bei jedem Betreten (auch wiederholt), aber
## zündet die Säule und markiert flag_id nur beim ERSTEN Erreichen.
func _activate() -> void:
	GameState.set_checkpoint(checkpoint_id, _owning_scene_path(), global_position)
	if autosave:
		SaveManager.save_game(save_slot)
		EventBus.toast_requested.emit("Fortschritt gesichert")
	if not is_active():
		_light_pillar()
		if not flag_id.is_empty():
			GameState.set_flag(flag_id)


## Pfad der Szene, in die ein Ladevorgang zurückkehren soll.
##
## Bewusst über `owner` statt über `get_tree().current_scene`:
##   - `owner` ist die Szene, in der DIESER Checkpoint platziert wurde. Das
##     stimmt auch dann, wenn die Welt als Unterszene in etwas anderem läuft.
##   - `current_scene` kann null sein, etwa während eines Szenenwechsels. Der
##     direkte Zugriff darauf war ein Absturz, der nur auf sich warten ließ.
## Der Rückfall auf `current_scene` deckt Knoten ab, die zur Laufzeit ohne
## `owner` erzeugt wurden.
func _owning_scene_path() -> String:
	if owner != null and not owner.scene_file_path.is_empty():
		return owner.scene_file_path
	var current: Node = get_tree().current_scene
	if current != null and not current.scene_file_path.is_empty():
		return current.scene_file_path
	return ""


func _light_pillar() -> void:
	if _pillar == null:
		return
	var material: StandardMaterial3D = _pillar.get_surface_override_material(0) as StandardMaterial3D
	if material == null:
		material = StandardMaterial3D.new()
		_pillar.set_surface_override_material(0, material)
	material.emission_enabled = true
	material.emission = LIT_COLOR
	material.emission_energy_multiplier = 1.5
