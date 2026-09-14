# HANDOVER — Alexle Realm

Übergabe an den nächsten Bearbeiter (Mensch oder Agent). Diese Datei ist so
geschrieben, dass sie **allein** ausreicht: kein Zugriff auf den vorigen
Gesprächsverlauf nötig.

Stand der Übergabe: 2026-09-15, nach Abschluss der M1-Inhalte
Projektpfad: `/Volumes/T7/Projekte/alexle135 spiel`

| Was | Wo |
|---|---|
| Einstieg, Aufbau, Befehle | [README.md](README.md) |
| Zustandsbericht: funktioniert / offen / Bugs | [docs/PROGRESS.md](docs/PROGRESS.md) |
| Logbuch: jeder Befehl, jede Entscheidung, jeder Rückschlag | [STATUS.md](STATUS.md) |
| Kanon, Annahmen, Zone-zu-Mechanik-Mapping | [docs/RESEARCH.md](docs/RESEARCH.md) |
| Architekturentscheidungen mit verworfenen Alternativen | [docs/DESIGN.md](docs/DESIGN.md) |
| Lizenzregeln, Blender-Pipeline | [docs/ASSETS.md](docs/ASSETS.md) |
| Arbeitsregister | [.arg/registry.yaml](.arg/registry.yaml), Regeln in [docs/ARG.md](docs/ARG.md) |

---

## 1. Wo du stehst

**M1 Vertical Slice: Inhalt vollständig, headless verifiziert.**

```bash
tools/run_tests.sh        # → 99 bestanden, 0 fehlgeschlagen, Exit 0
tools/smoke_test.sh       # → Exit 0
python3 tools/arg_check.py # → Exit 0, 15 Tasks, alle mit Belegen
```

