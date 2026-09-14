#!/usr/bin/env bash
# Headless-Smoke-Test für Alexle Realm.
#
# Prüft, was der Auftrag als Minimum verlangt:
#   - Projekt startet headless
#   - Exit-Code 0
#   - keine SCRIPT ERROR / Parser-Fehler im Log
#
# Aufruf aus dem Repo-Root:
#   tools/smoke_test.sh
#
# Godot-Binary überschreibbar:
#   GODOT=/pfad/zu/godot tools/smoke_test.sh

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"
LOG="$(mktemp -t alexle-realm-smoke)"

if [[ ! -x "$GODOT" ]]; then
  echo "FEHLER: Godot nicht gefunden unter '$GODOT'." >&2
  echo "        Setze GODOT=/pfad/zu/godot." >&2
  exit 127
fi

echo "== Godot: $("$GODOT" --version)"
echo "== Projekt: $REPO_ROOT/game"

"$GODOT" --headless --path "$REPO_ROOT/game" --quit-after 1 >"$LOG" 2>&1
EXIT_CODE=$?

# Godot meldet Skriptfehler im Log, beendet sich aber teils trotzdem mit 0.
# Deshalb wird das Log zusätzlich auf Fehlermuster geprüft.
ERRORS="$(grep -nE 'SCRIPT ERROR|Parse Error|Cannot open|Failed to load|ERROR:' "$LOG" || true)"

echo "--- Ausgabe ---"
grep -vE '^\s*$' "$LOG" || true
echo "---------------"

STATUS=0
if [[ $EXIT_CODE -ne 0 ]]; then
  echo "FEHLGESCHLAGEN: Exit-Code $EXIT_CODE (erwartet 0)"
  STATUS=1
fi
if [[ -n "$ERRORS" ]]; then
  echo "FEHLGESCHLAGEN: Fehlermuster im Log:"
  echo "$ERRORS"
  STATUS=1
fi

if [[ $STATUS -eq 0 ]]; then
  echo "OK: Exit-Code 0, keine Fehler im Log."
fi

rm -f "$LOG"
exit $STATUS
