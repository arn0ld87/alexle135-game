extends Node
## Tests für den Third-Person-Player-Controller (game/player/player.gd/.tscn).
##
## Zeit wird nirgends real abgewartet: `_physics_process(delta)` wird direkt
## mit festem Delta aufgerufen, damit die Suite deterministisch und schnell
## bleibt (siehe Auftrag).

const PLAYER_SCENE_PATH: String = "res://player/player.tscn"
const FIXED_DT: float = 1.0 / 60.0

var _runner: Object = null


func set_runner(runner: Object) -> void:
	_runner = runner


func _make_player() -> Player:
	var scene: PackedScene = load(PLAYER_SCENE_PATH)
	var player: Player = scene.instantiate()
	add_child(player)
	return player


func _press_attack_for_one_frame(player: Player) -> void:
	Input.action_press("attack")
	player._physics_process(FIXED_DT)
	Input.action_release("attack")


# --- 1. Szene lädt ----------------------------------------------------------

func test_player_szene_laedt_und_instanziiert() -> void:
	var player: Player = _make_player()
	_runner.assert_true(player != null, "Player-Instanz vorhanden")
	_runner.assert_true(player.is_inside_tree(), "Player im Szenenbaum")
	player.queue_free()


# --- 2./3. Angriff nur mit Schwert -------------------------------------------

func test_ohne_schwert_kein_angriff() -> void:
	var player: Player = _make_player()
	_press_attack_for_one_frame(player)
	_runner.assert_false(player.is_attacking(), "kein Angriff ohne Schwert im Inventar")
	player.queue_free()


func test_mit_schwert_ist_angriff_moeglich() -> void:
	GameState.add_item("sword_ed25519", 1)
	var player: Player = _make_player()
	_press_attack_for_one_frame(player)
	_runner.assert_true(player.is_attacking(), "Angriff mit Schwert im Inventar möglich")
	player.queue_free()


# --- 4. Kein zweiter Angriff während laufendem Angriff -----------------------

func test_zweiter_angriff_waehrend_laufendem_startet_nicht() -> void:
	GameState.add_item("sword_ed25519", 1)
	var player: Player = _make_player()

	_press_attack_for_one_frame(player)
	_runner.assert_true(player.is_attacking(), "erster Angriff gestartet")

	# 6 weitere Schritte: Windup (0.10s) ist damit sicher durchlaufen, der
	# Angriff steckt jetzt im Active-Fenster (0.18s).
	for _i: int in range(6):
		player._physics_process(FIXED_DT)

	# Erneuter Druck MITTEN im laufenden Angriff — darf keinen Neustart lösen.
	_press_attack_for_one_frame(player)

	# 28 weitere Schritte (insgesamt 36 seit Angriffsbeginn ~ 0.6s). Die reguläre
	# Sequenz (0.10 + 0.18 + 0.25 = 0.53s) ist damit vorbei. Hätte der zweite
	# Druck neu gestartet, liefe der Angriff bis ~0.68s weiter und wäre hier
	# noch aktiv.
	for _i: int in range(28):
		player._physics_process(FIXED_DT)
	_runner.assert_false(player.is_attacking(),
		"Angriff nach regulärer Gesamtdauer beendet, kein verlängerter Neustart")

	player.queue_free()


# --- 5. I-Frames verhindern zweiten Treffer ----------------------------------

func test_iframes_verhindern_zweiten_treffer() -> void:
	var player: Player = _make_player()
	var hurt_box: HurtBox = player.get_node("HurtBox") as HurtBox
	var start_health: int = GameState.health_quarters

	var first_hit: bool = hurt_box.receive_hit(2, player.global_position + Vector3(1, 0, 0))
	_runner.assert_true(first_hit, "erster Treffer wird angenommen")
	_runner.assert_eq(GameState.health_quarters, start_health - 2, "Schaden nach erstem Treffer")
	_runner.assert_true(player.is_invulnerable(), "unverwundbar nach Treffer")

	var second_hit: bool = hurt_box.receive_hit(2, player.global_position + Vector3(1, 0, 0))
	_runner.assert_false(second_hit, "zweiter Treffer während I-Frames abgelehnt")
	_runner.assert_eq(GameState.health_quarters, start_health - 2,
		"keine weitere Gesundheit während I-Frames verloren")

	player.queue_free()


