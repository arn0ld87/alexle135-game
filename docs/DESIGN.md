# DESIGN — Alexle Realm

**Die Wiederherstellung von alexle135.de**

Stand: 2026-09-15
Kanon und Mapping: [docs/RESEARCH.md](RESEARCH.md)
Arbeitsstand: [docs/PROGRESS.md](PROGRESS.md), [.arg/registry.yaml](../.arg/registry.yaml)

---

## 1. Pitch

Ein 3D-Action-Adventure im Zelda-Aufbau, dessen Welt aus echter Infrastruktur besteht.
Leipzig, das BFW, ein Homelab, Server und das Internet verschmelzen zu einer begehbaren
Infrastruktur-Welt. Der Spieler ist ein digitaler Wanderer, der ein zersplittertes
Wissensnetz wieder verbindet.

Die Besonderheit ist nicht die Kulisse, sondern die **Mechanik-Herkunft**: Jedes Rätsel
folgt aus einer echten Eigenschaft des Projekts, das die Zone benennt. Middleware-Reihenfolge
zählt im Traefik-Grat wirklich. Idempotenz heißt in der Ansible-Steppe wirklich, dass
zweimaliges Ausführen nichts ändert. Belegte Kanten tragen im Agora-Archiv wirklich, unbelegte
nicht. Eine Zone, die nur den Namen eines Projekts trägt und ein Standardrätsel enthält,
hätte den Punkt verfehlt.

## 2. Protagonist und Mentor

Der Spieler ist ein **digitaler Wanderer**: Third-Person, Kappe oder Hoodie, später ein
Laptop-Schild. Er hat keine Biografie und spricht nicht. Er ist ausdrücklich **nicht**
Alexander Schneider.

**AS** ist Mentor-NPC. Er erklärt, ordnet ein, warnt, lobt zurückhaltend. Seine Dialogregeln
folgen der belegten Tonlage der Website:

- Problem zuerst, Werkzeug danach.
- Kein Überschwang. Aufwand ist kein Qualitätsnachweis.
- Fachbegriffe werden benutzt und erklärt, nicht vermieden und nicht als Buzzword gesetzt.
- Trocken, gelegentlich selbstironisch. Nie Marketingsprech.
- Er spricht über Technik, nie über seine Biografie.

## 3. Konflikt und Ziel

Ein **Chaos-Paket** aus korruptiertem Deploy und dunkler Middleware hat das Wissensnetz
zersplittert. Folgen: Zonen isoliert, Quests liegen als ungelöste Tickets herum, das
Agora-Archiv hat seinen Evidence-Graphen verloren, die Terminal-Missionen sind offline.

Ziel: vier bis sechs Kern-Relikte sammeln, Dungeons abschließen, das Netz verbinden, das
Chaos-Paket im Kernel-Tempel besiegen, `alexle135.de` wieder online schalten.

Die Verankerung ist Kanon, nicht Erfindung: Das KI-Nachrichten-Portal ist auf der echten
Website tatsächlich in Wartung. Diese Zone bleibt im Spiel abgeschaltet — mit Wartungsschild.
Kanonisch korrekt und kostet keine Produktionszeit.

## 4. Ton

Praxisnah, trocken-humorvoll, technisch, lernbar. High-Fantasy nur als bewusste IT-Metapher.

| Klassisch | Alexle Realm |
|---|---|
| Schwert | CLI-Klinge `ed25519` |
| Schild | TLS-Schild |
| Bomben | Rollback |
| Bogen | Playbook-Bogen (Remote-Ausführung) |
| Greifhaken | Shell-Haken |
| Laterne | Evidence-Linse |

---

## 5. Gameplay-Loop

```text
Overworld -> NPC -> Quest -> Dungeon -> Rätsel -> Mini-Boss -> Item -> neues Gebiet -> Upgrade
```

Das Item am Ende eines Dungeons ist immer ein **Traversal-Item**: es öffnet Wege, die vorher
unpassierbar waren. Der Shell-Haken erreicht Vorsprünge, der Playbook-Bogen löst Schalter aus
der Ferne, die Evidence-Linse macht tragfähige Kanten sichtbar. Ohne diese Kopplung wäre die
Welt eine Reihe getrennter Level statt eines zusammenhängenden Raums.

