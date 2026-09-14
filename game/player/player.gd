class_name Player
extends CharacterBody3D
## Third-Person-Player-Controller: Bewegung, Sprung, Kamera-Anbindung,
## Nahkampf, Schadensannahme, Block, Tod/Respawn.
##
## Benutzt nur den vorhandenen Vertrag (GameState, EventBus, HitBox, HurtBox)
## und ändert ihn nicht.

const SWORD_ITEM: String = "sword_ed25519"
const SHIELD_ITEM: String = "shield_tls"

# --- Bewegung ----------------------------------------------------------------
const WALK_SPEED: float = 4.5
const SPRINT_SPEED: float = 7.5
const ATTACK_MOVE_FACTOR: float = 0.3
const BLOCK_MAX_SPEED: float = 1.5
## Reaktionszeit bis Zielgeschwindigkeit erreicht ist (move_toward-Rampe).
const ACCEL_TIME: float = 0.12
const JUMP_HEIGHT: float = 1.2
const VISUAL_TURN_SPEED: float = 10.0

# --- Angriff -------------------------------------------------------------
const ATTACK_WINDUP: float = 0.10
const ATTACK_ACTIVE: float = 0.18
const ATTACK_RECOVER: float = 0.25
const HITSTOP_DURATION: float = 0.08

# --- Schaden / Tod ---------------------------------------------------------
const IFRAME_DURATION: float = 0.8
const IFRAME_BLINK_INTERVAL: float = 0.08
const KNOCKBACK_STRENGTH: float = 6.0
const RESPAWN_DELAY: float = 1.2
const FALL_DEATH_Y: float = -50.0

## Wie lange ein Tastendruck gemerkt wird, bis er ausgeführt werden kann.
## 0,15 s ist der übliche Bereich: lang genug, dass sich nichts verschluckt
## anfühlt, kurz genug, dass keine ungewollten Aktionen nachfeuern.
const INPUT_BUFFER_TIME: float = 0.15

enum AttackPhase { NONE, WINDUP, ACTIVE, RECOVER }

@onready var _visual: Node3D = $Visual
@onready var _sword_mesh: MeshInstance3D = $Visual/SwordPivot/SwordMesh
@onready var _sword_pivot: Node3D = $Visual/SwordPivot
@onready var _hit_box: HitBox = $Visual/SwordPivot/HitBox
@onready var _hurt_box: HurtBox = $HurtBox
@onready var _camera_rig: Node3D = $CameraRig
@onready var _interact_range: Area3D = $InteractRange

var _control_enabled: bool = true

var _attack_phase: AttackPhase = AttackPhase.NONE
var _attack_timer: float = 0.0

# Eigene Flankenerkennung statt Input.is_action_just_pressed, weil Letzteres an
# einen echten Frame-Wechsel gebunden ist und in den Tests (direkte Aufrufe von
# _physics_process mit festem Delta) nicht zurückgesetzt wird.
#
# Zwei Regeln, beide nötig:
#
# 1. Der gedrückt/nicht-gedrückt-Zustand wird in JEDEM Physikschritt
#    aktualisiert, auch wenn die Aktion gerade unmöglich ist. Hängt die
#    Aktualisierung an einer Bedingung (nur am Boden, nur in Phase NONE),
#    bleibt der alte Zustand stehen und Tastendrücke verschwinden.
#
# 2. Eine erkannte Flanke wird GEPUFFERT statt sofort verworfen. Ohne Puffer
#    verfällt jeder Druck, der im falschen Moment kommt: Angriff während der
#    Nachziehphase oder Sprung kurz vor der Landung. Das fühlt sich für den
#    Spieler wie verschluckte Eingaben an, obwohl er gedrückt hat. Der Puffer
#    ist zugleich die Grundlage für Angriffsketten.
var _attack_was_pressed: bool = false
var _jump_was_pressed: bool = false
var _jump_buffer: float = 0.0
var _attack_buffer: float = 0.0

var _hitstop_timer: float = 0.0

var _invulnerable: bool = false
var _iframe_timer: float = 0.0
var _iframe_blink_timer: float = 0.0

var _respawn_timer: float = -1.0

var _facing_angle: float = 0.0


func _ready() -> void:
	_hurt_box.hit_received.connect(_on_hurt_box_hit_received)
	_hit_box.hit_confirmed.connect(_on_hit_box_hit_confirmed)
	EventBus.player_died.connect(_on_player_died)
	EventBus.inventory_changed.connect(_update_sword_visibility)
	_update_sword_visibility()
	_ensure_fallback_checkpoint()


## Sichert einen Rückfallpunkt, falls die Welt noch keinen Checkpoint gesetzt hat.
##
## Ohne das zeigt GameState.checkpoint_position auf (0,0,0). Sowohl die
## Absturzsicherung als auch der Respawn würden den Spieler dann dorthin
## setzen — liegt da kein Boden, fällt er endlos und die Absturzsicherung
## feuert immer wieder. Die eigene Startposition ist der einzige Punkt, von dem
## wir zum Zeitpunkt _ready sicher wissen, dass die Welt ihn vorgesehen hat.
func _ensure_fallback_checkpoint() -> void:
	if not GameState.checkpoint_scene.is_empty():
		return
	var scene_path: String = ""
	var current: Node = get_tree().current_scene
	if current != null:
		scene_path = current.scene_file_path
	GameState.set_checkpoint("player_spawn", scene_path, global_position)


