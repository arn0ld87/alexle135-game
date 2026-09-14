extends Node
## Tests für die 2D-Benutzeroberfläche (HUD, Herzen, Dialog, Interaktion,
## Toast, Pause-Menü).
##
## Deckt aus dem Auftrag ab: alle sechs Szenen laden, Viertelherz-Genauigkeit,
## Herzen nach Heart-Container, HUD ohne Player, Dialogbox-Lebenszyklus,
## Interaktions-Prompt-Sichtbarkeit, Pause-Menü inkl. Speichern/Laden.

const HUD_SCENE: String = "res://ui/hud.tscn"
const HEART_ROW_SCENE: String = "res://ui/heart_row.tscn"
const DIALOGUE_BOX_SCENE: String = "res://ui/dialogue_box.tscn"
const INTERACTION_PROMPT_SCENE: String = "res://ui/interaction_prompt.tscn"
const TOAST_SCENE: String = "res://ui/toast.tscn"
const PAUSE_MENU_SCENE: String = "res://ui/pause_menu.tscn"

var _runner: Object = null
var _dialogue_finished_count: int = 0


func set_runner(runner: Object) -> void:
	_runner = runner


func after_each() -> void:
	# Ein abgebrochener open()-Test darf die restliche Suite nicht hängen
	# lassen, und ein Speichertest darf keinen Stand in Slot 0 hinterlassen.
	get_tree().paused = false
	SaveManager.delete_save(0)


# --- 1. Alle sechs Szenen laden und instanziieren -----------------------

func test_alle_szenen_laden_ohne_fehler() -> void:
	var paths: PackedStringArray = [
		HUD_SCENE, HEART_ROW_SCENE, DIALOGUE_BOX_SCENE,
		INTERACTION_PROMPT_SCENE, TOAST_SCENE, PAUSE_MENU_SCENE,
	]
	for path: String in paths:
		var packed: PackedScene = load(path)
		_runner.assert_true(packed != null, "%s ist ladbar" % path)
		if packed == null:
			continue
		var instance: Node = packed.instantiate()
		_runner.assert_true(instance != null, "%s ist instanziierbar" % path)
		if instance == null:
			continue
		add_child(instance)
		instance.queue_free()


# --- 2. heart_row: Viertelherz-Genauigkeit -------------------------------

func test_heart_row_viertelherz_genauigkeit() -> void:
	var heart_row: HeartRow = (load(HEART_ROW_SCENE) as PackedScene).instantiate()
	add_child(heart_row)

	heart_row.set_health(16, 16)
	_runner.assert_eq(heart_row.filled_quarters(), 16, "16 von 16 Vierteln")
	_runner.assert_eq(heart_row.heart_count(), 4, "4 volle Herzen")

	heart_row.set_health(14, 16)
	_runner.assert_eq(heart_row.filled_quarters(), 14, "14 von 16 Vierteln")
	_runner.assert_eq(heart_row.heart_count(), 4, "weiterhin 4 Herzen (drei voll, ein halbes)")

	heart_row.set_health(0, 16)
	_runner.assert_eq(heart_row.filled_quarters(), 0, "0 von 16 Vierteln")
	_runner.assert_eq(heart_row.heart_count(), 4, "4 leere Herzen")

	heart_row.queue_free()


# --- 3. heart_row nach GameState.add_heart_container() -------------------

func test_heart_row_nach_heart_container() -> void:
	GameState.add_heart_container()
	var heart_row: HeartRow = (load(HEART_ROW_SCENE) as PackedScene).instantiate()
	add_child(heart_row)
	heart_row.set_health(GameState.health_quarters, GameState.max_health_quarters())
	_runner.assert_eq(heart_row.heart_count(), 5, "5 Herzen nach Heart-Container")
	heart_row.queue_free()


# --- 4. HUD zeigt Packets nach GameState.add_packets(137) ----------------

func test_hud_zeigt_packets() -> void:
	var hud: HUD = (load(HUD_SCENE) as PackedScene).instantiate()
	add_child(hud)
	GameState.add_packets(137)
	var label: Label = hud.get_node("PacketsLabel")
	_runner.assert_eq(label.text, "Packets: 137", "Packets-Text zeigt 137")
	hud.queue_free()


# --- 5. HUD reagiert auf health_changed, ohne dass ein Player existiert --

