# PROGRESS — Alexle Realm

Fortschrittsprotokoll nach Auftrag Abschnitt 23. Eine Zeile gilt nur als
„funktioniert", wenn ein ausgeführter Befehl das belegt. Vermutungen stehen
unter „Noch offen".

Stand: 2026-09-15 · Milestone **M1 Vertical Slice** · Godot 4.7.stable · Blender 5.2.1 LTS

Laufendes Logbuch mit Befehlen, Entscheidungen und Rückschlägen: [../STATUS.md](../STATUS.md)

---

## Funktioniert

Alles hier ist headless nachgewiesen. Die Befehle stehen unter „Tests".

**Start und Grundlage**

- Das Projekt startet ohne Fehler im Log (`tools/smoke_test.sh`, Exit 0).
- Drei Autoloads: `EventBus` (nur Signale), `GameState` (einzige Quelle der
  Wahrheit), `SaveManager`.
- 13 Eingabeaktionen, Tastatur und Gamepad, sieben benannte Kollisionslayer.

**Spielfigur**

- Laufen, Sprinten, Springen, Fallen; Bewegung relativ zur Kamera.
- Schulterkamera an einem `SpringArm3D`, Maussensitivität einstellbar.
- Angriff in drei Phasen (Vorbereitung 0,10 s / Fenster 0,18 s / Nachziehen
  0,25 s), Hit-Stop 0,08 s als lokaler Timer.
- I-Frames 0,8 s, Blocken, Tod und Respawn am Checkpoint.
- Absturzsicherung unter y = −50 mit Rückfall-Checkpoint.
- Eingabepuffer 0,15 s für Sprung und Angriff.

**Kampf**

- `HitBox` öffnet ein Angriffsfenster und trifft jede `HurtBox` höchstens einmal
  pro Aktivierung — auch bei Überlappung, die schon **vor** dem Öffnen bestand.
- `HurtBox` meldet nur; die Folgen entscheidet der Besitzer.
- Beide Seiten sind über echte `Area3D`-Überlappung getestet, nicht nur über
  direkte Methodenaufrufe.

**Gegner**

- Zustandsautomat IDLE → CHASE → TELEGRAPH → ATTACK → COOLDOWN, dazu HURT und
  DEAD.
- Sichtbereich 8 m, Verfolgungsaufgabe bei 12 m (Hysterese, damit er an der
  Grenze nicht flackert).
- Sichtbare Angriffsvorwarnung, die nie übersprungen wird. Die Schlagrichtung
  wird zu Beginn der Vorwarnung festgelegt und danach nicht korrigiert —
  Ausweichen wirkt.
- Tod: Belohnung in Packets, `EventBus.enemy_died`, optionales Weltflag. Ein
  erledigter Gegner bleibt nach dem Laden erledigt.
- Ein Typ vorhanden: Bitrot-Schleim, 3 Treffer.

**Interaktion und Welt**

- Kiste (genau einmal plünderbar, über Weltflag), verschlossene Tür mit
  Schlüsselbedarf und Verbrauch, Aufsammler, Schalter, Druckplatte, Checkpoint,
  NPC-Dialogauslöser.
- Hub „Leipzig-Knoten" als Blockout aus 21 Quadern, aus einer Datentabelle im
  Code erzeugt.
- VPS-Turm mit genau 48 Fenstern in einem `MultiMeshInstance3D` (ein
  Zeichenaufruf). Die Zahl ist Kanon und wird mitgetestet.

**Oberfläche**

- Herzenreihe auf Viertelherz genau, Packets, aktives Item, Quest-Hinweis,
  Mini-Map-Platzhalter.
- Dialogbox mit Schreibmaschineneffekt, Interaktions-Prompt, Toast-Warteschlange.
- Pause mit Speichern, Laden und Optionen; Einstellungen in `user://settings.json`.

**Speichern**

- Versioniertes JSON unter `user://saves/slot_N.json`, drei Speicherplätze,
  menschenlesbar, ohne Godot-Typen, mit Migrationspunkt.

**Spielbarer M1-Ablauf**

Spawn → AS ansprechen (Quest „Seite down") → Kiste öffnen (Schwert ed25519,
15 Packets) → Bitrot-Schleim besiegen → Terminal-Schlüssel aufnehmen → zurück zu
AS (Quest erledigt) → Tor aufschließen. Herzcontainer auf der Terrasse als
Belohnung fürs Erkunden. Zwei Checkpoints, einer davon mit Autospeichern.

---

## Noch offen

**Vor allem anderen**

1. **Ein Durchlauf am Bildschirm.** Alle 99 Nachweise sind headless. Dass die
   Figur trifft, ist gemessen; wie sich Kameraabstand, Lauftempo und die
   Vorwarnung von 0,5 s **anfühlen**, ist nicht gemessen. Kein neuer Inhalt vor
   diesem Durchlauf.

**Entscheidung des Auftraggebers**

