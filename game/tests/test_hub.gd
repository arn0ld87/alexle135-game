extends Node
## Integrationstests der Hub-Szene — der eigentliche M1-Nachweis.
##
## Die anderen Testdateien prüfen Systeme einzeln. Hier wird geprüft, ob sie
## zusammen eine spielbare Szene ergeben. Das deckt die Punkte aus Auftrag
## Abschnitt 26 ab, die sich nur im Zusammenspiel zeigen:
##   - Player fällt nicht durch die Welt
##   - Kollisionen funktionieren
##   - Tür bleibt ohne Key geschlossen, Key öffnet sie
##   - Chest lässt sich nicht unendlich looten
##   - Checkpoints funktionieren
##
## Alles läuft headless. Die Szene enthält HUD und Pause-Menü als CanvasLayer;
## beide müssen sich ohne Anzeigegerät instanziieren lassen.

const HUB_PATH: String = "res://scenes/hub.tscn"

var _runner: Object = null
var _hub: Node3D = null


func set_runner(runner: Object) -> void:
	_runner = runner


func after_each() -> void:
	if _hub != null and is_instance_valid(_hub):
		_hub.queue_free()
	_hub = null


## Lädt den Hub und lässt die Physik einige Schritte laufen, damit der Player
## tatsächlich auf dem Boden aufsetzt.
func _load_hub() -> Node3D:
	var scene: PackedScene = load(HUB_PATH)
	if scene == null:
		_runner.fail("Hub-Szene nicht ladbar: %s" % HUB_PATH)
		return null
	_hub = scene.instantiate()
	add_child(_hub)
	return _hub


# --- Aufbau ---------------------------------------------------------------

func test_hub_szene_ist_ladbar() -> void:
	var scene: PackedScene = load(HUB_PATH)
	_runner.assert_true(scene != null, "Hub-Szene ladbar")
	_runner.assert_true(scene.can_instantiate(), "Hub-Szene instanziierbar")


func atest_hub_enthaelt_alle_m1_inhalte() -> void:
	var hub: Node3D = _load_hub()
	if hub == null:
		return
	await _runner.wait_physics_frames(4)

	# Jeder dieser Knoten trägt einen Punkt der M1-Liste aus Auftrag Abschnitt 22.
	var expected: PackedStringArray = [
		"WorldEnvironment", "Sun", "Blockout", "VpsTower", "Player", "HUD",
		"PauseMenu", "AS", "ChestSword", "KeyTerminal", "HeartTerrace",
		"GateTerminal", "CheckpointSpawn", "CheckpointGate",
	]
	for node_name: String in expected:
		_runner.assert_true(hub.get_node_or_null(node_name) != null,
			"Hub enthält Knoten '%s'" % node_name)


func atest_blockout_erzeugt_kollisionskoerper() -> void:
	var hub: Node3D = _load_hub()
	if hub == null:
		return
	await _runner.wait_physics_frames(4)

	var blockout: Node = hub.get_node_or_null("Blockout")
	_runner.assert_true(blockout != null, "Blockout vorhanden")
	if blockout == null:
		return
	# Ohne erzeugte Körper stünde der Player im Leeren.
	_runner.assert_true(int(blockout.call("block_count")) >= 18,
		"Blockout erzeugt mindestens 18 Körper")

	var plaza: Node = blockout.call("find_block", "Platz")
	_runner.assert_true(plaza != null, "Bodenplatte 'Platz' erzeugt")
	if plaza is StaticBody3D:
		_runner.assert_eq((plaza as StaticBody3D).collision_layer, 1,
			"Boden liegt auf Layer 1 (world)")


# --- Player fällt nicht durch die Welt -----------------------------------

func atest_player_steht_auf_dem_boden() -> void:
	var hub: Node3D = _load_hub()
	if hub == null:
		return
	# Genug Schritte, damit der Spawn auf 1,0 m tatsächlich aufsetzt.
	await _runner.wait_physics_frames(30)

	var player: Node3D = hub.get_node_or_null("Player")
	_runner.assert_true(player != null, "Player in der Szene")
	if player == null:
		return

	# Der Ursprung der Spielfigur liegt an den FÜSSEN, nicht in der Kapselmitte
	# (die Kollisionsform sitzt um 0,875 versetzt). Auf einem Boden mit
	# Oberkante 0 ist die richtige Antwort daher y ungefähr 0 — nicht 0,875.
	# Der erste Anlauf dieses Tests erwartete 0,875 und schlug an einer
	# korrekten Implementierung fehl.
	_runner.assert_true(player.global_position.y > -0.05,
		"Player nicht durch den Boden gefallen (ist %.3f)" % player.global_position.y)
	_runner.assert_true(player.global_position.y < 0.6,
		"Player nicht in der Luft hängen geblieben (ist %.3f)" % player.global_position.y)
	_runner.assert_true(bool(player.call("is_on_floor")), "Player hat Bodenkontakt")


# --- Checkpoint und Quest beim Betreten ----------------------------------

func atest_hub_setzt_spawn_checkpoint() -> void:
	var hub: Node3D = _load_hub()
	if hub == null:
		return
	await _runner.wait_physics_frames(4)

	# Der Hub muss den gewollten Checkpoint setzen, nicht den Notnagel des Players.
	_runner.assert_eq(GameState.checkpoint_id, "hub_spawn", "Spawn-Checkpoint gesetzt")
	_runner.assert_eq(GameState.checkpoint_scene, HUB_PATH, "Szenenpfad im Checkpoint")


