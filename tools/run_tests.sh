#!/usr/bin/env bash
# Führt die Headless-Testsuite von Alexle Realm aus.
#
# Aufruf aus dem Repo-Root:
#   tools/run_tests.sh                       # gesamte Suite
#   tools/run_tests.sh test_player.gd        # nur diese Datei(en)
#
# Der Filter ist für parallele Arbeit gedacht: wer an einer eigenen Testdatei
# schreibt, lässt nicht die halbfertigen Dateien anderer mitlaufen.
#
# Godot-Binary überschreibbar:
#   GODOT=/pfad/zu/godot tools/run_tests.sh

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"

if [[ ! -x "$GODOT" ]]; then
  echo "FEHLER: Godot nicht gefunden unter '$GODOT'. Setze GODOT=/pfad/zu/godot." >&2
  exit 127
fi

LOG="$(mktemp -t alexle-realm-tests)"

if [[ $# -gt 0 ]]; then
  "$GODOT" --headless --path "$REPO_ROOT/game" res://tests/test_main.tscn -- "$@" 2>&1 | tee "$LOG"
else
  "$GODOT" --headless --path "$REPO_ROOT/game" res://tests/test_main.tscn 2>&1 | tee "$LOG"
fi
EXIT_CODE=${PIPESTATUS[0]}

# Zweite Verteidigungslinie gegen falsches Grün: Ein Script mit Parse-Fehler
# wird von Godot gemeldet, kann aber am Exit-Code vorbeigehen. Auf generisches
# "ERROR:" wird bewusst NICHT geprüft — test_core_state.gd erzeugt absichtlich
# Fehlermeldungen, wenn es die Abweisung ungültiger Speicher-Slots testet.
LOAD_ERRORS="$(grep -nE 'Parse Error|Failed to load script|Compile Error' "$LOG" || true)"
STATUS=$EXIT_CODE

if [[ -n "$LOAD_ERRORS" ]]; then
  echo ""
  echo "FEHLGESCHLAGEN: Script konnte nicht geladen werden:"
  echo "$LOAD_ERRORS"
  STATUS=1
fi

echo ""
if [[ $STATUS -eq 0 ]]; then
  echo "OK: Testsuite grün (Exit 0, keine Ladefehler)."
else
  echo "FEHLGESCHLAGEN: Status $STATUS (Godot-Exit $EXIT_CODE)."
fi

rm -f "$LOG"
exit $STATUS
