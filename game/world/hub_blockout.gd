@tool
class_name HubBlockout
extends Node3D
## Blockout-Geometrie des Hubs "Leipzig-Knoten / Homelab-Dorf".
##
## Warum aus Code und nicht als handgepflegte .tscn: Eine Szene mit rund zwanzig
## Quadern wäre 300 Zeilen Textdatei, in der man beim Verschieben einer Mauer
## drei Werte an zwei Stellen nachziehen muss (Mesh-Größe und Kollisionsform).
## Hier steht jede Wand einmal als Datenzeile. Das Blockout ist Wegwerfgeometrie
## für M1 — in M3 ersetzen Blender-Meshes diese Quader, und dann soll das
## Entfernen ein Löschen sein und keine Operation am offenen Herzen.
##
## Maßstab: 1 Einheit = 1 Meter. Der Held ist 1,75 m hoch, eine Mauer mit
## Höhe 4 ist also klar unüberwindbar, eine Stufe mit 0,4 begehbar.

## Ein Baustein des Blockouts.
## `material_key` verweist auf MATERIALS, nicht auf einen Pfad — so liegt die
## Art Direction an einer Stelle und nicht zwanzigmal im Datenblock.
class Block:
	var position: Vector3
	var size: Vector3
	var material_key: String
	var name_hint: String

	func _init(p: Vector3, s: Vector3, key: String, hint: String) -> void:
		position = p
		size = s
		material_key = key
		name_hint = hint


const MATERIALS: Dictionary = {
	"floor": "res://world/materials/mat_floor.tres",
	"wall": "res://world/materials/mat_wall.tres",
	"glass": "res://world/materials/mat_glass.tres",
	"accent": "res://world/materials/mat_accent.tres",
}

## Höhe der Umfassungsmauern. Deutlich über Sprunghöhe (1,2 m), damit der
## Spieler den Hub nicht versehentlich verlässt.
const WALL_HEIGHT: float = 4.0
const PLAZA_SIZE: float = 40.0

## Spawnpunkt des Spielers. Steht bewusst hier und nicht in der Szene:
## Die Hub-Szene setzt darüber ihren Start-Checkpoint, und Blockout und
## Spawn müssen zusammen wandern, wenn der Platz umgebaut wird.
##
## Y beträgt 0,1 und nicht 1,0: Der Ursprung der Spielfigur liegt an den Füßen
## (Kollisionskapsel sitzt auf 0,875 versetzt). Ein höherer Wert ließe den
## Spieler bei jedem Respawn erst einen Meter fallen.
const SPAWN_POSITION: Vector3 = Vector3(0.0, 0.1, 8.0)

@export var rebuild: bool = false:
	set(value):
		rebuild = false
		if is_inside_tree():
			build()

var _generated: Node3D = null


func _ready() -> void:
	build()


