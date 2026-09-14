extends Panel
class_name InteractionPrompt
## Interaktions-Hinweis unten mittig: Tastenhinweis "E" plus Zieltext.
##
## Blendet über EventBus.interaction_available / interaction_unavailable in
## bzw. aus (0.12 s). Wird zusätzlich stummgeschaltet, solange ein Dialog
## läuft — dafür ruft der HUD set_suppressed() auf, ein Dialog und der
## Interaktionshinweis sollen nie gleichzeitig sichtbar sein.

const FADE_DURATION: float = 0.12

@onready var _text_label: Label = $Margin/HBox/TextLabel

var _available: bool = false
var _suppressed: bool = false
var _tween: Tween = null


func _ready() -> void:
	modulate.a = 0.0
	EventBus.interaction_available.connect(_on_interaction_available)
	EventBus.interaction_unavailable.connect(_on_interaction_unavailable)


func _on_interaction_available(prompt_text: String) -> void:
	_available = true
	_text_label.text = prompt_text
	_update_visibility()


func _on_interaction_unavailable() -> void:
	_available = false
	_update_visibility()


func set_suppressed(suppressed: bool) -> void:
	if _suppressed == suppressed:
		return
	_suppressed = suppressed
	_update_visibility()


## Zielsichtbarkeit unabhängig von der laufenden Ein-/Ausblendanimation —
## für Tests, die den Zielzustand statt animierter Zwischenwerte prüfen.
func is_shown() -> bool:
	return _available and not _suppressed


func _update_visibility() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0 if is_shown() else 0.0, FADE_DURATION)