Der spielbare Ablauf: Spawn → AS ansprechen (Quest „Seite down") → Kiste öffnen
(Schwert ed25519, 15 Packets) → Bitrot-Schleim besiegen → Terminal-Schlüssel
aufnehmen → zurück zu AS (Quest erledigt) → Tor zum Terminal-Ufer aufschließen.

**Wichtigste Einschränkung:** Alle 99 Nachweise sind headless. Dass die Figur
steht, sich dreht, trifft und stirbt, ist gemessen. Wie sich Kameraabstand,
Lauftempo und die Angriffsvorwarnung von 0,5 s **anfühlen**, ist nicht gemessen.

---

## 2. Git-Zustand — bitte zuerst klären

```
Branch:   main
Commits:  3, alle als "Alexander Schneider <schneider@alexle135.de>"
          b82c6b1  Add core systems, player, enemies, and project structure
Getrackt: 116 Dateien, 1,6 MB ohne game/.godot/
```

**Unkommittiert im Arbeitsverzeichnis:**

```
 M .arg/registry.yaml          Statuswerte korrigiert, T-011 gefüllt
 M README.md                   Testzahlen, Asset-Fahrplan
 M STATUS.md                   Schritt 13, R9, R10, Abschnitt 8
 M game/enemies/enemy_base.gd  _face_player() — der R9-Fix
 M game/scenes/hub.tscn        Bitrot-Schleim eingehängt
 M game/tests/test_enemies.gd  +1 Regressionstest (Trefferlage)
 M game/tests/test_hub.gd      +2 Tests (Schleim im Hub, Persistenz)
 D game/tests/zz_debug.gd      Debug-Sonde entfernt (ist in HEAD eingecheckt)
 D game/tests/zz_debug.gd.uid
?? docs/PROGRESS.md            neu
?? HANDOVER.md                 diese Datei
```

**Offene Frage an den Auftraggeber:** Branch + PR oder direkt auf `main`?
Es wurde bewusst nichts committet — die Arbeitsregel lautet „keine Edits auf
`main`, PR-Workflow ist Default". Kläre das, bevor du selbst committest.

Nebenbefund: `game/tests/zz_debug.gd` (eine Debug-Sonde mit `print`-Ausgaben,
die ein Subagent liegen ließ) ist in `HEAD` eingecheckt. Die Löschung liegt
unkommittiert vor.

---

## 3. Werkzeuge und die vier Befehle

| Werkzeug | Version | Hinweis |
|---|---|---|
| Godot | 4.7.stable.official.5b4e0cb0f | **nicht im `PATH`** |
| Blender | 5.2.1 LTS | erst ab M3 nötig |
| Python | 3.14.7 + PyYAML | für `arg_check.py` |

Godot liegt unter `/Applications/Godot.app/Contents/MacOS/Godot`. Alle Skripte
nutzen diesen Pfad und lassen sich mit `GODOT=…` überschreiben.

```bash
# 1) Nach dem Anlegen einer Datei mit neuem class_name ZWINGEND zuerst:
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --import

# 2) Testsuite, optional mit Dateifilter
tools/run_tests.sh
tools/run_tests.sh test_enemies.gd

# 3) Startet das Projekt überhaupt?
tools/smoke_test.sh

# 4) Arbeitsregister konsistent?
python3 tools/arg_check.py
```

Vergisst man Schritt 1, scheitert der Testlauf mit
`Parse Error: Identifier "..." not declared`. Das ist keine Regression,
sondern der fehlende Import.

---

## 4. Architektur in fünf Sätzen

1. **`GameState` ist die einzige Quelle der Wahrheit** (Autoload). Gesundheit,
   Packets, Inventar, Weltflags, Quests, Checkpoint. Lesen direkt, Schreiben nur
   über Methoden — jede Änderung löst ein Signal aus.
2. **Gesundheit rechnet in Viertelherzen als Ganzzahl.** `QUARTERS_PER_HEART = 4`,
   `START_HEARTS = 4`, also 16 Viertel zu Beginn. Keine Fließkommazahlen, damit
   Speicherstände exakt vergleichbar bleiben.
3. **Der Weltzustand liegt vollständig in `GameState.flags`** (String → bool).
   `set_flag` ist idempotent. Jedes Objekt stellt beim `_ready` seinen
   Flag-Zustand wieder her, statt frisch zu starten — daraus folgen
   Kisten-Einmaligkeit und Dungeon-Persistenz ohne Sonderlogik.
4. **`EventBus` enthält nur Signale, keine Logik.** Die UI kennt den Spieler
   nicht, der Spieler kennt keine Kisten. Zusammengeführt wird **ausschließlich**
   in `game/scenes/hub.gd`. Halte das so: Es ist der Grund, warum die Systeme
   einzeln testbar sind.
5. **Der Speicherstand ist versioniertes JSON ohne Godot-Typen** unter
   `user://saves/slot_N.json`, mit `_migrate`-Haken. Extern lesbar und als
   Test-Fixture schreibbar.

**Kampfkontrakt** (geteilt zwischen Spieler und Gegnern): `HitBox.activate(dauer)`
öffnet ein Angriffsfenster und trifft jede `HurtBox` höchstens **einmal pro
Aktivierung** — auch bei Überlappung, die schon vor dem Öffnen bestand (deshalb
iteriert `activate` `get_overlapping_areas()` von Hand; Godot feuert
`area_entered` nur bei NEUER Überlappung). `HurtBox` **meldet nur**, die Folgen
entscheidet der Besitzer.

Kollisionslayer: `world=1, player=2, enemy=4, interactable=8, player_hitbox=16,
enemy_hitbox=32, trigger=64`.

---

## 5. Dateikarte

```
game/                       Godot-Projekt — project.godot liegt HIER, nicht in der Wurzel
├── project.godot           GESCHÜTZT. 13 Input-Actions, 7 Layer. Nicht ändern.
├── scenes/hub.tscn         Integrationsszene, hier hängt aller M1-Inhalt
├── scenes/hub.gd           die EINZIGE Stelle, die Systeme miteinander verdrahtet
├── player/                 player.gd/.tscn, player_camera.gd
├── enemies/                enemy_base.gd (Basisklasse), bitrot_slime.gd/.tscn
├── world/                  hub_blockout.gd (21 Quader aus Datentabelle), vps_tower.gd
├── ui/                     hud, heart_row, dialogue_box, pause_menu, theme.tres
├── scripts/core/           GESCHÜTZT-nah: event_bus, game_state, save_manager
├── scripts/systems/        hit_box.gd, hurt_box.gd — der geteilte Vertrag
├── scripts/interactions/   interactable.gd + 7 Unterklassen
└── tests/                  test_runner.gd + 7 Testdateien
tools/                      run_tests.sh, smoke_test.sh, arg_check.py
blender/                    leer bis M3
```

Das Blockout wird **im Code aus einer Datentabelle** erzeugt, nicht als
handgepflegte `.tscn`. Der Austausch gegen Blender-Meshes in M3 ist damit ein
Löschen, kein Umbau.

---

## 6. Das Test-Harness verstehen

Eigenbau, rund 180 Zeilen, kein GUT. Eigenheiten, die nicht offensichtlich sind:

- **Der Runner ist eine Szene**, kein `--script`-Aufruf. Grund: Autoloads
  existieren nur im Szenenbetrieb. Ein `extends SceneTree`-Runner sieht
  `GameState` nicht.
- Testdateien liegen in `game/tests/`, heißen `test_*.gd`, erweitern `Node` und
  setzen **kein** `class_name`.
- `test_*` läuft synchron, **`atest_*` darf Frames abwarten**
  (`await _runner.wait_physics_frames(n)`). Alles, was auf `Area3D`-Überlappung
  beruht, braucht `atest_`.
- Vor jedem Fall ruft der Runner `GameState.reset()`.
- **Der Runner zählt Testmethoden, nicht Assertions.** „99 bestanden" heißt
  99 Methoden.
- Prüfungen: `assert_true`, `assert_false`, `assert_eq`, `assert_ne`,
  `assert_almost_eq(ist, soll, toleranz, text)`, `fail(text)`.
- `queue_free()` wirkt erst nach einem Frame. In synchronen Tests deshalb
  **`free()`** benutzen, sonst bleiben alte Platzhalter in der Gruppe `"player"`
  und verfälschen den nächsten Test.
- **`test_core_state.gd` erzeugt absichtlich Godot-Fehlerzeilen**, wenn es
  ungültige Speicherplätze abweist. Deshalb grept `run_tests.sh` nur nach
  `Parse Error|Failed to load script|Compile Error`, nicht nach `ERROR:`.
  Maßgeblich sind die Ergebniszeile und der Exit-Code.

---

## 7. Stolperfallen, die schon Zeit gekostet haben

| Falle | Was gilt |
|---|---|
| **Ursprung der Spielfigur liegt an den FÜSSEN** | `CollisionShape3D` ist um y = 0,875 versetzt. Auf einem Boden mit Oberkante 0 ist y ≈ 0 richtig, nicht 0,875. Spawn steht auf y = 0,1. |
| **Ursprung des Schleims liegt in der Kugelmitte** | Radius 0,5, also y = 0,5. Nicht mit der Figur verwechseln. |
| **Das Harness meldete einmal falsches Grün** | Ein Parse-Fehler ergab „0 bestanden, 0 fehlgeschlagen" und **Exit 0**. Behoben dreifach (siehe STATUS.md R3). Konsequenz: Erfolgsmeldungen von Subagenten immer selbst nachfahren. |
| **`get_tree().current_scene` kann null sein** | Szenenpfade aus `owner` ableiten, nicht aus `current_scene`. Ein falscher Wert dort ist ein kaputter Speicherstand. |
| **`.tres` mit `;`-Kommentaren vor `[gd_resource]`** | funktioniert, ist geprüft. |
| **Maximal drei parallele Godot-Prozesse** | gemeinsamer Import-Cache unter `game/.godot/`. |
| **Die Testsuite ist geteilter Zustand** | Bei paralleler Arbeit `tools/run_tests.sh <datei>` benutzen, vor der Integration immer ungefiltert. |
| **Gegner drehen sich nicht von allein** | Die HitBox der Gegnerszenen sitzt auf lokal z = −0,8. Ohne `_face_player()` schlägt ein Gegner immer nach Welt-−Z. War R9. Wenn du einen neuen Gegnertyp baust: Das erledigt die Basisklasse, aber prüfe die Trefferlage in mehreren Richtungen. |

---

## 8. Was als Nächstes zu tun ist, in dieser Reihenfolge

1. **Ein Durchlauf am Bildschirm.** Nicht headless. Kameraabstand, Lauftempo
   (WALK 4,5 / SPRINT 7,5), Telegraph-Länge 0,5 s und Hit-Stop 0,08 s prüfen und
   gegebenenfalls anpassen. Kostet Minuten und kann Werte verschieben, auf denen
   sonst der ganze Dungeon aufbaut. **Kein neuer Inhalt davor.**
2. **Git-Frage klären** (Abschnitt 2), dann den aktuellen Stand sichern.
3. **M2 beginnen:** zweiter und dritter Gegnertyp, Mini-Boss, erster echter
   Dungeon mit Schlüssel-Tür-Rätsel und Bosstür. Der Erweiterungspunkt ist
   `Enemy._perform_attack()` — ein neuer Typ erbt und überschreibt nur diese
   Methode plus die `@export`-Werte in seiner Szene.
4. **`arg_check.py` erweitern** (Lehre aus R10): auch melden, wenn Evidence
   vollständig und Validierung ausgeführt ist, der Status aber auf `planned`
   steht. Der Fehler in der anderen Richtung wird bisher nicht gesehen.
5. **`tools/run_tests.sh` und `tools/arg_check.py` als ARG-Tasks nachtragen.**
   Fünf Agentenrollen (`blender-assets`, `docs-maintainer`, `godot-world`,
   `license-review`, `qa-gameplay`) haben noch keinen Task.
6. **Assets erst in M3.** Reihenfolge und Regeln in Abschnitt 10.

---

## 9. Drei Punkte, die dem Auftraggeber gehören

1. **Farbpalette.** Das Spiel folgt der Auftragsvorgabe: dunkel, blaue Akzente.
   Die aktuelle Website (`alexle-vsco/src/styles/warm-noir.css`) ist dagegen
   warm-monochrom — Sepiatöne, grüne Werte unter „orange"-Variablennamen,
   Terrakotta; Blau nur als `--signal-info`. Entschieden wurde für Blau, weil
   der Auftrag es verlangt **und** Blau im Spiel zusätzlich die Funktion
   „benutzbar" trägt. Die Palette liegt in genau drei Dateien:
   `game/ui/theme.tres`, `game/world/materials/mat_accent.tres`,
   `game/world/realm_environment.tres`. Umstellung ist damit abgegrenzt.
   Details: [docs/RESEARCH.md](docs/RESEARCH.md) §1.3, [STATUS.md](STATUS.md) R6.
2. **Branch-Strategie** (Abschnitt 2).
3. **Freigabe für Asset-Downloads** — bisher wurde keine erteilt und keiner
   durchgeführt.

---

## 10. Regeln, die nicht verhandelbar sind

**Datenschutz.** Niemals ins Repository: Passwörter, Tokens, API-Keys,
SSH-Keys, `.env`, private IP-Adressen, private Adressen, Telefonnummern,
sonstige private Daten. Vor jedem Commit auf Secrets prüfen. Thema und Story
basieren ausschließlich auf öffentlich auf alexle135.de Veröffentlichtem —
**keine erfundenen Lebensläufe oder Ereignisse.** Der Mentor-NPC spricht über
Technik, nie über Biografie. `/Volumes/T7/Projekte/alexle-vsco` bleibt lokal;
nichts daraus wird kopiert oder hochgeladen.

**Lizenzen.** Nur CC0, Public Domain, eindeutig kompatibel Lizenziertes oder
Eigenbau. Jedes Fremdasset **vor** der Nutzung in [docs/ASSETS.md](docs/ASSETS.md)
mit Quelle, Autor, Lizenz, Abrufdatum und Änderungen dokumentieren. Verboten:
Nintendo- und Zelda-Assets in jeder Form, aus Spielen extrahierte Dateien,
ungeklärte Pinterest-Dateien, gescrapte Store-Assets, geschützte Musik. Die
Zelda-Anlehnung ist **strukturell** (Dungeon-Aufbau, Item-öffnet-Weg, Herzen),
nicht visuell. Derzeit liegt **kein einziges Fremdasset** im Repo.

**Definition of Done.** „Code geschrieben" ist nicht fertig:

```
Implementierung + Projekt startet (smoke_test.sh Exit 0)
+ relevanter Test erfolgreich (run_tests.sh Exit 0)
+ keine offensichtliche Regression
+ Dokumentation aktualisiert
+ ARG aktualisiert (arg_check.py Exit 0)
+ Evidence vorhanden
```

**ARG-Regel.** `verified` und `done` sind ohne Belege nicht zulässig; ohne Beleg
ist der höchste erreichbare Status `review`. `validation` enthält **ausgeführte**
Befehle mit Ergebnis, nicht geplante. Offene Punkte als `"OFFEN: …"` — dann ist
`verified` gesperrt. Die ARG ist kein Wunschzettel.

**Maßgabe bei Zielkonflikten:**
`spielbar > stabil > verständlich > atmosphärisch > umfangreich`.
Ein sehr guter Dungeon schlägt acht unfertige Biome.

---

## 11. Wenn du Arbeit delegierst

Jeder Subagenten-Auftrag braucht: klaren Umfang, konkrete Eingabedateien,
erwartete Ausgabedateien, messbare Erfolgskriterien, **explizite Grenzen**
(was nicht angefasst werden darf) und einen Validierungsbefehl.

Was beim Lead bleibt: Gesamt- und Gameplay-Architektur, zentrale Datenmodelle,
Story- und Weltkonsistenz, Datenschutz-, Lizenz- und Sicherheitsentscheidungen,
Savegame-Architektur, komplexe systemübergreifende Fehler, offene Fehlersuche,
größere Refactorings, Performance-Architektur, Endintegration und alle
Abschlussreviews.

**Ergebnisse niemals blind übernehmen.** Prüfen auf: technische Korrektheit,
Scope-Treue, Regressionen, Architekturkonformität, Lizenzprobleme, erfundene
Inhalte, Secrets, unnötige Abhängigkeiten, Performanceprobleme.

Die Bilanz dieses Projekts als Begründung: Von sieben Lieferungen wurden
**drei nur nach Korrektur** angenommen — und in allen drei Fällen war der Fehler
von den mitgelieferten grünen Tests nicht abgedeckt (STATUS.md R4, R8, R9).
Gefunden wurden alle drei beim **Lesen**, nicht beim Messen. Grüne Suite ist
notwendig, nicht ausreichend.

**Zwei konkrete Verbote für Subagenten-Prompts**, beide aus Vorfällen:

- **Keine Prozess-Kills.** Ein Agent führte `pkill -9 -f "(Godot)"` aus und
  beendete alle Engine-Prozesse der Sitzung. Diesmal ohne Schaden, weil er
  allein lief; bei drei parallelen Agenten hätte er fremde Testläufe
  abgebrochen — und die Fehlschläge wären bei den anderen aufgetaucht.
- **Keine Dateien außerhalb des zugewiesenen Umfangs**, auch keine temporären.
  Ein Agent ließ `game/tests/zz_debug.gd` im Repo zurück, ohne es im
  Abschlussbericht zu erwähnen.

Und eine Selbstkritik zum Mitnehmen: Eine meiner Spezifikationen war
widersprüchlich (`collision_mask = 0` für *jedes* Interactable hätte
`body_entered` bei Checkpoint, Druckplatte und Auto-Aufnahme strukturell
unmöglich gemacht). Der Agent hat den Widerspruch aufgelöst statt die Vorgabe
stumpf zu befolgen. Das war richtig. Wenn eine Vorgabe nicht aufgeht, melde es
statt sie zu erfüllen.
