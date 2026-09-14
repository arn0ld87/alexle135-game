extends CanvasLayer
class_name PauseMenu
## Pause-Menü: Hauptseite und Optionsseite.
##
## `pause` öffnet/schließt und steuert get_tree().paused. Läuft mit
## process_mode = PROCESS_MODE_ALWAYS, damit die Eingabe bei pausiertem Baum
## noch ankommt — sonst könnte man das Menü nie wieder schließen.
##
## Einstellungen liegen als JSON unter user://settings.json. Maus-Sensitivität
## wird nicht direkt an einen Player weitergereicht (den kennt dieses Menü
## nicht), sondern über mouse_sensitivity_changed emittiert.

signal mouse_sensitivity_changed(value: float)

const SETTINGS_PATH: String = "user://settings.json"
const SENSITIVITY_MIN: float = 0.0005
const SENSITIVITY_MAX: float = 0.008
const SENSITIVITY_DEFAULT: float = 0.002
const SENSITIVITY_STEP: float = 0.0001
const SAVE_SLOT: int = 0

@onready var _root: Control = $Root
@onready var _main_page: Control = $Root/MainPage
@onready var _options_page: Control = $Root/OptionsPage

@onready var _playtime_label: Label = $Root/MainPage/Margin/VBox/PlaytimeLabel
@onready var _continue_button: Button = $Root/MainPage/Margin/VBox/ContinueButton
@onready var _save_button: Button = $Root/MainPage/Margin/VBox/SaveButton
@onready var _load_button: Button = $Root/MainPage/Margin/VBox/LoadButton
@onready var _options_button: Button = $Root/MainPage/Margin/VBox/OptionsButton
@onready var _quit_button: Button = $Root/MainPage/Margin/VBox/QuitButton

@onready var _sensitivity_slider: HSlider = $Root/OptionsPage/Margin/VBox/SensitivitySlider
@onready var _fullscreen_check: CheckButton = $Root/OptionsPage/Margin/VBox/FullscreenCheck
@onready var _volume_slider: HSlider = $Root/OptionsPage/Margin/VBox/VolumeSlider
@onready var _back_button: Button = $Root/OptionsPage/Margin/VBox/BackButton

var _open: bool = false
var _settings: Dictionary = {
	"mouse_sensitivity": SENSITIVITY_DEFAULT,
	"fullscreen": false,
	"master_volume": 1.0,
}


func _ready() -> void:
	_root.visible = false
	_options_page.visible = false

	_sensitivity_slider.min_value = SENSITIVITY_MIN
	_sensitivity_slider.max_value = SENSITIVITY_MAX
	_sensitivity_slider.step = SENSITIVITY_STEP
	_volume_slider.min_value = 0.0
	_volume_slider.max_value = 1.0
	_volume_slider.step = 0.01

	load_settings()
	apply_settings()

	_continue_button.pressed.connect(close)
	_save_button.pressed.connect(_on_save_pressed)
	_load_button.pressed.connect(_on_load_pressed)
	_options_button.pressed.connect(_show_options_page)
	_quit_button.pressed.connect(_on_quit_pressed)
	_back_button.pressed.connect(_show_main_page)
	_sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	_volume_slider.value_changed.connect(_on_volume_changed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if _open:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()


func open() -> void:
	if _open:
		return
	_open = true
	_root.visible = true
	_show_main_page()
	get_tree().paused = true


func close() -> void:
	if not _open:
		return
	_open = false
	_root.visible = false
	get_tree().paused = false


func is_open() -> bool:
	return _open

# --- Seiten ------------------------------------------------------------

func _show_main_page() -> void:
	_main_page.visible = true
	_options_page.visible = false
	_refresh_main_page()


func _show_options_page() -> void:
	_main_page.visible = false
	_options_page.visible = true


func _refresh_main_page() -> void:
	var total_seconds: int = int(GameState.playtime_seconds)
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	_playtime_label.text = "%02d:%02d" % [minutes, seconds]
	_load_button.disabled = not SaveManager.has_save(SAVE_SLOT)

# --- Hauptseiten-Aktionen ------------------------------------------------

func _on_save_pressed() -> void:
	var ok: bool = SaveManager.save_game(SAVE_SLOT)
	EventBus.toast_requested.emit("Gespeichert" if ok else "Speichern fehlgeschlagen")
	_refresh_main_page()


func _on_load_pressed() -> void:
	if not SaveManager.has_save(SAVE_SLOT):
		return
	if SaveManager.load_game(SAVE_SLOT):
		close()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()

# --- Optionen --------------------------------------------------------------

func _on_sensitivity_changed(value: float) -> void:
	_settings["mouse_sensitivity"] = value
	mouse_sensitivity_changed.emit(value)
	_save_settings_to_disk()


func _on_fullscreen_toggled(pressed: bool) -> void:
	_settings["fullscreen"] = pressed
	_apply_window_mode(pressed)
	_save_settings_to_disk()


func _on_volume_changed(value: float) -> void:
	_settings["master_volume"] = value
	_apply_master_volume(value)
	_save_settings_to_disk()


func _apply_window_mode(fullscreen: bool) -> void:
	if DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	)


func _apply_master_volume(value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index("Master")
	if bus_index < 0:
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(value, 0.0001)))


## Überträgt den aktuellen Einstellungs-Zustand auf UI, Fenster und Audio-Bus.
func apply_settings() -> void:
	_sensitivity_slider.value = float(_settings.get("mouse_sensitivity", SENSITIVITY_DEFAULT))
	_fullscreen_check.button_pressed = bool(_settings.get("fullscreen", false))
	_volume_slider.value = float(_settings.get("master_volume", 1.0))
	mouse_sensitivity_changed.emit(_sensitivity_slider.value)
	_apply_window_mode(_fullscreen_check.button_pressed)
	_apply_master_volume(_volume_slider.value)


## Liest user://settings.json. Fehlt die Datei oder ist sie ungültig, bleiben
## die eingebauten Standardwerte bestehen.
func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return
	var data: Dictionary = parsed
	_settings["mouse_sensitivity"] = clampf(
		float(data.get("mouse_sensitivity", SENSITIVITY_DEFAULT)), SENSITIVITY_MIN, SENSITIVITY_MAX
	)
	_settings["fullscreen"] = bool(data.get("fullscreen", false))
	_settings["master_volume"] = clampf(float(data.get("master_volume", 1.0)), 0.0, 1.0)


func _save_settings_to_disk() -> void:
	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(_settings, "\t"))
	file.close()
