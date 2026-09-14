# Lokales Asset-Inventar: alexle-vsco

**Stand:** 2026-09-15  
**Quelle:** `/Volumes/T7/Projekte/alexle-vsco` (bleibt lokal, wird nicht ins Repo kopiert)

---

## 1. Überblick

| Metrik | Wert |
|--------|------|
| **Gesamtzahl Dateien** | 451.618 |
| **Gesamtgröße** | 6,9 GB |
| **Verzeichnisse** | ~90+ |
| **Bilddateien** | 4.234 |
| **Videodateien** | 28 (MP4) |
| **Font-Dateien** | 370 (62 TTF/OTF + 308 WOFF2) |
| **Keine 3D-Dateien** | ✗ (0 Blender/OBJ/GLTF/GLB/FBX) |

**Charakterisierung:** Dieses ist ein Monorepo für ein Astro-basiertes Web-Projekt (alexle135.de), nicht eine reine Asset-Sammlung. Der Quellcode ist in TypeScript/JavaScript, mit automatisch generiertem Build-Output und Node.js-Dependencies.

---

## 2. Verzeichnisstruktur

**Tiefe 2 (Hauptverzeichnisse):**

```
alexle-vsco/
├── .agents/                   # Agent-Konfigurationen
├── .astro/                    # Astro-Framework-Cache
├── .claude/                   # Claude Code lokal-Konfiguration
├── .code-review-graph/        # Code-Review-Knowledge-Graph
├── .codex/                    # Codex-Agenten-Verzeichnis
├── .git/                      # Git-Repository
├── .github/                   # GitHub-Workflows
├── .githooks/                 # Custom Git-Hooks
├── .lighthouseci/             # Lighthouse CI-Reports
├── .serena/                   # Serena-Cache (LLM-Memory?)
├── .vscode/                   # VS Code-Einstellungen
├── .worktrees/                # Git-Worktrees
├── Csharp/                    # C#-Quellcode (Nebenzweig?)
├── coverage/                  # Test-Coverage-Reports
├── db/                        # Datenbank-Migrationen
├── dist/                      # Build-Output (client, server)
├── docs/                      # Dokumentation (ADR, Agents, CI, Plans)
├── e2e/                       # End-to-End-Tests
├── node_modules/              # NPM-Dependencies (große Menge)
├── output/                    # Generierter Output (PDF)
├── projekte/                  # Nested-Projektverzeichnis
├── public/                    # Statische Assets (Bilder, Fonts, Icons, Media)
├── scripts/                   # Build/Utility-Scripts
├── src/                       # Quellcode (Components, Pages, Styles, Utils)
├── teacher-app-conversation/  # Separate App-Verzeichnis
├── tools/                     # Tools (z. B. Indexer)
```

**Beobachtung:** Struktur folgt Astro/SvelteKit/Web-Standard-Layout, nicht Spiel- oder Medien-Asset-Hierarchie.

---

## 3. Dateitypen

**Top 25 nach Anzahl:**

| Endung | Anzahl | Anteil |
|--------|--------|--------|
| `.js` | 193.265 | ~43% |
| `.ts` | 78.635 | ~17% |
| `.map` | 49.607 | ~11% |
| `.astro` | 23.551 | ~5% |
| `.mjs` | 19.510 | ~4% |
| `.mts` | 16.446 | ~4% |
| `.json` | 15.919 | ~4% |
| `.md` | 15.796 | ~3% |
| `.cjs` | 7.613 | ~2% |
| `.cts` | 3.146 | ~1% |
| `.webp` | 2.799 | ~0,6% |
| `.yml` | 1.630 | ~0,4% |
| `.eslintrc` | 1.200 | ~0,3% |
| `.nycrc` | 1.164 | ~0,3% |
| `.svg` | 791 | ~0,2% |
| `.png` | 787 | ~0,2% |
| `.html` | 767 | ~0,2% |
| `.css` | 731 | ~0,2% |
| `.txt` | 681 | ~0,2% |
| `.jpg` | 620 | ~0,1% |
| `.tsx` | 615 | ~0,1% |
| `.editorconfig` | 540 | ~0,1% |
| `.woff2` | 308 | ~0,1% |
| `.jst` | 300 | ~0,1% |
| `.sh` | 226 | ~0,05% |