2. **Farbpalette.** Das Spiel folgt der Auftragsvorgabe (dunkel, blaue Akzente).
   Die aktuelle Website ist warm-monochrom. Begründung und Umstellweg:
   [RESEARCH.md](RESEARCH.md) §1.3 und [../STATUS.md](../STATUS.md) R6. Die
   Palette liegt in genau drei Dateien.

**Inhalt (M2 und später)**

3. Zwei weitere Gegnertypen und der Mini-Boss.
4. Der erste echte Dungeon mit Schlüssel-Tür-Rätsel und Bosstür.
5. Zonen jenseits des Hubs. Die Mechanik jeder Zone ist in
   [RESEARCH.md](RESEARCH.md) §2 aus einer belegten Projekteigenschaft
   abgeleitet, aber keine ist gebaut.
6. Quest-System mit Anzeigenamen. Heute zeigen Quest-Hinweis und Item-Slot die
   ID, weil `GameState` keine Anzeigenamen kennt. Eine Namensregistry gehört zum
   Quest-System in M4.
7. Funktionierende Mini-Map (heute ein leerer Platzhalter).

**Assets**

8. **Kein einziges Asset im Repository** — Absicht bis M3.
   `find game/assets blender -type f` → 0 Dateien. Erster Bedarf: die 9 Modelle
   aus [ASSETS.md](ASSETS.md) §5, Eigenbau in Blender. Ton und Schrift nur
   CC0/Public Domain und nur mit ausdrücklicher Freigabe pro Datei.
9. `blender/export_glb.py` ist geplant, aber zurückgestellt: ohne Modelle wäre
   es ungetestet und damit fragwürdige Evidence.

**Werkzeug**

10. `tools/arg_check.py` sollte auch die andere Richtung melden: Evidence
    vollständig, Validierung ausgeführt, Status trotzdem `planned`. Das war
    R10 und wurde nur von Hand gefunden.

---

## Bekannte Bugs

**Keine offenen.** Alle bisher gefundenen sind behoben und durch je einen
Regressionstest abgedeckt:

| Fund | Wirkung | Behoben durch | Test |
|---|---|---|---|
| Verschluckte Tastendrücke (R4) | Sprungtaste im Flug neu gedrückt löste bei der Landung keinen Sprung aus | Eingabepuffer 0,15 s | `test_player.gd` |
| Respawn ins Leere (R4) | ohne gesetzten Checkpoint zeigte die Position auf (0,0,0) | Rückfall-Checkpoint in `_ready` | `test_player.gd` |
| Checkpoint-Szenenpfad (R8) | Zugriff auf `current_scene` ohne Null-Prüfung — latenter Absturz und kaputter Speicherstand | Pfad kommt aus `owner` | `test_hub.gd` |
| Gegner drehte sich nie (R9) | Schlag ging immer nach Welt-−Z; ein Spieler südlich des Gegners war unangreifbar | `_face_player()` | `test_enemies.gd` |
| Harness meldete falsches Grün (R3) | ein Parse-Fehler ergab „0 bestanden, 0 fehlgeschlagen" und **Exit 0** | `can_instantiate()`-Prüfung, Null-Tests gelten als Fehlschlag, Log-Grep | selbst geprüft mit einer defekten Datei |

Zwei **bewusst** so gebaute Verhaltensweisen, die wie Fehler aussehen können:

- `test_core_state.gd` erzeugt absichtlich Godot-Fehlerzeilen, wenn es ungültige
  Speicherplätze abweist. Maßgeblich ist die Ergebniszeile und der Exit-Code.
- Der Spawn-Checkpoint speichert **nicht** automatisch. Sonst überschriebe ein
  Spieler, der ohne Laden neu startet und über den Spawn läuft, seinen
  gespeicherten Fortschritt.

---

