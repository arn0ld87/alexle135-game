#!/usr/bin/env python3
"""ARG-Hygieneprüfung für Alexle Realm.

Der Auftrag verlangt, dass das ARG den tatsächlichen Projektzustand
widerspiegelt und kein Wunschzettel ist. Genau das prüft dieses Skript,
damit "ARG ist gepflegt" eine nachweisbare Aussage bleibt.

Geprüft wird:
  1. Struktur: Pflichtfelder in jedem Task- und Agenteneintrag.
  2. Evidence-Disziplin: Status verified/done ohne Evidence oder ohne
     Validierungsbefehl ist ein Fehler.
  3. Dateiwahrheit: Jede unter evidence genannte Datei muss existieren.
  4. Offene Validierung: verified/done mit einem validation-Eintrag, der
     noch mit "OFFEN" beginnt, ist ein Widerspruch.
  5. Abhängigkeiten: Jede dependency muss auf eine existierende Task-ID zeigen.
  6. Verwaiste Zuständigkeit: Jeder Task-owner muss eine bekannte Agenten-ID sein.
  7. Doppelte IDs bei Tasks und Agenten.
  8. Unbenutzte Agentenrollen (Warnung, kein Fehler — geplante Rollen sind erlaubt).
  9. Gültige Statuswerte.

Aufruf:
    tools/arg_check.py            # aus dem Repo-Root
    python3 tools/arg_check.py

Exit-Code 0 = sauber, 1 = mindestens ein Fehler.
"""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:
    sys.stderr.write(
        "FEHLER: PyYAML fehlt. Alternativ: uv run --with pyyaml tools/arg_check.py\n"
    )
    raise SystemExit(127)

# YAML liefert unstrukturierte Daten. Die Aliase machen sichtbar, dass hier
# bewusst dynamisch gelesen wird — die Prüfung selbst validiert die Struktur.
Entry = dict[str, Any]

VALID_STATUS = {
    "planned",
    "assigned",
    "in_progress",
    "blocked",
    "review",
    "verified",
    "done",
    "deprecated",
}

# Diese Status behaupten abgeschlossene Arbeit und brauchen daher Belege.
CLAIMS_COMPLETION = {"verified", "done"}

TASK_REQUIRED = [
    "id",
    "name",
    "type",
    "status",
    "owner",
    "model_class",
    "scope",
    "dependencies",
    "inputs",
    "outputs",
    "validation",
    "evidence",
    "last_updated",
]

AGENT_REQUIRED = ["id", "name", "model_class", "scope", "status"]


def main() -> int:
    repo_root = Path(__file__).resolve().parent.parent
    registry_path = repo_root / ".arg" / "registry.yaml"

    if not registry_path.exists():
        print(f"FEHLER: {registry_path} fehlt.")
        return 1

    with registry_path.open(encoding="utf-8") as handle:
        data: Entry = yaml.safe_load(handle) or {}

    errors: list[str] = []
    warnings: list[str] = []

    agents: list[Entry] = data.get("agents") or []
    tasks: list[Entry] = data.get("tasks") or []

    # --- Agenten ---------------------------------------------------------
    agent_ids: set[str] = set()
    for index, agent in enumerate(agents):
        label: str = str(agent.get("id", f"agents[{index}]"))
        for field in AGENT_REQUIRED:
            if field not in agent or agent[field] in (None, ""):
                errors.append(f"Agent {label}: Feld '{field}' fehlt oder ist leer.")
        agent_status: str = str(agent.get("status"))
        if agent_status not in VALID_STATUS:
            errors.append(f"Agent {label}: Status '{agent_status}' ist ungültig.")
        agent_id: str = str(agent.get("id", ""))
        if agent_id and agent_id in agent_ids:
            errors.append(f"Agent {label}: ID doppelt vergeben.")
        if agent_id:
            agent_ids.add(agent_id)

    # --- Tasks -----------------------------------------------------------
    task_ids: set[str] = set()
    used_owners: set[str] = set()

    for index, task in enumerate(tasks):
        label = str(task.get("id", f"tasks[{index}]"))

        for field in TASK_REQUIRED:
            if field not in task:
                errors.append(f"Task {label}: Feld '{field}' fehlt.")

        status: str = str(task.get("status"))
        if status not in VALID_STATUS:
            errors.append(f"Task {label}: Status '{status}' ist ungültig.")

        task_id: str = str(task.get("id", ""))
        if task_id and task_id in task_ids:
            errors.append(f"Task {label}: ID doppelt vergeben.")
        if task_id:
            task_ids.add(task_id)

        owner: str = str(task.get("owner", ""))
        if owner:
            used_owners.add(owner)

        evidence: list[str] = [str(e) for e in (task.get("evidence") or [])]
        validation: list[str] = [str(v) for v in (task.get("validation") or [])]

        # Evidence-Disziplin: Behauptung nur mit Beleg.
        if status in CLAIMS_COMPLETION:
            if not evidence:
                errors.append(
                    f"Task {label}: Status '{status}' ohne Evidence. "
                    "Ohne Beleg höchstens 'review'."
                )
            if not validation:
                errors.append(f"Task {label}: Status '{status}' ohne validation-Eintrag.")
            for entry in validation:
                if str(entry).strip().upper().startswith("OFFEN"):
                    errors.append(
                        f"Task {label}: Status '{status}', aber Validierung ist "
                        f"noch offen ('{entry}')."
                    )

        # Dateiwahrheit
        for rel_path in evidence:
            if not (repo_root / rel_path).exists():
                errors.append(f"Task {label}: Evidence-Datei fehlt: {rel_path}")

        # Outputs sind Absichtserklärungen, solange nicht abgeschlossen.
        # Bei abgeschlossener Arbeit müssen sie existieren.
        if status in CLAIMS_COMPLETION:
            for rel_path in [str(o) for o in (task.get("outputs") or [])]:
                if not (repo_root / rel_path).exists():
                    errors.append(
                        f"Task {label}: als '{status}' markiert, aber Output fehlt: {rel_path}"
                    )

    # --- Querverweise ----------------------------------------------------
    for task in tasks:
        label = str(task.get("id", "?"))
        for dep in [str(d) for d in (task.get("dependencies") or [])]:
            if dep not in task_ids:
                errors.append(f"Task {label}: dependency '{dep}' ist keine bekannte Task-ID.")
        task_owner: str = str(task.get("owner", ""))
        if task_owner and task_owner not in agent_ids:
            errors.append(
                f"Task {label}: owner '{task_owner}' ist keine registrierte Agentenrolle."
            )

    for agent_id in sorted(agent_ids - used_owners):
        warnings.append(
            f"Agentenrolle '{agent_id}' hat keinen zugewiesenen Task "
            "(zulässig, wenn geplant)."
        )

    # --- Ausgabe ---------------------------------------------------------
    print(f"ARG-Prüfung: {len(tasks)} Tasks, {len(agents)} Agentenrollen")

    status_counts: dict[str, int] = {}
    for task in tasks:
        key = str(task.get("status"))
        status_counts[key] = status_counts.get(key, 0) + 1
    print("Status: " + ", ".join(f"{k}={v}" for k, v in sorted(status_counts.items())))

    for warning in warnings:
        print(f"  HINWEIS  {warning}")
    for error in errors:
        print(f"  FEHLER   {error}")

    if errors:
        print(f"\nFEHLGESCHLAGEN: {len(errors)} Problem(e) im ARG.")
        return 1

    print("\nOK: ARG ist konsistent, jede Abschlussbehauptung hat Belege.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