## Die Bausteine des Hubs. Reihenfolge ohne Bedeutung, Namen nur zur Orientierung
## im Szenenbaum.
func _blocks() -> Array[Block]:
	var half: float = PLAZA_SIZE * 0.5
	var blocks: Array[Block] = [
		# --- Grundfläche ---------------------------------------------------
		Block.new(Vector3(0, -0.5, 0), Vector3(PLAZA_SIZE, 1.0, PLAZA_SIZE),
			"floor", "Platz"),

		# --- Umfassung. Der Süden (+Z) bleibt offen: dort steht später das
		#     Tor mit der verschlossenen Tür zum Terminal-Ufer.
		Block.new(Vector3(0, WALL_HEIGHT * 0.5, -half), Vector3(PLAZA_SIZE, WALL_HEIGHT, 1.0),
			"wall", "MauerNord"),
		Block.new(Vector3(-half, WALL_HEIGHT * 0.5, 0), Vector3(1.0, WALL_HEIGHT, PLAZA_SIZE),
			"wall", "MauerWest"),
		Block.new(Vector3(half, WALL_HEIGHT * 0.5, 0), Vector3(1.0, WALL_HEIGHT, PLAZA_SIZE),
			"wall", "MauerOst"),
		# Südmauer in zwei Teilen, dazwischen eine 6 m breite Torlücke.
		Block.new(Vector3(-13, WALL_HEIGHT * 0.5, half), Vector3(14.0, WALL_HEIGHT, 1.0),
			"wall", "MauerSuedWest"),
		Block.new(Vector3(13, WALL_HEIGHT * 0.5, half), Vector3(14.0, WALL_HEIGHT, 1.0),
			"wall", "MauerSuedOst"),
		# Torrahmen als Akzent: markiert den Ausgang als bedeutsam.
		Block.new(Vector3(-3.2, 2.0, half), Vector3(0.4, 4.0, 1.2), "accent", "TorpfostenWest"),
		Block.new(Vector3(3.2, 2.0, half), Vector3(0.4, 4.0, 1.2), "accent", "TorpfostenOst"),
		Block.new(Vector3(0, 4.1, half), Vector3(7.0, 0.4, 1.2), "accent", "Torsturz"),

		# --- Terrasse im Norden, darauf der VPS-Turm ----------------------
		Block.new(Vector3(-10, 0.75, -13), Vector3(16.0, 1.5, 10.0), "floor", "Terrasse"),
		# Drei Stufen statt Rampe: klarer lesbar, was begehbar ist.
		Block.new(Vector3(-10, 0.2, -7.6), Vector3(6.0, 0.4, 1.2), "wall", "Stufe1"),
		Block.new(Vector3(-10, 0.6, -8.8), Vector3(6.0, 0.4, 1.2), "wall", "Stufe2"),
		Block.new(Vector3(-10, 1.0, -10.0), Vector3(6.0, 0.4, 1.2), "wall", "Stufe3"),

		# --- Werkstatt / BFW-Baracke im Osten -----------------------------
		Block.new(Vector3(13, 1.6, -8), Vector3(9.0, 3.2, 7.0), "wall", "Werkstatt"),
		Block.new(Vector3(13, 1.8, -4.4), Vector3(6.0, 2.0, 0.2), "glass", "WerkstattFenster"),

		# --- Tux-Händlerstand im Westen -----------------------------------
		Block.new(Vector3(-15, 1.2, 4), Vector3(5.0, 0.3, 4.0), "wall", "HaendlerDach"),
		Block.new(Vector3(-13.2, 0.6, 4), Vector3(0.3, 1.2, 4.0), "wall", "HaendlerTheke"),

		# --- Podest für den Mentor AS, mittig und leicht erhöht -----------
		Block.new(Vector3(0, 0.2, -2), Vector3(5.0, 0.4, 5.0), "floor", "PodestAS"),
		Block.new(Vector3(0, 0.45, -2), Vector3(5.2, 0.1, 5.2), "accent", "PodestKante"),

		# --- Zwei Serverschränke als Deckung im Kampfbereich --------------
		Block.new(Vector3(8, 1.0, 6), Vector3(1.6, 2.0, 1.6), "wall", "Rack1"),
		Block.new(Vector3(-6, 1.0, 10), Vector3(1.6, 2.0, 1.6), "wall", "Rack2"),
	]
	return blocks


func build() -> void:
	if _generated != null and is_instance_valid(_generated):
		_generated.free()
	for child: Node in get_children():
		if child.name == "GeneratedBlockout":
			child.free()

	_generated = Node3D.new()
	_generated.name = "GeneratedBlockout"
	add_child(_generated)

	var cache: Dictionary = {}
	for key: String in MATERIALS:
		cache[key] = load(str(MATERIALS[key]))

	for block: Block in _blocks():
		_generated.add_child(_make_body(block, cache))


func _make_body(block: Block, material_cache: Dictionary) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = block.name_hint
	# Layer 1 = world. Der Player kollidiert ausschließlich mit dieser Ebene.
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = block.position

	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = block.size
	var visual: MeshInstance3D = MeshInstance3D.new()
	visual.name = "Mesh"
	visual.mesh = mesh
	if material_cache.has(block.material_key):
		visual.material_override = material_cache[block.material_key]

	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = block.size
	var collider: CollisionShape3D = CollisionShape3D.new()
	collider.name = "Collider"
	collider.shape = shape

	body.add_child(visual)
	body.add_child(collider)
	return body


## Anzahl erzeugter Kollisionskörper. Für Tests.
func block_count() -> int:
	if _generated == null or not is_instance_valid(_generated):
		return 0
	return _generated.get_child_count()


## Liefert den erzeugten Körper mit diesem Namen, oder null.
func find_block(name_hint: String) -> StaticBody3D:
	if _generated == null or not is_instance_valid(_generated):
		return null
	return _generated.get_node_or_null(name_hint) as StaticBody3D
