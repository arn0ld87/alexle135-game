# ASSETS — Herkunft, Lizenzen, Pipeline

Stand: 2026-09-15
Lokale Inventur: [docs/research/asset-inventory.md](research/asset-inventory.md)

Diese Datei ist verbindlich. Ein Asset, das hier nicht mit geklärter Lizenz steht, darf nicht
im Repository liegen und nicht im Spiel verwendet werden.

---

## 1. Lizenzregeln

### Zulässig

- CC0 / Public Domain
- Lizenzen, die für ein potenziell veröffentlichtes Spiel eindeutig kompatibel sind, mit
  erfüllter Namensnennung
- Eigenbau: selbst modellierte Meshes, selbst geschriebene Shader, prozedurale Texturen
- Material, dessen Urheberschaft Alexander Schneider ausdrücklich bestätigt hat

### Ausgeschlossen

- Nintendo-Assets, Zelda-Modelle, -Texturen, -Musik, -Schriften, -UI
- Aus Spielen extrahierte Assets, in jeder Form
- Pinterest-Dateien und alles mit ungeklärter Herkunft
- Aus Asset-Stores gescrapte Dateien
- Urheberrechtlich geschützte Musik
- „Gratis"-Assets ohne auffindbaren Lizenztext

Die Zelda-Anlehnung ist **strukturell** (Dungeon-Aufbau, Item-öffnet-Weg, Herzen als
Lebensanzeige), nicht visuell. Kein Asset und kein UI-Element wird nachgebaut.

### Pflichtangaben je Fremdasset

| Feld | Bedeutung |
|---|---|
| Datei | Pfad im Repository |
| Quelle | vollständige URL |
| Autor | wie von der Quelle genannt |
| Lizenz | exakte Bezeichnung, z. B. CC0 1.0 |
| Abrufdatum | wann heruntergeladen |
| Namensnennung nötig | ja/nein, und wenn ja der genaue Text |
| Änderungen | was verändert wurde |

---

## 2. Fremdassets im Repository

**Derzeit keine.** Das Projekt läuft vollständig auf Primitivgeometrie und prozeduralen
Materialien. Diese Tabelle wird mit dem ersten Import gefüllt und bleibt sonst leer.

| Datei | Quelle | Autor | Lizenz | Abrufdatum | Namensnennung | Änderungen |
|---|---|---|---|---|---|---|
| — | — | — | — | — | — | — |

### Geprüfte Bezugsquellen

Verwendbar, jeweils **pro Datei** zu prüfen — eine Plattform ist keine Lizenz:

| Quelle | Typische Lizenz | Hinweis |
|---|---|---|
| Poly Haven | CC0 | HDRIs, Texturen, Modelle |
| Kenney | CC0 | Low-Poly-Sets, passt zum Blockout-Stil |
| Quaternius | CC0 | Charaktere und Umgebung |
| OpenGameArt | gemischt | Lizenz steht pro Datei, nicht pro Seite. Immer einzeln prüfen |
| itch.io | gemischt | nur explizite CC0-Einträge |
| Mixamo | eigene Bedingungen | nur wenn die Bedingungen den Anwendungsfall zulassen. Bis dahin nicht benutzt |

---

## 3. Lokales Verzeichnis `alexle-vsco`

Quelle: `/Volumes/T7/Projekte/alexle-vsco`
Vollständige Inventur: [docs/research/asset-inventory.md](research/asset-inventory.md)

### Befund: Das ist kein Fotoarchiv

Der Auftrag ging von einer VSCO-Fotobibliothek aus. Die Inventur zeigt etwas anderes:

| Metrik | Wert |
|---|---|
| Dateien insgesamt | 451.618 |
| Gesamtgröße | 6,9 GB |
| Häufigste Typen | `.js` (193.265), `.ts` (78.635), `.map` (49.607), `.astro` (23.551), `.mjs` (19.510) |
| Bilddateien | 4.234 (66 % WebP, 19 % PNG, 15 % JPG) |
| Videos | 28 MP4 |
| Schriftdateien | 370 (WOFF2 und TTF) |
| 3D-/Blender-Dateien | **0** |

