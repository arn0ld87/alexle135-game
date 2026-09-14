extends Panel
class_name DialogueBox
## Dialogbox unten im Bild mit Schreibmaschineneffekt (~45 Zeichen/Sekunde).
##
## `interact` bzw. ui_accept: läuft der Text noch, wird er sofort komplett
## angezeigt; ist er komplett, geht es zur nächsten Zeile. Nach der letzten
## Zeile schließt die Box und emittiert dialogue_finished. Solange ein Dialog
## läuft, ist is_active() true — der Player-Controller sperrt darüber die
## Steuerung.

const CHARS_PER_SECOND: float = 45.0

@onready var _speaker_label: Label = $Margin/VBox/SpeakerLabel
@onready var _body_label: Label = $Margin/VBox/BodyLabel

var _lines: PackedStringArray = []
var _line_index: int = -1
var _visible_chars: float = 0.0
var _active: bool = false


func _ready() -> void:
	visible = false
	set_process(false)


## Startet einen neuen Dialog. Bricht einen laufenden Dialog ab und beginnt
## von vorn — Aufrufer sind dafür verantwortlich, nicht mitten in einem
## laufenden Dialog erneut zu starten.
func start(speaker: String, lines: PackedStringArray) -> void:
	if lines.is_empty():
		return
	_lines = lines
	_speaker_label.text = speaker
	_line_index = -1
	_active = true
	visible = true
	_advance_to_next_line()


func advance() -> void:
	if not _active:
		return
	var full_text: String = _lines[_line_index]
	if int(_visible_chars) < full_text.length():
		_visible_chars = float(full_text.length())
		_body_label.text = full_text
		set_process(false)
		return
	_advance_to_next_line()


func is_active() -> bool:
	return _active


func current_line_index() -> int:
	return _line_index


func _advance_to_next_line() -> void:
	_line_index += 1
	if _line_index >= _lines.size():
		_close()
		return
	_visible_chars = 0.0
	_body_label.text = ""
	set_process(true)
	EventBus.dialogue_advanced.emit(_line_index)


func _close() -> void:
	_active = false
	visible = false
	_line_index = -1
	_lines = []
	set_process(false)
	EventBus.dialogue_finished.emit()


func _process(delta: float) -> void:
	if _line_index < 0 or _line_index >= _lines.size():
		set_process(false)
		return
	var full_text: String = _lines[_line_index]
	_visible_chars = minf(float(full_text.length()), _visible_chars + delta * CHARS_PER_SECOND)
	_body_label.text = full_text.substr(0, int(_visible_chars))
	if int(_visible_chars) >= full_text.length():
		set_process(false)


func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		advance()
		get_viewport().set_input_as_handled()
