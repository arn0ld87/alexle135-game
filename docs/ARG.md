# ARG — Agent- und Arbeitsregister

Maschinenlesbare Quelle der Wahrheit: [.arg/registry.yaml](../.arg/registry.yaml)
Prüfskript: `python3 tools/arg_check.py`

Dieses Dokument erklärt die Regeln. Die Daten stehen in der YAML-Datei, damit sie
nicht an zwei Stellen gepflegt werden müssen.

Vor dieser Einrichtung wurde geprüft, ob im Projekt oder in den Nachbarprojekten
unter `/Volumes/T7/Projekte/` bereits eine ARG-Konvention existiert (Suche nach
`ARG.md`, `registry.yaml`, `.arg/`, `agent registry`, `agent graph`). Es wurde keine
gefunden. Daher wurde das im Auftrag beschriebene Minimalformat angelegt, kein
konkurrierendes System.

---

## 1. Was das ARG leistet

Es beantwortet vier Fragen nachprüfbar:

1. Wer ist für was zuständig?
2. Was ist tatsächlich fertig — und woran ist das zu erkennen?
3. Was hängt von was ab?
4. Was ist offen oder blockiert?

Es ist **kein Wunschzettel**. Ein Eintrag beschreibt den Ist-Zustand.

---

## 2. Statuswerte

| Status | Bedeutung |
|---|---|
| `planned` | Aufgabe ist beschrieben, niemand arbeitet daran |
| `assigned` | Zugewiesen, noch nicht begonnen |
| `in_progress` | In Arbeit |
| `blocked` | Wartet auf etwas Externes. Der Grund gehört ins `scope`-Feld |
| `review` | Implementiert, aber noch nicht verifiziert |
| `verified` | Abgeschlossen **und** durch ausgeführte Prüfung belegt |
| `done` | Abgeschlossen ohne ausführbare Prüfung (z. B. Dokumentation), mit Belegen |
| `deprecated` | Ersetzt oder verworfen. Bleibt als Spur stehen |

### Die Evidence-Regel

> `verified` und `done` sind ohne Belege nicht zulässig. Ohne Beleg ist der
> höchste erreichbare Status `review`.

Konkret abgelehnt wird:

```yaml
status: done          # ohne evidence, ohne validation
```

Verlangt wird:

```yaml
status: verified
validation:
  - "tools/run_tests.sh test_core_state.gd -> 25 bestanden, 0 fehlgeschlagen, Exit 0"
evidence:
  - game/scripts/core/game_state.gd
  - game/tests/test_core_state.gd
```

`validation` enthält **ausgeführte** Befehle mit deren Ergebnis, nicht geplante.
Ein noch offener Punkt wird als `"OFFEN: ..."` notiert — dann ist `verified`
automatisch gesperrt.

---

## 3. Automatische Hygieneprüfung

`tools/arg_check.py` prüft und liefert Exit-Code 1 bei Verstoß:

1. Pflichtfelder in jedem Task- und Agenteneintrag
2. `verified`/`done` ohne `evidence` oder ohne `validation`
3. `verified`/`done`, obwohl ein `validation`-Eintrag mit `OFFEN` beginnt
4. Unter `evidence` genannte Dateien, die nicht existieren
5. Bei `verified`/`done`: `outputs`, die nicht existieren
6. `dependencies`, die auf unbekannte Task-IDs zeigen
7. `owner`, der keine registrierte Agentenrolle ist
8. Doppelte IDs
9. Ungültige Statuswerte

Damit ist „das ARG ist gepflegt" eine prüfbare Aussage und keine Behauptung.
Das Skript läuft in wenigen Millisekunden und gehört vor jeden Milestone-Abschluss.

---

## 4. Wann wird aktualisiert

Pflicht bei: neuer Agentenrolle, neuem Task, geänderter Zuständigkeit, neuer
Abhängigkeit, abgeschlossenem Task, fehlgeschlagenem Task, ersetzter
Implementierung, neuem Artefakt, erfolgreicher Verifikation, Architekturänderung,
Milestone-Abschluss.

Reihenfolge am Milestone-Ende:

