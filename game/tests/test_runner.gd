extends Node
## Minimales Headless-Test-Harness für Alexle Realm.
##
## Warum kein GUT: GUT ist ein zusätzliches Addon mit eigener Update-Last und
## Lizenzfrage. Für das, was Abschnitt 26 des Auftrags verlangt (Kollision,
## Tür/Key, Chest-Einmaligkeit, Damage, I-Frames, Save/Load, Dungeon-Clear),
## reicht ein eigener Runner. Kein Fremdcode.
##
## Warum eine Szene und nicht `--script`: Im `--script`-Modus baut Godot keine
## Autoloads auf, GameState/EventBus/SaveManager wären nicht vorhanden. Als
## Szene läuft der Runner gegen die echte Verdrahtung.
##
## Aufruf (oder einfach tools/run_tests.sh):
##   godot --headless --path game res://tests/test_main.tscn
##
## Exit-Code 0 = alle Tests grün, 1 = mindestens ein Fehlschlag.
##
## Eine Testdatei ist ein Script unter res://tests/ mit Namen test_*.gd, das
## `Node` erweitert und kein `class_name` setzt. Methoden:
##   func test_*()   -> synchroner Test
##   func atest_*()  -> Test, der Frames abwarten darf (await)
##   func before_each() / after_each()  -> optional
## Der Runner injiziert sich per `set_runner(runner)`.

const TEST_DIR: String = "res://tests"

var _failures: PackedStringArray = []
var _passed: int = 0
var _current_test: String = ""


func _ready() -> void:
	await _run_all()


func _run_all() -> void:
	print("== Alexle Realm Testlauf ==")
	var files: PackedStringArray = _collect_test_files()
	if files.is_empty():
		print("WARNUNG: keine Testdateien unter %s gefunden." % TEST_DIR)

	for path: String in files:
		await _run_file(path)

	# Schutz gegen falsches Grün: Wenn Dateien gefunden wurden, aber keine
	# einzige Testmethode gelaufen ist, war etwas kaputt (Parse-Fehler,
	# falsche Methodennamen, leere Datei). Ohne diese Prüfung meldete der
	# Runner "0 bestanden, 0 fehlgeschlagen" und Exit 0 — ein Fehlschlag,
	# der wie Erfolg aussieht.
	if not files.is_empty() and _passed == 0 and _failures.is_empty():
		_failures.append(
			"Keine Testmethode ausgeführt, obwohl %d Testdatei(en) gefunden wurden."
			% files.size()
		)

	print("")
	print("== Ergebnis: %d bestanden, %d fehlgeschlagen ==" % [_passed, _failures.size()])
	for f: String in _failures:
		print("  FEHLER  %s" % f)

	get_tree().quit(1 if _failures.size() > 0 else 0)


func _collect_test_files() -> PackedStringArray:
	var result: PackedStringArray = []
	# Optionaler Filter: alles nach "--" auf der Kommandozeile gilt als
	# Liste von Dateinamen. Nötig, weil mehrere Entwickler parallel an
	# eigenen Testdateien arbeiten und dann nicht die halbfertigen Dateien
	# der anderen mitlaufen lassen wollen.
	#   godot --headless --path game res://tests/test_main.tscn -- test_player.gd
	var filter: PackedStringArray = OS.get_cmdline_user_args()

	var dir: DirAccess = DirAccess.open(TEST_DIR)
	if dir == null:
		push_error("Testverzeichnis nicht lesbar: %s" % TEST_DIR)
		return result
	dir.list_dir_begin()
	var fname: String = dir.get_next()
	while fname != "":
		if not dir.current_is_dir() and fname.begins_with("test_") and fname.ends_with(".gd"):
			if fname != "test_runner.gd" and (filter.is_empty() or filter.has(fname)):
				result.append("%s/%s" % [TEST_DIR, fname])
		fname = dir.get_next()
	dir.list_dir_end()
	result.sort()

	if not filter.is_empty():
		print("(Filter aktiv: %s)" % ", ".join(filter))
	return result


