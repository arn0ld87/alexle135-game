class_name Interactable
extends Area3D
## Basisklasse für alle benutzbaren Weltobjekte (Kisten, Türen, Hebel, NPCs, ...).
##
## Vertrag (nicht ändern, der Player hängt daran):
##   - `collision_layer = 8` (interactable), `collision_mask = 0`. Der Player
##     findet Objekte über seine eigene Area3D "InteractRange" (mask = 8).
##   - `interact()` ist die EINZIGE Eintrittstür für den Player. Unterklassen
##     überschreiben `_perform_interaction`, nicht `interact` selbst.
##   - `flag_id` ist die stabile ID für Weltzustand. Leer = das Objekt merkt
##     sich nichts über Szenenwechsel oder Speicherstände hinweg.
##   - Bei `one_shot = true` wird `flag_id` nach erfolgreicher Interaktion
##     gesetzt. GameState.set_flag ist idempotent, also lösen wiederholte
##     Aufrufe kein zweites Signal aus — darauf beruht die Einmaligkeit.

## Gemeldet, nachdem eine Interaktion erfolgreich abgeschlossen wurde.
signal interacted(interactable: Interactable)

## Stabile ID für den Weltzustand. Leer = nicht persistent.
@export var flag_id: String = ""
## Text für den Interaktions-Prompt, z.B. "Kiste öffnen".
@export var prompt_text: String = "Benutzen"
## Wenn true, ist das Objekt nach einer Benutzung dauerhaft erschöpft.
@export var one_shot: bool = true


## Standardkonfiguration für "per Tastendruck gefundene" Interactables: das
## Objekt sucht selbst nichts (monitoring = false), lässt sich aber von der
## InteractRange-Area3D des Players finden (monitorable = true). Subklassen,
## die selbst Körper erkennen müssen (auto_pickup, Druckplatte, Checkpoint),
## überschreiben das in ihrem eigenen `_ready()` nach `super._ready()`.
func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	monitoring = false
	monitorable = true
	if is_consumed():
		_restore_consumed_state()


## Ob eine Interaktion gerade möglich ist. Unterklassen überschreiben das für
## eigene Voraussetzungen (Schlüssel vorhanden, Flag gesetzt, ...).
func can_interact() -> bool:
	return not is_consumed()


## Eintrittstür für den Player. Prüft can_interact(), führt dann die konkrete
## Interaktion aus und pflegt danach Flag und Signal.
func interact(interactor: Node3D) -> void:
	if not can_interact():
		return
	_perform_interaction(interactor)
	if one_shot and not flag_id.is_empty():
		GameState.set_flag(flag_id)
	interacted.emit(self)


## true, wenn das Objekt über sein Flag bereits als verbraucht markiert ist.
func is_consumed() -> bool:
	return one_shot and not flag_id.is_empty() and GameState.get_flag(flag_id)


## Prompt für die aktuelle Situation. Unterklassen überschreiben das für
## zustandsabhängige Texte (z.B. "Verschlossen — Schlüssel fehlt").
func get_prompt() -> String:
	return prompt_text


## Von Unterklassen überschrieben: die eigentliche Wirkung der Interaktion.
func _perform_interaction(_interactor: Node3D) -> void:
	pass


## Von Unterklassen überschrieben: visuellen/physischen Zustand herstellen,
## den ein bereits verbrauchtes Objekt beim Laden eines Speicherstands haben
## muss (Kiste offen, Tür offen und ohne Kollision, ...).
func _restore_consumed_state() -> void:
	pass