## Tests

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --import
tools/run_tests.sh
# → == Ergebnis: 99 bestanden, 0 fehlgeschlagen ==   Exit 0
tools/smoke_test.sh
# → Exit 0, keine Fehlermuster im Log
python3 tools/arg_check.py
# → Exit 0, 15 Tasks, jede Abschlussbehauptung gedeckt
```

| Datei | Fälle | Deckt ab |
|---|---|---|
| `test_core_state.gd` | 25 | Gesundheit, Währung, Inventar, Flags, Quests, Speichern und Laden |
| `test_player.gd` | 14 | Bewegung, Angriff, I-Frames, Blocken, Absturzsicherung, Eingabepuffer |
| `test_ui.gd` | 9 | Viertelherz-Genauigkeit, Dialoglebenszyklus, Pause, Speichern aus dem Menü |
| `test_world_assets.gd` | 9 | Ressourcen laden, Art-Direction-Regeln, 48 Container-Fenster |
| `test_interactions.gd` | 14 | Kiste einmalig, Tür mit und ohne Schlüssel, Druckplatte, Checkpoint |
| `test_enemies.gd` | 14 | Zustandsautomat, Vorwarnung, Tod, Trefferlage, Kampfkontrakt über Area3D |
| `test_hub.gd` | 14 | Integration: Figur fällt nicht durch die Welt, kompletter M1-Ablauf |

Gezählt werden Testmethoden, nicht Assertions.

**Die Punkte aus Auftrag Abschnitt 26 sind einzeln abgedeckt:** Spielfigur fällt
nicht durch die Welt (steht mit Bodenkontakt), Kollisionen wirken, Tür bleibt
ohne Schlüssel zu, Schlüssel öffnet und wird verbraucht, Kiste ist genau einmal
plünderbar, geleerte Kiste bleibt nach dem Laden leer, Checkpoints funktionieren,
erledigter Gegner bleibt erledigt, Speichern und Laden ist verlustfrei.

**Was die Testzahl nicht beweist.** In drei von sieben Subagenten-Lieferungen war
der eigentliche Fehler von den mitgelieferten grünen Tests nicht abgedeckt
(R4, R8, R9). Gefunden wurden alle drei beim Lesen, nicht beim Messen. Deshalb
gilt hier: grüne Suite ist notwendig, nicht ausreichend.

---

## ARG-Status

```bash
python3 tools/arg_check.py    # → Exit 0
```

**15 Tasks, alle 15 auf `verified` oder `done`**, jeder mit ausgeführter
Validierung und benannter Evidence. Ausgelesen aus der Datei, nicht aus dem
Gedächtnis:

| Task | Titel | Status |
|---|---|---|
| T-001 | Repository- und Projektgerüst | verified |
| T-002 | Zentrales Datenmodell und Persistenz | verified |
| T-003 | Kampfkontrakt HitBox / HurtBox | verified |
| T-004 | Headless-Test-Harness | verified |
| T-005 | Website-Recherche alexle135.de | verified |
| T-006 | Inventur lokaler Assets unter `alexle-vsco` | verified |
| T-007 | Kanon-Mapping und Art Direction | done |
| T-008 | Player-Controller, Kamera, Kampfanbindung | verified |
| T-009 | HUD, Dialog, Pause- und Optionsmenü | verified |
| T-010 | Interaktive Objekte und Checkpoints | verified |
| T-011 | Gegner-Basisklasse und erster Gegnertyp | verified |
| T-012 | Hub-Blockout Leipzig-Knoten | verified |
| T-013 | Lizenz- und Asset-Dokumentation | done |
| T-014 | Art-Direction-Ressourcen und VPS-Turm | verified |
| T-015 | Art-Direction-Konflikt entschieden und dokumentiert | done |

Die Regel bleibt: `verified` und `done` sind ohne Belege nicht zulässig; ohne
Beleg ist der höchste erreichbare Status `review`. Dass ein zu **niedriger**
Status genauso falsch ist, war die Lehre aus R10.

Zwei Dinge fehlen der ARG noch, ohne dass das Prüfskript sie melden könnte:
`tools/arg_check.py` und `tools/run_tests.sh` sind selbst nicht als Tasks
geführt, obwohl sie Projektarbeit sind. Fünf Agentenrollen (`blender-assets`,
`docs-maintainer`, `godot-world`, `license-review`, `qa-gameplay`) haben
keinen zugewiesenen Task — zulässig, solange sie geplant sind, und beim
M2-Aufsetzen zu füllen.

---

## Datenschutz und Lizenz

Vor jedem Abschluss geprüft, nicht nur behauptet:

```bash
# Secret-Scan über alles, was ins Repository käme
# Muster: password, token, api_key, secret, BEGIN PRIVATE KEY, private IPs
# → keine Treffer
```

- Keine Passwörter, Tokens, Schlüssel, `.env`-Dateien, privaten Adressen,
  Telefonnummern oder privaten IP-Adressen im Repository.
- Eine öffentlich belegte geschäftliche Kontaktadresse wurde trotz Zulässigkeit
  aus den Recherchedaten entfernt, weil sie für das Spiel keinen Nutzen hat.
- Keine erfundenen Lebensläufe oder Ereignisse. Der Mentor-NPC spricht über
  Technik, nie über Biografie.
- `/Volumes/T7/Projekte/alexle-vsco` bleibt lokal. Nichts daraus wird kopiert
  oder hochgeladen.
- Keine Fremdassets, also auch keine Lizenzfragen offen. Regeln für den Fall,
  dass welche dazukommen: [ASSETS.md](ASSETS.md).

---

## Nächster sinnvoller Milestone

**M2 nicht sofort.** Zuerst der Durchlauf am Bildschirm (Punkt 1 unter „Noch
offen") — er kostet Minuten und kann Werte verschieben, auf denen sonst der
ganze Dungeon aufbaut. Erst danach M2: zweiter und dritter Gegnertyp, der erste
echte Dungeon mit Schlüssel-Tür-Rätsel und Bosstür.

Begründung nach der Maßgabe `spielbar > stabil > verständlich > atmosphärisch >
umfangreich`: Ein Dungeon auf ungeprüftem Spielgefühl ist Arbeit, die im
Zweifelsfall zweimal gemacht wird.