func _run_file(path: String) -> void:
	var script: Script = load(path)
	if script == null:
		_failures.append("%s: Script nicht ladbar" % path)
		return

	# Bei einem Parse-Fehler liefert load() ein Script-Objekt zurück, das sich
	# nicht instanziieren lässt. Ungeprüft würde script.new() hier nur eine
	# Fehlermeldung ins Log schreiben und der Lauf ginge scheinbar gut weiter.
	if not script.can_instantiate():
		_failures.append(
			"%s: Script nicht instanziierbar — Parse-Fehler oder fehlendes extends Node."
			% path
		)
		return

	var instance: Variant = script.new()
	if not instance is Node:
		_failures.append("%s: Testklasse muss Node erweitern" % path)
		return

	var node: Node = instance
	add_child(node)
	if node.has_method("set_runner"):
		node.call("set_runner", self)

	print("")
	print("-- %s" % path.get_file())

	# Methodenliste vorher einsammeln: Tests dürfen Kinder anlegen, das soll
	# die Iteration nicht beeinflussen.
	var sync_tests: PackedStringArray = []
	var async_tests: PackedStringArray = []
	for method: Dictionary in node.get_method_list():
		var mname: String = str(method.get("name", ""))
		if mname.begins_with("test_"):
			sync_tests.append(mname)
		elif mname.begins_with("atest_"):
			async_tests.append(mname)
	sync_tests.sort()
	async_tests.sort()

	for mname: String in sync_tests:
		_begin_test(path, mname, node)
		node.call(mname)
		_end_test(mname, node)

	for mname: String in async_tests:
		_begin_test(path, mname, node)
		await node.call(mname)
		_end_test(mname, node)

	node.queue_free()


var _failures_before: int = 0


func _begin_test(path: String, mname: String, node: Node) -> void:
	_current_test = "%s::%s" % [path.get_file(), mname]
	# Jeder Test startet auf definiertem Zustand. Ohne das sickern Flags und
	# Inventar aus vorherigen Tests durch und Fehler werden unreproduzierbar.
	GameState.reset()
	if node.has_method("before_each"):
		node.call("before_each")
	_failures_before = _failures.size()


func _end_test(mname: String, node: Node) -> void:
	if node.has_method("after_each"):
		node.call("after_each")
	if _failures.size() == _failures_before:
		_passed += 1
		print("   ok    %s" % mname)
	else:
		print("   FAIL  %s" % mname)


# --- Helfer für zeitabhängige Tests ---------------------------------------

## Wartet echte Physik-Frames ab. Nur in atest_*-Methoden verwenden.
## Nötig für alles, was auf Area3D-Überlappung beruht (HitBox/HurtBox):
## Godot wertet Überlappungen erst im Physik-Schritt aus.
func wait_physics_frames(count: int = 1) -> void:
	for _i: int in range(maxi(1, count)):
		await get_tree().physics_frame


# --- Assertions ------------------------------------------------------------

func assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append("%s: %s (erwartet true)" % [_current_test, message])


func assert_false(condition: bool, message: String) -> void:
	if condition:
		_failures.append("%s: %s (erwartet false)" % [_current_test, message])


func assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s: %s (ist %s, erwartet %s)"
			% [_current_test, message, str(actual), str(expected)])


func assert_ne(actual: Variant, unexpected: Variant, message: String) -> void:
	if actual == unexpected:
		_failures.append("%s: %s (sollte nicht %s sein)"
			% [_current_test, message, str(unexpected)])


func assert_almost_eq(actual: float, expected: float, tolerance: float, message: String) -> void:
	if absf(actual - expected) > tolerance:
		_failures.append("%s: %s (ist %f, erwartet %f +/- %f)"
			% [_current_test, message, actual, expected, tolerance])


## Explizites Scheitern, z.B. in einem Zweig, der nicht erreicht werden darf.
func fail(message: String) -> void:
	_failures.append("%s: %s" % [_current_test, message])
