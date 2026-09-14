extends Node3D
## Integrationsebene des Hubs.
##
## Diese Datei ist der Kleber zwischen Subsystemen, die einander bewusst NICHT
## kennen: Der Player weiß nicht, was eine Kiste ist. Die UI weiß nicht, dass es
## einen Player gibt. Interactables wissen nicht, wer sie benutzt. Jede dieser
## Trennungen ist beabsichtigt und wird hier zusammengeführt — und nur hier.
##
## Wer Gameplay-Logik in diese Datei schreibt, verlagert Verhalten aus den
## Systemen in die Szene. Dann ist es in der nächsten Szene wieder weg.

## Stabile ID des Start-Checkpoints.
const SPAWN_CHECKPOINT_ID: String = "hub_spawn"
## Erste Hauptquest laut docs/DESIGN.md Abschnitt 9.
const FIRST_QUEST_ID: String = "q_seite_down"

@onready var _player: Player = $Player
@onready var _hud: Node = $HUD
@onready var _pause_menu: Node = $PauseMenu
@onready var _camera_rig: Node3D = $Player/CameraRig

## Das Interactable, das gerade in Reichweite ist. null bedeutet: keins.
var _current_interactable: Interactable = null


func _ready() -> void:
	_establish_spawn_checkpoint()
	_connect_dialogue_lock()
	_connect_settings()
	_start_first_quest()


# --- Checkpoint ------------------------------------------------------------

## Setzt den Spawn als Checkpoint, falls noch keiner aus einem Speicherstand kommt.
##
## Wichtig für die Absturzsicherung: Der Player legt sich im Notfall selbst einen
## Rückfallpunkt an seiner Startposition an. Dieser hier ist der gewollte Fall —
## eine Position, von der die Welt weiß, dass dort Boden ist.
##
## Ein bestehender Checkpoint wird NICHT überschrieben, sonst würde das Laden
## eines Speicherstands den Fortschritt auf den Hub-Eingang zurücksetzen.
func _establish_spawn_checkpoint() -> void:
	var existing: String = GameState.checkpoint_id
	if existing != "" and existing != "player_spawn":
		return
	GameState.set_checkpoint(
		SPAWN_CHECKPOINT_ID,
		scene_file_path,
		HubBlockout.SPAWN_POSITION
	)


# --- Quest ---------------------------------------------------------------

func _start_first_quest() -> void:
	if GameState.quest_state(FIRST_QUEST_ID) == "inactive":
		GameState.start_quest(FIRST_QUEST_ID)
	if GameState.quest_state(FIRST_QUEST_ID) == "active":
		_set_quest_hint("Seite down — sprich mit AS")


func _set_quest_hint(text: String) -> void:
	if _hud.has_method("set_quest_hint"):
		_hud.call("set_quest_hint", text)


# --- Dialog sperrt die Steuerung -----------------------------------------

func _connect_dialogue_lock() -> void:
	EventBus.dialogue_requested.connect(_on_dialogue_requested)
	EventBus.dialogue_finished.connect(_on_dialogue_finished)


func _on_dialogue_requested(_speaker: String, _lines: PackedStringArray) -> void:
	_player.set_control_enabled(false)


func _on_dialogue_finished() -> void:
	# Nur freigeben, wenn der Player lebt. Stirbt er während eines Dialogs,
	# gehört die Steuerung dem Respawn und nicht dem Dialogende.
	if GameState.is_alive():
		_player.set_control_enabled(true)


# --- Einstellungen -------------------------------------------------------

func _connect_settings() -> void:
	if not _pause_menu.has_signal("mouse_sensitivity_changed"):
		return
	_pause_menu.connect("mouse_sensitivity_changed", _on_mouse_sensitivity_changed)
	# Beim Start den gespeicherten Wert übernehmen, nicht erst bei der
	# nächsten Änderung im Optionsmenü.
	if _pause_menu.has_method("load_settings"):
		_pause_menu.call("load_settings")


func _on_mouse_sensitivity_changed(value: float) -> void:
	# Dynamischer Zugriff: player_camera.gd trägt bewusst kein class_name,
	# es ist ein Szenen-lokales Skript und keine öffentliche API.
	_camera_rig.set("mouse_sensitivity", value)


# --- Interaktion ---------------------------------------------------------

func _physics_process(_delta: float) -> void:
	_refresh_interaction_target()


## Fragt jeden Physikschritt, was in Reichweite ist, und meldet Änderungen an die UI.
##
## Der Prompt wird nur bei einem WECHSEL gemeldet, nicht jeden Frame. Sonst würde
## die UI sechzigmal pro Sekunde dieselbe Einblendung neu anstoßen.
func _refresh_interaction_target() -> void:
	var found: Interactable = null

	var candidate: Node3D = _player.get_interactable_in_range()
	if candidate != null:
		var as_interactable: Interactable = candidate as Interactable
		if as_interactable != null and as_interactable.can_interact():
			found = as_interactable

	if found == _current_interactable:
		return

	_current_interactable = found
	if found != null:
		EventBus.interaction_available.emit(found.get_prompt())
	else:
		EventBus.interaction_unavailable.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	# Läuft ein Dialog, gehört die Taste der Dialogbox zum Weiterblättern.
	if _hud.has_method("is_dialogue_active") and bool(_hud.call("is_dialogue_active")):
		return
	if _current_interactable == null or not _current_interactable.can_interact():
		return
	_current_interactable.interact(_player)
	# Nach der Benutzung kann sich der Zustand geändert haben (Kiste leer,
	# Tür offen). Neu bewerten, damit der Prompt nicht stehen bleibt.
	_refresh_interaction_target()
