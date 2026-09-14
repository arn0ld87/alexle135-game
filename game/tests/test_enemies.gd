extends Node
## Tests für die Gegner (Basisklasse + Bitrot-Schleim) und den Kampfkontrakt
## HitBox/HurtBox — Auftrag M1.
##
## Baut für Verfolgungs-/Angriffstests einen minimalen Player-Ersatz
## (CharacterBody3D, Layer "player", Gruppe "player", HurtBox) statt
## game/player/*, das liegt bei einem anderen Entwickler in Arbeit.

const BITROT_SLIME_SCENE: PackedScene = preload("res://enemies/bitrot_slime.tscn")

var _runner: Object = null

# Für Test 11 (enemy_died genau einmal) — bewusst Member-Felder statt einer
# lokalen Lambda-Closure, die nur eine KOPIE einer lokalen Variable mutieren
# würde.
var _enemy_died_count: int = 0
var _last_enemy_died_id: String = ""

# Für Test 13 (Kampfkontrakt), aus demselben Grund.
var _contract_hit_count: int = 0
var _contract_confirmed_count: int = 0


func set_runner(runner: Object) -> void:
	_runner = runner


## Minimaler Player-Ersatz (Gruppe "player", Layer 2, mit HurtBox).
func _make_player() -> CharacterBody3D:
	var body: CharacterBody3D = CharacterBody3D.new()
	body.collision_layer = 2
	body.collision_mask = 0
	body.add_to_group("player")
	var shape: CollisionShape3D = CollisionShape3D.new()
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.6
	shape.shape = capsule
	body.add_child(shape)

	var hurt_box: HurtBox = HurtBox.new()
	hurt_box.collision_layer = 2
	var hurt_shape: CollisionShape3D = CollisionShape3D.new()
	var hurt_capsule: CapsuleShape3D = CapsuleShape3D.new()
	hurt_capsule.radius = 0.3
	hurt_capsule.height = 1.6
	hurt_shape.shape = hurt_capsule
	hurt_box.add_child(hurt_shape)
	body.add_child(hurt_box)
	return body


func _on_enemy_died(enemy_id: String) -> void:
	_enemy_died_count += 1
	_last_enemy_died_id = enemy_id


func _on_contract_hurt_box_hit(_damage_quarters: int, _from_position: Vector3) -> void:
	_contract_hit_count += 1


func _on_contract_hit_confirmed(_target: HurtBox, _damage_quarters: int) -> void:
	_contract_confirmed_count += 1


# --- 1. Szene laedt fehlerfrei, auch ohne Player -----------------------------

func test_szene_laedt_und_instanziiert_ohne_player() -> void:
	var slime: BitrotSlime = BITROT_SLIME_SCENE.instantiate() as BitrotSlime
	_runner.assert_true(slime != null, "instanziiert")
	add_child(slime)
	slime.queue_free()


# --- 2. Startwerte -----------------------------------------------------------

func test_startwerte() -> void:
	var slime: BitrotSlime = BITROT_SLIME_SCENE.instantiate() as BitrotSlime
	add_child(slime)
	_runner.assert_eq(slime.health(), 3, "Startgesundheit")
	_runner.assert_false(slime.is_dead(), "startet lebendig")
	_runner.assert_eq(slime.current_state(), Enemy.State.IDLE, "startet in IDLE")
	slime.queue_free()


# --- 3. Ohne Player bleibt IDLE, distance_to_player() ist INF ----------------

func test_ohne_player_bleibt_idle_und_distanz_ist_inf() -> void:
	var slime: BitrotSlime = BITROT_SLIME_SCENE.instantiate() as BitrotSlime
	add_child(slime)
	slime._physics_process(0.1)
	_runner.assert_eq(slime.current_state(), Enemy.State.IDLE, "bleibt IDLE ohne Spieler")
	_runner.assert_eq(slime.distance_to_player(), INF, "Distanz ist INF ohne Spieler")
	slime.queue_free()


# --- 4. Player innerhalb detect_radius -> CHASE ------------------------------

func test_player_innerhalb_detect_radius_wechselt_zu_chase() -> void:
	var slime: BitrotSlime = BITROT_SLIME_SCENE.instantiate() as BitrotSlime
	add_child(slime)
	var player: CharacterBody3D = _make_player()
	add_child(player)
	player.global_position = Vector3(5.0, 0.0, 0.0)  # < detect_radius(8.0), > attack_range(1.6)

	slime._physics_process(0.1)
	_runner.assert_eq(slime.current_state(), Enemy.State.CHASE, "wechselt zu CHASE")

	player.free()
	slime.queue_free()