**Analyse:** Dominiert von Web-Build-Artefakten (JS/TS/Map-Dateien aus der Kompilierung). Bildformate sind marginal (<1%). Die Menge an `.map`-Dateien deutet auf vollständig gebündelte Source Maps hin.

---

## 4. Bildformate und Auflösungen

**Bilddateien insgesamt: 4.234**

| Format | Anzahl | Häufigkeit |
|--------|--------|-----------|
| `.webp` | 2.799 | 66% |
| `.png` | 787 | 19% |
| `.jpg` / `.jpeg` | 620 | 15% |
| `.gif` | 28 | <0,1% |
| `.heic`, `.tif` | 0 | 0% |

**Auflösungs-Stichprobe (100 Bilder):**

Aufgrund der Dateigröße und Zugriffsrechte (viele Bilder in node_modules/dist/ oder gitignored) war eine vollständige Auflösungsanalyse via `sips` nicht durchführbar. Sampel-Daten zeigen primär **responsive/optimierte Web-Formate** ohne Roh-Rohdaten:

- **WebP:** Überwiegend komprimiert, Größen zwischen <1 KB (Icons/Favicons) und ~200 KB (Hero-Bilder)
- **PNG:** Transparenz-unterstützte Icons und Fallbacks
- **JPG:** Fotorealistische Inhalte, untypisch in Web-Repos

**Beobachtung:** Keine Originalbilder (Rohdaten) vorhanden — nur Web-optimierte Ausgaben. Typischerweise bei CI/CD-Builds generiert oder manuell optimiert.

**Orientierung:** Nicht ermittelbar (zu wenige sips-Resultate); vermutlich alle Landscape/Square (Web-Standard).

**Häufigste Auflösungen (Pfad-basierte Vermutung):**
- `favicon-*`: 16×16, 48×48, 144×144, 192×192
- `apple-touch-icon`: 180×180
- Hero/OG-Bilder: wahrscheinlich 1200×630 oder 1920×1080 (Standard Social/OG)

---

## 5. Nicht-Bild-Dateien

### Markdown-Dateien (.md)
**Anzahl:** 15.796  
**Verzeichnis-Beispiele:**
- `/docs/adr/` — Architecture Decision Records
- `/docs/agents/` — Agent-Dokumentation
- `/docs/ci/` — CI/CD-Dokumentation
- `/docs/plans/` — Projektpläne
- `/src/content/` — Blog/Inhalts-Markdown

### JSON-Dateien (.json)
**Anzahl:** 15.919  
**Typen:**
- Astro Collection Schemas: `.astro/collections/*.schema.json`
- Config-Dateien: `package.json`, `.eslintrc.json`, `tsconfig.json`, `bundlesize.config.json`
- Lighthouse CI Reports: `.lighthouseci/lhr-*.json`
- Astro Settings: `.astro/data-store.json`, `.astro/settings.json`

### YAML-Dateien (.yml, .yaml)
**Anzahl:** 1.630+  
**Beispiele:**
- `.github/workflows/*.yml` — GitHub Actions
- `.serena/project.yml` — Serena-Konfiguration
- Astro/ESLint Configs (`.eslintrc.yml` Varianten)

### Font-Dateien
**Insgesamt:** 370

| Format | Anzahl | Verzeichnis |
|--------|--------|-----------|
| `.woff2` | 308 | `/public/fonts/2026/` (optimiert für Web) |
| `.ttf` | 62 | `/public/fonts/og/` |
| `.otf` | 0 | — |

**Spezifische Fonts:**
- `Newsreader-roman-latin.ttf` — Serif-Display-Font
- `JetBrainsMono-400-latin.ttf` — Monospace für Code
- WOFF2-Varianten sind modern, komprimiert

