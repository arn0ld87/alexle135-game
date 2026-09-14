extends Node
## Tests für die interaktiven Weltobjekte (Kiste, Tür, Pickup, Hebel,
## Druckplatte, Checkpoint, NPC-Dialog) — Auftrag Abschnitt 26.
##
## Baut für Bewegungs-/Berührungstests einen minimalen Player-Ersatz
## (CharacterBody3D, Layer "player", Gruppe "player") statt game/player/*,
## das liegt bei einem anderen Entwickler in Arbeit.

const CHEST_SCENE: PackedScene = preload("res://scenes/interactables/chest.tscn")
const LOCKED_DOOR_SCENE: PackedScene = preload("res://scenes/interactables/locked_door.tscn")
const ITEM_PICKUP_SCENE: PackedScene = preload("res://scenes/interactables/item_pickup.tscn")
const LEVER_SWITCH_SCENE: PackedScene = preload("res://scenes/interactables/lever_switch.tscn")
const PRESSURE_PLATE_SCENE: PackedScene = preload("res://scenes/interactables/pressure_plate.tscn")
const CHECKPOINT_SCENE: PackedScene = preload("res://scenes/interactables/checkpoint.tscn")
const NPC_DIALOGUE_SCENE: PackedScene = preload("res://scenes/interactables/npc_dialogue.tscn")

var _runner: Object = null


func set_runner(runner: Object) -> void:
	_runner = runner


## Platzhalter für den Interagierenden, wenn nur die Position/der Typ zählt.
## Muss im Baum hängen, sonst wirft global_position/look_at Fehler.
func _make_interactor(position: Vector3 = Vector3.ZERO) -> Node3D:
	var node: Node3D = Node3D.new()
	add_child(node)
	node.global_position = position
	return node


## Minimaler Player-Ersatz für Berührungstests (Gruppe "player", Layer 2).
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
	return body


# --- 1. Alle Szenen instanziieren fehlerfrei --------------------------------

func test_alle_szenen_instanziieren_fehlerfrei() -> void:
	var scenes: Array[PackedScene] = [
		CHEST_SCENE, LOCKED_DOOR_SCENE, ITEM_PICKUP_SCENE, LEVER_SWITCH_SCENE,
		PRESSURE_PLATE_SCENE, CHECKPOINT_SCENE, NPC_DIALOGUE_SCENE,
	]
	for scene: PackedScene in scenes:
		var instance: Node = scene.instantiate()
		_runner.assert_true(instance != null, "instanziiert")
		add_child(instance)
		instance.queue_free()


# --- 2/3. Kiste --------------------------------------------------------------

func test_kiste_erste_benutzung_gibt_item_zweite_nicht() -> void:
	var chest: Chest = CHEST_SCENE.instantiate() as Chest
	chest.flag_id = "test_chest_sword"
	chest.item_id = "sword_ed25519"
	chest.item_count = 1
	add_child(chest)
	var interactor: Node3D = _make_interactor()

	chest.interact(interactor)
	_runner.assert_eq(GameState.item_count("sword_ed25519"), 1, "erste Öffnung gibt Item")

	chest.interact(interactor)
	_runner.assert_eq(GameState.item_count("sword_ed25519"), 1, "zweite Öffnung gibt nichts mehr")
	_runner.assert_true(chest.is_consumed(), "Kiste gilt als verbraucht")

	interactor.queue_free()
	chest.queue_free()


func test_kiste_startet_offen_wenn_flag_vorher_gesetzt() -> void:
	GameState.set_flag("test_chest_preopened")
	var chest: Chest = CHEST_SCENE.instantiate() as Chest
	chest.flag_id = "test_chest_preopened"
	add_child(chest)

	_runner.assert_true(chest.is_consumed(), "startet als verbraucht")
	_runner.assert_false(chest.can_interact(), "kann nicht mehr geöffnet werden")

	chest.queue_free()


# --- 4-7. Verschlossene Tür ---------------------------------------------------

func test_tuer_bleibt_ohne_schluessel_geschlossen() -> void:
	var door: LockedDoor = LOCKED_DOOR_SCENE.instantiate() as LockedDoor
	door.flag_id = "test_door_ohne_schluessel"
	add_child(door)
	var interactor: Node3D = _make_interactor()

	door.interact(interactor)
	_runner.assert_false(door.is_open(), "bleibt geschlossen ohne Schlüssel")

	interactor.queue_free()
	door.queue_free()


