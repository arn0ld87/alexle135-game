# Alexle Realm

**Die Wiederherstellung von alexle135.de**

Ein 3D-Action-Adventure im Zelda-Aufbau, dessen Welt aus echter Infrastruktur besteht.
Leipzig, das BFW, ein Homelab, Server und das Internet verschmelzen zu einer begehbaren
Infrastruktur-Welt. Der Spieler ist ein digitaler Wanderer, der ein zersplittertes
Wissensnetz wieder verbindet.

Godot 4.7 · GDScript · Forward+ · Blender 5.2 LTS · glTF 2.0

---

## Was dieses Projekt besonders macht

Die Kulisse ist nicht der Punkt. Der Punkt ist die **Mechanik-Herkunft**: Jedes Rätsel
folgt aus einer echten Eigenschaft des Projekts, das die Zone benennt.

| Zone | Echte Eigenschaft | Daraus folgende Mechanik |
|---|---|---|
| Traefik-Grat | Middleware-Reihenfolge zählt | Tore öffnen nur in der richtigen Reihenfolge; die Hydra bekommt pro Runde einen Kopf mehr, solange sie falsch bleibt |
| Ansible-Steppe | Idempotenz | Rätsel, die man beliebig oft ausführen kann, ohne dass sich etwas ändert. Nur der fehlende Schritt zählt |
| Agora-Archiv | Evidence-Gating | Graph-Rätsel, in dem nur belegte Kanten tragen. Das Phantom erzeugt plausible Kanten ohne Quelle — wer darauf tritt, fällt |
| Terminal-Ufer | Fork-Bomben forken Prozesse | Der Boss teilt sich bei Treffern. Er muss begrenzt werden, nicht erschlagen |
| Homelab-Dorf | VPS mit rund 48 Docker-Containern | Der VPS-Turm zeigt genau 48 Fenster. Ein Test prüft die Zahl mit |

Eine Zone, die nur den Namen eines Projekts trägt und ein Standardrätsel enthält, hätte
den Punkt verfehlt. Die vollständige Zuordnung steht in
[docs/RESEARCH.md](docs/RESEARCH.md) Abschnitt 2 — jede Sachaussage dort ist auf eine
Quelle zurückführbar.

---

## Stand

**Milestone M1 (Vertical Slice) — in Arbeit.** Was nachweisbar funktioniert:

| Bereich | Zustand | Nachweis |
|---|---|---|
| Projekt startet headless | grün | `tools/smoke_test.sh` → Exit 0 |
| Datenmodell, Speichern und Laden | grün | 25 Tests |
| Spieler, Kamera, Nahkampf | grün | 14 Tests |
| HUD, Dialog, Pause und Optionen | grün | 9 Tests |
| Weltressourcen, VPS-Turm | grün | 9 Tests |
| Kisten, Türen, Schlüssel, Checkpoints | grün | 14 Tests |
| Hub-Szene (Integration) | grün | 12 Tests |
| Gegner | in Arbeit | — |

**83 Testfälle grün**, keine bekannten Fehlschläge. Der aktuelle Stand, alle
Entscheidungen und alle Rückschläge stehen fortlaufend in [STATUS.md](STATUS.md).

Was in M1 **nicht** enthalten ist, bewusst: eine große offene Welt, Reiten, Wetter,
Mehrspieler, Blender-Modelle (die Welt läuft auf Primitivgeometrie), eine funktionierende
Mini-Map (nur Platzhalter) und ein Quest-Log-Fenster. Begründungen in
[docs/DESIGN.md](docs/DESIGN.md) Abschnitt 11.

---

## Schnellstart

### Voraussetzungen