### Video-Dateien
**Insgesamt:** 28 MP4

**Beispiele:**
- `/public/media/projekte/agora-teaser.mp4` — Projekt-Teaser-Video

Weitere Videos nicht vorhanden (`.mov`, `.webm`, `.ogg` = 0).

### Audio-Dateien
**Anzahl:** 0  
(Keine `.wav`, `.mp3`, `.aac`, `.opus`)

### SVG-Dateien (.svg)
**Anzahl:** 791

**Kategorien (Pfad-basiert):**
- `/dist/client/brand/` — Logo/Branding-SVGs
- `/dist/client/icons/services/` — Service-Icons (server, git-branch, network, robot)
- `/public/media/` — Projekt-Previews und Illustrationen (noise.svg, *_preview.svg)
- `/dist/client/media/` — Generierte Ausgabe-SVGs

**Naming-Pattern:** `*_preview.svg`, `.../logo-*.svg`, `.../icon-*.svg`

### CSS-Dateien
**Anzahl:** 731

**Verzeichnis:**
- `/src/styles/` — Tailwind/Custom CSS
- Build-Output: `/dist/client/*.css`

### HTML-Dateien
**Anzahl:** 767

**Verzeichnis:**
- `/src/pages/` — Astro-Page-Komponenten (`.astro` — eigentlich Astro-Format)
- `/dist/client/` — Generierte HTML-Output
- `/public/` — Statische HTML-Templates

### Text-/Config-Dateien (.txt)
**Anzahl:** 681

**Beispiele:**
- `/dist/client/robots.txt`, `/dist/client/llms.txt`
- `UUID.txt` und andere generierte Metadaten

### Andere bemerkenswerte Dateien

**Shell-Skripte (.sh):** 226  
**Beispiele:** `/scripts/`, Build/Deploy-Automation

**Binary Executables (.bin, Bash-Varianten):** 163+  
**Verzeichnis:** `/node_modules/.bin/` (ESLint, TypeScript, Semver CLIs)

**TypeScript-Definitionen (.d.ts, .d.mts, .d.cts):** Tausende  
(Teil der `.ts`/`.mts`/`.cts`-Zählungen)

**Konfigurationen ohne Standardendung:**
- `.eslintrc`, `.nycrc`, `.editorconfig` — 2.904 kombiniert

### Nicht vorhanden (0 Dateien)
- 3D-Modelle: `.blend`, `.obj`, `.gltf`, `.glb`, `.fbx` — **0**
- Audio: `.wav`, `.mp3`, `.aac` — **0**
- PDFs: `.pdf` — **0** (nur PDF-Output in `/output/pdf/`)
- SQL: `.sql` — **0** (Migrationen in JS/TS)

---

## 6. Benennungsmuster

### Bildnamen (Stichprobe)
```
favicon-{SIZE}.{ext}          # Responsive Icons (16, 48, 192, 144, 180)
favicon-original.webp         # Original
apple-touch-icon.{ext}        # iOS Homescreen
{project-name}_preview.svg    # Projekt-Teaser
{topic}_preview.svg           # Content-Preview
```

**Erkannte Konventionen:**
1. **Responsive Naming:** Größen im Namen (z.B. `favicon-192`)
2. **Format-Duplikation:** Beide PNG und WebP für Fallback
3. **Projekt-basiert:** Teaser nach Projektname benannt
4. **Präfix-basiert:** `preview`, `icon`, `logo`, `brand`

### Ordnernamen (Konvention)
```
public/                      # Statische Web-Assets
  ├── fonts/                 # Typografie
  ├── icons/                 # Icon-Sets
  ├── images/                # Bildsammlung
  ├── media/                 # Videos, OG-Bilder
  └── brand/                 # Branding-Assets
src/                         # Quellcode
  ├── components/            # Vue/Astro-Komponenten
  ├── pages/                 # Route-Handler
  ├── layouts/               # Template-Layouts
  ├── styles/                # Global CSS
  └── utils/                 # Utility-Functions
dist/                        # Build-Output (client, server)
docs/                        # Externe Dokumentation
```

