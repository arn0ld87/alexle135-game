class_name NpcDialogue
extends Interactable
## Ansprechbarer NPC. Anders als Kiste/Hebel ist er NICHT one_shot — man
## kann beliebig oft mit ihm sprechen, Quest-Fortschritt bestimmt nur, welche
## Zeilen gerade gesendet werden.

@export var speaker_name: String = "AS"
@export var lines: PackedStringArray = []
@export var lines_after_completion: PackedStringArray = []
@export var starts_quest_id: String = ""
@export var completes_quest_id: String = ""
@export var required_item_to_complete: String = ""


func _ready() -> void:
	one_shot = false
	super._ready()


func _perform_interaction(interactor: Node3D) -> void:
	_face_interactor(interactor)

	if not starts_quest_id.is_empty() and GameState.quest_state(starts_quest_id) == "inactive":
		GameState.start_quest(starts_quest_id)

	var use_completion_lines: bool = false
	if not completes_quest_id.is_empty():
		if GameState.quest_state(completes_quest_id) == "done":
			use_completion_lines = true
		elif required_item_to_complete.is_empty() or GameState.has_item(required_item_to_complete):
			# quest_completed darf nicht doppelt feuern — deshalb nur hier,
			# nie für eine bereits abgeschlossene Quest erneut aufgerufen.
			GameState.complete_quest(completes_quest_id)
			use_completion_lines = true

	var lines_to_send: PackedStringArray = lines_after_completion if use_completion_lines else lines
	if not lines_to_send.is_empty():
		EventBus.dialogue_requested.emit(speaker_name, lines_to_send)


## Dreht den NPC zum Interagierenden, ohne sich nach oben/unten zu neigen.
func _face_interactor(interactor: Node3D) -> void:
	var target: Vector3 = interactor.global_position
	target.y = global_position.y
	if target.is_equal_approx(global_position):
		return
	look_at(target, Vector3.UP)
