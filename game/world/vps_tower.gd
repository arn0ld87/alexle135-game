@tool
class_name VpsTower
extends Node3D
## Der VPS-Turm im Hub: ein Serverturm, dessen leuchtende Fenster die Container
## des echten Homelabs darstellen.
##
## Die Zahl 48 ist Kanon, nicht Dekoration: Laut alexle135.de läuft das Homelab auf
## einem Contabo-VPS mit rund 48 Docker-Containern hinter Traefik
## (Belege: docs/research/website-research.md, Abschnitt 3). Der Turm zeigt genau
## so viele Fenster. Wer die Zahl ändert, ändert eine belegte Aussage über die Welt —
## deshalb prüft test_world_assets.gd sie mit.
##
## Umsetzung als MultiMeshInstance3D: 48 Fenster in einem einzigen Draw Call.
## 48 einzelne MeshInstance3D wären 48 Draw Calls für reine Dekoration und würden
## dem 60-FPS-Ziel aus Auftrag Abschnitt 25 entgegenlaufen.

## Kanonische Containerzahl. Ergibt bei 8 Fenstern pro Etage genau 6 Etagen.
const CONTAINER_COUNT: int = 48
const WINDOWS_PER_FLOOR: int = 8
const FLOORS: int = CONTAINER_COUNT / WINDOWS_PER_FLOOR

## Wie viele Fenster dunkel bleiben — ein Homelab, in dem jeder Container läuft,
## sieht unecht aus. Deterministisch gewählt, damit der Turm nicht bei jedem
## Start flackert.
const DARK_WINDOWS: int = 5

@export var floor_height: float = 2.2
@export var tower_width: float = 6.0
@export var tower_depth: float = 4.0
## Wird im Editor neu aufgebaut, wenn sich etwas ändert.
@export var rebuild: bool = false:
	set(value):
		rebuild = false
		if is_inside_tree():
			_build()

var _windows: MultiMeshInstance3D = null


func _ready() -> void:
	_build()


## Anzahl tatsächlich erzeugter Fenster. Für Tests und zur Kontrolle.
func window_count() -> int:
	if _windows == null or _windows.multimesh == null:
		return 0
	return _windows.multimesh.instance_count


func tower_height() -> float:
	return float(FLOORS) * floor_height


func _build() -> void:
	_clear_generated()
	_build_body()
	_build_windows()


func _clear_generated() -> void:
	for child: Node in get_children():
		if child.name.begins_with("Generated"):
			child.free()
	_windows = null


func _build_body() -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "GeneratedBody"
	# Layer 1 = world. Der Turm ist ein massives Hindernis.
	body.collision_layer = 1
	body.collision_mask = 0

	var height: float = tower_height()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(tower_width, height, tower_depth)

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "Shell"
	mesh_instance.mesh = box
	mesh_instance.material_override = load("res://world/materials/mat_wall.tres")
	mesh_instance.position = Vector3(0.0, height * 0.5, 0.0)

	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = box.size
	var collider: CollisionShape3D = CollisionShape3D.new()
	collider.name = "Collider"
	collider.shape = shape
	collider.position = Vector3(0.0, height * 0.5, 0.0)

	body.add_child(mesh_instance)
	body.add_child(collider)
	add_child(body)


func _build_windows() -> void:
	var window_mesh: BoxMesh = BoxMesh.new()
	window_mesh.size = Vector3(0.45, 0.3, 0.06)

	var multi: MultiMesh = MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.use_colors = true
	multi.mesh = window_mesh
	multi.instance_count = CONTAINER_COUNT

	var lit: Color = Color(0.302, 0.639, 1.0)      # #4da3ff — Container läuft
	var dark: Color = Color(0.06, 0.08, 0.11)      # Container aus

	# Deterministisch: derselbe Seed liefert bei jedem Start dasselbe Muster.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 48
	var dark_indices: Dictionary = {}
	while dark_indices.size() < DARK_WINDOWS:
		dark_indices[rng.randi_range(0, CONTAINER_COUNT - 1)] = true

	# Fenster sitzen auf der Vorderseite (+Z), leicht vor der Fassade.
	var z: float = tower_depth * 0.5 + 0.02
	var spacing: float = tower_width / float(WINDOWS_PER_FLOOR + 1)

	for index: int in range(CONTAINER_COUNT):
		var floor_index: int = index / WINDOWS_PER_FLOOR
		var column: int = index % WINDOWS_PER_FLOOR
		var x: float = -tower_width * 0.5 + spacing * float(column + 1)
		var y: float = floor_height * (float(floor_index) + 0.6)
		multi.set_instance_transform(index, Transform3D(Basis(), Vector3(x, y, z)))
		multi.set_instance_color(index, dark if dark_indices.has(index) else lit)

	_windows = MultiMeshInstance3D.new()
	_windows.name = "GeneratedWindows"
	_windows.multimesh = multi

	# Emission über Instanzfarbe: ein Material für alle 48 Fenster.
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.emission_enabled = true
	mat.emission = Color(1.0, 1.0, 1.0)
	mat.emission_energy_multiplier = 1.4
	# Emission folgt der Albedo, damit dunkle Fenster nicht mitleuchten.
	mat.emission_operator = BaseMaterial3D.EMISSION_OP_MULTIPLY
	mat.roughness = 0.3
	_windows.material_override = mat

	add_child(_windows)