func atest_hub_startet_erste_hauptquest() -> void:
	var hub: Node3D = _load_hub()
	if hub == null:
		return
	await _runner.wait_physics_frames(4)

	_runner.assert_eq(GameState.quest_state("q_seite_down"), "active",
		"erste Hauptquest läuft")


# --- Tür bleibt ohne Schlüssel zu ----------------------------------------

func atest_tor_bleibt_ohne_schluessel_geschlossen() -> void:
	var hub: Node3D = _load_hub()
	if hub == null:
		return
	await _runner.wait_physics_frames(4)

	var gate: Interactable = hub.get_node_or_null("GateTerminal") as Interactable
	_runner.assert_true(gate != null, "Tor vorhanden")
	if gate == null:
		return

	_runner.assert_false(bool(gate.call("is_open")), "Tor startet geschlossen")
	_runner.assert_false(gate.can_interact(), "ohne Schlüssel nicht benutzbar")

	gate.interact(hub.get_node_or_null("Player"))
	_runner.assert_false(bool(gate.call("is_open")),
		"Tor bleibt nach Benutzungsversuch ohne Schlüssel zu")


func atest_tor_oeffnet_mit_schluessel_und_verbraucht_ihn() -> void:
	var hub: Node3D = _load_hub()
	if hub == null:
		return
	await _runner.wait_physics_frames(4)

	GameState.add_item("key_terminal", 1)
	var gate: Interactable = hub.get_node_or_null("GateTerminal") as Interactable
	if gate == null:
		_runner.fail("Tor fehlt")
		return

	_runner.assert_true(gate.can_interact(), "mit Schlüssel benutzbar")
	gate.interact(hub.get_node_or_null("Player"))

	_runner.assert_true(bool(gate.call("is_open")), "Tor ist offen")
	_runner.assert_eq(GameState.item_count("key_terminal"), 0, "Schlüssel verbraucht")
	_runner.assert_true(GameState.get_flag("hub_gate_terminal_open"),
		"Öffnungszustand als Weltflag gesichert")


# --- Kiste ist genau einmal plünderbar -----------------------------------

func atest_kiste_gibt_schwert_genau_einmal() -> void:
	var hub: Node3D = _load_hub()
	if hub == null:
		return
	await _runner.wait_physics_frames(4)

	var chest: Interactable = hub.get_node_or_null("ChestSword") as Interactable
	if chest == null:
		_runner.fail("Kiste fehlt")
		return

	var player: Node3D = hub.get_node_or_null("Player")
	chest.interact(player)
	_runner.assert_eq(GameState.item_count("sword_ed25519"), 1, "Schwert erhalten")
	_runner.assert_eq(GameState.packets, 15, "Packets erhalten")

	# Zweiter und dritter Versuch dürfen nichts mehr geben.
	chest.interact(player)
	chest.interact(player)
	_runner.assert_eq(GameState.item_count("sword_ed25519"), 1, "kein zweites Schwert")
	_runner.assert_eq(GameState.packets, 15, "keine weiteren Packets")
	_runner.assert_true(chest.is_consumed(), "Kiste gilt als geleert")


func atest_geleerte_kiste_bleibt_nach_neuladen_leer() -> void:
	# Das ist der Persistenzpfad, den ein Speicherstand nehmen muss: Flag gesetzt,
	# Szene neu aufgebaut, Kiste muss sich als bereits geöffnet erkennen.
	GameState.set_flag("hub_chest_sword")

	var hub: Node3D = _load_hub()
	if hub == null:
		return
	await _runner.wait_physics_frames(4)

	var chest: Interactable = hub.get_node_or_null("ChestSword") as Interactable
	if chest == null:
		_runner.fail("Kiste fehlt")
		return

	_runner.assert_true(chest.is_consumed(), "Kiste startet als geleert")
	_runner.assert_false(chest.can_interact(), "nicht erneut benutzbar")

	chest.interact(hub.get_node_or_null("Player"))
	_runner.assert_eq(GameState.item_count("sword_ed25519"), 0,
		"kein Schwert aus einer bereits geleerten Kiste")


# --- Mentor-Dialog --------------------------------------------------------

func atest_as_startet_quest_und_ist_mehrfach_ansprechbar() -> void:
	var hub: Node3D = _load_hub()
	if hub == null:
		return
	await _runner.wait_physics_frames(4)

	var npc: Interactable = hub.get_node_or_null("AS") as Interactable
	if npc == null:
		_runner.fail("AS fehlt")
		return

	var player: Node3D = hub.get_node_or_null("Player")
	npc.interact(player)
	_runner.assert_eq(GameState.quest_state("q_seite_down"), "active", "Quest aktiv")

	# Ein NPC ist kein Einwegobjekt.
	_runner.assert_true(npc.can_interact(), "AS bleibt ansprechbar")
	npc.interact(player)
	_runner.assert_true(npc.can_interact(), "AS auch nach zweitem Gespräch ansprechbar")


func atest_as_schliesst_quest_erst_mit_schluessel_ab() -> void:
	var hub: Node3D = _load_hub()
	if hub == null:
		return
	await _runner.wait_physics_frames(4)

	var npc: Interactable = hub.get_node_or_null("AS") as Interactable
	var player: Node3D = hub.get_node_or_null("Player")
	if npc == null:
		_runner.fail("AS fehlt")
		return

	npc.interact(player)
	_runner.assert_eq(GameState.quest_state("q_seite_down"), "active",
		"ohne Schlüssel noch nicht abgeschlossen")

	GameState.add_item("key_terminal", 1)
	npc.interact(player)
	_runner.assert_eq(GameState.quest_state("q_seite_down"), "done",
		"mit Schlüssel abgeschlossen")
