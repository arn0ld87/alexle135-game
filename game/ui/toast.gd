extends Panel
class_name Toast
## Kurznachricht oben mittig. Reagiert auf toast_requested und item_acquired.
##
## Mehrere Meldungen stapeln sich nicht: sie landen in einer Warteschlange
## und werden nacheinander gezeigt, jede für HOLD_DURATION, danach Fade-out.

const HOLD_DURATION: float = 2.2
const FADE_DURATION: float = 0.2

@onready var _label: Label = $Margin/Label

var _queue: Array[String] = []
var _showing: bool = false
var _hold_timer: float = 0.0
var _tween: Tween = null


func _ready() -> void:
	modulate.a = 0.0
	set_process(false)
	EventBus.toast_requested.connect(_on_toast_requested)
	EventBus.item_acquired.connect(_on_item_acquired)


func _on_toast_requested(message: String) -> void:
	_enqueue(message)


func _on_item_acquired(item_id: String, _count: int) -> void:
	_enqueue("%s erhalten" % item_id)


func _enqueue(message: String) -> void:
	_queue.append(message)
	if not _showing:
		_show_next()


func _show_next() -> void:
	if _queue.is_empty():
		_showing = false
		return
	_showing = true
	_label.text = _queue.pop_front()
	if _tween != null and _tween.is_valid():
		_tween.kill()
	modulate.a = 1.0
	_hold_timer = HOLD_DURATION
	set_process(true)


func _process(delta: float) -> void:
	_hold_timer -= delta
	if _hold_timer <= 0.0:
		set_process(false)
		_tween = create_tween()
		_tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
		_tween.tween_callback(_show_next)


## Anzahl noch wartender Meldungen (die aktuell gezeigte nicht mitgezählt).
func queue_size() -> int:
	return _queue.size()


func current_text() -> String:
	return _label.text if _showing else ""


func is_showing() -> bool:
	return _showing