# --- 6. Blocken halbiert Schaden nur mit Schild ------------------------------

func test_blocken_halbiert_schaden_nur_mit_schild() -> void:
	var player: Player = _make_player()
	var hurt_box: HurtBox = player.get_node("HurtBox") as HurtBox

	Input.action_press("block")
	var health_vor_erstem_treffer: int = GameState.health_quarters
	hurt_box.receive_hit(4, player.global_position + Vector3(1, 0, 0))
	_runner.assert_eq(GameState.health_quarters, health_vor_erstem_treffer - 4,
		"voller Schaden trotz Blocken ohne Schild")
	Input.action_release("block")

	# I-Frames aus dem ersten Treffer deterministisch ablaufen lassen (0.8s).
	for _i: int in range(60):
		player._physics_process(FIXED_DT)
	_runner.assert_false(player.is_invulnerable(), "I-Frames nach 1s abgelaufen")

	GameState.add_item("shield_tls", 1)
	Input.action_press("block")
	var health_vor_zweitem_treffer: int = GameState.health_quarters
	hurt_box.receive_hit(4, player.global_position + Vector3(1, 0, 0))
	_runner.assert_eq(GameState.health_quarters, health_vor_zweitem_treffer - 2,
		"halbierter Schaden beim Blocken mit Schild")
	Input.action_release("block")

	player.queue_free()


# --- 7. teleport_to setzt Position exakt -------------------------------------

func test_teleport_to_setzt_position_exakt() -> void:
	var player: Player = _make_player()
	var ziel: Vector3 = Vector3(12.5, 3.0, -7.25)
	player.teleport_to(ziel)
	_runner.assert_almost_eq(player.global_position.x, ziel.x, 0.0001, "Teleport X")
	_runner.assert_almost_eq(player.global_position.y, ziel.y, 0.0001, "Teleport Y")
	_runner.assert_almost_eq(player.global_position.z, ziel.z, 0.0001, "Teleport Z")
	player.queue_free()


# --- 8. Absturzsicherung unter Y = -50 ---------------------------------------

func test_faellt_unter_y_minus_50_landet_auf_checkpoint() -> void:
	GameState.set_checkpoint("test_cp", "res://scenes/hub.tscn", Vector3(5, 1, 2))
	var player: Player = _make_player()
	var start_health: int = GameState.health_quarters

	player.teleport_to(Vector3(0, -60, 0))
	player._physics_process(FIXED_DT)

	_runner.assert_almost_eq(player.global_position.x, 5.0, 0.0001, "Checkpoint X nach Absturz")
	_runner.assert_almost_eq(player.global_position.y, 1.0, 0.0001, "Checkpoint Y nach Absturz")
	_runner.assert_almost_eq(player.global_position.z, 2.0, 0.0001, "Checkpoint Z nach Absturz")
	_runner.assert_eq(GameState.health_quarters, start_health, "kein Schaden durch Absturz")

	player.queue_free()


# --- 9. set_control_enabled(false) verhindert Bewegung -----------------------

func test_set_control_enabled_false_verhindert_bewegung() -> void:
	var player: Player = _make_player()
	player.set_control_enabled(false)

	Input.action_press("move_forward")
	for _i: int in range(30):
		player._physics_process(FIXED_DT)
	Input.action_release("move_forward")

	_runner.assert_almost_eq(player.velocity.x, 0.0, 0.01, "keine X-Geschwindigkeit bei Sperre")
	_runner.assert_almost_eq(player.velocity.z, 0.0, 0.01, "keine Z-Geschwindigkeit bei Sperre")
	_runner.assert_almost_eq(player.global_position.x, 0.0, 0.01, "Position X unverändert bei Sperre")
	_runner.assert_almost_eq(player.global_position.z, 0.0, 0.01, "Position Z unverändert bei Sperre")

	player.queue_free()


