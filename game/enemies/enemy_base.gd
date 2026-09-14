class_name Enemy
extends CharacterBody3D
## Erweiterbare Basisklasse für alle Gegner (Auftrag Abschnitt M1/M2).
##
## Ein neuer Gegnertyp erbt hiervon und überschreibt in seiner Szene nur die
## @export-Werte (Tempo, Reichweiten, Timings) sowie bei Bedarf `_perform_attack()`
## für eine eigene Angriffsform. Der Zustandsautomat selbst bleibt unverändert.
##
## Lebenspunkte sind lokal am Gegner (nicht in GameState — das ist reiner
## Spielerzustand). Ein Treffer der HurtBox zieht immer genau EINEN Punkt ab,
## unabhängig von `damage_quarters`. Das hält die M1-Balance simpel.
##
## Feste Kindknoten, die jede Gegner-Szene mitbringen muss:
##   HurtBox (res://scripts/systems/hurt_box.gd)
##   HitBox  (res://scripts/systems/hit_box.gd)
## Optional: ein Knoten "Visual/Telegraph" für die sichtbare Angriffs-Vorwarnung.

enum State { IDLE, CHASE, TELEGRAPH, ATTACK, COOLDOWN, HURT, DEAD }

## Dauer des Zurückweichens nach einem Treffer, bevor wieder verfolgt wird.
const HURT_DURATION: float = 0.18
## Geschwindigkeit des Knockbacks bei einem Treffer.
const HURT_KNOCKBACK_SPEED: float = 4.0
## Dauer des sichtbaren Einsinkens beim Tod, bevor der Knoten entfernt wird.
const DEATH_SINK_DURATION: float = 0.6
## Zielskalierung (y) am Ende des Einsinkens.
const DEATH_SINK_SCALE_Y: float = 0.1

## Stabile ID, z.B. "bitrot_slime_hub_01". Für EventBus.enemy_died und Saves.
@export var enemy_id: String = ""
## Treffer bis zum Tod. Lokale Lebenspunkte, nicht in GameState.
@export var max_health: int = 3
@export var move_speed: float = 2.4
## Ab dieser Distanz beginnt die Verfolgung.
@export var detect_radius: float = 8.0
## Ab dieser Distanz gibt der Gegner die Verfolgung auf. Bewusst größer als
## detect_radius (Hysterese) — sonst würde er an der Grenze flackern.
@export var forget_radius: float = 12.0
## Ab dieser Distanz beginnt der Angriff.
@export var attack_range: float = 1.6
## Sichtbare Vorwarnung VOR dem Schlag. Darf nie übersprungen werden.
@export var telegraph_time: float = 0.5
@export var attack_active_time: float = 0.2
@export var attack_cooldown: float = 1.1
@export var packets_reward: int = 5
## Wenn gesetzt, bleibt der Gegner nach dem Tod tot (persistent über Flags).
@export var death_flag_id: String = ""

@onready var _hurt_box: HurtBox = $HurtBox
@onready var _hit_box: HitBox = $HitBox
## Optional — nicht jede zukünftige Gegnerszene muss einen Telegraphen haben.
@onready var _telegraph: Node3D = get_node_or_null("Visual/Telegraph")

var _state: State = State.IDLE
var _state_timer: float = 0.0
var _health: int = 0
var _gravity: float = 24.0


func _ready() -> void:
	_health = max_health
	# Ein erledigter Gegner darf nach dem Laden eines Speicherstands nicht
	# wieder dastehen. Muss VOR dem Verbinden von Signalen passieren.
	if not death_flag_id.is_empty() and GameState.get_flag(death_flag_id):
		queue_free()
		return
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity", 24.0)
	_hurt_box.hit_received.connect(_on_hurt_box_hit_received)
	if _telegraph != null:
		_telegraph.visible = false


func _physics_process(delta: float) -> void:
	if _state == State.DEAD:
		return
	_apply_gravity(delta)
	match _state:
		State.IDLE:
			_process_idle()
		State.CHASE:
			_process_chase()
		State.TELEGRAPH:
			_process_telegraph(delta)
		State.ATTACK:
			_process_attack(delta)
		State.COOLDOWN:
			_process_cooldown(delta)
		State.HURT:
			_process_hurt(delta)
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= _gravity * delta

# --- Zustände ----------------------------------------------------------------

func _process_idle() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	if distance_to_player() < detect_radius:
		_set_state(State.CHASE)


func _process_chase() -> void:
	var player: Node3D = _get_player()
	if player == null:
		velocity.x = 0.0
		velocity.z = 0.0
		_set_state(State.IDLE)
		return

	var dist: float = global_position.distance_to(player.global_position)
	if dist <= attack_range:
		velocity.x = 0.0
		velocity.z = 0.0
		_set_state(State.TELEGRAPH)
		return
	if dist >= forget_radius:
		velocity.x = 0.0
		velocity.z = 0.0
		_set_state(State.IDLE)
		return

	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() > 0.001:
		var direction: Vector3 = to_player.normalized()
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		_face_player()
	else:
		velocity.x = 0.0
		velocity.z = 0.0