Es handelt sich um ein **Astro-Web-Monorepo** — allem Anschein nach die Quelle von
alexle135.de. Der überwiegende Teil der Dateien sind Build-Artefakte und Abhängigkeiten
(`node_modules`, `dist`, Source-Maps), keine verwertbaren Spielassets.

**Folgen für das Spiel:**

- Für die Art Direction ist das Verzeichnis **wertvoller als erwartet**: `src/styles/warm-noir.css`
  enthält die tatsächliche Markenpalette und die Schriftnamen. Das hat eine Annahme in
  [docs/RESEARCH.md](RESEARCH.md) durch Belege ersetzt und einen Konflikt aufgedeckt
  (siehe dort Abschnitt 1.3).
- Als **Texturquelle** ist es weitgehend unbrauchbar: Die 4.234 Bilder sind
  Website-Grafiken (Screenshots, Projektkacheln, Icons), keine Fotomotive für Poster
  oder Oberflächen. Es gibt keine 3D-Dateien.
- Die geplante Verwendung „Poster-Texturen im Hub" ist damit **hinfällig**, solange nicht
  eine andere, tatsächliche Fotoquelle benannt wird.

### Verbindliche Regeln, unverändert

1. Die Dateien bleiben **lokal**. Nichts wird ins Repository kopiert.
2. Nichts wird hochgeladen, an einen Dienst gesendet oder in eine Fremd-API gegeben.
3. Der Lizenzstatus ist **nicht geklärt**. Die Inventur erfasst ausschließlich Metadaten
   und behauptet keine Urheberschaft.
4. Verwendung erst, wenn Alexander Schneider die Rechte **je verwendeter Datei**
   ausdrücklich bestätigt. Bei einem Web-Monorepo ist das besonders wichtig: Dort liegen
   neben eigenen Grafiken auch Fremdabhängigkeiten mit eigenen Lizenzen.
5. Freigegebene Bilder kämen als **verkleinerte, komprimierte Ableitungen** ins Projekt
   (maximal 1024 px lange Kante), nicht als Originale. `.gitignore` enthält deshalb
   `assets/_source_private/`.

### Zu den 370 Schriftdateien

Die Website nutzt **Geist**, **Geist Mono** und **Newsreader**. Diese Dateien werden
**nicht** ins Spiel übernommen — es bleibt bei Godots Standardschrift (siehe Abschnitt 7).

Sollte später eine Markenschrift gewünscht sein, gilt: Schriftlizenzen sind der am
häufigsten übersehene Fallstrick bei Spieleveröffentlichungen. Die Lizenz wird dann
**pro Schriftschnitt am Original der Herausgeber** geprüft und hier dokumentiert. Dass
eine Datei lokal vorliegt, ist keine Lizenz. Eine Vermutung über die Lizenzart wird hier
absichtlich nicht hingeschrieben, weil sie sonst irgendwann als geprüft gelesen wird.

---

## 4. Blender-Pipeline

Blender 5.2.1 LTS (Auftrag nennt 4.x; installiert und verwendet ist die neuere LTS).

### Maß- und Achskonvention

| Regel | Wert |
|---|---|
| Maßstab | 1 Godot-Unit = 1 Meter. In Blender in Metern modellieren, Szenen-Skalierung 1.0 |
| Held | rund 1,75 m hoch |
| Vorwärtsachse | Das Modell schaut in Blender nach **-Y**. Der glTF-Export dreht das auf Godots **-Z** |
| Ursprung | an den Füßen bzw. an der Standfläche, nicht in der Mitte |
| Transformationen | vor dem Export anwenden (Position, Rotation, Skalierung) |
| Geometrie | Dreiecke und Vierecke. Keine problematischen N-Gons |
| Normalen | nach außen, vor dem Export neu berechnen |