# --- 10. Regression: Eingabepuffer ------------------------------------------
# Gefunden im Review, nicht von den ursprünglichen Tests abgedeckt.
# Vorher verfiel jeder Tastendruck, der nicht genau im richtigen Moment kam:
# Angriff während Vorbereitung/Nachziehen und Sprung kurz vor der Landung
# wurden verschluckt, obwohl der Spieler gedrückt hatte.

func test_angriff_waehrend_nachziehphase_wird_gepuffert() -> void:
	GameState.add_item("sword_ed25519", 1)
	var player: Player = _make_player()

	_press_attack_for_one_frame(player)
	_runner.assert_true(player.is_attacking(), "erster Angriff läuft")

	# Der Angriff dauert 0,10 + 0,18 + 0,25 = 0,53 s. Bei 0,50 s ist er noch in
	# der Nachziehphase — ein Druck hier muss gemerkt werden, statt zu verfallen.
	var frames_to_late_recover: int = int(0.50 / FIXED_DT) - 1
	for _i: int in range(frames_to_late_recover):
		player._physics_process(FIXED_DT)
	_runner.assert_true(player.is_attacking(), "Angriff noch in der Nachziehphase")

	_press_attack_for_one_frame(player)

	# Auslaufen lassen, ohne die Taste erneut zu berühren.
	for _i: int in range(6):
		player._physics_process(FIXED_DT)

	_runner.assert_true(player.is_attacking(),
		"gepufferter Druck löst direkt den nächsten Angriff aus")
	player.queue_free()


func test_gepufferter_druck_verfaellt_nach_ablauf() -> void:
	GameState.add_item("sword_ed25519", 1)
	var player: Player = _make_player()

	# Druck, während kein Angriff möglich ist (Steuerung gesperrt), dann lange
	# warten: Der Puffer darf nicht unbegrenzt gültig bleiben, sonst feuert
	# eine alte Eingabe verspätet nach.
	player.set_control_enabled(false)
	_press_attack_for_one_frame(player)
	for _i: int in range(int(0.4 / FIXED_DT)):
		player._physics_process(FIXED_DT)

	player.set_control_enabled(true)
	player._physics_process(FIXED_DT)

	_runner.assert_false(player.is_attacking(),
		"abgelaufener Puffer löst keinen Angriff mehr aus")
	player.queue_free()


func test_ein_druck_loest_nur_einen_angriff_aus() -> void:
	GameState.add_item("sword_ed25519", 1)
	var player: Player = _make_player()

	_press_attack_for_one_frame(player)
	# Komplett auslaufen lassen (0,53 s), Taste bleibt unberührt.
	for _i: int in range(int(0.6 / FIXED_DT)):
		player._physics_process(FIXED_DT)

	_runner.assert_false(player.is_attacking(),
		"ein einzelner Druck erzeugt keinen zweiten Angriff")
	player.queue_free()


# --- 11. Regression: Checkpoint-Rückfallpunkt -------------------------------
# Ohne diesen Rückfall zeigte checkpoint_position auf (0,0,0). Absturzsicherung
# und Respawn hätten den Spieler dorthin gesetzt — ohne Boden an dieser Stelle
# fällt er endlos und die Sicherung feuert immer wieder.

func test_player_setzt_rueckfall_checkpoint_wenn_keiner_existiert() -> void:
	_runner.assert_true(GameState.checkpoint_scene.is_empty(), "Vorbedingung: kein Checkpoint")

	var player: Player = _make_player()

	_runner.assert_eq(GameState.checkpoint_id, "player_spawn", "Rückfallpunkt gesetzt")
	_runner.assert_false(GameState.checkpoint_scene.is_empty(), "Szenenpfad hinterlegt")
	player.queue_free()


func test_vorhandener_checkpoint_wird_nicht_ueberschrieben() -> void:
	GameState.set_checkpoint("echter_cp", "res://scenes/hub.tscn", Vector3(9, 2, 3))

	var player: Player = _make_player()

	_runner.assert_eq(GameState.checkpoint_id, "echter_cp", "bestehender Checkpoint bleibt")
	_runner.assert_almost_eq(GameState.checkpoint_position.x, 9.0, 0.0001,
		"Position des bestehenden Checkpoints unverändert")
	player.queue_free()
