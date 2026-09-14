# STATUS — Alexle Realm

**Live-Logbuch.** Wird fortlaufend gepflegt, nicht rückblickend geschrieben.
Enthält jeden ausgeführten Befehl mit Ergebnis, jede Entscheidung mit Begründung
und jeden Rückschlag mit Behebung — auch die selbstverschuldeten.

Letzte Aktualisierung: 2026-09-15, nach UI-Review und Auswertung des Asset-Inventars
Aktueller Milestone: **M1 Vertical Slice** (in Arbeit)

Verwandte Dokumente: [docs/DESIGN.md](docs/DESIGN.md) ·
[docs/RESEARCH.md](docs/RESEARCH.md) · [docs/ARG.md](docs/ARG.md) ·
[.arg/registry.yaml](.arg/registry.yaml)

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
| Hub-Szene (Integration) | grün | `test_hub.gd` → 12/12 |
| Asset-Inventar | abgeschlossen | 451.618 Dateien erfasst, Secret-Scan clean |
| Gegner | in Arbeit | Subagent liefert noch, inkl. Kampfkontrakt-Integrationstest |

**Testsumme aktuell: 83 Testfälle grün** (25 Core + 14 Player + 9 UI + 9 Welt +
14 Interactions + 12 Hub), keine bekannten Fehlschläge.

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
| godot-enemies | mittel | Gegner-Basisklasse, erster Typ, Kampfkontrakt-Integrationstest | läuft noch | offen |
| lead-architect | lead | Kontrakt, Harness, Welt-Ressourcen, Hub-Integration, alle Reviews | 83 Tests grün | laufend |

Kein Subagent hat bisher eine geschützte Datei verändert. Geprüft über
Stichproben auf `project.godot` und die Kern-Skripte.

---

## 7. Offene Punkte

1. **Interaktive Objekte** — Subagent liefert noch. Wird selbst nachgeprüft, nicht auf
   Zuruf übernommen (Konsequenz aus R3).
2. **Gegner** — noch nicht begonnen. Nächster Dispatch, sobald die Interactables
   integriert sind.
3. **Hub-Szene** — der Integrationsschritt. Braucht Player, UI, Interactables und einen
   Gegner. Muss einen echten Checkpoint am Spawn setzen, damit der Rückfallpunkt aus R4
   nur Notnagel bleibt und nicht der Normalfall.
4. **Kampfkontrakt** steht im ARG auf `review`, nicht `verified`: Ein Integrationstest
   über echte Area3D-Überlappung fehlt. Der Player testet seine Seite, die Gegnerseite
   ist offen. Wird mit dem Gegner-Task geschlossen.
5. **Art-Direction-Entscheidung** (R6) liegt beim Auftraggeber. Bis zu einer Gegenweisung
   bleibt es bei Blau.
6. **Poster-Textur im Hub** ist nach dem Inventurbefund hinfällig. Falls Fotomotive
   gewünscht sind, braucht es eine andere, benannte Quelle.
7. **`blender/export_glb.py`** ist geplant, aber bewusst zurückgestellt: ohne Modelle
   wäre es ungetestet und damit fragwürdige Evidence. Gehört zu M3.
