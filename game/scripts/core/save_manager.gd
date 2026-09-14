extends Node
## Persistenz (Autoload "SaveManager").
##
## Format: JSON unter user://. Bewusst menschenlesbar und ohne Godot-Typen,
## damit ein Speicherstand auch außerhalb der Engine inspiziert und in Tests
## als Fixture geschrieben werden kann.
##
## Kompatibilität: SAVE_VERSION wird erhöht, sobald sich das Schema ändert.
## `_migrate` ist die einzige Stelle, an der alte Stände angepasst werden.

const SAVE_VERSION: int = 1
const SAVE_DIR: String = "user://saves"
const MAX_SLOTS: int = 3


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot]


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))


## Schreibt den aktuellen GameState. Gibt false bei I/O-Fehlern zurück,
## damit Aufrufer den Fehlschlag sichtbar machen können statt ihn zu schlucken.
func save_game(slot: int = 0) -> bool:
	if slot < 0 or slot >= MAX_SLOTS:
		push_error("SaveManager: ungültiger Slot %d" % slot)
		return false

	var payload: Dictionary = {
		"save_version": SAVE_VERSION,
		"saved_at_unix": int(Time.get_unix_time_from_system()),
		"state": GameState.to_dict(),
	}

	var file: FileAccess = FileAccess.open(slot_path(slot), FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: konnte Slot %d nicht schreiben (%d)"
			% [slot, FileAccess.get_open_error()])
		return false

	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	EventBus.game_saved.emit(slot)
	return true


## Lädt einen Slot in den GameState. Gibt false zurück, wenn der Slot fehlt
## oder unlesbar ist — der bestehende Zustand bleibt dann unangetastet.
func load_game(slot: int = 0) -> bool:
	if not has_save(slot):
		return false

	var file: FileAccess = FileAccess.open(slot_path(slot), FileAccess.READ)
	if file == null:
		push_error("SaveManager: konnte Slot %d nicht lesen" % slot)
		return false

	var text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_error("SaveManager: Slot %d enthält kein gültiges JSON" % slot)
		return false

	var payload: Dictionary = parsed
	var version: int = int(payload.get("save_version", 0))
	var state: Dictionary = payload.get("state", {})
	if state.is_empty():
		push_error("SaveManager: Slot %d hat keinen state-Block" % slot)
		return false

	state = _migrate(state, version)
	GameState.from_dict(state)
	EventBus.game_loaded.emit(slot)
	return true


func delete_save(slot: int) -> void:
	if has_save(slot):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(slot_path(slot)))


## Kurzinfo für ein Hauptmenü, ohne den laufenden Zustand zu überschreiben.
## Gibt ein leeres Dictionary zurück, wenn der Slot nicht existiert.
func peek_slot(slot: int) -> Dictionary:
	if not has_save(slot):
		return {}
	var file: FileAccess = FileAccess.open(slot_path(slot), FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return {}
	var payload: Dictionary = parsed
	var state: Dictionary = payload.get("state", {})
	return {
		"saved_at_unix": int(payload.get("saved_at_unix", 0)),
		"playtime_seconds": float(state.get("playtime_seconds", 0.0)),
		"max_hearts": int(state.get("max_hearts", GameState.START_HEARTS)),
		"checkpoint_id": str(state.get("checkpoint_id", "")),
	}


## Migriert einen alten state-Block auf SAVE_VERSION.
## Noch keine Migration nötig — Version 1 ist das Ausgangsformat.
func _migrate(state: Dictionary, from_version: int) -> Dictionary:
	if from_version == SAVE_VERSION:
		return state
	if from_version < 1:
		push_warning("SaveManager: Stand ohne Version, wird als v1 gelesen")
	if from_version > SAVE_VERSION:
		push_warning("SaveManager: Stand ist neuer (v%d) als diese Version (v%d)"
			% [from_version, SAVE_VERSION])
	return state