# --- 5. Player ausserhalb forget_radius -> zurueck zu IDLE -------------------

func test_player_ausserhalb_forget_radius_wechselt_zu_idle() -> void:
	var slime: BitrotSlime = BITROT_SLIME_SCENE.instantiate() as BitrotSlime
	add_child(slime)
	slime.force_state(Enemy.State.CHASE)
	var player: CharacterBody3D = _make_player()
	add_child(player)
	player.global_position = Vector3(20.0, 0.0, 0.0)  # > forget_radius(12.0)

	slime._physics_process(0.1)
	_runner.assert_eq(slime.current_state(), Enemy.State.IDLE, "faellt zurueck nach IDLE")

	player.free()
	slime.queue_free()


# --- 6. Player in attack_range -> TELEGRAPH, Telegraph sichtbar -------------

func test_player_in_attack_range_wechselt_zu_telegraph() -> void:
	var slime: BitrotSlime = BITROT_SLIME_SCENE.instantiate() as BitrotSlime
	add_child(slime)
	var player: CharacterBody3D = _make_player()
	add_child(player)
	player.global_position = Vector3(1.0, 0.0, 0.0)  # < attack_range(1.6)

	slime._physics_process(0.1)  # IDLE -> CHASE
	slime._physics_process(0.1)  # CHASE -> TELEGRAPH
	_runner.assert_eq(slime.current_state(), Enemy.State.TELEGRAPH, "wechselt zu TELEGRAPH")
	var telegraph: Node3D = slime.get_node("Visual/Telegraph")
	_runner.assert_true(telegraph.visible, "Telegraph-Knoten ist sichtbar")

	player.free()
	slime.queue_free()


# --- 7. Telegraph-Phase wird nicht uebersprungen -----------------------------

func test_telegraph_phase_wird_nicht_uebersprungen() -> void:
	var slime: BitrotSlime = BITROT_SLIME_SCENE.instantiate() as BitrotSlime
	add_child(slime)
	var player: CharacterBody3D = _make_player()
	add_child(player)
	player.global_position = Vector3(1.0, 0.0, 0.0)

	slime._physics_process(0.1)  # IDLE -> CHASE
	slime._physics_process(0.1)  # CHASE -> TELEGRAPH
	var hit_box: HitBox = slime.get_node("HitBox") as HitBox
	_runner.assert_false(hit_box.is_active(), "HitBox direkt nach TELEGRAPH-Eintritt noch nicht aktiv")

	slime._physics_process(slime.telegraph_time + 0.01)  # TELEGRAPH -> ATTACK
	_runner.assert_true(hit_box.is_active(), "HitBox nach Ablauf der Telegraph-Zeit aktiv")

	player.free()
	slime.queue_free()


# --- 8. Drei Treffer toeten den Gegner ---------------------------------------

func test_drei_treffer_toeten_den_gegner() -> void:
	var slime: BitrotSlime = BITROT_SLIME_SCENE.instantiate() as BitrotSlime
	add_child(slime)
	var hurt_box: HurtBox = slime.get_node("HurtBox") as HurtBox
	var from_position: Vector3 = slime.global_position + Vector3(1.0, 0.0, 0.0)

	hurt_box.receive_hit(2, from_position)
	_runner.assert_eq(slime.health(), 2, "erster Treffer")
	_runner.assert_false(slime.is_dead(), "nach erstem Treffer noch am Leben")

	hurt_box.receive_hit(2, from_position)
	_runner.assert_eq(slime.health(), 1, "zweiter Treffer")
	_runner.assert_false(slime.is_dead(), "nach zweitem Treffer noch am Leben")

	hurt_box.receive_hit(2, from_position)
	_runner.assert_eq(slime.health(), 0, "dritter Treffer toetet")
	_runner.assert_true(slime.is_dead(), "gilt jetzt als tot")

	slime.queue_free()


# --- 9. Toter Gegner nimmt keinen Schaden mehr und greift nicht an ----------

