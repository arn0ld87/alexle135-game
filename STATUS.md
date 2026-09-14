# STATUS — Alexle Realm

**Live-Logbuch.** Wird fortlaufend gepflegt, nicht rückblickend geschrieben.
Enthält jeden ausgeführten Befehl mit Ergebnis, jede Entscheidung mit Begründung
und jeden Rückschlag mit Behebung — auch die selbstverschuldeten.

Letzte Aktualisierung: 2026-09-15, nach Gegner-Review und Einhängen des Schleims in den Hub
Aktueller Milestone: **M1 Vertical Slice** (Inhalt vollständig, Abschlussbericht offen)

Verwandte Dokumente: [README.md](README.md) · [HANDOVER.md](HANDOVER.md) ·
[docs/PROGRESS.md](docs/PROGRESS.md) ·
[docs/DESIGN.md](docs/DESIGN.md) · [docs/RESEARCH.md](docs/RESEARCH.md) ·
[docs/ASSETS.md](docs/ASSETS.md) · [docs/ARG.md](docs/ARG.md) ·
[.arg/registry.yaml](.arg/registry.yaml)

Arbeitsteilung der Dokumente: **STATUS.md** ist das Logbuch (was wann passiert
ist, mit Befehl und Ergebnis), **docs/PROGRESS.md** der Zustandsbericht (was
funktioniert, was offen ist), **README.md** der Einstieg.

---

## 1. Zustand auf einen Blick

| Bereich | Stand | Nachweis |
|---|---|---|
| Projekt startet headless | grün | `tools/smoke_test.sh` → Exit 0, Log fehlerfrei |
| Datenmodell, Save/Load | grün | `test_core_state.gd` → 25/25 |
| Player, Kamera, Kampf | grün | `test_player.gd` → 14/14 |
| HUD, Dialog, Pause und Optionen | grün | `test_ui.gd` → 9/9 |
| Art-Direction-Ressourcen, VPS-Turm | grün | `test_world_assets.gd` → 9/9 |
| ARG-Konsistenz | grün | `tools/arg_check.py` → Exit 0, 15 Tasks |
| Interaktive Objekte, Checkpoints | grün | `test_interactions.gd` → 14/14, dreimal stabil |
| Gegner, Kampfkontrakt | grün | `test_enemies.gd` → 14/14, inkl. Area3D-Integrationstest |
| Hub-Szene (Integration) | grün | `test_hub.gd` → 14/14, Gegner eingehängt |
| Asset-Inventar | abgeschlossen | 451.618 Dateien erfasst, Secret-Scan clean |
| Fremdassets im Repo | 0 | `find game/assets blender -type f` → 0 Dateien |

**Testsumme aktuell: 99 Testfälle grün** (25 Core + 14 Player + 9 UI + 9 Welt +
14 Interactions + 14 Gegner + 14 Hub), keine bekannten Fehlschläge.
Zählweise: Der Runner zählt Testmethoden, nicht einzelne Assertions.

### Werkzeugversionen

| Werkzeug | Auftrag verlangt | Tatsächlich installiert |
|---|---|---|
| Godot | 4.3+ | **4.7.stable.official.5b4e0cb0f** |
| Blender | 4.x | **5.2.1 LTS** (Build 2026-08-25) |
| Python | — | 3.14.7, PyYAML 6.0.3, uv vorhanden |

Beide Abweichungen gehen nach oben und sind bewusst. Godot liegt **nicht** im `PATH`;
alle Skripte nutzen `/Applications/Godot.app/Contents/MacOS/Godot`, überschreibbar
per `GODOT=`.

---

## 2. Befehlsreferenz

Alles aus dem Repo-Root aufzurufen. Der Pfad enthält ein Leerzeichen — beim
manuellen Aufruf in Anführungszeichen setzen.

```bash
tools/smoke_test.sh
```
Startet das Projekt headless. Prüft Exit-Code **und** das Log auf Fehlermuster,
weil Godot bei Skriptfehlern trotzdem mit 0 beenden kann.

```bash
tools/run_tests.sh
```
Gesamte Testsuite.

```bash
tools/run_tests.sh test_player.gd
```
Nur eine Datei. Für parallele Arbeit gedacht: ohne Filter läuft man gegen die
halbfertigen Testdateien anderer.

```bash
python3 tools/arg_check.py
```
ARG-Hygiene: Abschlussbehauptung ohne Belege, fehlende Dateien, unbekannte
Abhängigkeiten, doppelte IDs.

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --import
```
Nötig nach dem Anlegen neuer Skripte oder Szenen. Ohne diesen Schritt kennt
Godot ein neues `class_name` nicht.

---

## 3. Chronologie

### Schritt 1 — Bestandsaufnahme

Arbeitsverzeichnis war **vollständig leer**: kein Repository, keine Dateien,
kein ARG.

```bash
find . -maxdepth 3 -type d          # nur "."
find . -type f | wc -l              # 0
```

Werkzeugprüfung: Godot 4.7 und Blender 5.2.1 vorhanden, `godot` nicht im `PATH`.

Suche nach einer bestehenden ARG-Konvention, bevor eine neue erfunden wird — auch
in den Nachbarprojekten:

```bash
find /Volumes/T7/Projekte -maxdepth 3 \( -iname 'ARG.md' -o -iname 'registry.yaml' \
  -o -ipath '*/.arg/*' -o -iname 'agent*registry*' \)