```text
Tests laufen lassen  ->  Ergebnis in validation eintragen  ->  Status setzen
->  tools/arg_check.py  ->  docs/PROGRESS.md aktualisieren
```

Nie umgekehrt. Status vor Prüfung zu setzen ist genau der Fehler, den die
Evidence-Regel verhindert.

---

## 5. Agentenrollen

| Rolle | Kostenklasse | Zuständig für |
|---|---|---|
| `lead-architect` | lead | Architektur, Datenmodelle, Save-Format, Kampfkontrakt, Weltkonsistenz, Privacy, Lizenz, Integration, finale Reviews |
| `research-web` | mid | Belegte Faktenextraktion von alexle135.de, ohne Interpretation |
| `research-assets` | cheap | Metadaten-Inventur lokaler Assets, nur lesend |
| `godot-gameplay` | mid | Player, Kamera, Kampfanbindung |
| `godot-ui` | mid | HUD, Dialog, Menüs |
| `godot-interactions` | mid | Kisten, Türen, Schlüssel, Schalter, Checkpoints |
| `godot-enemies` | mid | Gegner-Basisklasse, Gegnertypen, Bosse |
| `godot-world` | mid | Blockout, Navigation, Beleuchtung |
| `blender-assets` | mid | Eigenbau-Meshes, glTF-Export |
| `qa-gameplay` | cheap | Testfälle nach Spezifikation |
| `docs-maintainer` | cheap | PROGRESS.md, CONTROLS.md, ASSETS.md |
| `license-review` | cheap | Herkunft und Lizenz jedes Fremdassets |

Eine Rolle ohne zugewiesenen Task ist zulässig, solange sie geplant ist — das
Prüfskript weist darauf als Hinweis hin, nicht als Fehler. Einweg-Rollen für
einen einzelnen Task werden nicht angelegt, wenn eine bestehende Rolle passt.

---

## 6. Delegationsregeln

Beim Hauptagenten (`lead-architect`) bleiben: Gesamt- und Gameplay-Architektur,
zentrale Datenmodelle, Savegame-Format, Story- und Weltkonsistenz, Privacy,
Lizenz, Security, komplexe Cross-System-Fehler, offene Fehlersuche, größere
Refactorings, Performance-Architektur, finale Integration und Review,
Entscheidungen mit mehreren sinnvollen Lösungen.

Delegiert wird an günstigere Rollen: Dateisuche, Inventur, Boilerplate, einfache
Komponenten, triviale Refactorings, Umbenennungen, Formatierung, JSON/YAML,
Dokumentationspflege, Lizenzlisten, Import-/Exportskripte, Testfälle nach klarer
Spezifikation, Linting, repetitive Szenen, einfache UI-Komponenten, Fehler mit
eindeutigem Reproduktionsweg.

Jeder delegierte Task braucht: klaren Scope, konkrete Eingabedateien, erwartete
Ausgabedateien, messbares Erfolgskriterium, explizite Constraints (was *nicht*
angefasst werden darf) und eine Validierung.

### Parallelisierung und geteilter Zustand

Parallele Arbeit ist erlaubt, solange keine zwei Rollen dieselben Dateien
schreiben. **Die Testsuite ist ebenfalls geteilter Zustand:** Läuft
`tools/run_tests.sh` ohne Filter, während eine andere Rolle gerade eine
Testdatei schreibt, scheitert der Lauf an fremdem, halbfertigem Code. Deshalb
nimmt der Runner einen Dateifilter:

```bash
tools/run_tests.sh test_player.gd
```

Vor der Integration läuft die Suite immer ungefiltert.

---

## 7. Übernahme von Subagenten-Ergebnissen

Kein Ergebnis wird ungeprüft übernommen. Geprüft wird auf: technische
Korrektheit, Scope-Einhaltung, Regressionen, Architekturkonformität,
Lizenzprobleme, erfundene Inhalte, Secrets, unnötige Abhängigkeiten,
Performance-Probleme.

Bereits angewandt: Die Website-Recherche (T-005) wurde vor Übernahme einem
Struktur- und Privacy-Scan unterzogen; eine öffentlich belegte Kontaktadresse
wurde trotz Erlaubnis redigiert, weil sie für das Spiel keinen Nutzen hat.
