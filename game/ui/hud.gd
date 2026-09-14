extends CanvasLayer
class_name HUD
## Spiel-HUD: Herzen, Packets, ausgerüstetes Item, Mini-Map-Platzhalter,
## Quest-Hinweis, Interaktions-Prompt, Dialogbox und Toast.
##
## Der HUD kennt weder Player noch Welt — er hört ausschließlich auf
## GameState/EventBus und aktualisiert seine Kinder. Er lässt sich als Kind
## in jede 3D-Szene hängen (layer = 10).

@onready var _heart_row: HeartRow = $HeartRow
@onready var _packets_label: Label = $PacketsLabel
@onready var _equipped_item_label: Label = $EquippedItemPanel/Label
@onready var _quest_hint_label: Label = $QuestHintLabel
@onready var _interaction_prompt: InteractionPrompt = $InteractionPrompt
@onready var _dialogue_box: DialogueBox = $DialogueBox
@onready var _toast: Toast = $Toast


func _ready() -> void:
	EventBus.health_changed.connect(_on_health_changed)
	EventBus.packets_changed.connect(_on_packets_changed)
	EventBus.item_equipped.connect(_on_item_equipped)
	EventBus.quest_started.connect(_on_quest_started)
	EventBus.quest_completed.connect(_on_quest_completed)
	EventBus.dialogue_requested.connect(_on_dialogue_requested)
	EventBus.dialogue_advanced.connect(_on_dialogue_advanced)
	EventBus.dialogue_finished.connect(_on_dialogue_finished)

	_refresh_from_game_state()

# --- Öffentliche API ---------------------------------------------------

func set_quest_hint(text: String) -> void:
	_quest_hint_label.text = text


func show_dialogue(speaker: String, lines: PackedStringArray) -> void:
	_dialogue_box.start(speaker, lines)


func is_dialogue_active() -> bool:
	return _dialogue_box.is_active()

# --- Initialer Zustand -------------------------------------------------

## Liest GameState direkt, damit der HUD sofort korrekt anzeigt und nicht
## erst auf das nächste Signal wartet (z.B. nach einem Ladevorgang).
func _refresh_from_game_state() -> void:
	_heart_row.set_health(GameState.health_quarters, GameState.max_health_quarters())
	_on_packets_changed(GameState.packets)
	_on_item_equipped(GameState.equipped_item)
	set_quest_hint(_find_active_quest_id())


func _find_active_quest_id() -> String:
	for quest_id: String in GameState.quests:
		if GameState.quest_state(quest_id) == "active":
			return quest_id
	return ""

# --- EventBus-Handler ----------------------------------------------------

func _on_health_changed(current_quarters: int, max_quarters: int) -> void:
	_heart_row.set_health(current_quarters, max_quarters)


func _on_packets_changed(total: int) -> void:
	_packets_label.text = "Packets: %d" % total


func _on_item_equipped(item_id: String) -> void:
	_equipped_item_label.text = item_id if not item_id.is_empty() else "—"


func _on_quest_started(quest_id: String) -> void:
	set_quest_hint(quest_id)


func _on_quest_completed(quest_id: String) -> void:
	if _quest_hint_label.text == quest_id:
		set_quest_hint("")


func _on_dialogue_requested(speaker: String, lines: PackedStringArray) -> void:
	show_dialogue(speaker, lines)


func _on_dialogue_advanced(_line_index: int) -> void:
	_interaction_prompt.set_suppressed(true)


func _on_dialogue_finished() -> void:
	_interaction_prompt.set_suppressed(false)