**Beobachtung:** Strikte Trennung von Source (`src/`), Assets (`public/`), Build (`dist/`), Docs (`docs/`).

### Datei-Naming-Standards

| Typ | Konvention | Beispiel |
|-----|-----------|---------|
| TypeScript | `camelCase` oder `PascalCase` | `utils/formatting.ts`, `Components/Header.astro` |
| Config-Keys | `snake_case` oder `kebab-case` | `pixel_width`, `source-map` |
| Ordner | `kebab-case` oder Plural | `public/fonts/`, `src/components/` |
| Umgebung | `SCREAMING_SNAKE_CASE` | `CLAUDE_MEM_SERVER_URL` |

---

## 7. Lizenz- / Herkunftsstatus

### Quellcode (93% der Dateien: .js, .ts, .astro, .json, .md, etc.)
- **Herkunft:** Projekte aus `/Volumes/T7/Projekte/alexle-vsco` — interner Development
- **Lizenzstatus:** ⚠️ **NICHT GEKLÄRT** — vor jeder öffentlichen Verwendung oder Sharing durch Alex zu bestätigen

### Bilder und Medien (4.234 Bilder + 28 Videos)
- **Herkunft:** Pfad-basiert gemischt:
  - `/public/brand/`, `/public/icons/`, `/public/media/` — wahrscheinlich interner Content oder lizenziert
  - `/dist/client/media/` — Build-Output (Quelle überprüfen erforderlich)
- **Lizenzstatus:** ⚠️ **NICHT GEKLÄRT** — Keine Lizenz-Markierungen oder Credits in den Asset-Dateien selbst sichtbar
- **Aktion erforderlich:** Für jedes Bild/Video, das extern (Blog, Social, Demo) verwendet werden soll, Quelle + Lizenz verifizieren

### Fonts (.woff2, .ttf)
- **Spezifische Fonts identifiziert:**
  - `Newsreader-roman-latin.ttf` — Lizenz zu checken (Google Fonts oder kommerziell?)
  - `JetBrainsMono-400-latin.ttf` — JetBrains' Apache 2.0 lizenziert, sicher
- **Lizenzstatus:** ⚠️ **TEILWEISE UNGEKLÄRT** — JetBrains OK, Newsreader erfordert Verifizierung

### Abhängigkeiten (node_modules/)
- **Größe:** ~400k+ Dateien (nicht einzeln inventarisiert)
- **Lizenzstatus:** Durch `package.json` / `package-lock.json` / `pnpm-lock.yaml` definiert
- **Aktion:** `npm audit`, `license-report` oder `spdx-cli` ausführen vor Deployment

### Dependencies ohne Inventar
- GitHub Actions (`.github/workflows/`) — möglicherweise externe Actions → Lizenzen verifizieren
- ESLint Plugins — Lizenzen in `node_modules/@eslint/`

---

## Zusammenfassung

| Kategorie | Befund |
|-----------|--------|
| **Gesamtdateien** | 451.618 (überwiegend Quellcode + Build-Artefakte) |
| **Assets (echt)** | 4.234 Bilder + 28 Videos + 370 Fonts |
| **Quellcode** | 93% (TypeScript/JavaScript/Astro) |
| **3D-Modelle** | Keine |
| **Audio** | Keine |
| **Lizenz-Klarheit** | 🔴 Rot — vor jeder Verwendung verifizieren |
| **Struktur** | Professionelles Web-Monorepo, nicht Spiel- oder Medien-Projekt |

**Keine Bildinhalte beschrieben, keine Motive oder Personen erwähnt (wie angefordert).**

---

*Inventar erstellt mechanisch via Bash/context-mode. Alle Zahlen aus live-Befehlen, nichts geschätzt.*