grep -rl --include='CLAUDE.md' -iE '\bARG\b|agent registry' /Volumes/T7/Projekte
```

Ergebnis: **keine Treffer.** Es gibt keine Hauskonvention, die übernommen werden
müsste. Daher das Minimalformat aus dem Auftrag, kein konkurrierendes System.

### Schritt 2 — Fundament

Verzeichnisstruktur, `git init`, `.gitignore` mit Secret-Mustern, `project.godot`
mit 13 Input-Actions, sieben Collision-Layern und Forward+.

Danach der zentrale Vertrag, auf dem alle Subagenten aufsetzen: `EventBus`
(nur Signale, keine Logik), `GameState` (einzige Quelle der Wahrheit),
`SaveManager` (versioniertes JSON), `HitBox`/`HurtBox`.

Erster Prüflauf:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --import
tools/smoke_test.sh
# → "Autoload-Selbsttest ok", Exit 0
```

### Schritt 3 — Test-Harness

Eigener Runner statt GUT. 25 Testfälle für Datenmodell und Persistenz:

```bash
tools/run_tests.sh
# → 25 bestanden, 0 fehlgeschlagen, Exit 0
```

### Schritt 4 — Recherche (zwei Subagenten parallel)

Website-Recherche und lokale Asset-Inventur laufen gleichzeitig, weil sie sich
nicht in die Quere kommen.

Website: **25 Seiten** abgerufen, **10 Projekte** erfasst, zwei Kanon-Widersprüche
unaufgelöst dokumentiert statt geglättet.

Review der Rückgabe vor Übernahme:

```bash
grep -nE '^#{1,3} ' docs/research/website-research.md          # 16 Überschriften
grep -nEi '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}|\+49|192\.168\.' docs/research/website-research.md
# → ein Treffer: geschäftliche Kontaktadresse
sed -i '' 's|<adresse>|<bewusst nicht im Repo gespeichert>|g' docs/research/website-research.md
# → Scan danach clean
```

### Schritt 5 — Kanon, ARG, Dokumentation

`docs/RESEARCH.md` mit strikter Trennung Kanon / `[ANNAHME]` / `[FIKTION]`,
Mapping der zehn Projekte auf Zone, Item, NPC, Boss und jeweils eine aus dem
Kanon abgeleitete Mechanik.

ARG angelegt, dazu ein Prüfskript, damit „ARG ist gepflegt" nachweisbar bleibt:

```bash
python3 tools/arg_check.py
# → 13 Tasks, 12 Rollen, 4 Hinweise, 0 Fehler, Exit 0
```

`docs/DESIGN.md`, `docs/ASSETS.md` folgen. `docs/CONTROLS.md` an ein günstiges
Modell delegiert (rein mechanische Ableitung aus der Input-Map) und stichprobenartig
gegengeprüft:

```bash
grep -nE 'Springen|Angreifen|Blocken|Karte|Sprinten' docs/CONTROLS.md
# → 13 Actions, 11 mit Tastatur, 13 mit Gamepad. Differenz erklärt:
#   Angriff und Blocken liegen auf der Maus. Stichproben korrekt.
```

### Schritt 6 — Art Direction in Ressourcen

Weltumgebung und fünf Blockout-Materialien als handgeschriebene `.tres`.
Vorab geprüft, ob Kommentare vor dem `[gd_resource]`-Tag zulässig sind, statt
es zu vermuten — sie sind es.

VPS-Turm mit **48 Container-Fenstern** als MultiMesh in einem Draw Call. Die Zahl
ist Kanon (Homelab mit rund 48 Docker-Containern), deshalb prüft ein Test sie mit.

```bash
tools/run_tests.sh test_world_assets.gd
# → 9 bestanden, 0 fehlgeschlagen, Exit 0
#   inkl. "atest_vps_turm_erzeugt_achtundvierzig_fenster"
```

### Schritt 7 — Implementierung delegiert

Drei Subagenten auf disjunkten Dateibereichen: Player, UI, interaktive Objekte.
Dazu jeweils Scope, Eingabedateien, erwartete Ausgabedateien, messbares
Erfolgskriterium, explizite Verbotsliste und Validierungsbefehl.

### Schritt 8 — Player-Review

Rückgabe des Subagenten: 4 Dateien, 9 Tests, beide Läufe grün.

Eigene Nachprüfung statt Übernahme auf Zuruf:

```bash
grep -c 'SAVE_VERSION: int = 1' game/scripts/core/save_manager.gd   # 1 → unverändert
grep -cE '^[a-z_]+=\{' game/project.godot                           # 13 → keine neue Action
tools/run_tests.sh test_player.gd                                   # 9/9, Exit 0
```

Scope eingehalten, keine geschützte Datei angetastet. Beim Lesen des Codes dann
zwei echte Fehler gefunden, die die Tests nicht abdeckten — siehe Rückschlag 4.
Nach Fix und drei neuen Regressionstests:

```bash
tools/run_tests.sh test_player.gd
# → 14 bestanden, 0 fehlgeschlagen, Exit 0
```

### Schritt 9 — UI-Review

Rückgabe: 13 Dateien, 9 Tests. Eigene Nachprüfung:

```bash
tools/run_tests.sh test_ui.gd            # → 9/9, Exit 0
grep -cE '^[a-z_]+=\{' game/project.godot # → 13, keine neue Action
grep -ohE 'Color\([0-9.]+, ?[0-9.]+, ?[0-9.]+(, ?[0-9.]+)?\)' game/ui/*.tscn game/ui/theme.tres \
  | sort | uniq -c | sort -rn
```

Der Palette-Check über Hex-Werte lief ins Leere — Godot schreibt Farben als Float-Tripel.
Nach Umstellung auf die Float-Form: Akzent `#4da3ff`, heller Akzent `#7cc4ff`, Text
`#e6edf7`, gedimmt `#8b98ab`, Rand `#1d2635`, Herz `#ff5a6e` und das Glas-Panel `#131a26`
bei 82 % Deckkraft exakt wie vorgegeben. **Ohne Nachbesserung angenommen.**

Zwei gemeldete Abweichungen sind sachlich richtig und kein Mangel: Quest-Hinweis und
Item-Slot zeigen die jeweilige ID, weil `GameState` keine Anzeigenamen kennt. Eine
Namensregistry gehört zum Quest-System in M4.