## 6. Kampf

Bewusst leicht, kein Soulslike:

- Schwertangriff in drei Phasen: 0,10 s Vorbereitung, 0,18 s Trefferfenster, 0,25 s Nachziehen.
- Leichter Hit-Stop (0,08 s) bei bestätigtem Treffer. Umgesetzt als eigener Timer am Angreifer,
  **nicht** über `Engine.time_scale` — das würde die ganze Szene treffen.
- Kurze I-Frames (0,8 s) nach erlittenem Schaden, mit sichtbarem Blinken.
- Blocken halbiert Schaden, verlangt das TLS-Schild und begrenzt die Bewegung.
- Optionales Lock-on.
- Gesundheit in **Viertelherzen** als Ganzzahl, vier Startherzen. Ganzzahlen statt Fließkomma,
  damit Speicherstände exakt vergleichbar bleiben und halbe Herzen nicht durch
  Rundungsfehler entstehen.
- Bosse werden telegrafiert: sichtbare Vorwarnung in `#ffb347`, bevor der Schlag kommt.

## 7. Persistenz

Der Weltzustand liegt vollständig in **Weltflags** (`GameState.flags`): geöffnete Kisten,
entriegelte Türen, gelöste Rätsel, abgeschlossene Dungeons. Ein Flag ist eine stabile
Zeichenkette wie `hub_chest_sword` oder `dungeon_terminal_cleared`.

Daraus folgen zwei Eigenschaften, die der Auftrag ausdrücklich verlangt:

- Eine Kiste lässt sich nicht mehrfach plündern, weil `set_flag` idempotent ist.
- Ein abgeschlossener Dungeon bleibt nach dem Laden abgeschlossen, weil jedes Objekt
  beim `_ready` seinen Flag-Zustand wiederherstellt, statt frisch zu starten.

Speicherformat: JSON unter `user://saves/slot_N.json`, versioniert, mit einem
Migrationspunkt. Bewusst menschenlesbar und ohne Godot-Typen — ein Speicherstand lässt
sich außerhalb der Engine inspizieren und in Tests als Fixture schreiben.

---

## 8. Welt

### Hub: Leipzig-Knoten / Homelab-Dorf

Elemente: VPS-Turm mit **48 Container-Fenstern** (die Zahl ist Kanon, nicht Dekoration),
Glasfassaden, AS als Mentor, Mitlernende vom BFW, Tux-Händlerstand, Traefik-Wächter am Tor,
ROI-Händler.

Tutorialpfad: Laufen → NPC ansprechen → Kiste öffnen → Schwert `ed25519` erhalten →
erster Kampf → verschlossene Tür → Schlüssel → Durchgang.

Leipzig wird **nur stilisiert angedeutet**. Keine 1:1-Rekonstruktion, keine erkennbaren
realen Gebäude, keine Straßennamen.

### Zonen

| Zone | Thema | Gameplay | Dungeon | Reward | Boss |
|---|---|---|---|---|---|
| Terminal-Ufer | Linux, Terminal Missionen | Plattformen, Befehls-Schreine | WebContainer-Höhle | Shell-Haken | Fork-Bomb-Schleim |
| Container-Werft | Docker, Compose | Container-Inseln, Volumes verbinden | Compose-Labyrinth | Compose-Hammer | Daemon-Wächter |
| Traefik-Grat | HTTPS, Middleware | Tore, Klippen, Reihenfolge | Header-Tempel | TLS-Schild | Middleware-Hydra |
| Ansible-Steppe | Automation | idempotente Rätsel | Idempotenz-Mine | Playbook-Bogen | Drift-Golem |
| CodeHack-Arena | CodeHack | Kampftraining, Boss-Rush | Boss-Rush | Heart-Container | Syntax-Ritter |
| Agora-Archiv | Neo4j, Evidence | Graph-Rätsel | Knowledge-Graph-Kathedrale | Evidence-Linse | Halluzinations-Phantom |
| IHK-Radar-Turm | FISI, IHK | Sammel-Schreine | — | Skill-Chips | — |
| Kernel-Kern | Finale | alle Items nötig | Root-Dungeon | Master-Deploy | Chaos-Paket |