func _physics_process(delta: float) -> void:
	# Immer zuerst und immer unbedingt: sonst verfallen Tastendrücke, die
	# während Hit-Stop, Respawn oder eines laufenden Angriffs erfolgen.
	_update_input_edges(delta)

	if _hitstop_timer > 0.0:
		_hitstop_timer -= delta
		return

	if _respawn_timer >= 0.0:
		_advance_respawn(delta)
		return

	_process_iframes(delta)
	_process_attack(delta)
	_update_sword_swing()
	_apply_gravity_and_jump(delta)
	_apply_horizontal_movement(delta)
	move_and_slide()
	_check_fall_safety()

# --- Bewegung ----------------------------------------------------------------

func _apply_gravity_and_jump(delta: float) -> void:
	var gravity: float = _gravity()
	if is_on_floor():
		if velocity.y < 0.0:
			velocity.y = 0.0
		if _control_enabled and _wants_jump():
			velocity.y = _jump_velocity(gravity)
	else:
		velocity.y -= gravity * delta


func _apply_horizontal_movement(delta: float) -> void:
	var input_vec: Vector2 = Vector2.ZERO
	if _control_enabled:
		input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	var cam_basis: Basis = _camera_rig.global_transform.basis
	var raw_dir: Vector3 = cam_basis * Vector3(input_vec.x, 0.0, input_vec.y)
	raw_dir.y = 0.0
	if raw_dir.length_squared() > 0.0001:
		raw_dir = raw_dir.normalized()

	var target_speed: float = SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED
	if is_attacking():
		target_speed *= ATTACK_MOVE_FACTOR
	if is_blocking():
		target_speed = minf(target_speed, BLOCK_MAX_SPEED)
	if not _control_enabled:
		target_speed = 0.0

	var target_velocity: Vector3 = raw_dir * target_speed
	var horizontal: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	var accel: float = SPRINT_SPEED / ACCEL_TIME
	horizontal = horizontal.move_toward(target_velocity, accel * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	if _control_enabled and raw_dir.length_squared() > 0.0001:
		# atan2(-x, -z): Winkel 0 entspricht der Ruhehaltung des Visual-Knotens,
		# der laut Kontrakt nach -Z blickt.
		_facing_angle = atan2(-raw_dir.x, -raw_dir.z)
	var turn_t: float = clampf(delta * VISUAL_TURN_SPEED, 0.0, 1.0)
	_visual.rotation.y = lerp_angle(_visual.rotation.y, _facing_angle, turn_t)


func _gravity() -> float:
	return float(ProjectSettings.get_setting("physics/3d/default_gravity", 24.0))


func _jump_velocity(gravity: float) -> float:
	return sqrt(2.0 * gravity * JUMP_HEIGHT)


## Aktualisiert Tastenflanken und lässt die Eingabepuffer ablaufen.
## Muss unbedingt in jedem Physikschritt laufen, unabhängig von Zustand,
## Hit-Stop, Respawn und Steuerungssperre.
func _update_input_edges(delta: float) -> void:
	_jump_buffer = maxf(0.0, _jump_buffer - delta)
	_attack_buffer = maxf(0.0, _attack_buffer - delta)

	var jump_now: bool = Input.is_action_pressed("jump")
	if jump_now and not _jump_was_pressed:
		_jump_buffer = INPUT_BUFFER_TIME
	_jump_was_pressed = jump_now

	var attack_now: bool = Input.is_action_pressed("attack")
	if attack_now and not _attack_was_pressed:
		_attack_buffer = INPUT_BUFFER_TIME
	_attack_was_pressed = attack_now


## Verbraucht einen gepufferten Sprungwunsch. Nach dem Verbrauch ist der Puffer
## leer, damit ein Druck nicht zwei Sprünge auslöst.
func _wants_jump() -> bool:
	if _jump_buffer <= 0.0:
		return false
	_jump_buffer = 0.0
	return true

# --- Angriff -------------------------------------------------------------

## Verbraucht einen gepufferten Angriffswunsch.
func _wants_attack() -> bool:
	if _attack_buffer <= 0.0:
		return false
	_attack_buffer = 0.0
	return true


func _process_attack(delta: float) -> void:
	if _attack_phase == AttackPhase.NONE:
		if _control_enabled and _wants_attack() and GameState.has_item(SWORD_ITEM):
			_attack_phase = AttackPhase.WINDUP
			_attack_timer = ATTACK_WINDUP
		return

	_attack_timer -= delta
	match _attack_phase:
		AttackPhase.WINDUP:
			if _attack_timer <= 0.0:
				_attack_phase = AttackPhase.ACTIVE
				_attack_timer = ATTACK_ACTIVE
				_hit_box.activate(ATTACK_ACTIVE)
		AttackPhase.ACTIVE:
			if _attack_timer <= 0.0:
				_attack_phase = AttackPhase.RECOVER
				_attack_timer = ATTACK_RECOVER
		AttackPhase.RECOVER:
			if _attack_timer <= 0.0:
				_attack_phase = AttackPhase.NONE
				_attack_timer = 0.0
		AttackPhase.NONE:
			pass


## Rein optische Schwing-Animation um den Drehpunkt SwordPivot.
func _update_sword_swing() -> void:
	var angle_deg: float = 0.0
	match _attack_phase:
		AttackPhase.WINDUP:
			angle_deg = lerpf(0.0, -40.0, 1.0 - (_attack_timer / ATTACK_WINDUP))
		AttackPhase.ACTIVE:
			angle_deg = lerpf(-40.0, 100.0, 1.0 - (_attack_timer / ATTACK_ACTIVE))
		AttackPhase.RECOVER:
			angle_deg = lerpf(100.0, 0.0, 1.0 - (_attack_timer / ATTACK_RECOVER))
		AttackPhase.NONE:
			angle_deg = 0.0
	_sword_pivot.rotation_degrees.x = angle_deg


func _on_hit_box_hit_confirmed(_target: HurtBox, _damage_quarters: int) -> void:
	# Engine-unabhängige Kurzpause nur für den Player, NICHT Engine.time_scale.
	_hitstop_timer = HITSTOP_DURATION


func _update_sword_visibility() -> void:
	_sword_mesh.visible = GameState.has_item(SWORD_ITEM)

# --- Schaden, Block, I-Frames ------------------------------------------------

func _on_hurt_box_hit_received(damage_quarters: int, from_position: Vector3) -> void:
	var actual_damage: int = damage_quarters
	if is_blocking():
		actual_damage = maxi(1, damage_quarters / 2)
	GameState.apply_damage(actual_damage)
	_apply_knockback(from_position)
	_start_iframes()


func _apply_knockback(from_position: Vector3) -> void:
	var away: Vector3 = global_position - from_position
	away.y = 0.0
	var knock_dir: Vector3 = away.normalized() if away.length_squared() > 0.0001 \
		else -_visual.global_transform.basis.z
	velocity.x = knock_dir.x * KNOCKBACK_STRENGTH
	velocity.z = knock_dir.z * KNOCKBACK_STRENGTH
	velocity.y = maxf(velocity.y, KNOCKBACK_STRENGTH * 0.4)


func _start_iframes() -> void:
	_invulnerable = true
	_hurt_box.set_vulnerable(false)
	_iframe_timer = IFRAME_DURATION
	_iframe_blink_timer = IFRAME_BLINK_INTERVAL


func _process_iframes(delta: float) -> void:
	if not _invulnerable:
		return
	_iframe_timer -= delta
	_iframe_blink_timer -= delta
	if _iframe_blink_timer <= 0.0:
		_iframe_blink_timer = IFRAME_BLINK_INTERVAL
		_visual.visible = not _visual.visible
	if _iframe_timer <= 0.0:
		_invulnerable = false
		_hurt_box.set_vulnerable(true)
		_visual.visible = true


func is_blocking() -> bool:
	return _control_enabled and Input.is_action_pressed("block") and GameState.has_item(SHIELD_ITEM)

# --- Tod / Respawn -----------------------------------------------------------

func _on_player_died() -> void:
	if _respawn_timer >= 0.0:
		return
	set_control_enabled(false)
	_attack_phase = AttackPhase.NONE
	_attack_timer = 0.0
	_respawn_timer = RESPAWN_DELAY


func _advance_respawn(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity() * delta
	velocity.x = 0.0
	velocity.z = 0.0
	move_and_slide()
	_respawn_timer -= delta
	if _respawn_timer <= 0.0:
		_respawn_timer = -1.0
		_respawn()


func _respawn() -> void:
	teleport_to(GameState.checkpoint_position)
	GameState.heal_full()
	EventBus.player_respawned.emit()
	set_control_enabled(true)

# --- Absturzsicherung --------------------------------------------------------

func _check_fall_safety() -> void:
	if global_position.y < FALL_DEATH_Y:
		teleport_to(GameState.checkpoint_position)

# --- Öffentliche API -----------------------------------------------------

func is_attacking() -> bool:
	return _attack_phase != AttackPhase.NONE


func is_invulnerable() -> bool:
	return _invulnerable


func teleport_to(position: Vector3) -> void:
	global_position = position
	velocity = Vector3.ZERO


func set_control_enabled(enabled: bool) -> void:
	_control_enabled = enabled


## Meldet nur, was in Reichweite ist. Kiste/Tür-Logik ist Sache anderer Systeme.
func get_interactable_in_range() -> Node3D:
	var candidates: Array[Node3D] = []
	for body: Node3D in _interact_range.get_overlapping_bodies():
		candidates.append(body)
	for area: Area3D in _interact_range.get_overlapping_areas():
		candidates.append(area)
	if candidates.is_empty():
		return null

	var nearest: Node3D = candidates[0]
	var nearest_dist: float = global_position.distance_squared_to(nearest.global_position)
	for candidate: Node3D in candidates:
		var dist: float = global_position.distance_squared_to(candidate.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = candidate
	return nearest
