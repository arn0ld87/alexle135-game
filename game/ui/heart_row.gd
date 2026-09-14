extends Control
class_name HeartRow
## Herzenreihe: zeigt Gesundheit viertelherz-genau, selbst gezeichnet.
##
## Warum _draw() statt TextureRect: es gibt noch keine Texturen (kommen erst
## mit den echten Assets). Jedes Herz hat 5 Füllstufen (0/4 bis 4/4), als
## proportional gefüllter Block mit Rand dargestellt.

const HEART_SIZE: float = 28.0
const HEART_GAP: float = 4.0
const FLASH_DURATION: float = 0.15

const COLOR_EMPTY: Color = Color(0.223529, 0.184314, 0.141176)
const COLOR_FULL: Color = Color(1.0, 0.352941, 0.431373)
const COLOR_FLASH: Color = Color(1.0, 1.0, 1.0)
const COLOR_BORDER: Color = Color(0.172549, 0.141176, 0.109804)

var _max_hearts: int = GameState.START_HEARTS
var _current_quarters: int = GameState.START_HEARTS * GameState.QUARTERS_PER_HEART
var _flash_time_left: float = 0.0


func _ready() -> void:
	set_process(false)
	set_health(GameState.health_quarters, GameState.max_health_quarters())


func set_health(current_quarters: int, max_quarters: int) -> void:
	var previous_quarters: int = _current_quarters
	_max_hearts = maxi(1, ceili(float(max_quarters) / GameState.QUARTERS_PER_HEART))
	_current_quarters = clampi(current_quarters, 0, max_quarters)
	custom_minimum_size = Vector2(
		_max_hearts * HEART_SIZE + maxi(0, _max_hearts - 1) * HEART_GAP, HEART_SIZE
	)
	if _current_quarters < previous_quarters:
		_flash_time_left = FLASH_DURATION
		set_process(true)
	queue_redraw()


func heart_count() -> int:
	return _max_hearts


func filled_quarters() -> int:
	return _current_quarters


func _process(delta: float) -> void:
	_flash_time_left = maxf(0.0, _flash_time_left - delta)
	queue_redraw()
	if _flash_time_left <= 0.0:
		set_process(false)


func _draw() -> void:
	for i: int in range(_max_hearts):
		var start_quarters: int = i * GameState.QUARTERS_PER_HEART
		var filled_in_heart: int = clampi(
			_current_quarters - start_quarters, 0, GameState.QUARTERS_PER_HEART
		)
		var x: float = i * (HEART_SIZE + HEART_GAP)
		var full_rect: Rect2 = Rect2(x, 0.0, HEART_SIZE, HEART_SIZE)
		draw_rect(full_rect, COLOR_EMPTY)
		if filled_in_heart > 0:
			var fill_width: float = HEART_SIZE * float(filled_in_heart) / GameState.QUARTERS_PER_HEART
			var fill_color: Color = COLOR_FLASH if _flash_time_left > 0.0 else COLOR_FULL
			draw_rect(Rect2(x, 0.0, fill_width, HEART_SIZE), fill_color)
		draw_rect(full_rect, COLOR_BORDER, false, 1.0)
