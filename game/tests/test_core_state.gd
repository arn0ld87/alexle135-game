extends Node
## Tests für GameState und SaveManager — das zentrale Datenmodell.
##
## Deckt aus Auftrag Abschnitt 26 ab:
##   - Damage funktioniert
##   - Save lädt korrekt
##   - Dungeon-Clear bleibt gespeichert (über Flags)
##   - Chest lässt sich nicht unendlich looten (Flag-Mechanik, Bauteil davon)

const TEST_SLOT: int = 2

var _runner: Object = null


func set_runner(runner: Object) -> void:
	_runner = runner


func after_each() -> void:
	SaveManager.delete_save(TEST_SLOT)


# --- Gesundheit ------------------------------------------------------------

func test_start_mit_vier_herzen() -> void:
	_runner.assert_eq(GameState.max_hearts, 4, "Startherzen")
	_runner.assert_eq(GameState.health_quarters, 16, "Start-Viertelherzen")
	_runner.assert_true(GameState.is_alive(), "lebt beim Start")


func test_damage_reduziert_gesundheit() -> void:
	var applied: bool = GameState.apply_damage(2)
	_runner.assert_true(applied, "Schaden wurde angenommen")
	_runner.assert_eq(GameState.health_quarters, 14, "nach halbem Herz Schaden")


func test_damage_kann_nicht_unter_null() -> void:
	GameState.apply_damage(999)
	_runner.assert_eq(GameState.health_quarters, 0, "Gesundheit bei 0 gedeckelt")
	_runner.assert_false(GameState.is_alive(), "gilt als tot")


func test_toter_spieler_nimmt_keinen_schaden_mehr() -> void:
	GameState.apply_damage(999)
	var applied: bool = GameState.apply_damage(4)
	_runner.assert_false(applied, "kein Schaden im Todeszustand")


func test_heilung_ueberschreitet_maximum_nicht() -> void:
	GameState.apply_damage(4)
	GameState.heal(999)
	_runner.assert_eq(GameState.health_quarters, 16, "Heilung bei Maximum gedeckelt")


func test_heart_container_erhoeht_maximum_und_fuellt_auf() -> void:
	GameState.apply_damage(8)
	GameState.add_heart_container()
	_runner.assert_eq(GameState.max_hearts, 5, "Maximum erhöht")
	_runner.assert_eq(GameState.health_quarters, 20, "voll aufgefüllt")


func test_negativer_schaden_wird_ignoriert() -> void:
	var applied: bool = GameState.apply_damage(-5)
	_runner.assert_false(applied, "negativer Schaden abgewiesen")
	_runner.assert_eq(GameState.health_quarters, 16, "Gesundheit unverändert")


# --- Währung ---------------------------------------------------------------

func test_packets_sammeln_und_ausgeben() -> void:
	GameState.add_packets(50)
	_runner.assert_eq(GameState.packets, 50, "Packets gesammelt")
	_runner.assert_true(GameState.spend_packets(30), "Ausgabe erfolgreich")
	_runner.assert_eq(GameState.packets, 20, "Rest korrekt")


func test_packets_ohne_deckung_nicht_ausgebbar() -> void:
	GameState.add_packets(10)
	_runner.assert_false(GameState.spend_packets(11), "Ausgabe abgewiesen")
	_runner.assert_eq(GameState.packets, 10, "Guthaben unverändert")


# --- Inventar --------------------------------------------------------------

func test_item_aufnehmen_und_verbrauchen() -> void:
	GameState.add_item("key_terminal", 2)
	_runner.assert_eq(GameState.item_count("key_terminal"), 2, "zwei Schlüssel")
	_runner.assert_true(GameState.consume_item("key_terminal"), "einen verbraucht")
	_runner.assert_eq(GameState.item_count("key_terminal"), 1, "einer übrig")


func test_item_verbrauch_ohne_bestand_schlaegt_fehl() -> void:
	_runner.assert_false(GameState.consume_item("key_terminal"), "nichts zu verbrauchen")


func test_equipped_item_wird_bei_letztem_verbrauch_geleert() -> void:
	GameState.add_item("item_rollback", 1)
	GameState.equip_item("item_rollback")
	_runner.assert_eq(GameState.equipped_item, "item_rollback", "ausgerüstet")
	GameState.consume_item("item_rollback")
	_runner.assert_eq(GameState.equipped_item, "", "Slot geleert")


func test_nicht_besessenes_item_nicht_ausruestbar() -> void:
	_runner.assert_false(GameState.equip_item("sword_ed25519"), "Ausrüsten abgewiesen")


# --- Weltflags (Kisten, Türen, Dungeon-Clear) ------------------------------

func test_flag_setzen_und_lesen() -> void:
	_runner.assert_false(GameState.get_flag("hub_chest_sword"), "initial nicht gesetzt")
	GameState.set_flag("hub_chest_sword")
	_runner.assert_true(GameState.get_flag("hub_chest_sword"), "nach Setzen gesetzt")


func test_flag_ist_idempotent() -> void:
	var emissions: Array[String] = []
	var handler: Callable = func(flag_id: String, _value: bool) -> void:
		emissions.append(flag_id)
	EventBus.flag_changed.connect(handler)
	GameState.set_flag("hub_chest_sword")
	GameState.set_flag("hub_chest_sword")
	GameState.set_flag("hub_chest_sword")
	EventBus.flag_changed.disconnect(handler)
	# Genau das verhindert, dass eine Kiste mehrfach Beute ausschüttet.
	_runner.assert_eq(emissions.size(), 1, "nur eine Signalauslösung")


# --- Quests ----------------------------------------------------------------

