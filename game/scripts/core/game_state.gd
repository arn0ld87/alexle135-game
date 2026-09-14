extends Node
## Zentraler Laufzeit- und Persistenzzustand (Autoload "GameState").
##
## Dies ist die EINZIGE Quelle der Wahrheit für Spielerfortschritt.
## Szenen und UI dürfen lesen, aber nur über die Methoden hier schreiben,
## damit jede Änderung ein EventBus-Signal auslöst.
##
## Gesundheit wird in Viertelherzen gerechnet (int), nicht in Fließkomma-
## Herzen. Ein Herz = 4 Quarters. Das vermeidet Rundungsfehler bei halben
## Herzen und macht Speicherstände exakt vergleichbar.

const QUARTERS_PER_HEART: int = 4
const START_HEARTS: int = 4

# --- Zustand ---------------------------------------------------------------

var max_hearts: int = START_HEARTS
var health_quarters: int = START_HEARTS * QUARTERS_PER_HEART
var packets: int = 0

## item_id -> Anzahl. Traversal-Items und Schlüssel liegen hier ebenfalls.
var inventory: Dictionary = {}
## Aktuell auf dem Item-Slot liegendes Item ("" = leer).
var equipped_item: String = ""

## Persistente Weltflags. Schlüssel sind stabile IDs wie
## "hub_chest_sword_opened" oder "dungeon_terminal_cleared".
## NUR bool-Werte, damit das Save-Format trivial bleibt.
var flags: Dictionary = {}

## quest_id -> { "state": String, "step": int }
## state: "inactive" | "active" | "done"
var quests: Dictionary = {}

## Letzter Checkpoint. Wird beim Tod und beim Laden verwendet.
var checkpoint_scene: String = ""
var checkpoint_position: Vector3 = Vector3.ZERO
var checkpoint_id: String = ""

var playtime_seconds: float = 0.0

# --- Ableitungen -----------------------------------------------------------

func max_health_quarters() -> int:
	return max_hearts * QUARTERS_PER_HEART


func is_alive() -> bool:
	return health_quarters > 0


func _process(delta: float) -> void:
	playtime_seconds += delta

# --- Gesundheit ------------------------------------------------------------

## Fügt Schaden zu. Gibt true zurück, wenn der Schaden tatsächlich anlag.
## I-Frames sind Sache des Players, nicht von GameState.
func apply_damage(amount_quarters: int) -> bool:
	if amount_quarters <= 0 or not is_alive():
		return false
	health_quarters = maxi(0, health_quarters - amount_quarters)
	EventBus.player_damaged.emit(amount_quarters)
	EventBus.health_changed.emit(health_quarters, max_health_quarters())
	if health_quarters == 0:
		EventBus.player_died.emit()
	return true


func heal(amount_quarters: int) -> void:
	if amount_quarters <= 0:
		return
	health_quarters = mini(max_health_quarters(), health_quarters + amount_quarters)
	EventBus.health_changed.emit(health_quarters, max_health_quarters())


func heal_full() -> void:
	health_quarters = max_health_quarters()
	EventBus.health_changed.emit(health_quarters, max_health_quarters())


## Heart-Container: erhöht das Maximum und füllt neu auf.
func add_heart_container() -> void:
	max_hearts += 1
	heal_full()

# --- Währung ---------------------------------------------------------------

func add_packets(amount: int) -> void:
	if amount == 0:
		return
	packets = maxi(0, packets + amount)
	EventBus.packets_changed.emit(packets)


## Gibt true zurück, wenn genug Packets vorhanden waren und abgebucht wurde.
func spend_packets(amount: int) -> bool:
	if amount <= 0 or packets < amount:
		return false
	packets -= amount
	EventBus.packets_changed.emit(packets)
	return true

# --- Inventar --------------------------------------------------------------

func add_item(item_id: String, count: int = 1) -> void:
	if item_id.is_empty() or count <= 0:
		return
	inventory[item_id] = int(inventory.get(item_id, 0)) + count
	EventBus.item_acquired.emit(item_id, count)
	EventBus.inventory_changed.emit()


## Verbraucht `count` Stück. Gibt false zurück, wenn zu wenig vorhanden ist.
func consume_item(item_id: String, count: int = 1) -> bool:
	var have: int = int(inventory.get(item_id, 0))
	if count <= 0 or have < count:
		return false
	if have == count:
		inventory.erase(item_id)
		if equipped_item == item_id:
			equipped_item = ""
			EventBus.item_equipped.emit("")
	else:
		inventory[item_id] = have - count
	EventBus.inventory_changed.emit()
	return true


func has_item(item_id: String, count: int = 1) -> bool:
	return int(inventory.get(item_id, 0)) >= count


func item_count(item_id: String) -> int:
	return int(inventory.get(item_id, 0))


func equip_item(item_id: String) -> bool:
	if not item_id.is_empty() and not has_item(item_id):
		return false
	equipped_item = item_id
	EventBus.item_equipped.emit(item_id)
	return true