func test_hud_reagiert_auf_health_changed_ohne_player() -> void:
	var hud: HUD = (load(HUD_SCENE) as PackedScene).instantiate()
	add_child(hud)
	GameState.apply_damage(6)
	var heart_row: HeartRow = hud.get_node("HeartRow")
	_runner.assert_eq(heart_row.filled_quarters(), 10, "HUD-Herzreihe folgt GameState-Schaden")
	hud.queue_free()


# --- 6 + 7. dialogue_box: Lebenszyklus und dialogue_finished genau einmal -

func atest_dialogue_box_lebenszyklus_und_finished_einmal() -> void:
	var dialogue_box: DialogueBox = (load(DIALOGUE_BOX_SCENE) as PackedScene).instantiate()
	add_child(dialogue_box)

	# Ein lokal erfasster Zähler in einer Lambda würde nur eine Kopie
	# mutieren, nicht die äußere Variable — deshalb ein Feld plus
	# gebundene Methode statt einer Closure.
	_dialogue_finished_count = 0
	EventBus.dialogue_finished.connect(_on_dialogue_finished_test_hook)

	var lines: PackedStringArray = ["Hi.", "Ok.", "Ende."]
	dialogue_box.start("Fremder", lines)
	_runner.assert_true(dialogue_box.is_active(), "aktiv direkt nach start()")

	# Genug Frames abwarten, bis der Schreibmaschineneffekt jede (kurze)
	# Zeile fertig aufgedeckt hat — sonst würde advance() nur die laufende
	# Zeile komplettieren statt weiterzuschalten.
	for _i: int in range(lines.size()):
		await _runner.wait_physics_frames(60)
		dialogue_box.advance()

	_runner.assert_false(dialogue_box.is_active(), "inaktiv nach drei advance()-Aufrufen")
	_runner.assert_eq(_dialogue_finished_count, 1, "dialogue_finished genau einmal emittiert")

	EventBus.dialogue_finished.disconnect(_on_dialogue_finished_test_hook)
	dialogue_box.queue_free()


func _on_dialogue_finished_test_hook() -> void:
	_dialogue_finished_count += 1


# --- 8. interaction_prompt reagiert auf Verfügbarkeit ---------------------

func test_interaction_prompt_reagiert_auf_verfuegbarkeit() -> void:
	var prompt: InteractionPrompt = (load(INTERACTION_PROMPT_SCENE) as PackedScene).instantiate()
	add_child(prompt)

	_runner.assert_false(prompt.is_shown(), "initial nicht sichtbar")
	EventBus.interaction_available.emit("Kiste öffnen")
	_runner.assert_true(prompt.is_shown(), "sichtbar nach interaction_available")
	EventBus.interaction_unavailable.emit()
	_runner.assert_false(prompt.is_shown(), "unsichtbar nach interaction_unavailable")

	prompt.queue_free()


# --- 9. pause_menu: open()/close() steuern is_open() und Baum-Pause ------

func test_pause_menu_open_close() -> void:
	var pause_menu: PauseMenu = (load(PAUSE_MENU_SCENE) as PackedScene).instantiate()
	add_child(pause_menu)

	pause_menu.open()
	_runner.assert_true(pause_menu.is_open(), "is_open() nach open()")
	_runner.assert_true(get_tree().paused, "Baum pausiert nach open()")

	pause_menu.close()
	_runner.assert_false(pause_menu.is_open(), "is_open() nach close()")
	_runner.assert_false(get_tree().paused, "Baum nicht mehr pausiert nach close()")

	pause_menu.queue_free()


# --- 10. pause_menu: "Speichern" schreibt Stand, "Laden" wird verfügbar --

func test_pause_menu_speichern_und_laden() -> void:
	SaveManager.delete_save(0)
	var pause_menu: PauseMenu = (load(PAUSE_MENU_SCENE) as PackedScene).instantiate()
	add_child(pause_menu)
	pause_menu.open()

	var save_button: Button = pause_menu.get_node("Root/MainPage/Margin/VBox/SaveButton")
	save_button.pressed.emit()
	_runner.assert_true(SaveManager.has_save(0), "Speichern hat einen Stand in Slot 0 angelegt")

	var load_button: Button = pause_menu.get_node("Root/MainPage/Margin/VBox/LoadButton")
	_runner.assert_false(load_button.disabled, "Laden ist nach dem Speichern verfügbar")

	pause_menu.close()
	pause_menu.queue_free()