func _process_telegraph(delta: float) -> void:
	# Bewusst KEINE Prüfung auf den Spieler hier — die Vorwarnung läuft immer
	# vollständig ab, auch wenn der Spieler wegläuft. Genau das gibt ihm die
	# Chance zum Ausweichen.
	velocity.x = 0.0
	velocity.z = 0.0
	_state_timer -= delta
	if _state_timer <= 0.0:
		_set_state(State.ATTACK)


func _process_attack(delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	_state_timer -= delta
	if _state_timer <= 0.0:
		_set_state(State.COOLDOWN)


func _process_cooldown(delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	_state_timer -= delta
	if _state_timer <= 0.0:
		if distance_to_player() < detect_radius:
			_set_state(State.CHASE)
		else:
			_set_state(State.IDLE)


func _process_hurt(delta: float) -> void:
	_state_timer -= delta
	if _state_timer <= 0.0:
		velocity.x = 0.0
		velocity.z = 0.0
		_set_state(State.CHASE)


func _set_state(new_state: State) -> void:
	if _state == new_state:
		return
	_state = new_state
	match new_state:
		State.TELEGRAPH:
			_state_timer = telegraph_time
			# Beim Eintritt in die Vorwarnung wird die Richtung EINMAL festgelegt
			# und danach nicht mehr korrigiert. Deshalb ist Ausweichen überhaupt
			# möglich: wer sich während der Vorwarnung um den Gegner herumbewegt,
			# steht beim Schlag nicht mehr in der Schlagrichtung.
			_face_player()
			if _telegraph != null:
				_telegraph.visible = true
		State.ATTACK:
			_state_timer = attack_active_time
			if _telegraph != null:
				_telegraph.visible = false
			_perform_attack()
		State.COOLDOWN:
			_state_timer = attack_cooldown
		State.HURT:
			_state_timer = HURT_DURATION
		_:
			_state_timer = 0.0


## Angriffsform. Standard: HitBox einmalig für `attack_active_time` aktivieren.
## Ein neuer Gegnertyp mit eigener Angriffsform überschreibt nur diese Methode.
func _perform_attack() -> void:
	_hit_box.activate(attack_active_time)

# --- Schaden und Tod -----------------------------------------------------------

func _on_hurt_box_hit_received(_damage_quarters: int, from_position: Vector3) -> void:
	if is_dead():
		return
	_health -= 1

	var direction: Vector3 = global_position - from_position
	direction.y = 0.0
	if direction.length() > 0.001:
		direction = direction.normalized()
		velocity.x = direction.x * HURT_KNOCKBACK_SPEED
		velocity.z = direction.z * HURT_KNOCKBACK_SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	if _health <= 0:
		_die()
		return
	_set_state(State.HURT)


func _die() -> void:
	_state = State.DEAD
	_state_timer = 0.0
	velocity = Vector3.ZERO
	_hurt_box.set_vulnerable(false)
	_hit_box.deactivate()
	collision_layer = 0
	collision_mask = 0
	GameState.add_packets(packets_reward)
	EventBus.enemy_died.emit(enemy_id)
	if not death_flag_id.is_empty():
		GameState.set_flag(death_flag_id)
	_play_death_sink()


func _play_death_sink() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale:y", DEATH_SINK_SCALE_Y, DEATH_SINK_DURATION)
	tween.tween_callback(queue_free)

# --- Öffentliche API (Tests und Debug) -----------------------------------------

func current_state() -> int:
	return _state


func health() -> int:
	return _health


func is_dead() -> bool:
	return _state == State.DEAD


## Nur für Tests und Debug. Setzt den Zustand ohne Ein-/Austritts-Seiteneffekte.
func force_state(state: int) -> void:
	_state = state as State


## Dreht den Körper um die Y-Achse zum Spieler.
##
## Nicht kosmetisch, sondern kampfentscheidend: Die HitBox der Gegnerszenen
## sitzt nach VORN versetzt (lokal -Z, siehe docs/ASSETS.md). Ohne diese Drehung
## schlägt ein Gegner immer in Richtung der Weltachse -Z, egal wo der Spieler
## steht — er verfolgt ihn dann korrekt, trifft aber nur zufällig.
func _face_player() -> void:
	var player: Node3D = _get_player()
	if player == null:
		return
	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() < 0.001:
		return
	var direction: Vector3 = to_player.normalized()
	# Vorn ist -Z: gesucht ist der Winkel, für den die gedrehte -Z-Achse
	# (-sin y, 0, -cos y) auf `direction` zeigt.
	rotation.y = atan2(-direction.x, -direction.z)


## INF, wenn kein Knoten der Gruppe "player" existiert — der Normalfall in
## Unit-Tests. Der Gegner darf dabei nicht abstürzen.
func distance_to_player() -> float:
	var player: Node3D = _get_player()
	if player == null:
		return INF
	return global_position.distance_to(player.global_position)


func _get_player() -> Node3D:
	if not is_inside_tree():
		return null
	return get_tree().get_first_node_in_group("player") as Node3D