func test_quest_lebenszyklus() -> void:
	_runner.assert_eq(GameState.quest_state("q_seite_down"), "inactive", "vor Start")
	GameState.start_quest("q_seite_down")
	_runner.assert_eq(GameState.quest_state("q_seite_down"), "active", "nach Start")
	GameState.set_quest_step("q_seite_down", 2)
	_runner.assert_eq(int((GameState.quests["q_seite_down"] as Dictionary)["step"]), 2, "Schritt")
	GameState.complete_quest("q_seite_down")
	_runner.assert_eq(GameState.quest_state("q_seite_down"), "done", "abgeschlossen")


func test_quest_doppelter_start_setzt_fortschritt_nicht_zurueck() -> void:
	GameState.start_quest("q_seite_down")
	GameState.set_quest_step("q_seite_down", 3)
	GameState.start_quest("q_seite_down")
	_runner.assert_eq(int((GameState.quests["q_seite_down"] as Dictionary)["step"]), 3,
		"Schritt erhalten")


# --- Persistenz ------------------------------------------------------------

func test_save_und_load_stellt_zustand_wieder_her() -> void:
	GameState.add_heart_container()
	GameState.apply_damage(3)
	GameState.add_packets(137)
	GameState.add_item("sword_ed25519", 1)
	GameState.equip_item("sword_ed25519")
	GameState.set_flag("dungeon_terminal_cleared")
	GameState.start_quest("q_mission_starten")
	GameState.set_quest_step("q_mission_starten", 1)
	GameState.set_checkpoint("hub_spawn", "res://scenes/hub.tscn", Vector3(3, 1, -7))

	_runner.assert_true(SaveManager.save_game(TEST_SLOT), "Speichern erfolgreich")

	GameState.reset()
	_runner.assert_eq(GameState.packets, 0, "Reset hat geleert")

	_runner.assert_true(SaveManager.load_game(TEST_SLOT), "Laden erfolgreich")
	_runner.assert_eq(GameState.max_hearts, 5, "Herzen wiederhergestellt")
	_runner.assert_eq(GameState.health_quarters, 17, "Gesundheit wiederhergestellt")
	_runner.assert_eq(GameState.packets, 137, "Packets wiederhergestellt")
	_runner.assert_eq(GameState.equipped_item, "sword_ed25519", "Ausrüstung wiederhergestellt")
	_runner.assert_eq(GameState.item_count("sword_ed25519"), 1, "Inventar wiederhergestellt")
	_runner.assert_eq(GameState.quest_state("q_mission_starten"), "active", "Quest aktiv")
	_runner.assert_eq(GameState.checkpoint_id, "hub_spawn", "Checkpoint-ID")
	_runner.assert_almost_eq(GameState.checkpoint_position.z, -7.0, 0.001, "Checkpoint-Z")


func test_dungeon_clear_ueberlebt_speichern() -> void:
	GameState.set_flag("dungeon_terminal_cleared")
	SaveManager.save_game(TEST_SLOT)
	GameState.reset()
	SaveManager.load_game(TEST_SLOT)
	_runner.assert_true(GameState.get_flag("dungeon_terminal_cleared"),
		"Dungeon bleibt nach Laden abgeschlossen")


func test_geoeffnete_kiste_ueberlebt_speichern() -> void:
	GameState.set_flag("hub_chest_sword")
	SaveManager.save_game(TEST_SLOT)
	GameState.reset()
	SaveManager.load_game(TEST_SLOT)
	_runner.assert_true(GameState.get_flag("hub_chest_sword"),
		"Kiste bleibt nach Laden geöffnet")


func test_laden_eines_leeren_slots_schlaegt_fehl() -> void:
	SaveManager.delete_save(TEST_SLOT)
	_runner.assert_false(SaveManager.load_game(TEST_SLOT), "leerer Slot nicht ladbar")


func test_laden_aendert_zustand_bei_fehlschlag_nicht() -> void:
	SaveManager.delete_save(TEST_SLOT)
	GameState.add_packets(42)
	SaveManager.load_game(TEST_SLOT)
	_runner.assert_eq(GameState.packets, 42, "Zustand unangetastet")


func test_ungueltiger_slot_wird_abgewiesen() -> void:
	_runner.assert_false(SaveManager.save_game(-1), "negativer Slot abgewiesen")
	_runner.assert_false(SaveManager.save_game(SaveManager.MAX_SLOTS), "Slot über Maximum")


func test_peek_slot_liefert_kurzinfo_ohne_zustandswechsel() -> void:
	GameState.add_packets(99)
	GameState.set_checkpoint("hub_spawn", "res://scenes/hub.tscn", Vector3.ZERO)
	SaveManager.save_game(TEST_SLOT)
	GameState.reset()

	var info: Dictionary = SaveManager.peek_slot(TEST_SLOT)
	_runner.assert_eq(str(info.get("checkpoint_id", "")), "hub_spawn", "Checkpoint in Kurzinfo")
	_runner.assert_eq(GameState.packets, 0, "peek hat Zustand nicht geladen")


func test_save_datei_ist_gueltiges_json() -> void:
	GameState.add_packets(7)
	SaveManager.save_game(TEST_SLOT)
	var file: FileAccess = FileAccess.open(SaveManager.slot_path(TEST_SLOT), FileAccess.READ)
	_runner.assert_true(file != null, "Datei lesbar")
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	_runner.assert_true(parsed is Dictionary, "JSON parsebar")
	_runner.assert_eq(int((parsed as Dictionary).get("save_version", 0)),
		SaveManager.SAVE_VERSION, "Version im Stand")