Optional: CMD-Katakomben (Windows Terminal Missionen), NVMe-Nebel mit Speed-Boots
(Sprint-Faktor rund 12,7 — der belegte Unterschied zwischen SATA und NVMe Gen4),
Nachrichten-Relais (abgeschaltet, mit Wartungsschild).

Wie jede Mechanik aus welchem belegten Projektdetail folgt, steht vollständig in
[docs/RESEARCH.md](RESEARCH.md), Abschnitt 2.

## 9. Quests

Hauptquests:

1. **Seite down** — Ausgangslage, Tutorial, Schwert
2. **Mission starten** — Terminal-Ufer, Shell-Haken
3. **YAML verbinden** — Container-Werft, Compose-Hammer
4. **Header korrekt setzen** — Traefik-Grat, TLS-Schild
5. **Einmal sauber lösen** — Ansible-Steppe, Playbook-Bogen
6. **Nur belegte Kanten** — Agora-Archiv, Evidence-Linse
7. **Healthgate grün** — Kernel-Kern, Finale

Nebenquests: SSH-Key statt Passwort, Ticket-Routing (Tickets nach Hardware, Software,
Netzwerk sortieren, bei niedriger Sicherheit an einen menschlichen Dispatcher eskalieren —
genau der belegte Ablauf des echten Projekts), zwölf Radar-Runen (zwei pro echter
IHK-Kategorie), Proxmox-Homelab, CodeHack-Arena.

Dialoge: deutsch, kurz, verständlich, technisch. Kein Marketing-Sprech.

---

## 10. Technik

```text
Godot 4.7 stable (Auftrag verlangt 4.3+)
GDScript, statisch typisiert
Forward+
Blender 5.2.1 LTS (Auftrag verlangt 4.x)
glTF 2.0, 1 Godot-Unit = 1 Meter
```

Beide Werkzeuge sind neuer als im Auftrag genannt. Abweichung nach oben, bewusst, weil
genau diese Versionen installiert sind.

### Architekturentscheidungen

| Entscheidung | Begründung | Alternative und warum nicht |
|---|---|---|
| Gesundheit als Viertelherz-Ganzzahl | exakt, speicherbar, keine Rundungsfehler | Float-Herzen: halbe Herzen driften |
| Weltzustand nur in `GameState.flags` | eine Quelle der Wahrheit, trivial serialisierbar | Zustand in Szenen: geht bei Szenenwechsel verloren |
| Signalbus `EventBus` ohne Logik | UI kennt den Player nicht, Systeme bleiben einzeln testbar | Direkte Referenzen: harte Kopplung |
| JSON-Speicherstand ohne Godot-Typen | extern lesbar, als Test-Fixture schreibbar | `ResourceSaver`: undurchsichtig, versionsgebunden |
| HitBox trifft jede HurtBox einmal pro Aktivierung | ein Schwung über mehrere Physik-Frames macht einmal Schaden | Schaden pro Frame: unspielbar |
| Hit-Stop als lokaler Timer | trifft nur den Angreifer | `Engine.time_scale`: verlangsamt alles, inklusive UI |
| Eigenes Test-Harness statt GUT | ~180 Zeilen, kein Fremdcode, keine Lizenzfrage | GUT: zusätzliche Update-Last für den gebrauchten Umfang |
| Test-Harness als Szene, nicht `--script` | Autoloads sind nur im Szenenbetrieb vorhanden | `--script`: `GameState` existiert dort nicht |
| Blockout zuerst über CSG, Meshes später | spielbar vor schön, Auftrag Abschnitt 29 | Assets zuerst: lange nichts spielbar |

### Projektstruktur

