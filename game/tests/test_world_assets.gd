extends Node
## Tests für Weltressourcen: Environment und Blockout-Materialien.
##
## Zweck: Diese Ressourcen sind handgeschriebene .tres-Dateien. Ein Tippfehler in
## einem Property-Namen fällt in Godot sonst erst auf, wenn die Szene visuell falsch
## aussieht — headless und ohne Fehlermeldung. Der Test macht das sofort sichtbar.
##
## Zusätzlich sichert er die Regeln der Art Direction ab: der blaue Akzent muss
## tatsächlich über dem Glow-Schwellwert liegen, sonst leuchtet nichts und die
## Weltlesbarkeit ("was blau leuchtet, ist benutzbar") bricht zusammen.

const ENV_PATH: String = "res://world/realm_environment.tres"

const MATERIAL_PATHS: Array[String] = [
	"res://world/materials/mat_floor.tres",
	"res://world/materials/mat_wall.tres",
	"res://world/materials/mat_accent.tres",
	"res://world/materials/mat_glass.tres",
	"res://world/materials/mat_warning.tres",
]

var _runner: Object = null


func set_runner(runner: Object) -> void:
	_runner = runner


func test_environment_laedt() -> void:
	var env: Resource = ResourceLoader.load(ENV_PATH)
	_runner.assert_true(env != null, "Environment ladbar")
	_runner.assert_true(env is Environment, "ist ein Environment")


func test_environment_traegt_art_direction() -> void:
	var env: Environment = ResourceLoader.load(ENV_PATH)
	if env == null:
		_runner.fail("Environment nicht ladbar")
		return
	_runner.assert_true(env.glow_enabled, "Glow aktiv (Emission-Akzente sichtbar)")
	_runner.assert_true(env.fog_enabled, "Fog aktiv (Tiefenwirkung)")
	_runner.assert_true(env.ssao_enabled, "SSAO aktiv (Kanten im Blockout lesbar)")
	# Ein niedriger Schwellwert würde die ganze Szene weichzeichnen.
	_runner.assert_true(env.glow_hdr_threshold >= 1.0,
		"Glow-Schwellwert mindestens 1.0, damit nur echte Emission leuchtet")
	_runner.assert_eq(env.background_mode, Environment.BG_SKY, "Himmel als Hintergrund")
	_runner.assert_true(env.sky != null, "Sky-Ressource vorhanden")


func test_alle_materialien_laden() -> void:
	for path: String in MATERIAL_PATHS:
		var mat: Resource = ResourceLoader.load(path)
		_runner.assert_true(mat != null, "ladbar: %s" % path)
		_runner.assert_true(mat is StandardMaterial3D, "ist StandardMaterial3D: %s" % path)


func test_akzentmaterial_leuchtet_ueber_glow_schwelle() -> void:
	var env: Environment = ResourceLoader.load(ENV_PATH)
	var accent: StandardMaterial3D = ResourceLoader.load("res://world/materials/mat_accent.tres")
	if env == null or accent == null:
		_runner.fail("Environment oder Akzentmaterial nicht ladbar")
		return
	_runner.assert_true(accent.emission_enabled, "Akzent hat Emission")
	# Sonst bleibt der Akzent stumpf und die Welt verliert ihre Orientierungsregel.
	_runner.assert_true(accent.emission_energy_multiplier > env.glow_hdr_threshold,
		"Akzent-Emission liegt über dem Glow-Schwellwert")


func test_warnmaterial_ist_deutlich_heller_als_akzent() -> void:
	var accent: StandardMaterial3D = ResourceLoader.load("res://world/materials/mat_accent.tres")
	var warning: StandardMaterial3D = ResourceLoader.load("res://world/materials/mat_warning.tres")
	if accent == null or warning == null:
		_runner.fail("Materialien nicht ladbar")
		return
	# Boss-Telegraphen müssen sich gegen normale blaue Akzente durchsetzen.
	_runner.assert_true(warning.emission_energy_multiplier > accent.emission_energy_multiplier,
		"Warnung leuchtet stärker als der normale Akzent")


func test_glasmaterial_ist_transparent() -> void:
	var glass: StandardMaterial3D = ResourceLoader.load("res://world/materials/mat_glass.tres")
	if glass == null:
		_runner.fail("Glasmaterial nicht ladbar")
		return
	_runner.assert_ne(glass.transparency, BaseMaterial3D.TRANSPARENCY_DISABLED,
		"Transparenz eingeschaltet")
	_runner.assert_true(glass.albedo_color.a < 1.0, "Alpha unter 1.0")
	_runner.assert_true(glass.albedo_color.a > 0.5,
		"Alpha über 0.5 — Glas, keine unsichtbare Fläche")


func test_vps_turm_zeigt_genau_achtundvierzig_container() -> void:
	# Kanonische Zahl: Homelab mit rund 48 Docker-Containern hinter Traefik.
	# Dieser Test verhindert, dass aus dem Beleg versehentlich Dekoration wird.
	_runner.assert_eq(VpsTower.CONTAINER_COUNT, 48, "kanonische Containerzahl")
	_runner.assert_eq(VpsTower.FLOORS * VpsTower.WINDOWS_PER_FLOOR, 48,
		"Etagen mal Fenster pro Etage ergibt 48")


func atest_vps_turm_erzeugt_achtundvierzig_fenster() -> void:
	var scene: PackedScene = ResourceLoader.load("res://world/vps_tower.tscn")
	_runner.assert_true(scene != null, "Turmszene ladbar")
	if scene == null:
		return

	var tower: Node3D = scene.instantiate()
	add_child(tower)
	await _runner.wait_physics_frames(2)

	_runner.assert_eq(tower.call("window_count"), 48, "48 Fensterinstanzen erzeugt")
	# Der Turm muss den Spieler physisch blockieren, nicht nur aussehen wie ein Turm.
	var body: Node = tower.get_node_or_null("GeneratedBody")
	_runner.assert_true(body != null, "Kollisionskörper erzeugt")
	if body is StaticBody3D:
		_runner.assert_eq((body as StaticBody3D).collision_layer, 1,
			"Turm liegt auf Layer 1 (world)")

	tower.queue_free()


func test_boden_und_wand_sind_unterscheidbar() -> void:
	var floor_mat: StandardMaterial3D = ResourceLoader.load("res://world/materials/mat_floor.tres")
	var wall_mat: StandardMaterial3D = ResourceLoader.load("res://world/materials/mat_wall.tres")
	if floor_mat == null or wall_mat == null:
		_runner.fail("Materialien nicht ladbar")
		return
	# Im Blockout ohne Texturen ist der Helligkeitsunterschied die einzige
	# Information, die Boden von Wand trennt.
	var floor_v: float = floor_mat.albedo_color.get_luminance()
	var wall_v: float = wall_mat.albedo_color.get_luminance()
	_runner.assert_true(absf(wall_v - floor_v) > 0.01,
		"Boden und Wand unterscheiden sich in der Helligkeit")