### Schritt 10 — Asset-Inventar widerlegt eine Auftragsannahme

Der Inventur-Subagent lief mit Abstand am längsten (rund 34 Minuten) und lieferte den
inhaltlich folgenreichsten Befund.

**Der Auftrag ging von einer VSCO-Fotobibliothek aus. Das trifft nicht zu.**

| Metrik | Wert |
|---|---|
| Dateien | 451.618 |
| Größe | 6,9 GB |
| Häufigste Typen | `.js` (193.265), `.ts` (78.635), `.map` (49.607), `.astro` (23.551) |
| Bilder | 4.234 (66 % WebP) — Website-Grafiken, keine Fotomotive |
| Schriftdateien | 370 |
| 3D-Dateien | **0** |

Es ist ein **Astro-Web-Monorepo**, allem Anschein nach die Quelle von alexle135.de.

Review vor Übernahme — bei einem Web-Repo ist der Secret-Scan Pflicht, nicht optional:

```bash
grep -nEi '\.env|secret|token|api[_-]?key|password|credential|\.pem|id_rsa' asset-inventory.md
# → keine Treffer
grep -nEi '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}|192\.168\.|\+49' asset-inventory.md
# → keine Treffer
```

**Als Texturquelle ist das Verzeichnis damit weitgehend unbrauchbar** — die geplante
Poster-Textur im Hub ist hinfällig. **Für die Art Direction ist es wertvoller als erwartet:**

```bash
grep -oE '\-\-[a-z0-9-]+:\s*#[0-9a-fA-F]{3,8}' \
  /Volumes/T7/Projekte/alexle-vsco/src/styles/warm-noir.css
grep -ohE "font-family:[^;]+" /Volumes/T7/Projekte/alexle-vsco/src/styles/*.css | sort -u
```

Das ersetzte eine Annahme durch Belege — und legte einen Konflikt offen, siehe R6.

### Schritt 11 — Interactions-Review

Rückgabe: 15 Dateien, 14 Tests. Der Agent meldete, dass Physik-Tests **4** statt
2 Frames abwarten, weil mit 2 Frames „in etwa der Hälfte der Läufe" die
Area3D-Überlappung noch nicht ausgewertet war. Das klang nach einem flaky Test,
also wurde es nachgemessen statt geglaubt:

```bash
for i in 1 2 3; do tools/run_tests.sh test_interactions.gd | grep '^== Ergebnis'; done
# → Lauf 1: 14 bestanden, 0 fehlgeschlagen
# → Lauf 2: 14 bestanden, 0 fehlgeschlagen
# → Lauf 3: 14 bestanden, 0 fehlgeschlagen
grep -rnE 'print\(|DEBUG' game/scripts/interactions/ game/scenes/interactables/
# → keine Treffer (der Agent hatte seine Debug-Ausgaben selbst entfernt)
```

**Angenommen.** Von fünf gemeldeten Abweichungen ist eine bemerkenswert: Meine
Spezifikation verlangte `collision_mask = 0` für **jedes** Interactable — das
hätte `body_entered` bei Checkpoint, Druckplatte und Auto-Aufnahme strukturell
unmöglich gemacht. Der Agent hat den Widerspruch erkannt und in den betroffenen
Unterklassen aufgelöst, statt die Spezifikation stumpf zu befolgen. Das war die
richtige Entscheidung; der Fehler lag bei mir.

### Schritt 12 — Hub-Szene, der Integrationsschritt

Blockout als Code statt als Szene (`hub_blockout.gd`, 21 Quader aus einer
Datentabelle), damit der Austausch gegen Blender-Meshes in M3 ein Löschen ist und
keine Operation am offenen Herzen. `hub.gd` ist die einzige Stelle, an der Player,
UI und Interactables voneinander erfahren.

