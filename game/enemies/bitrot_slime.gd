class_name BitrotSlime
extends Enemy
## Bitrot-Schleim — Brut des Chaos-Pakets. Der einfachste Auswuchs des
## korrupten Deploys: ein einfacher Nahkämpfer ohne Sonderfähigkeit.
## Erster von mindestens drei Gegnertypen des Auftrags; Typ zwei und drei
## kommen mit dem Mini-Boss in M2 (siehe enemy_base.gd für den Erweiterungspunkt).
##
## Werte (max_health, move_speed, Reichweiten, Timings, packets_reward) werden
## bewusst nicht hier im Code, sondern als Node-Properties in bitrot_slime.tscn
## gesetzt — das ist der übliche Godot-Weg, @export-Werte pro Szene zu tunen.
##
## Eigene Note: dezentes Wabbeln im Leerlauf, rein kosmetisch auf dem Visual-
## Knoten, ohne Einfluss auf Kollisionsform oder Zustandsautomatik.

const WOBBLE_AMPLITUDE: float = 0.04
const WOBBLE_SPEED: float = 2.6

@onready var _visual: Node3D = get_node_or_null("Visual")

var _wobble_time: float = 0.0


func _process(delta: float) -> void:
	if is_dead() or _visual == null:
		return
	_wobble_time += delta
	var wobble: float = 1.0 + sin(_wobble_time * WOBBLE_SPEED) * WOBBLE_AMPLITUDE
	_visual.scale = Vector3(wobble, wobble, wobble)