### Material

Metallic/Roughness über den Principled BSDF. Nur diese Eingänge verwenden, weil glTF
nur diese überträgt:

```text
Base Color, Metallic, Roughness, Normal, Emission, Alpha
```

Alles andere (Verschiebung, Subsurface, komplexe Knotenbäume) überlebt den Export nicht
und muss vorher gebacken werden.

Emission trägt die Art Direction: blaue Akzente (`#4da3ff`) sind Emission, nicht Base Color.
So leuchten sie in der dunklen Welt ohne zusätzliche Lichtquelle.

### Export

Format: **glTF 2.0 binär (`.glb`)**, ein Ziel pro Objektgruppe.

```text
blender/src/<name>.blend        Quelldatei, kommt ins Repository
game/assets/models/<name>.glb   Exportergebnis, kommt ins Repository
```

Die `.blend` gehört mit ins Repository — ein `.glb` ohne Quelldatei ist nicht wartbar.
`*.blend1`-Sicherungen sind in `.gitignore` ausgeschlossen.

Automatisierung: `blender/export_glb.py` (geplant, siehe ARG T-014), aufrufbar als

```bash
blender --background blender/src/hero.blend --python blender/export_glb.py
```

### Checkliste vor jedem Export

1. Transformationen angewendet
2. Ursprung an der Standfläche
3. Modell schaut nach -Y
4. Normalen nach außen
5. Materialien nur mit glTF-fähigen Eingängen
6. Keine ungenutzten Datenblöcke (`File > Clean Up > Unused Data-Blocks`)
7. Dreiecksanzahl im Budget (Held 4.000–8.000)
8. UV-Layout vorhanden, ein Atlas pro Objekt, maximal 2K

### Import in Godot

Godot importiert `.glb` automatisch. Reimport nicht vergessen, wenn sich eine Datei ändert:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --import
```

---

## 5. Eigenbau-Modelle (Plan)

Aus Auftrag Abschnitt 19. Alle für M3, keines auf dem M1-Pfad — M1 läuft auf Primitiven.

| Nr. | Modell | Budget (Dreiecke) | Zustand |
|---|---|---|---|
| 1 | Low-Poly-Held, ca. 1,75 m, 2K-Atlas | 4.000–8.000 | geplant |
| 2 | Mentor AS | 3.000–6.000 | geplant |
| 3 | VPS-/Homelab-Turm (48 Container-Fenster) | 2.000–4.000 | geplant |
| 4 | Schwert `ed25519` | 300–800 | geplant |
| 5 | Schild `TLS` | 300–800 | geplant |
| 6 | Docker-Container (modular, kachelbar) | 200–500 | geplant |
| 7 | Traefik-Tor | 1.000–2.500 | geplant |
| 8 | Tux-Händlerstand | 1.000–2.500 | geplant |
| 9 | Chaos-Paket (Endboss) | 5.000–10.000 | geplant |

Animationen für den Helden, mindestens: Idle, Walk, Slash. Ergänzend Run, Hurt, Die.

---

## 6. Audio

Derzeit **keine Audiodateien** im Projekt. Wenn Audio kommt, gelten dieselben Lizenzregeln.
Keine urheberrechtlich geschützte Musik, auch nicht als Platzhalter — ein Platzhalter, der
versehentlich im Build landet, ist dasselbe Problem wie ein finales Asset.

---

## 7. Schriften

Es wird die in Godot eingebaute Standardschrift verwendet. Keine Schriftdatei wird
heruntergeladen oder eingebunden, solange die Lizenz nicht geprüft ist. Schriftlizenzen
sind der am häufigsten übersehene Fallstrick bei Spieleveröffentlichungen.

Die Terminal-Ästhetik entsteht über Layout, Raster und Farbe, nicht über eine
zugekaufte Monospace-Schrift.