Platzierter M1-Ablauf: Spawn → AS ansprechen (Quest „Seite down") → Kiste öffnen
(Schwert `ed25519`) → Gegner → Schlüssel → zurück zu AS (Quest erledigt) → Tor
aufschließen.

Der Hub-Test fand auf Anhieb zwei Probleme (R7, R8) — einer davon in meinem
eigenen Test. Danach:

```bash
tools/run_tests.sh test_hub.gd
# → 12 bestanden, 0 fehlgeschlagen, Exit 0
```

---

### Schritt 13 — Gegner-Review und Abschluss der M1-Inhalte

```bash
# Unabhängige Nachprüfung der Erfolgsmeldung des Subagenten
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --import
tools/run_tests.sh
# → 96 bestanden, 0 fehlgeschlagen, Exit 0
tools/smoke_test.sh
# → Exit 0
python3 tools/arg_check.py
# → Exit 0

# Scope- und Hygieneprüfung
grep -rnE 'print\(|print_debug|DEBUG|breakpoint' game/enemies/ game/tests/test_enemies.gd
# → keine Treffer
find . -type f -mmin -60   # untauglich als Scope-Nachweis: --import berührt zu viel
# → statt dessen gezielt: game/tests/zz_debug.gd gefunden, Scope-Verletzung (R9)
rm -f game/tests/zz_debug.gd game/tests/zz_debug.gd.uid

# Layer-Abgleich der beiden Kampfseiten, die sich nie gemeinsam getestet hatten
grep -nE 'collision_layer|collision_mask' game/player/player.tscn
# → Spieler-HitBox Maske 4 gegen Gegner-HurtBox Layer 4  ✓
# → Gegner-HitBox Maske 2 gegen Spieler-HurtBox Layer 2  ✓

# Nach Fix (R9), eingehängtem Schleim und zwei neuen Hub-Tests
tools/run_tests.sh
# → 99 bestanden, 0 fehlgeschlagen, Exit 0
tools/run_tests.sh test_enemies.gd   # → 14 bestanden
tools/run_tests.sh test_hub.gd       # → 14 bestanden
```

Der Schleim steht auf `(10, 0.5, -6)`: auf dem Weg zum Schlüssel, nicht auf dem
Weg zur Kiste. Ein Gegner vor der ersten Waffe wäre eine Sackgasse, kein
Tutorial. Der Abstand zum Spawn ist größer als sein `detect_radius` von 8 m —
das prüft der Hub-Test mit, damit die Reihenfolge nicht durch eine spätere
Positionsänderung kippt.

Damit ist die M1-Inhaltsliste vollständig: Start, Laufen, Blockout, NPC, Dialog,
Kiste, Schwert, **Gegner**, Tür, Schlüssel, Speichern, Herz-HUD.

---

## 4. Rückschläge

Vollständig, auch die eigenen Fehler.

### R1 — Test-Harness sah Autoloads nicht

**Symptom:** `SCRIPT ERROR: Compile Error: Identifier not found: GameState`

**Ursache:** Der Runner war als `extends SceneTree` gebaut und wurde mit
`--script` gestartet. In diesem Modus baut Godot **keine Autoloads** auf.

**Behebung:** Umbau auf `extends Node` plus eine Testszene
(`res://tests/test_main.tscn`), gestartet als normale Szene. Damit läuft die Suite
gegen die echte Verdrahtung statt gegen Attrappen.

**Folge:** Frame-abhängige Tests wurden möglich (`atest_*` mit
`await wait_physics_frames()`), was für alles auf Area3D-Überlappung nötig ist.

### R2 — Neues `class_name` war nicht auflösbar

**Symptom:** `Parse Error: Identifier "VpsTower" not declared in the current scope`

**Ursache:** Godot registriert globale Klassennamen erst beim Import. Ein frisch
per Datei angelegtes Skript ist der Engine noch unbekannt.

**Behebung:** `--headless --path game --import` vor dem Testlauf. Steht jetzt in
der Befehlsreferenz und in jedem Subagenten-Auftrag.

### R3 — Das Harness meldete falsches Grün (kritisch)

**Symptom:** Bei einem Parse-Fehler in einer Testdatei meldete der Runner
`0 bestanden, 0 fehlgeschlagen` und beendete mit **Exit 0**.

**Bewertung:** Der schwerste Fund bisher, und selbstverschuldet. Ein Fehlschlag,
der wie Erfolg aussieht, entwertet **jede** Evidence in diesem Projekt — und drei
Subagenten validierten zu diesem Zeitpunkt gegen genau dieses Harness.

**Ursache:** Bei einem Parse-Fehler gibt `load()` ein Skript-Objekt zurück, das
sich nicht instanziieren lässt. `script.new()` schrieb nur eine Zeile ins Log,
der Lauf zählte null Tests und galt als bestanden.

**Behebung in drei Ebenen:**
1. `script.can_instantiate()` wird geprüft, Fehlschlag wird als Testfehler gezählt.
2. Ein Lauf mit gefundenen Dateien, aber null ausgeführten Testmethoden gilt als Fehler.
3. `run_tests.sh` prüft das Log zusätzlich auf `Parse Error`, `Failed to load script`
   und `Compile Error`.

Auf generisches `ERROR:` wird **bewusst nicht** geprüft: `test_core_state.gd`
erzeugt absichtlich Fehlermeldungen, wenn es die Abweisung ungültiger
Speicher-Slots testet.

**Gegenprobe, weil eine Fix-Behauptung ohne Nachweis nichts wert ist:**

```bash
printf 'extends Node\nfunc test_kaputt() -> void:\n\tdies ist kein gueltiges GDScript\n' \
  > game/tests/test_zzz_harness_probe.gd
tools/run_tests.sh test_zzz_harness_probe.gd
# → "0 bestanden, 1 fehlgeschlagen"
# → "FEHLER  Script nicht instanziierbar — Parse-Fehler oder fehlendes extends Node."
# → Exit 1   (vorher: Exit 0)
rm game/tests/test_zzz_harness_probe.gd
```

**Folge:** Alle Erfolgsmeldungen von Subagenten werden selbst nachgeprüft, weil
ein Teil von ihnen gegen die kaputte Version validiert hat.

### R4 — Verschluckte Tastendrücke im Player, und ein erster Fix, der zu kurz griff

**Symptom:** Kein Testfehlschlag. Beim Lesen des Codes gefunden.

**Ursache:** Der Subagent hatte `Input.is_action_just_pressed` durch eine eigene
Flankenerkennung ersetzt — richtig, weil Godots Variante an echte Frames gebunden
ist und in den Tests nicht zurückgesetzt wird. Aber die Zustandsaktualisierung
hing an Bedingungen:

- `_wants_jump()` lief nur, wenn der Spieler am Boden stand.
- `_wants_attack()` lief nur in Angriffsphase `NONE`.

Dadurch blieb der alte Tastenzustand stehen. Wer die Sprungtaste im Flug neu
drückte und bei der Landung hielt, sprang nicht. Wer während der Nachziehphase
angriff, verlor den Druck.

**Erster Fix — unzureichend, und das ist der lehrreiche Teil:** Ich habe den
Zustand in jedem Physikschritt aktualisiert. Beim Nachdenken über den Testfall
fiel auf, dass das nicht reicht: Die Flanke wird jetzt korrekt *erkannt*, aber
weiterhin *verworfen*, weil sie nur in Phase `NONE` beziehungsweise am Boden
ausgelesen wird. Das Symptom wäre geblieben.

**Zweiter Fix, tragfähig:** Ein Eingabepuffer von 0,15 s. Eine erkannte Flanke
wird gemerkt, bis sie verbraucht werden kann oder abläuft. Das behebt beide Fälle
wirklich und ist zugleich die Grundlage für Angriffsketten.

**Zweiter Fund im selben Review:** Ohne gesetzten Checkpoint zeigt
`GameState.checkpoint_position` auf `(0,0,0)`. Absturzsicherung und Respawn hätten
den Spieler dorthin gesetzt — liegt da kein Boden, fällt er endlos und die
Sicherung feuert immer wieder. Behoben durch einen Rückfallpunkt: Der Player setzt
in `_ready` seine eigene Startposition als Checkpoint, falls noch keiner existiert.

**Nachweis:** fünf neue Regressionstests (Puffer greift, Puffer läuft ab, ein Druck
erzeugt nur einen Angriff, Rückfallpunkt wird gesetzt, bestehender Checkpoint wird
nicht überschrieben) → `test_player.gd` 14/14, Exit 0.

### R5 — Doppelte Task-ID im ARG, durch das eigene Prüfskript gefangen

**Symptom:** `python3 tools/arg_check.py` → 13 Fehler, Exit 1.

**Ursache:** Beim Einfügen von T-015 habe ich den Anfang des T-013-Blocks als Anker
benutzt und am Ende wieder eingesetzt. Ergebnis: ein leerer T-013-Stub mit nur `id` und
`name`, plus der vollständige Eintrag weiter unten.

**Behebung:** Stub entfernt, danach 15 Tasks, Exit 0.

**Wert des Fundes:** Genau dafür existiert das Skript. Ohne die Prüfung wäre ein
widersprüchliches ARG im Repository gelandet — und das ARG soll den tatsächlichen
Projektzustand widerspiegeln, nicht einen plausibel aussehenden. Die Prüfung läuft in
Millisekunden und hat sich damit selbst bezahlt.

### R6 — Die Art Direction des Auftrags entspricht nicht mehr der aktuellen Website

**Kein Fehler, aber die inhaltlich wichtigste Abweichung bisher.**

**Symptom:** Auftrag und Belegstand von Dezember 2025 sagen „dunkles Glassmorphism, blaue
Akzente". Die lokale Website-Quelle sagt etwas anderes.

**Fund** aus `/Volumes/T7/Projekte/alexle-vsco/src/styles/warm-noir.css`:

| Variable | Wert | Charakter |
|---|---|---|
| `--mono-50` … `--mono-975` | `#1c1b18` → `#ffffff` | warmes Monochrom, Sepiastich, **kein Blau** |
| `--orange-400/500/600` | `#1f6b3b`, `#14532d`, `#0f3d21` | trotz Namen **grün** — Rebrand mit beibehaltenen Variablennamen |
| `--clay-400/500/600` | `#a85a38`, `#7a3a20`, `#5c2c18` | Terrakotta |
| `--signal-info` | `#2a5b7a` | gedämpftes Blau, nur als Informationssignal |
| `--terminal-bg` | `#14181a` | Terminal-Fläche |

Schriften: **Geist**, **Geist Mono**, **Newsreader**. Eine zweite Datei heißt `v2-theme.css`.

**Deutung:** Die Marke hat sich vom dunkel-blauen Stand (Dezember 2025) zu einem
warm-monochromen, editorialen Auftritt entwickelt. Beide Angaben sind echt und beschreiben
verschiedene Zeitpunkte.

**Entscheidung:** Das Spiel bleibt bei dunkel mit Blau-Akzent.

- Der Auftrag gibt es ausdrücklich vor. Das ist eine bewusste Vorgabe, keine Ableitung,
  die stillschweigend ersetzt werden sollte.
- Blau trägt im Spiel zusätzlich eine Funktion: Es markiert Benutzbarkeit. Ein warmes
  Monochrom mit grünen und terrakottafarbenen Akzenten müsste diese Rolle neu verteilen —
  ein Art-Direction-Umbau, keine Farbanpassung.
- Die Palette ist an genau drei Stellen gebündelt, damit eine Umstellung abgegrenzt bleibt:
  `game/ui/theme.tres`, `game/world/materials/mat_accent.tres`,
  `game/world/realm_environment.tres`.

**Diese Entscheidung gehört Alexander Schneider.** Sie ist hier und in
[docs/RESEARCH.md](docs/RESEARCH.md) Abschnitt 1.3 dokumentiert, damit sie sich umdrehen
lässt, ohne den Grund rekonstruieren zu müssen.

### R7 — Mein Hub-Test schlug an korrektem Code fehl

**Symptom:** `atest_player_steht_auf_dem_boden` meldete „Player über der
Bodenoberkante (ist 0.000)".

**Ursache: mein Test, nicht der Code.** Ich hatte angenommen, der Ursprung der
Spielfigur liege in der Kapselmitte, und deshalb `y > 0.5` erwartet. Tatsächlich
sitzt die Kollisionsform um 0,875 versetzt — **der Ursprung liegt an den Füßen**.
Das ist die saubere Konvention und steht so auch in `docs/ASSETS.md` für Modelle.
Auf einem Boden mit Oberkante 0 ist `y ≈ 0` die richtige Antwort.

Nachgeprüft, statt geraten:

```bash
grep -A6 'name="CollisionShape3D" type="CollisionShape3D" parent="."' game/player/player.tscn
# → transform = Transform3D(1,0,0, 0,1,0, 0,0,1, 0, 0.875, 0)
```

Der zweite Assert im selben Test (`is_on_floor()`) war grün — der Spieler stand
also längst korrekt. Genau dieses Detail hat den Unterschied zwischen
„Code kaputt" und „Erwartung kaputt" entschieden.

**Behebung:** Erwartung auf `-0.05 < y < 0.6` korrigiert, mit Kommentar, damit der
nächste Leser nicht dieselbe Annahme trifft. Zusätzlich `SPAWN_POSITION` von
`y = 1.0` auf `y = 0.1` gesetzt: Mit Fußursprung wäre der Spieler bei jedem
Respawn erst einen Meter gefallen.

**Lehre:** Ein fehlschlagender Test ist eine Behauptung über zwei Dinge — den Code
**und** die Erwartung. Vor jeder Codeänderung gehört geklärt, welche der beiden
falsch ist.

### R8 — Checkpoint griff auf `current_scene` ohne Null-Prüfung zu

**Symptom:** `atest_hub_setzt_spawn_checkpoint` meldete
`res://tests/test_main.tscn` statt `res://scenes/hub.tscn`.

**Ursache:** `checkpoint.gd` nutzte `get_tree().current_scene.scene_file_path`.
Zwei Probleme, von denen der Test nur das harmlosere zeigte:

1. Im Testkontext ist `current_scene` die Testszene, nicht der Hub. Das allein
   wäre ein Testartefakt.
2. **`current_scene` kann null sein**, etwa während eines Szenenwechsels. Der
   direkte Zugriff darauf war ein Absturz, der nur auf sich warten ließ.

Der Checkpoint schreibt den Pfad, zu dem ein Ladevorgang zurückkehrt. Ein
falscher oder leerer Wert dort ist ein kaputter Speicherstand.

**Behebung:** Der Pfad kommt jetzt aus `owner` — der Szene, in der dieser
Checkpoint tatsächlich platziert wurde. Das ist strikt besser als `current_scene`:
Es stimmt auch, wenn die Welt als Unterszene läuft, und es kann nicht auf null
zugreifen. `current_scene` bleibt nur als Rückfall für Knoten, die zur Laufzeit
ohne `owner` erzeugt wurden.

**Nebenwirkung:** Mit dem Fix wurde meine ursprüngliche Testerwartung richtig —
der Test prüft jetzt genau das, was er prüfen sollte.

### R9 — Der Gegner schlug immer nach Norden, und 13 grüne Tests sahen es nicht

**Symptom:** keiner. Alle 13 Tests des Subagenten waren grün, der Smoke-Test
grün, der Kampfkontrakt-Integrationstest grün. Gefunden beim Lesen der Szene
gegen den Zustandsautomaten.

**Ursache:** `bitrot_slime.tscn` setzt die HitBox-Kollisionsform auf lokal
`z = -0.8`, also nach vorn. Der Zustandsautomat in `enemy_base.gd` enthielt aber
**keine Drehung**: Die Verfolgung setzte nur `velocity`, nie `rotation.y`. Ein
Gegner zeigte damit dauerhaft in Richtung der Weltachse -Z. Er verfolgte den
Spieler korrekt aus jeder Richtung, sein Schlag landete aber immer im Norden.

Warum die Tests grün blieben: Test 6 prüft den Zustandswechsel zu `TELEGRAPH`,
Test 7 prüft `hit_box.is_active()`. Beide Aussagen waren wahr. Kein Test prüfte
die **Lage** der Schlagform. Beide platzieren den Spieler zudem auf `(1, 0, 0)` —
ausgerechnet die Richtung, in die der Gegner nicht schlagen konnte.

**Behebung:** `_face_player()` in `enemy_base.gd`, aufgerufen in der Verfolgung
und **einmal** beim Eintritt in die Vorwarnung. Bewusst nicht danach: Die
Schlagrichtung wird zu Beginn der Vorwarnung festgelegt und nicht mehr
korrigiert. Genau das macht Ausweichen möglich — wer um den Gegner herumläuft,
während der Telegraph leuchtet, steht beim Schlag nicht mehr im Weg.

**Gegenprobe**, weil ein grüner Test ohne bewiesene Rotfähigkeit keine Evidence
ist (Lehre aus R3):

```bash
# _face_player() vorübergehend auf sofortiges return gesetzt
tools/run_tests.sh test_enemies.gd
# → 13 bestanden, 3 fehlgeschlagen, Exit 1
# → "Schlagform zeigt zum Spieler bei Versatz (1.2, 0.0, 0.0)
#    (Form 1.44 m, Koerper 1.20 m)"
# → bei Versatz (0.0, 0.0, 1.2): Form 2.00 m gegen Koerper 1.20 m
# Rücknahme, dann:
tools/run_tests.sh
# → 99 bestanden, 0 fehlgeschlagen, Exit 0
grep -cE 'TEMPORAER' game/enemies/enemy_base.gd
# → 0
```

Die 2,00 m bei einer Schlagform mit Radius 1,0 sind der Beleg für die Schwere:
Ein Spieler südlich des Schleims war **unangreifbar**.

**Zweiter Fund im selben Review, Scope:** Der Agent hatte
`game/tests/zz_debug.gd` samt `.uid` im Repo zurückgelassen — eine Debug-Sonde
mit `print`-Ausgaben, die in seinem Abschlussbericht nicht auftaucht („nur die
vier genannten Dateien"). Sie lief nicht mit, weil der Runner nur `test_*.gd`
sammelt, gehörte aber nicht ins Repo. Entfernt.

**Dritter Fund, Grenzüberschreitung:** Der Agent hat `pkill -9 -f "(Godot)"`
ausgeführt und damit **alle** Engine-Prozesse der Sitzung beendet, nicht nur
seine eigenen. In diesem Lauf war er der einzige aktive Agent, der Schaden also
null. Bei drei parallelen Agenten hätte er fremde Testläufe abgebrochen — und
die Fehlschläge wären bei den anderen aufgetaucht, nicht bei ihm. Konsequenz:
Prozess-Kills werden in künftigen Subagenten-Prompts ausdrücklich verboten.

### R10 — Die eigene ARG war der unzuverlässigste Teil des Projekts

**Symptom:** `grep 'status:' .arg/registry.yaml` zeigte T-008, T-009 auf
`in_progress` und T-010, T-011, T-012 auf `planned` — obwohl die Arbeit fertig,
getestet und in derselben Datei mit vollständigen `validation`- und
`evidence`-Blöcken belegt war.

**Ursache:** Ich hatte die Belege eingetragen, aber das `status`-Feld nicht
mitgeführt. `tools/arg_check.py` hat das nicht gemeldet, und zwar korrekt: Es
prüft, ob eine **Abschlussbehauptung** gedeckt ist. Ein zu niedriger Status
behauptet nichts und ist deshalb keine Regelverletzung.

**Warum es trotzdem zählt:** Der Auftrag verlangt, dass die ARG den echten
Projektstand zeigt. Ein Register, das fertige Arbeit als `planned` führt, ist
genauso unbrauchbar wie eines, das unfertige Arbeit als `verified` führt — nur
in der harmloseren Richtung. Beim Aufsetzen des nächsten Milestones hätte ich
Tasks neu dispatchen können, die längst erledigt sind.

**Behebung:** Fünf Statuswerte korrigiert, T-003 von `review` auf `verified`
(der offene Integrationstest liegt jetzt vor), T-011 mit Validierung, Evidence
und Notizen gefüllt. Dabei habe ich zwei eigene Zahlen falsch geraten (`16
bestanden` für `test_enemies.gd`) und nach dem Nachmessen auf 14 korrigiert —
der Runner zählt Testmethoden, nicht Assertions.

**Lehre für das Prüfskript:** `arg_check.py` sollte künftig auch die andere
Richtung melden — ein Task mit vollständiger Evidence und ausgeführter
Validierung, der auf `planned` steht, ist ein Hinweis wert. Notiert unter den
offenen Punkten, nicht sofort umgesetzt: Das Skript ist Werkzeug, nicht Spiel.

---

## 5. Entscheidungen

| Entscheidung | Begründung | Verworfene Alternative |
|---|---|---|
| Gesundheit als Viertelherz-Ganzzahl | exakt, speicherbar, keine Rundungsfehler bei halben Herzen | Float-Herzen: driften |
| Weltzustand nur in `GameState.flags` | eine Quelle der Wahrheit; macht Kisten-Einmaligkeit und Dungeon-Clear trivial | Zustand in Szenen: verfällt beim Szenenwechsel |
| JSON-Speicherstand ohne Godot-Typen | extern lesbar, als Test-Fixture schreibbar | `ResourceSaver`: undurchsichtig, versionsgebunden |
| Hit-Stop als lokaler Timer | trifft nur den Angreifer | `Engine.time_scale`: verlangsamt alles, auch die UI |
| Eigenes Test-Harness statt GUT | rund 180 Zeilen, kein Fremdcode, keine Lizenzfrage | GUT: zusätzliche Update-Last |
| Harness als Szene statt `--script` | Autoloads existieren nur im Szenenbetrieb (siehe R1) | — |
| Dateifilter im Testrunner | die Suite ist geteilter Zustand; parallele Agenten sähen sonst fremden halbfertigen Code | sequenziell arbeiten: deutlich langsamer |
| Maximal drei parallele Godot-Prozesse | gemeinsamer Import-Cache unter `game/.godot/` | mehr Parallelität: Cache-Kollisionen |
| Eingabepuffer 0,15 s | behebt verschluckte Eingaben wirklich (siehe R4) | reine Flankenerkennung: Symptom bleibt |
| Checkpoint-Rückfallpunkt im Player | `_ready` ist der einzige Moment, in dem eine sicher vorgesehene Position bekannt ist | Fallback in der Hub-Szene: jede neue Szene müsste daran denken |
| `pyproject.toml` mit gelockerter Typprüfung | der Linter verbietet jedes `Any`; bei YAML-Parsing führt das nur zu Scheintypen | Code verbiegen: schlechter lesbar, prüft nichts |
| Ein Gegnertyp in M1, nicht drei | die M1-Liste des Auftrags nennt „Gegner"; drei Typen stehen in der Gesamtliste | drei halbfertige Gegner |
| Mini-Map als leerer Platzhalter | ehrlicher als eine Karte, die falsch zeichnet | Funktion vorziehen: M4-Arbeit in M1 |
| Kontaktadresse trotz Erlaubnis redigiert | hat für das Spiel keinen Nutzen, minimiert die Angriffsfläche | drin lassen |
| Blaue Palette trotz warm-noir-Website | Auftragsvorgabe; Blau trägt im Spiel die Funktion „benutzbar" (siehe R6) | auf warm-noir umstellen: Art-Direction-Umbau ohne Auftrag |
| 370 lokale Schriftdateien nicht übernommen | Schriftlizenzen sind der häufigste Fallstrick bei Veröffentlichungen | Geist/Newsreader einbinden: Lizenz ungeprüft |
| Keine Lizenzvermutung zu den Schriften notiert | eine notierte Vermutung wird später als geprüft gelesen | „wahrscheinlich OFL" hinschreiben |
| Keine Agora-Versionsnummer im Spiel | Kanon widerspricht sich (0.9.0 gegen 0.9.5) | eine Version auswählen: Erfindung |
| KI-Portal-Zone bleibt abgeschaltet | die echte Seite ist in Wartung; kanonisch korrekt und kostenlos | Zone bauen: Produktionszeit ohne Kanondeckung |

---

## 6. Subagenten-Protokoll

| Rolle | Modellklasse | Auftrag | Ergebnis | Review |
|---|---|---|---|---|
| research-web | mittel | Belegte Fakten von alexle135.de, ohne Interpretation | 25 Seiten, 10 Projekte, 2 Widersprüche dokumentiert | angenommen nach Struktur- und Privacy-Scan; Kontaktadresse redigiert |
| research-assets | günstig | Metadaten-Inventur von `alexle-vsco`, nur lesend | 451.618 Dateien, 6,9 GB; widerlegte die Auftragsannahme „Fotobibliothek" | angenommen nach Secret- und Privacy-Scan; Befund löste R6 aus |
| docs-maintainer | günstig | `CONTROLS.md` aus der Input-Map ableiten | 13 Actions, korrekt übersetzt | angenommen nach Stichproben |
| godot-gameplay | mittel | Player, Kamera, Kampfanbindung | 4 Dateien, 9 Tests grün | angenommen **nach Korrektur**: 2 echte Fehler gefunden (R4), 5 Regressionstests ergänzt |
| godot-ui | mittel | HUD, Dialog, Pause- und Optionsmenü | 13 Dateien, 9 Tests grün | angenommen **ohne** Nachbesserung; Palette exakt eingehalten |
| godot-interactions | mittel | Kisten, Türen, Schlüssel, Schalter, Checkpoints | 15 Dateien, 14 Tests grün | angenommen nach Flakiness- und Debug-Prüfung; eine Härtung des Lead nachgezogen (R8) |
| godot-enemies | mittel | Gegner-Basisklasse, erster Typ, Kampfkontrakt-Integrationstest | 4 Dateien, 13 Tests grün | angenommen **nach Korrektur**: Drehung zum Spieler fehlte (R9), 1 Regressionstest ergänzt, zurückgelassene Debug-Sonde entfernt, Prozess-Kill gerügt |
| lead-architect | lead | Kontrakt, Harness, Welt-Ressourcen, Hub-Integration, alle Reviews | 99 Tests grün | laufend |

Kein Subagent hat eine geschützte Datei verändert. Geprüft über Stichproben auf
`project.godot` (durchgehend 13 Actions) und die Kern-Skripte.

Bilanz der Reviews: Von sieben Lieferungen wurden **drei nur nach Korrektur**
angenommen (Player, Interactions, Gegner), und in allen drei Fällen war der
Fehler von den mitgelieferten grünen Tests nicht abgedeckt. Das ist das
belastbarste Argument gegen „Tests grün, also fertig".

---

## 7. Offene Punkte

1. **Art-Direction-Entscheidung** (R6) liegt beim Auftraggeber. Bis zu einer Gegenweisung
   bleibt es bei Blau. Umstellung betrifft genau drei Dateien.
2. **Kein Spieltest mit Bild.** Alle 99 Nachweise sind headless. Dass die Figur steht,
   sich dreht, trifft und stirbt, ist gemessen; wie es sich **anfühlt** (Kameraabstand,
   Tempo, Telegraph-Länge), ist nicht gemessen. Das braucht einen Durchlauf am Bildschirm
   und ist der nächste sinnvolle Schritt vor jedem neuen Inhalt.
3. **`tools/run_tests.sh` und `tools/arg_check.py` sind nicht als ARG-Tasks geführt**,
   obwohl sie Projektarbeit sind. Fünf Agentenrollen haben keinen Task. Beim M2-Aufsetzen
   nachziehen.
4. **Kein einziges Asset im Repo** — bewusst, siehe Abschnitt 8. Erster Bedarf in M3.
5. **`arg_check.py` sollte auch zu niedrige Status melden** (Lehre aus R10): Evidence
   vollständig, Validierung ausgeführt, Status trotzdem `planned` → Hinweis.
6. **Poster-Textur im Hub** ist nach dem Inventurbefund hinfällig. Falls Fotomotive
   gewünscht sind, braucht es eine andere, benannte Quelle.
7. **`blender/export_glb.py`** ist geplant, aber bewusst zurückgestellt: ohne Modelle
   wäre es ungetestet und damit fragwürdige Evidence. Gehört zu M3.
8. **Zwei Gegnertypen und der Mini-Boss** fehlen (M2), ebenso der erste echte Dungeon.

---

## 8. Assets — Zeitpunkt und Regeln

Häufige Frage, deshalb hier festgehalten: **Es liegt kein einziges Asset im
Repository, und das ist bis M3 der Plan.**

```bash
find game/assets blender -type f | grep -v '.gitkeep' | wc -l
# → 0
```

| Phase | Assets | Herkunft |
|---|---|---|
| M1 (jetzt) | keine | Blockout aus Primitivgeometrie, Materialien prozedural in `.tres`, Godots Standardschrift |
| M2 | keine neuen | zweiter Gegnertyp und Mini-Boss laufen weiter auf Primitiven |
| M3 (Art Pass) | **Eigenbau in Blender** | die 9 Modelle mit Dreiecksbudget aus `docs/ASSETS.md` §5 |
| M3/M4 | ggf. Ton und Schrift | **nur** CC0/Public Domain, jeweils mit Quelle, Autor, Lizenz und Abrufdatum in `docs/ASSETS.md` **vor** der Nutzung |

Reihenfolge ist Absicht: Erst steht die Mechanik mit gemessenen Maßen, dann
entstehen Modelle, die in diese Maße passen. Umgekehrt wird jede Geometrie
zweimal gebaut.

**Herunterladen tue ich nichts ohne ausdrückliche Freigabe** — pro Datei, mit
Quelle und Lizenz genannt. Das ist keine Formalität: Ein einziges Asset mit
ungeklärter Herkunft macht die spätere Veröffentlichung des Spiels angreifbar,
und genau das schließt Auftrag Abschnitt 6 aus (keine Nintendo- oder
Zelda-Assets, kein gerippter Spielinhalt, keine ungeklärten Pinterest-Dateien,
keine geschützte Musik).

Die 370 Schriftdateien und 4.234 Bilder im lokalen Verzeichnis `alexle-vsco`
bleiben **lokal und ungenutzt**: Ihr Lizenzstatus ist ungeklärt, und es sind
Website-Grafiken, keine Spielmotive.