func test_tuer_oeffnet_mit_schluessel_und_verbraucht_ihn() -> void:
	GameState.add_item("key_generic", 1)
	var door: LockedDoor = LOCKED_DOOR_SCENE.instantiate() as LockedDoor
	door.flag_id = "test_door_consume"
	door.consume_key = true
	add_child(door)
	var interactor: Node3D = _make_interactor()

	door.interact(interactor)
	_runner.assert_true(door.is_open(), "öffnet mit Schlüssel")
	_runner.assert_false(GameState.has_item("key_generic"), "Schlüssel wurde verbraucht")

	interactor.queue_free()
	door.queue_free()


func test_tuer_mit_consume_key_false_behaelt_schluessel() -> void:
	GameState.add_item("key_generic", 1)
	var door: LockedDoor = LOCKED_DOOR_SCENE.instantiate() as LockedDoor
	door.flag_id = "test_door_keep_key"
	door.consume_key = false
	add_child(door)
	var interactor: Node3D = _make_interactor()

	door.interact(interactor)
	_runner.assert_true(door.is_open(), "öffnet mit Schlüssel")
	_runner.assert_true(GameState.has_item("key_generic"), "Schlüssel bleibt im Inventar")

	interactor.queue_free()
	door.queue_free()


func test_tuer_oeffnet_ueber_flag_ohne_schluessel() -> void:
	GameState.set_flag("test_lever_pulled")
	var door: LockedDoor = LOCKED_DOOR_SCENE.instantiate() as LockedDoor
	door.flag_id = "test_door_via_flag"
	door.required_flag_id = "test_lever_pulled"
	add_child(door)
	var interactor: Node3D = _make_interactor()

	door.interact(interactor)
	_runner.assert_true(door.is_open(), "öffnet über required_flag_id ohne Schlüssel")

	interactor.queue_free()
	door.queue_free()


# --- 8/9. Item-Pickup ----------------------------------------------------------

func test_item_pickup_gibt_item_und_verschwindet() -> void:
	var pickup: ItemPickup = ITEM_PICKUP_SCENE.instantiate() as ItemPickup
	pickup.flag_id = "test_pickup_key"
	pickup.item_id = "key_generic"
	pickup.item_count = 1
	add_child(pickup)
	var interactor: Node3D = _make_interactor()

	pickup.interact(interactor)
	_runner.assert_eq(GameState.item_count("key_generic"), 1, "Item aufgenommen")
	_runner.assert_false(pickup.visible, "wird unsichtbar")

	pickup.interact(interactor)
	_runner.assert_eq(GameState.item_count("key_generic"), 1, "kein zweites Item")

	interactor.queue_free()
	pickup.queue_free()


func test_item_pickup_herzcontainer_erhoeht_maximum() -> void:
	var pickup: ItemPickup = ITEM_PICKUP_SCENE.instantiate() as ItemPickup
	pickup.flag_id = "test_pickup_heart"
	pickup.is_heart_container = true
	add_child(pickup)
	var interactor: Node3D = _make_interactor()

	pickup.interact(interactor)
	_runner.assert_eq(GameState.max_hearts, 5, "Herz-Maximum um eins erhöht")

	interactor.queue_free()
	pickup.queue_free()


# --- 10. Hebel -------------------------------------------------------------------

func test_hebel_setzt_target_flag() -> void:
	var lever: LeverSwitch = LEVER_SWITCH_SCENE.instantiate() as LeverSwitch
	lever.flag_id = "test_lever_used"
	lever.target_flag_id = "test_lever_target"
	add_child(lever)
	var interactor: Node3D = _make_interactor()

	lever.interact(interactor)
	_runner.assert_true(GameState.get_flag("test_lever_target"), "Ziel-Flag gesetzt")

	interactor.queue_free()
	lever.queue_free()


# --- 11. Druckplatte (Physik-Frames nötig) ---------------------------------------