- **Godot 4.3 oder neuer.** Entwickelt und getestet mit 4.7. Download:
  [godotengine.org](https://godotengine.org/download)
- Optional für die Asset-Pipeline: **Blender 4.x oder neuer** (verwendet wird 5.2 LTS)
- Optional für die ARG-Prüfung: **Python 3.12+** mit PyYAML

### Spielen

Das Godot-Projekt liegt im Unterordner `game/`, nicht im Wurzelverzeichnis.

1. Godot starten, **Import** wählen
2. `game/project.godot` öffnen
3. F5 drücken

Oder direkt von der Kommandozeile:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path game
```

Beim ersten Start importiert Godot die Ressourcen. Das dauert einen Moment und ist normal.

### Godot liegt nicht im PATH

Auf macOS liegt die Binärdatei in der App. Alle Skripte im Projekt benutzen standardmäßig
`/Applications/Godot.app/Contents/MacOS/Godot` und lassen sich überschreiben:

```bash
GODOT=/pfad/zu/godot tools/run_tests.sh
```

---

## Steuerung

Kurzfassung. Vollständig und aus der Input-Map abgeleitet:
[docs/CONTROLS.md](docs/CONTROLS.md).

| Aktion | Tastatur / Maus | Gamepad (Xbox) |
|---|---|---|
| Bewegen | W A S D | Linker Stick |
| Kamera | Maus | Rechter Stick |
| Sprinten | Shift | Linker Stick gedrückt |
| Springen | Leertaste | A |
| Interagieren | E | B |
| Angreifen | Linke Maustaste | X |
| Blocken | Rechte Maustaste | RB |
| Item benutzen | F | Y |
| Ziel aufschalten | Q | LB |
| Karte | M | Back |
| Pause | Escape | Menu |

Maus-Sensitivität und Vollbild sind im Pause-Menü unter Optionen einstellbar und werden
in `user://settings.json` gespeichert.

---

## Entwicklung

### Die drei Prüfbefehle

Alle aus dem Wurzelverzeichnis aufzurufen.

```bash
tools/smoke_test.sh
```

Startet das Projekt headless. Prüft den Exit-Code **und** das Log auf Fehlermuster —
Godot kann bei Skriptfehlern trotzdem mit 0 beenden.

```bash
tools/run_tests.sh                    # gesamte Suite
tools/run_tests.sh test_player.gd     # nur eine Datei
```

Führt die Testsuite headless aus. Der Dateifilter ist für parallele Arbeit gedacht: Wer
an einer eigenen Testdatei schreibt, lässt nicht die halbfertigen Dateien anderer
mitlaufen.

```bash
python3 tools/arg_check.py
```

Prüft das Arbeitsregister auf Abschlussbehauptungen ohne Belege, fehlende Dateien,
unbekannte Abhängigkeiten und doppelte IDs.

### Nach dem Anlegen neuer Dateien

Godot registriert ein neues `class_name` erst beim Import:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --import
```

Ohne diesen Schritt scheitert ein Testlauf mit
`Identifier "..." not declared in the current scope`.

---

## Projektstruktur

```text
alexle135 spiel/
├── README.md              diese Datei
├── STATUS.md              Live-Logbuch: Befehle, Entscheidungen, Rückschläge
├── pyproject.toml         Konfiguration der Hilfsskripte
│
├── docs/
│   ├── RESEARCH.md        Kanon, Annahmen, Mapping auf Spielinhalte
│   ├── DESIGN.md          Pitch, Systeme, Zonen, Architekturentscheidungen
│   ├── ASSETS.md          Lizenzregeln und Blender-Pipeline
│   ├── CONTROLS.md        Steuerung, aus der Input-Map abgeleitet
│   ├── PROGRESS.md        Milestone-Protokoll
│   ├── ARG.md             Arbeitsregister: Regeln und Rollen
│   └── research/          Rohdaten mit Quellenangaben
│
├── .arg/registry.yaml     maschinenlesbares Arbeitsregister
├── tools/                 smoke_test.sh, run_tests.sh, arg_check.py
├── blender/               Quelldateien und Exportskripte
│
└── game/                  Godot-Projekt (project.godot liegt HIER)
    ├── scenes/            boot, hub, interactables
    ├── player/            Spieler und Kamera
    ├── world/             Blockout, Materialien, Umgebung
    ├── enemies/           Gegner
    ├── ui/                HUD, Dialog, Menüs
    ├── scripts/
    │   ├── core/          Autoloads: EventBus, GameState, SaveManager
    │   ├── systems/       HitBox, HurtBox
    │   └── interactions/  Kisten, Türen, Schalter, Checkpoints
    ├── assets/            models, textures, audio
    └── tests/             Headless-Testsuite
```

Alles Godot-relevante liegt unter `game/`, weil der Prüfbefehl
`godot --headless --path game` das erzwingt.

---

## Architektur in fünf Punkten

Die vollständige Liste mit verworfenen Alternativen steht in
[docs/DESIGN.md](docs/DESIGN.md) Abschnitt 10.

**1. `GameState` ist die einzige Quelle der Wahrheit.**
Gesundheit, Währung, Inventar, Weltflags, Quests und Checkpoint liegen in einem Autoload.
Szenen und UI dürfen lesen, aber nur über Methoden schreiben — jede Änderung löst ein
Signal aus.

**2. Gesundheit rechnet in Viertelherzen als Ganzzahl.**
Vier Startherzen sind 16 Viertel. Ganzzahlen statt Fließkomma, damit Speicherstände exakt
vergleichbar bleiben und halbe Herzen nicht durch Rundungsfehler entstehen.

**3. Der Weltzustand liegt vollständig in Flags.**
`hub_chest_sword`, `dungeon_terminal_cleared` und so weiter. Daraus folgen zwei
Eigenschaften direkt: Eine Kiste lässt sich nicht mehrfach plündern, weil `set_flag`
idempotent ist. Ein abgeschlossener Dungeon bleibt nach dem Laden abgeschlossen, weil
jedes Objekt beim `_ready` seinen Flag-Zustand wiederherstellt statt frisch zu starten.

**4. `EventBus` enthält nur Signale, keine Logik.**
Die UI kennt den Spieler nicht. Der Spieler kennt keine Kisten. Kisten wissen nicht, wer
sie benutzt. Zusammengeführt wird ausschließlich in `game/scenes/hub.gd`.

**5. Der Speicherstand ist JSON ohne Godot-Typen.**
Menschenlesbar unter `user://saves/slot_N.json`, versioniert, mit einem Migrationspunkt.
Ein Stand lässt sich außerhalb der Engine inspizieren und in Tests als Vorgabe schreiben.

---

## Tests

Die Suite läuft headless und ohne Fremdaddon. Der Runner ist eigenbaut (rund 180 Zeilen)
statt GUT — für den benötigten Umfang kein Fremdcode und keine Lizenzfrage.

```bash
tools/run_tests.sh
```

| Datei | Fälle | Deckt ab |
|---|---|---|
| `test_core_state.gd` | 25 | Gesundheit, Währung, Inventar, Flags, Quests, Speichern und Laden |
| `test_player.gd` | 14 | Bewegung, Angriff, I-Frames, Blocken, Absturzsicherung, Eingabepuffer |
| `test_ui.gd` | 9 | Viertelherz-Genauigkeit, Dialoglebenszyklus, Pause, Speichern aus dem Menü |
| `test_world_assets.gd` | 9 | Ressourcen laden, Art-Direction-Regeln, 48 Container-Fenster |
| `test_interactions.gd` | 14 | Kiste einmalig, Tür mit und ohne Schlüssel, Druckplatte, Checkpoint |
| `test_hub.gd` | 12 | Integration: Spieler fällt nicht durch die Welt, kompletter M1-Ablauf |

### Eine Testdatei schreiben

Ein Script unter `game/tests/` mit Namen `test_*.gd`, das `Node` erweitert und **kein**
`class_name` setzt:

```gdscript
extends Node

var _runner: Object = null

func set_runner(runner: Object) -> void:
    _runner = runner

func test_etwas_synchrones() -> void:
    _runner.assert_eq(2 + 2, 4, "Grundrechenarten")

func atest_etwas_mit_physik() -> void:
    await _runner.wait_physics_frames(2)
    _runner.assert_true(true, "nach zwei Physikschritten")
```

`test_*` läuft synchron, `atest_*` darf Frames abwarten — nötig für alles, was auf
Area3D-Überlappung beruht. Vor jedem Fall ruft der Runner `GameState.reset()`, damit
keine Flags aus dem vorherigen Test durchsickern.

Verfügbare Prüfungen: `assert_true`, `assert_false`, `assert_eq`, `assert_ne`,
`assert_almost_eq(ist, soll, toleranz, text)`, `fail(text)`.

### Ein Hinweis zu Fehlermeldungen im Testlauf

`test_core_state.gd` erzeugt **absichtlich** Godot-Fehlerzeilen, wenn es die Abweisung
ungültiger Speicher-Slots prüft. Das ist erwartetes Verhalten und kein Fehlschlag.
Maßgeblich ist die Zeile `== Ergebnis: N bestanden, 0 fehlgeschlagen ==` und der
Exit-Code.

---

## Mitwirken

### Das Arbeitsregister (ARG)

Zuständigkeiten und Arbeitsstand stehen in [.arg/registry.yaml](.arg/registry.yaml), die
Regeln in [docs/ARG.md](docs/ARG.md). Die zentrale Regel:

> `verified` und `done` sind ohne Belege nicht zulässig. Ohne Beleg ist der höchste
> erreichbare Status `review`.

`validation` enthält **ausgeführte** Befehle mit deren Ergebnis, nicht geplante. Ein
noch offener Punkt wird als `"OFFEN: ..."` notiert — dann ist `verified` automatisch
gesperrt. `tools/arg_check.py` setzt das durch.

### Definition of Done

```text
Implementierung vorhanden
+ Projekt startet (tools/smoke_test.sh, Exit 0)
+ relevanter Test erfolgreich (tools/run_tests.sh, Exit 0)
+ keine offensichtliche Regression
+ Dokumentation aktualisiert
+ ARG aktualisiert (tools/arg_check.py, Exit 0)
+ Evidence vorhanden
```

„Code geschrieben" ist nicht fertig.

### Parallele Arbeit

Die Testsuite ist geteilter Zustand. Läuft `tools/run_tests.sh` ohne Filter, während
jemand anders eine Testdatei schreibt, scheitert der Lauf an fremdem, halbfertigem Code.
Deshalb während der Arbeit mit Filter aufrufen, vor der Integration immer ungefiltert.

---

## Assets und Lizenzen

Verbindlich: [docs/ASSETS.md](docs/ASSETS.md).

**Derzeit sind keine Fremdassets im Repository.** Das Projekt läuft vollständig auf
Primitivgeometrie und prozeduralen Materialien. Es wird Godots Standardschrift verwendet;
keine Schriftdatei ist eingebunden.

Zulässig sind CC0, Public Domain, eindeutig kompatibel lizenzierte Assets und Eigenbau.
Jedes Fremdasset wird mit Quelle, Autor, Lizenz, Abrufdatum und Änderungen dokumentiert.

**Ausgeschlossen:** Nintendo- und Zelda-Assets in jeder Form, aus Spielen extrahierte
Dateien, Material mit ungeklärter Herkunft, urheberrechtlich geschützte Musik. Die
Zelda-Anlehnung ist **strukturell** (Dungeon-Aufbau, Item-öffnet-Weg, Herzen als
Lebensanzeige), nicht visuell.

Die Blender-Pipeline (1 Godot-Einheit = 1 Meter, Ursprung an den Füßen, Blickrichtung
-Y, Metallic/Roughness, glTF-taugliche Materialeingänge) steht in
[docs/ASSETS.md](docs/ASSETS.md) Abschnitt 4.

---

## Datenschutz

Thema, Welt und Story basieren ausschließlich auf öffentlich auf alexle135.de
Veröffentlichtem. Nicht im Repository und nicht im Spiel:

- Passwörter, Tokens, API-Schlüssel, SSH-Schlüssel, `.env`-Dateien
- private IP-Adressen, Postadressen, Telefonnummern, Kontaktadressen
- erfundene Lebensläufe oder Ereignisse

Eine öffentlich belegte geschäftliche Kontaktadresse wurde trotz Zulässigkeit aus den
Recherchedaten entfernt, weil sie für das Spiel keinen Nutzen hat. Der Mentor-NPC spricht
über Technik, nie über Biografie.

Die lokale Bildquelle unter `/Volumes/T7/Projekte/alexle-vsco` bleibt **lokal**. Nichts
davon wird ins Repository kopiert oder hochgeladen, und ihr Lizenzstatus ist ungeklärt.

---

## Kanon und offene Punkte

Zwei Widersprüche in den Quellen wurden **nicht geglättet**:

1. Die Agora-Version wird an einer Stelle als 0.9.0, an anderer als 0.9.5 angegeben.
   Das Spiel nennt deshalb **keine** Agora-Versionsnummer.
2. Das KI-Nachrichten-Portal ist laut Projektseite in Wartung, trägt auf der Startseite
   aber „Stable". Die zugehörige Zone bleibt im Spiel **tatsächlich abgeschaltet**, mit
   Wartungsschild. Kanonisch korrekt und kostet keine Produktionszeit.

**Eine Entscheidung wartet auf den Auftraggeber:** Die aktuelle Website-Palette ist
warm-monochrom (Sepiatöne, grüne und terrakottafarbene Akzente), der Auftrag verlangt
dagegen dunkles Glassmorphism mit Blau. Das Spiel folgt dem Auftrag, weil Blau hier
zusätzlich die Funktion „benutzbar" trägt. Die Palette liegt an drei zentralen Stellen und
ist damit abgegrenzt austauschbar. Werte, Begründung und Umstellweg:
[docs/RESEARCH.md](docs/RESEARCH.md) Abschnitt 1.3 und [STATUS.md](STATUS.md) R6.

---

## Credits

**Alexander Schneider** — Welt, Thema und Kanon, nach den auf
[alexle135.de](https://alexle135.de) veröffentlichten Projekten.

Erstellt mit [Godot Engine](https://godotengine.org) (MIT) und
[Blender](https://www.blender.org) (GPL).

Asset-Lizenzen: [docs/ASSETS.md](docs/ASSETS.md). Derzeit keine Fremdassets.