# --- Weltflags -------------------------------------------------------------
# Flags sind der Mechanismus, der verhindert, dass eine Kiste zweimal
# geplündert oder ein Dungeon erneut als "neu" behandelt wird.

func set_flag(flag_id: String, value: bool = true) -> void:
	if flag_id.is_empty():
		return
	var old: bool = bool(flags.get(flag_id, false))
	if old == value:
		return
	if value:
		flags[flag_id] = true
	else:
		flags.erase(flag_id)
	EventBus.flag_changed.emit(flag_id, value)


func get_flag(flag_id: String) -> bool:
	return bool(flags.get(flag_id, false))

# --- Quests ----------------------------------------------------------------

func start_quest(quest_id: String) -> void:
	if quest_id.is_empty() or quests.has(quest_id):
		return
	quests[quest_id] = { "state": "active", "step": 0 }
	EventBus.quest_started.emit(quest_id)


func set_quest_step(quest_id: String, step: int) -> void:
	if not quests.has(quest_id):
		start_quest(quest_id)
	var entry: Dictionary = quests[quest_id]
	entry["step"] = step
	quests[quest_id] = entry
	EventBus.quest_step_changed.emit(quest_id, step)


func complete_quest(quest_id: String) -> void:
	if not quests.has(quest_id):
		quests[quest_id] = { "state": "done", "step": 0 }
	else:
		var entry: Dictionary = quests[quest_id]
		entry["state"] = "done"
		quests[quest_id] = entry
	EventBus.quest_completed.emit(quest_id)


func quest_state(quest_id: String) -> String:
	if not quests.has(quest_id):
		return "inactive"
	return str((quests[quest_id] as Dictionary).get("state", "inactive"))

# --- Checkpoints -----------------------------------------------------------

func set_checkpoint(id: String, scene_path: String, position: Vector3) -> void:
	checkpoint_id = id
	checkpoint_scene = scene_path
	checkpoint_position = position
	EventBus.checkpoint_reached.emit(id)

# --- Serialisierung --------------------------------------------------------
# Bewusst flach und JSON-nah. Vector3 wird als Array gespeichert, weil JSON
# keine Godot-Typen kennt und wir das Format ohne Godot lesen wollen.

func to_dict() -> Dictionary:
	return {
		"max_hearts": max_hearts,
		"health_quarters": health_quarters,
		"packets": packets,
		"inventory": inventory.duplicate(),
		"equipped_item": equipped_item,
		"flags": flags.duplicate(),
		"quests": quests.duplicate(true),
		"checkpoint_id": checkpoint_id,
		"checkpoint_scene": checkpoint_scene,
		"checkpoint_position": [
			checkpoint_position.x, checkpoint_position.y, checkpoint_position.z
		],
		"playtime_seconds": playtime_seconds,
	}


func from_dict(data: Dictionary) -> void:
	max_hearts = int(data.get("max_hearts", START_HEARTS))
	health_quarters = int(data.get("health_quarters", max_health_quarters()))
	packets = int(data.get("packets", 0))

	inventory = {}
	for key: Variant in (data.get("inventory", {}) as Dictionary):
		inventory[str(key)] = int((data["inventory"] as Dictionary)[key])

	equipped_item = str(data.get("equipped_item", ""))

	flags = {}
	for key: Variant in (data.get("flags", {}) as Dictionary):
		if bool((data["flags"] as Dictionary)[key]):
			flags[str(key)] = true

	quests = {}
	for key: Variant in (data.get("quests", {}) as Dictionary):
		var raw: Dictionary = (data["quests"] as Dictionary)[key]
		quests[str(key)] = {
			"state": str(raw.get("state", "inactive")),
			"step": int(raw.get("step", 0)),
		}

	checkpoint_id = str(data.get("checkpoint_id", ""))
	checkpoint_scene = str(data.get("checkpoint_scene", ""))
	var pos: Array = data.get("checkpoint_position", [0.0, 0.0, 0.0])
	if pos.size() == 3:
		checkpoint_position = Vector3(float(pos[0]), float(pos[1]), float(pos[2]))
	else:
		checkpoint_position = Vector3.ZERO

	playtime_seconds = float(data.get("playtime_seconds", 0.0))

	EventBus.health_changed.emit(health_quarters, max_health_quarters())
	EventBus.packets_changed.emit(packets)
	EventBus.inventory_changed.emit()
	EventBus.item_equipped.emit(equipped_item)


## Setzt alles auf Spielstart zurück. Für "Neues Spiel" und Tests.
func reset() -> void:
	max_hearts = START_HEARTS
	health_quarters = START_HEARTS * QUARTERS_PER_HEART
	packets = 0
	inventory = {}
	equipped_item = ""
	flags = {}
	quests = {}
	checkpoint_id = ""
	checkpoint_scene = ""
	checkpoint_position = Vector3.ZERO
	playtime_seconds = 0.0
	EventBus.health_changed.emit(health_quarters, max_health_quarters())
	EventBus.packets_changed.emit(packets)
	EventBus.inventory_changed.emit()