func atest_druckplatte_kontinuierliches_gewicht() -> void:
	var plate: PressurePlate = PRESSURE_PLATE_SCENE.instantiate() as PressurePlate
	plate.target_flag_id = "test_plate_flag"
	plate.requires_continuous_weight = true
	add_child(plate)

	var player: CharacterBody3D = _make_player()
	add_child(player)
	player.global_position = plate.global_position

	await _runner.wait_physics_frames(4)
	_runner.assert_true(GameState.get_flag("test_plate_flag"), "Flag beim Betreten gesetzt")
	_runner.assert_true(plate.is_pressed(), "Platte gilt als gedrückt")

	player.global_position = Vector3(50.0, 50.0, 50.0)
	await _runner.wait_physics_frames(4)
	_runner.assert_false(GameState.get_flag("test_plate_flag"), "Flag beim Verlassen entfernt")
	_runner.assert_false(plate.is_pressed(), "Platte gilt als losgelassen")

	player.queue_free()
	plate.queue_free()


# --- 12. Checkpoint (Physik-Frames nötig) -----------------------------------------

func atest_checkpoint_setzt_zustand_beim_betreten() -> void:
	var checkpoint: Checkpoint = CHECKPOINT_SCENE.instantiate() as Checkpoint
	checkpoint.checkpoint_id = "test_checkpoint"
	checkpoint.autosave = false
	add_child(checkpoint)
	checkpoint.global_position = Vector3(4.0, 0.0, -2.0)

	var player: CharacterBody3D = _make_player()
	add_child(player)
	player.global_position = checkpoint.global_position

	# Braucht mehrere Physik-Frames: der frisch hinzugefügte/verschobene
	# CharacterBody3D muss erst beim Physikserver ankommen, bevor die
	# Area3D-Überlappung ausgewertet wird.
	await _runner.wait_physics_frames(4)
	_runner.assert_eq(GameState.checkpoint_id, "test_checkpoint", "Checkpoint-ID gesetzt")
	_runner.assert_almost_eq(GameState.checkpoint_position.x, 4.0, 0.01, "Checkpoint-X")
	_runner.assert_almost_eq(GameState.checkpoint_position.z, -2.0, 0.01, "Checkpoint-Z")

	player.queue_free()
	checkpoint.queue_free()


# --- 13/14. NPC-Dialog --------------------------------------------------------------

func test_npc_mehrfach_ansprechbar_startet_quest_einmal() -> void:
	var npc: NpcDialogue = NPC_DIALOGUE_SCENE.instantiate() as NpcDialogue
	npc.lines = PackedStringArray(["Hallo."])
	npc.starts_quest_id = "test_quest_npc"
	add_child(npc)
	var interactor: Node3D = _make_interactor(Vector3(1.0, 0.0, 0.0))

	var starts: Array[String] = []
	var handler: Callable = func(quest_id: String) -> void:
		starts.append(quest_id)
	EventBus.quest_started.connect(handler)

	npc.interact(interactor)
	npc.interact(interactor)
	npc.interact(interactor)

	EventBus.quest_started.disconnect(handler)

	_runner.assert_eq(starts.size(), 1, "Quest genau einmal gestartet")
	_runner.assert_eq(GameState.quest_state("test_quest_npc"), "active", "Quest aktiv")
	_runner.assert_true(npc.can_interact(), "NPC bleibt nach Gespräch ansprechbar")

	interactor.queue_free()
	npc.queue_free()


func test_npc_schliesst_quest_nur_mit_item_ab() -> void:
	var npc: NpcDialogue = NPC_DIALOGUE_SCENE.instantiate() as NpcDialogue
	npc.lines = PackedStringArray(["Hallo."])
	npc.lines_after_completion = PackedStringArray(["Danke."])
	npc.completes_quest_id = "test_quest_complete"
	npc.required_item_to_complete = "quest_item"
	add_child(npc)
	var interactor: Node3D = _make_interactor(Vector3(1.0, 0.0, 0.0))
	GameState.start_quest("test_quest_complete")

	npc.interact(interactor)
	_runner.assert_eq(GameState.quest_state("test_quest_complete"), "active",
		"ohne Item nicht abgeschlossen")

	GameState.add_item("quest_item", 1)
	npc.interact(interactor)
	_runner.assert_eq(GameState.quest_state("test_quest_complete"), "done",
		"mit Item im Inventar abgeschlossen")

	interactor.queue_free()
	npc.queue_free()
