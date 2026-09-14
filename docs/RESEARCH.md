# RESEARCH — Alexle Realm

Stand: 2026-09-15
Belege: [docs/research/website-research.md](research/website-research.md) (25 abgerufene Seiten, jede
Sachaussage dort mit Quell-URL), [docs/research/asset-inventory.md](research/asset-inventory.md)

Dieses Dokument trennt strikt drei Ebenen:

1. **Kanon** — belegt auf alexle135.de. Darf im Spiel als Fakt auftreten.
2. **Annahme** — von mir gesetzt, nicht belegt. Als `[ANNAHME]` markiert.
3. **Erfindung** — freie Spielfiktion. Als `[FIKTION]` markiert.

Alles, was nicht als Annahme oder Fiktion markiert ist, steht in der Belegdatei mit Quelle.

---

## 1. Kanon-Fakten

### 1.1 Person und Kontext

| Fakt | Verwendung im Spiel |
|---|---|
| Umschulung zum Fachinformatiker Systemintegration seit Juni 2025 am BFW Leipzig, Abschluss geplant Juni 2027 | Rahmen des Hub-Gebiets, NPC-Gruppe „Mitlernende" |
| Standort Leipzig | Hub heißt „Leipzig-Knoten", nur stilisiert |
| Vorher Bundeswehr, Post, Handel, ein Stück Selbstständigkeit (eine zweite Quelle formuliert „Handwerk") | **Nicht im Spiel verwendet.** Widersprüchlich belegt und privat-biografisch — bleibt draußen |
| Homelab: Contabo-VPS mit rund 48 Docker-Containern hinter Traefik | VPS-Turm im Hub hat 48 Container-Fenster. Konkrete Zahl statt Dekoration |
| Tailscale-Tailnet, AdGuard Home als DNS-Filter | Traefik-Wächter und ein DNS-Filter-Schrein als Weltelemente |
| CachyOS als Daily Driver, MacBook Air M3, iMac 2017 mit OCLP | **Nicht im Spiel verwendet.** Privates Gerätinventar, kein Spielwert |
| Grundhaltung „Erst Problem, dann Tool." | Dialogleitlinie für den Mentor-NPC AS |
| Selbstkritische Tonlage, z. B. „500 Stunden sind kein Qualitätszertifikat." | AS lobt den Spieler nie überschwänglich |

Nicht übernommen und nicht im Repo: Kontaktadressen, GitHub-Handle, Geräteseriennummern,
alles was über den beruflichen Kontext hinausgeht. Das GitHub-Profil ist öffentlich belegt,
hat aber keinen Spielwert und bleibt deshalb draußen.

### 1.2 Die zehn Projekte

Alle zehn sind in der Projektübersicht der Website gelistet. Statusangaben sind Website-Angaben.

| Projekt | Status laut Website | Fachvokabular (Kanon) |
|---|---|---|
| Agora | Stability Beta, AGPL-3.0 | Evidence-Gating, Wissensgraph (Neo4j), Stakeholder-Personas, Claims, Run-Vertrag, Run-Budget |
| Docker Compose Builder | Live | Compose-Stacks, YAML-Generierung, Services, Volumes; Services: Nginx, PHP-FPM, MySQL, PostgreSQL, Redis, Traefik, Prometheus, Grafana, Adminer |
| Ticket-Routing mit KI-Agenten | Prototyp | Classifier Workflow, Confidence Score, Eskalation, Kategorien Hardware/Software/Netzwerk |
| Terminal Missionen | Live | WebContainer, 11 Missionen (6 Linux, 3 Docker, 3 Git), CTF-Challenges, Custom Node.js Shell mit über 25 Befehlen, Cross-Origin Isolation |
| CodeHack (C# lernen als Spiel) | Stable | 45 Aufgaben, 9 Tracks, 8 Boss-Battles, XP/Level/Bytes, Skill-Tree, Daily Challenge, Cosmetics-Shop |
| Windows Terminal Missionen | Stable | 6 Missionen, 78 Minuten, CMD, PowerShell, Diskpart, WMIC, Scheduled Tasks |
| IHK Radar | Stable | 60 Prüfungsthemen in 6 Kategorien (Netzwerk, Server & OS, Sicherheit, Programmierung, Projektmanagement, Wirtschaft & Recht), lokale Speicherung |
| ROI-Rechner | Stable | ROI-Zeitraum, Zeitersparnis, Setup-Aufwand, Stundensatz, Häufigkeit |
| KI Nachrichten Portal | Projektseite: in Wartung. Startseiten-Badge: Stable | RSS-Aggregation, Dubletten-Erkennung, Cron-Job, KI-Zusammenfassungen |
| M.2 Schnittstelle (Vortrag) | Kein Label | Formfaktoren, B-Key/M-Key, NVMe vs. SATA, ca. 550 MB/s gegen ca. 7.000 MB/s |

**Offener Widerspruch im Kanon:** Die Agora-Version wird auf der Über-mich-Seite als 0.9.0, auf der
Projektseite als 0.9.5 angegeben. Nicht aufgelöst. Das Spiel nennt deshalb **keine Agora-Versionsnummer**.

**Zweiter Widerspruch:** Das KI Nachrichten Portal ist laut Projektseite in Wartung, trägt auf der
Startseite aber „Stable". Das ist für das Spiel kein Problem, sondern ein Geschenk: Der Konflikt
(eine Zone ist real offline) ist damit kanonisch gedeckt und wird narrativ genutzt, statt geglättet.

### 1.3 Visuelle Identität — mit offenem Konflikt

Aus den Website-Texten belegt: dunkles Farbschema mit Blau-Akzenten, Glassmorphism (mehrfach
explizit als Design-Ansatz genannt, „Glaseffekt-Cards, also semi-transparente Panels"),
Terminal-Ästhetik (simulierter Terminal-Screenshot auf der Startseite, Blogeinträge mit
Terminal-Codezeilen), Karten-Layout mit Status-Badges. Quelle ist im Wesentlichen der
Update-Blogpost von Dezember 2025.

**Dann kam ein widersprechender Fund.** Die Asset-Inventur hat gezeigt, dass
`/Volumes/T7/Projekte/alexle-vsco` kein Fotoarchiv ist, sondern die **Quelle der Website**
(Astro-Monorepo). Dort liegt `src/styles/warm-noir.css` — die tatsächliche, aktuelle Palette:

| Rolle laut Variablenname | Wert | Charakter |
|---|---|---|
| `--mono-50` bis `--mono-975` | `#1c1b18` → `#ffffff` | warmes Monochrom, Beige-/Sepiastich, **kein Blaustich** |
| `--orange-400/500/600` | `#1f6b3b`, `#14532d`, `#0f3d21` | trotz Namen **grün** — offenbar ein Rebrand, bei dem die Variablennamen blieben |
| `--clay-400/500/600` | `#a85a38`, `#7a3a20`, `#5c2c18` | Terrakotta |
| `--signal-info` | `#2a5b7a` | gedämpftes Blau, ausschließlich Informationssignal |
| `--terminal-bg` | `#14181a` | Terminal-Fläche |

Schriften laut denselben Quellen: **Geist**, **Geist Mono**, **Newsreader** (Serif).
Eine zweite Datei heißt `v2-theme.css`.

**Deutung:** Die Marke hat sich vom dunkel-blauen Stand (Dezember 2025, den der Blogpost
beschreibt) zu einem warm-monochromen, editorialen Auftritt entwickelt. Beide Angaben sind echt,
sie beschreiben verschiedene Zeitpunkte. Der Widerspruch wird nicht geglättet.

**Entscheidung und ihre Begründung:** Das Spiel bleibt bei **dunkel mit Blau-Akzent**.

- Der Auftrag gibt „dunkles Glassmorphism, blaue Akzente, Terminal-Ästhetik" ausdrücklich vor.
  Das ist eine bewusste Vorgabe, keine Ableitung, die ich stillschweigend ersetzen sollte.
- Blau trägt hier zusätzlich eine Spielfunktion: Es markiert Benutzbarkeit (siehe Abschnitt 5).
  Ein warmes Monochrom mit grünen und terrakottafarbenen Akzenten müsste diese Rolle neu
  verteilen — das ist ein Art-Direction-Umbau, keine Farbanpassung.
- Die Palette liegt an genau drei Stellen zentral: `game/ui/theme.tres`,
  `game/world/materials/mat_accent.tres`, `game/world/realm_environment.tres`. Eine Umstellung
  auf warm-noir ist damit ein überschaubarer, abgegrenzter Vorgang — kein Umbau quer durchs Projekt.

Diese Entscheidung gehört Alexander Schneider, nicht mir. Sie ist hier dokumentiert, damit er sie
umdrehen kann, ohne den Grund rekonstruieren zu müssen.

---

## 2. Mapping: Kanon auf Spielinhalte

Leseart der Tabelle: Was auf der Website steht, wird zu Zone, Item, NPC, Boss, Quest. Die
**Mechanik**-Spalte ist der eigentliche Punkt — ein Projektname als Ortsbezeichnung ohne passende
Spielmechanik wäre bloße Dekoration.

| Kanon-Quelle | Zone | Item | NPC | Boss | Mechanik, die aus dem Kanon folgt |
|---|---|---|---|---|---|
| Terminal Missionen (WebContainer, 25+ Befehle, CTF) | Terminal-Ufer, Dungeon „WebContainer-Höhle" | Shell-Haken (Traversal: Greifhaken) | Shell-Lehrling | Fork-Bomb-Schleim | Befehls-Schreine: der Spieler wählt aus echten Shell-Befehlen den passenden. Falsche Wahl schadet nicht, blockiert nur. Der Fork-Bomb-Boss **teilt sich bei Treffern**, wie eine Fork-Bomb Prozesse forkt — er muss nicht erschlagen, sondern begrenzt werden |
| Docker Compose Builder (Services, Volumes, YAML) | Container-Werft, Dungeon „Compose-Labyrinth" | Compose-Hammer | Tux-Händler | Daemon-Wächter | Container-Inseln, die erst zusammenhängen, wenn der Spieler ein Volume zwischen zwei Services legt. Die neun echten Services sind die neun Inseltypen |
| Traefik als Reverse Proxy, Middleware-Reihenfolge | Traefik-Grat, Dungeon „Header-Tempel" | TLS-Schild | Traefik-Wächter | Middleware-Hydra | Tore öffnen nur bei **richtiger Reihenfolge** der Middleware-Platten. Die Hydra bekommt pro Runde einen Kopf mehr, wenn die Reihenfolge falsch bleibt |
| Ansible-/Automationsdenken, Idempotenz | Ansible-Steppe, Dungeon „Idempotenz-Mine" | Playbook-Bogen | — | Drift-Golem | Rätsel, die man **beliebig oft ausführen kann, ohne dass sich der Zustand ändert**. Wer zweimal dasselbe tut, kommt nicht weiter — nur der fehlende Schritt zählt. Der Drift-Golem macht Änderungen rückgängig, die nicht festgeschrieben wurden |
| CodeHack (8 Boss-Battles, XP, Skill-Tree, Bytes) | CodeHack-Arena | Heart-Container | Arena-Ansager | Syntax-Ritter | Boss-Rush als reines Kampftraining. Lokale Währung „Bytes" nur innerhalb der Arena, umtauschbar in Packets |
| Agora (Evidence-Gating, Wissensgraph, Claims) | Agora-Archiv, Dungeon „Knowledge-Graph-Kathedrale" | Evidence-Linse | Archivar | Halluzinations-Phantom | **Die beste Mechanik des Projekts.** Graph-Rätsel: Knoten sind per Kante verbunden, aber nur belegte Kanten tragen Gewicht. Die Evidence-Linse zeigt, welche Kante eine Quelle hat. Das Phantom erzeugt plausibel aussehende Kanten ohne Quelle — wer darauf tritt, fällt |
| IHK Radar (60 Themen, 6 Kategorien) | IHK-Radar-Turm | Skill-Chips | Prüfer | — | Sammel-Schreine, zwölf Runen, zwei pro echter Kategorie |
| ROI-Rechner (Zeitersparnis, Setup-Aufwand) | Händlerposten im Hub | — | ROI-Händler | — | Der Händler nennt für jedes Angebot Setup-Kosten und Ersparnis pro Nutzung, statt eines nackten Preises. Kaufentscheidung wird zur Rechnung |
| KI Nachrichten Portal (in Wartung, RSS, Dubletten) | Nachrichten-Relais (optional) | — | — | — | Die Zone ist **tatsächlich abgeschaltet** und bleibt es. Ein Wartungsschild erklärt es. Kanonisch korrekt, kostet keine Produktionszeit |
| Windows Terminal Missionen (CMD, Diskpart) | CMD-Katakomben (optional) | — | — | — | Zweiter Befehlssatz, andere Syntax für dieselbe Rätselart |
| M.2-Vortrag (SATA ca. 550, NVMe Gen4 ca. 7.000 MB/s) | NVMe-Nebel (optional) | Speed-Boots | — | — | Der belegte Faktor von rund 12,7 ist der Sprint-Multiplikator im Nebel-Abschnitt. Echte Zahl, echte Wirkung |
| Homelab: 48 Container hinter Traefik, Tailscale, AdGuard | Hub „Leipzig-Knoten / Homelab-Dorf" | Schwert `ed25519` | AS (Mentor), Mitlernende | — | Der VPS-Turm zeigt 48 Container-Fenster. Tutorial: Laufen, NPC, Kiste, Schwert, erster Kampf |
| Kernel-Ebene, Chaos-Paket | Kernel-Kern, Dungeon „Root-Dungeon" | Master-Deploy | — | Chaos-Paket | Finale, verlangt alle Kern-Relikte |

### 2.1 Der Konflikt, kanonisch verankert

`[FIKTION]` Ein Chaos-Paket aus korruptiertem Deploy und dunkler Middleware hat das Wissensnetz
zersplittert. Die Verankerung ist aber überall Kanon: Middleware-Reihenfolge zählt wirklich
(Traefik-Blogpost), das Nachrichtenportal ist wirklich in Wartung, Evidence-Gating trennt wirklich
Belegtes von Hypothesen. Das Spiel erfindet keine Katastrophe, es dramatisiert dokumentierte
Eigenschaften.

### 2.2 IT-Metaphern für Spielgegenstände

Aus Auftrag Abschnitt 8, hier auf den Kanon bezogen:

| Klassisch | Alexle Realm | Kanon-Anker |
|---|---|---|
| Schwert | CLI-Klinge `ed25519` | SSH-Keys statt Passwörter (Nebenquest), ed25519 ist ein echtes Schlüsselformat |
| Schild | TLS-Schild | Traefik mit Let's Encrypt, belegt bei CodeHack |
| Bomben | Rollback | Deploy-Denken |
| Bogen | Playbook-Bogen (Remote-Ausführung) | Automationsdenken |
| Greifhaken | Shell-Haken | Custom Shell der Terminal Missionen |
| Laterne | Evidence-Linse | Evidence-Gating aus Agora |

---

## 3. Annahmen (explizit, nicht belegt)

| Nr. | Annahme | Warum tragfähig | Risiko wenn falsch |
|---|---|---|---|
| A1 | ~~Die Farbpalette entspricht der Website hinreichend~~ **Überholt, siehe 1.3.** Die Website nutzt inzwischen warmes Monochrom. Die blaue Palette ist jetzt eine bewusste Auftragsvorgabe, keine Annahme über die Website | Auftrag gibt Blau vor; Blau trägt im Spiel die Funktion „benutzbar" | Gering, aber real: Das Spiel sieht der aktuellen Website nicht ähnlich. Umstellung auf warm-noir ist an drei zentralen Dateien möglich |
| A2 | „Packets" als Währungsname ist frei verwendbar | Aus dem Auftrag, nicht von der Website. CodeHack nutzt kanonisch „Bytes" | Gering. Bytes bleibt der Arena vorbehalten, kein Widerspruch |
| A3 | Zwölf Radar-Runen bei sechs echten Kategorien = zwei pro Kategorie | Auftrag nennt zwölf, Website sechs Kategorien. Teilt sich glatt | Keines |
| A4 | AS spricht als Mentor, nicht als Spielfigur | Auftrag verlangt es ausdrücklich | Keines |
| A5 | Ein Low-Poly-Stil mit Blockout-Basis trägt die Art Direction | Glassmorphism ist ein 2D-UI-Effekt, in 3D nur über Emission und Transparenz andeutbar | Mittel. Der Glas-Look muss in 3D über Material und Beleuchtung entstehen, nicht über kopierte UI-Optik |

---

## 4. Asset-Inventar

Vollständige Inventur: [docs/research/asset-inventory.md](research/asset-inventory.md).
Bewertung und Lizenzregeln: [docs/ASSETS.md](ASSETS.md), Abschnitt 3.

**Der Auftrag nahm eine VSCO-Fotobibliothek an. Das trifft nicht zu.** Unter
`/Volumes/T7/Projekte/alexle-vsco` liegt ein Astro-Web-Monorepo mit 451.618 Dateien und 6,9 GB,
überwiegend Build-Artefakte (`.js`, `.ts`, `.map`). Enthalten sind 4.234 Bilder (meist
WebP-Website-Grafiken), 28 Videos, 370 Schriftdateien und **keine** 3D-Dateien.

Zwei Folgen:

1. **Als Texturquelle weitgehend unbrauchbar.** Es sind Website-Grafiken, keine Fotomotive.
   Die geplante Poster-Textur im Hub ist hinfällig, bis eine echte Fotoquelle benannt wird.
2. **Für die Art Direction wertvoller als erwartet.** `src/styles/warm-noir.css` enthält die
   tatsächliche Markenpalette und die Schriftnamen. Damit wurde Annahme A1 durch Belege
   ersetzt — und ein Konflikt sichtbar, siehe Abschnitt 1.3.

Verbindlich bleibt: Das Verzeichnis bleibt **lokal**, nichts wird kopiert oder hochgeladen, der
Lizenzstatus ist **nicht geklärt**, und alle Texturen im Spiel entstehen bis auf Weiteres
prozedural oder stammen aus CC0-Quellen.

---

## 5. Art Direction

Die Werte setzen die **Auftragsvorgabe** um (dunkel, Blau-Akzent, Glas, Terminal). Sie sind
ausdrücklich **nicht** die aktuelle Website-Palette — die ist warm-monochrom, siehe
Abschnitt 1.3 samt Begründung dieser Entscheidung.

| Rolle | Hex | Einsatz |
|---|---|---|
| Grund | `#0c0f16` | Hintergrund, Nebelfarbe, UI-Grund |
| Panel (Glas) | `#131a26` bei ca. 82 % | UI-Panels, Fensterflächen am VPS-Turm |
| Rand | `#1d2635` | 1-px-Kanten, Kachelfugen |
| Akzent Blau | `#4da3ff` | Interaktives, Schwertspur, Quest-Marker |
| Akzent hell | `#7cc4ff` | Hover, aktiver Zustand, Emission |
| Text | `#e6edf7` | Fließtext |
| Text gedimmt | `#8b98ab` | Nebeninfo, Platzhalter |
| Herz | `#ff5a6e` | Lebensanzeige |
| Warnung | `#ffb347` | Boss-Telegraph, Gefahr |

Leitlinien:

- **Dunkel, nicht schwarz.** Der Grundton hat Blaustich. Reines Schwarz nur als Vignette.
- **Blau ist Bedeutung, nicht Dekoration.** Was blau leuchtet, ist benutzbar. Wer diese Regel für
  Deko bricht, zerstört die Lesbarkeit der Welt.
- **Glas in 3D über Material, nicht über UI-Kopie.** Halbtransparente Flächen mit schwacher
  Emission und scharfer Kante. Kein Bloom-Gewitter.
- **Terminal-Ästhetik heißt Monospace und Raster,** nicht grüner Text auf schwarz. Keine
  Matrix-Optik.
- **Leipzig nur stilisiert.** Keine erkennbaren realen Gebäude, keine Straßennamen.
- **Trocken-humorvoll, technisch, lernbar.** Kein High-Fantasy-Kitsch außer als bewusste
  IT-Metapher. Keine Marketingsprache — die Website vermeidet sie ausdrücklich, das Spiel auch.

---

## 6. Was bewusst draußen bleibt

- Private Daten jeder Art: Adressen, Telefonnummern, private IP-Adressen, Kontaktadressen,
  Gerätelisten, Seriennummern.
- Der Vorberuf-Lebenslauf. Widersprüchlich belegt und ohne Spielwert.
- Nintendo-/Zelda-Assets, -Modelle, -Musik, -UI. Die Inspiration ist strukturell, nicht visuell.
- Erfundene Ereignisse aus Alexander Schneiders Leben. Der Mentor-NPC spricht über Technik,
  nicht über Biografie.
- Agora-Versionsnummern, solange der Kanon sich widerspricht.