func test_toter_gegner_nimmt_keinen_schaden_und_greift_nicht_an() -> void:
	var slime: BitrotSlime = BITROT_SLIME_SCENE.instantiate() as BitrotSlime
	add_child(slime)
	var hurt_box: HurtBox = slime.get_node("HurtBox") as HurtBox
	var from_position: Vector3 = slime.global_position + Vector3(1.0, 0.0, 0.0)
	for _i: int in range(3):
		hurt_box.receive_hit(2, from_position)
	_runner.assert_true(slime.is_dead(), "vorbereitet: Gegner ist tot")

	var accepted: bool = hurt_box.receive_hit(2, from_position)
	_runner.assert_false(accepted, "HurtBox nimmt nach dem Tod keinen Treffer mehr an")
	_runner.assert_eq(slime.health(), 0, "Gesundheit bleibt bei 0")

	# Player direkt am Gegner platzieren — ohne den Todeszustand wuerde das
	# einen Angriff auslösen.
	var player: CharacterBody3D = _make_player()
	add_child(player)
	player.global_position = slime.global_position
	slime._physics_process(0.1)
	_runner.assert_eq(slime.current_state(), Enemy.State.DEAD, "bleibt DEAD, greift nicht mehr an")

	player.free()
	slime.queue_free()


# --- 10. Tod gibt Packets ----------------------------------------------------

func test_tod_gibt_packets() -> void:
	var slime: BitrotSlime = BITROT_SLIME_SCENE.instantiate() as BitrotSlime
	add_child(slime)
	var reward: int = slime.packets_reward
	var hurt_box: HurtBox = slime.get_node("HurtBox") as HurtBox
	var from_position: Vector3 = slime.global_position + Vector3(1.0, 0.0, 0.0)
	for _i: int in range(3):
		hurt_box.receive_hit(2, from_position)

	_runner.assert_eq(GameState.packets, reward, "Packets steigen um packets_reward")

	slime.queue_free()


# --- 11. Tod emittiert EventBus.enemy_died genau einmal ---------------------

func test_tod_emittiert_enemy_died_genau_einmal() -> void:
	_enemy_died_count = 0
	_last_enemy_died_id = ""
	EventBus.enemy_died.connect(_on_enemy_died)

	var slime: BitrotSlime = BITROT_SLIME_SCENE.instantiate() as BitrotSlime
	slime.enemy_id = "test_bitrot_slime_death_signal"
	add_child(slime)
	var hurt_box: HurtBox = slime.get_node("HurtBox") as HurtBox
	var from_position: Vector3 = slime.global_position + Vector3(1.0, 0.0, 0.0)
	for _i: int in range(3):
		hurt_box.receive_hit(2, from_position)

	EventBus.enemy_died.disconnect(_on_enemy_died)
	_runner.assert_eq(_enemy_died_count, 1, "enemy_died genau einmal ausgeloest")
	_runner.assert_eq(_last_enemy_died_id, "test_bitrot_slime_death_signal", "enemy_died mit korrekter ID")

	slime.queue_free()


# --- 12. death_flag_id bereits gesetzt -> Gegner entfernt sich selbst -------

func atest_tod_flag_vorher_gesetzt_entfernt_gegner_beim_ready() -> void:
	GameState.set_flag("test_bitrot_slime_bereits_erledigt")
	var slime: BitrotSlime = BITROT_SLIME_SCENE.instantiate() as BitrotSlime
	slime.death_flag_id = "test_bitrot_slime_bereits_erledigt"
	add_child(slime)

	# Direkt danach prüfen, nicht nach echten Physik-Frames: queue_free()
	# markiert den Knoten sofort, gibt ihn aber wenig später im selben
	# Frame tatsächlich frei — nach einem echten Physik-Frame wäre die
	# Referenz bereits ungültig und jeder weitere Methodenaufruf ein Crash.
	_runner.assert_true(
		slime.is_queued_for_deletion(),
		"entfernt sich selbst, weil das Todes-Flag beim Laden schon gesetzt war"
	)
	await _runner.wait_physics_frames(1)


# --- 13. Kampfkontrakt-Integrationstest: HitBox trifft HurtBox über echte
#         Area3D-Ueberlappung -------------------------------------------------