```text
alexle135 spiel/
├── docs/            RESEARCH, DESIGN, ASSETS, CONTROLS, PROGRESS, ARG
│   └── research/    Rohdaten mit Quellenangaben
├── .arg/            registry.yaml — maschinenlesbares Arbeitsregister
├── tools/           smoke_test.sh, run_tests.sh, arg_check.py
├── blender/         Quelldateien und Exportskripte
└── game/            Godot-Projekt (project.godot liegt hier)
    ├── scenes/      boot, hub, interactables
    ├── player/      Player und Kamera
    ├── world/       Weltbausteine
    ├── dungeons/    Dungeon-Räume
    ├── enemies/     Gegner
    ├── npcs/        NPCs
    ├── ui/          HUD, Dialog, Menüs
    ├── scripts/     core (Autoloads), systems, interactions
    ├── shaders/
    ├── assets/      models, textures, audio
    └── tests/       Headless-Testsuite
```

Alles Godot-relevante liegt unter `game/`, weil der Auftrag
`godot --headless --path game --quit-after 1` als Prüfbefehl festlegt. Das erzwingt
`project.godot` in `game/`.

---

## 11. Milestones und Scope

Priorität aus Auftrag Abschnitt 29: **spielbar > stabil > verständlich > atmosphärisch > umfangreich.**
Lieber ein sehr guter Dungeon als acht unfertige Biome.

| Milestone | Inhalt | Zustand |
|---|---|---|
| **M1 Vertical Slice** | Godot startet, Spieler läuft, Blockout-Hub, NPC, Dialog, Kiste, Schwert, ein Gegner, Tür, Schlüssel, Save-System, Herz-HUD | in Arbeit |
| M2 Terminal-Dungeon | 3 Räume, 2 Rätsel, Mini-Boss, Shell-Haken, Ausgang. 10–20 Minuten Spielzeit | geplant |
| M3 Art Pass | Blender-Meshes, Beleuchtung, HDRI, UI-Feinschliff, Poster | geplant |
| M4 Zweite Zone | Container-Werft oder Traefik-Grat vollständig, Quest-Log, Mini-Map, 2 Nebenquests, Boss | geplant |
| M5 Polish | Tutorial-Hinweise, Game Over, Credits, Lizenzen, README | geplant |

### Ausdrücklich nicht im MVP

Open World in BotW-Größe, Reiten, Wettersimulation, Mehrspieler, Online-Konten,
Mikrotransaktionen.

### M1-Scope-Entscheidungen

- **Ein Gegnertyp, nicht drei.** Auftrag Abschnitt 10 verlangt insgesamt mindestens drei
  Gegnertypen, die M1-Liste in Abschnitt 22 aber nur „Gegner". Für M1 entsteht eine
  erweiterbare Basisklasse plus ein sorgfältig gebauter Gegner. Typ zwei und drei kommen
  mit dem Mini-Boss in M2.
- **Mini-Map als Platzhalter.** Rahmen und Position stehen in M1, die Funktion kommt in M4.
  Ein leerer Rahmen ist ehrlicher als eine Karte, die falsch zeichnet.
- **Kein Quest-Log-Fenster in M1.** Der HUD zeigt einen einzeiligen Quest-Hinweis. Das
  vollständige Log gehört zu M4, wo es mehrere parallele Quests gibt.
- **Mentor-Dialoge geschrieben, keine Sprachausgabe.** Kein Audio auf dem M1-Pfad.
- **Platzhaltergeometrie aus Primitiven.** Blender-Modelle sind M3. In M1 muss die Welt
  spielbar sein, nicht schön.

## 12. Qualitätsziele

- 60 FPS auf einem normalen Laptop.
- Low-Poly, Instancing, kleine Texturen, modulare Szenen, wenige Draw Calls, einfache Shader.
- Keine 4K-Texturflut. Held: 4.000–8.000 Dreiecke, 2K-Atlas.
- Das Projekt muss **jederzeit** startbar bleiben: `tools/smoke_test.sh` verlangt Exit 0
  und ein fehlerfreies Log.

## 13. Definition of Done

Ein Task ist erst abgeschlossen, wenn alles davon zutrifft:

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
