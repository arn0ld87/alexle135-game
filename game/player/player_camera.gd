extends Node3D
## Third-Person-Kamerasteuerung. Sitzt als "CameraRig" im Player, hält als
## Kind eine SpringArm3D mit der eigentlichen Camera3D.
##
## Dieser Knoten selbst trägt die Yaw-Drehung (horizontal), die SpringArm3D
## trägt die Pitch-Drehung (vertikal). Die Kamerakollision (Shoulder-Cam)
## übernimmt die SpringArm3D selbst über ihren eingebauten Shapecast — hier
## wird bewusst kein eigenes Raycasting gebaut.

## Vom Optionsmenü später einstellbar.
@export var mouse_sensitivity: float = 0.0025
@export var gamepad_sensitivity: float = 3.0

const PITCH_MIN_DEG: float = -60.0
const PITCH_MAX_DEG: float = 25.0
## Rechter Stick: Joypad-Achsen 2 (X) und 3 (Y), siehe JOY_AXIS_RIGHT_*.
const GAMEPAD_DEADZONE: float = 0.2

@onready var _spring_arm: SpringArm3D = $SpringArm3D

var _yaw: float = 0.0
var _pitch: float = 0.0


func _ready() -> void:
	_yaw = rotation.y
	_pitch = _spring_arm.rotation.x
	# Headless-Tests haben keinen DisplayServer mit Fenster — CAPTURED würde
	# dort fehlschlagen bzw. ist sinnlos, deshalb die Prüfung.
	if DisplayServer.get_name() != "headless":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		_apply_look(-motion.relative.x * mouse_sensitivity, -motion.relative.y * mouse_sensitivity)


func _process(delta: float) -> void:
	var stick_x: float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var stick_y: float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	if absf(stick_x) < GAMEPAD_DEADZONE:
		stick_x = 0.0
	if absf(stick_y) < GAMEPAD_DEADZONE:
		stick_y = 0.0
	if stick_x != 0.0 or stick_y != 0.0:
		_apply_look(-stick_x * gamepad_sensitivity * delta, -stick_y * gamepad_sensitivity * delta)


## Dreht Yaw (dieser Knoten) und Pitch (SpringArm3D), Pitch begrenzt.
func _apply_look(yaw_delta: float, pitch_delta: float) -> void:
	_yaw += yaw_delta
	_pitch = clampf(_pitch + pitch_delta, deg_to_rad(PITCH_MIN_DEG), deg_to_rad(PITCH_MAX_DEG))
	rotation.y = _yaw
	_spring_arm.rotation.x = _pitch