func atest_kampfkontrakt_hitbox_trifft_hurtbox_ueber_area3d_ueberlappung() -> void:
	_contract_hit_count = 0
	_contract_confirmed_count = 0

	var hurt_box: HurtBox = HurtBox.new()
	hurt_box.collision_layer = 2
	hurt_box.collision_mask = 0
	var hurt_shape: CollisionShape3D = CollisionShape3D.new()
	var hurt_sphere: SphereShape3D = SphereShape3D.new()
	hurt_sphere.radius = 0.5
	hurt_shape.shape = hurt_sphere
	hurt_box.add_child(hurt_shape)
	hurt_box.hit_received.connect(_on_contract_hurt_box_hit)
	add_child(hurt_box)

	var hit_box: HitBox = HitBox.new()
	hit_box.collision_layer = 32
	hit_box.collision_mask = 2
	hit_box.damage_quarters = 2
	var hit_shape: CollisionShape3D = CollisionShape3D.new()
	var hit_sphere: SphereShape3D = SphereShape3D.new()
	hit_sphere.radius = 0.5
	hit_shape.shape = hit_sphere
	hit_box.add_child(hit_shape)
	hit_box.hit_confirmed.connect(_on_contract_hit_confirmed)
	add_child(hit_box)

	# a) beide an derselben Position, Ueberlappung entsteht VOR activate().
	hurt_box.global_position = Vector3.ZERO
	hit_box.global_position = Vector3.ZERO
	await _runner.wait_physics_frames(2)

	# b) activate() muss die bereits bestehende Ueberlappung sofort mitnehmen
	#    -> genau EIN Treffer.
	hit_box.activate()
	await _runner.wait_physics_frames(1)
	_runner.assert_eq(_contract_hit_count, 1, "genau ein Treffer trotz Ueberlappung vor activate()")
	_runner.assert_eq(_contract_confirmed_count, 1, "hit_confirmed genau einmal ausgeloest")

	# c) mehrere Physik-Frames waehrend derselben Aktivierung -> weiterhin nur EIN Treffer.
	await _runner.wait_physics_frames(3)
	_runner.assert_eq(_contract_hit_count, 1, "kein Schaden pro Frame waehrend derselben Aktivierung")

	# d) deactivate(), dann erneut activate() -> ein zweiter Treffer ist möglich.
	hit_box.deactivate()
	await _runner.wait_physics_frames(1)
	hit_box.activate()
	await _runner.wait_physics_frames(1)
	_runner.assert_eq(_contract_hit_count, 2, "zweite Aktivierung erzeugt einen zweiten Treffer")

	# e) set_vulnerable(false) -> activate() meldet keinen Treffer mehr.
	hit_box.deactivate()
	hurt_box.set_vulnerable(false)
	await _runner.wait_physics_frames(1)
	hit_box.activate()
	await _runner.wait_physics_frames(1)
	_runner.assert_eq(_contract_hit_count, 2, "kein weiterer Treffer nach set_vulnerable(false)")
	_runner.assert_eq(_contract_confirmed_count, 2, "hit_confirmed nicht ausgeloest, wenn unverwundbar")

	hurt_box.queue_free()
	hit_box.queue_free()


# --- 14. Der Gegner schlägt dorthin, wo der Spieler steht --------------------
# Regression: Die HitBox der Gegnerszene sitzt auf lokal z = -0,8. Der erste
# Zustandsautomat enthielt keine Drehung, also zeigte die Schlagrichtung immer
# nach Welt- -Z. Ein Spieler, der von +X kam, wurde verfolgt und angegriffen,
# konnte aber nicht getroffen werden. Die Tests 6 und 7 waren grün, weil sie
# nur den Zustandswechsel und is_active() prüfen, nicht die Trefferlage.

func test_hitbox_zeigt_beim_angriff_zum_spieler() -> void:
	for offset: Vector3 in [
		Vector3(1.2, 0.0, 0.0),   # Spieler östlich
		Vector3(-1.2, 0.0, 0.0),  # westlich
		Vector3(0.0, 0.0, 1.2),   # südlich (die Richtung, die vorher fehlschlug)
	]:
		var slime: BitrotSlime = BITROT_SLIME_SCENE.instantiate() as BitrotSlime
		add_child(slime)
		var player: CharacterBody3D = _make_player()
		add_child(player)
		player.global_position = offset

		slime._physics_process(0.1)  # IDLE -> CHASE
		slime._physics_process(0.1)  # CHASE -> TELEGRAPH

		var hit_shape: Node3D = slime.get_node("HitBox/CollisionShape3D") as Node3D
		var shape_distance: float = hit_shape.global_position.distance_to(player.global_position)
		var body_distance: float = slime.global_position.distance_to(player.global_position)
		# Die versetzte Schlagform muss näher am Spieler liegen als der Körper
		# selbst — sonst schlägt der Gegner an ihm vorbei.
		_runner.assert_true(shape_distance < body_distance,
			"Schlagform zeigt zum Spieler bei Versatz %s (Form %.2f m, Körper %.2f m)"
			% [offset, shape_distance, body_distance])

		player.free()
		slime.free()
