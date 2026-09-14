extends Node
## Einstiegspunkt (main_scene). Entscheidet, was als Erstes geladen wird.
##
## Warum eine eigene Boot-Szene: Autoloads sind hier garantiert initialisiert,
## und der Headless-Smoke-Test (`godot --headless --quit-after 1`) kann das
## Projekt hochfahren, ohne dass eine Spielwelt mit Physik gestartet wird.

## Wird im Headless-Modus NICHT geladen, damit der Smoke-Test schnell und
## ohne Rendering-Abhängigkeiten durchläuft.
const FIRST_SCENE: String = "res://scenes/hub.tscn"


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("[boot] headless: Autoloads ok, überspringe Szenenwechsel")
		_verify_autoloads()
		return

	if not ResourceLoader.exists(FIRST_SCENE):
		push_error("[boot] Startszene fehlt: %s" % FIRST_SCENE)
		return

	get_tree().change_scene_to_file(FIRST_SCENE)


## Minimaler Selbsttest der Autoloads. Läuft auch headless und macht
## kaputte Verdrahtung sofort im CI-Log sichtbar.
func _verify_autoloads() -> void:
	var problems: PackedStringArray = []

	if GameState.max_health_quarters() != GameState.START_HEARTS * GameState.QUARTERS_PER_HEART:
		problems.append("GameState: max_health_quarters falsch")
	if not GameState.is_alive():
		problems.append("GameState: startet nicht lebendig")
	if SaveManager.SAVE_VERSION < 1:
		problems.append("SaveManager: SAVE_VERSION ungültig")
	if not EventBus.has_signal("health_changed"):
		problems.append("EventBus: health_changed fehlt")

	if problems.is_empty():
		print("[boot] Autoload-Selbsttest ok")
	else:
		for p: String in problems:
			push_error("[boot] %s" % p)
