class_name HitBox
extends Area3D
## Aktives Angriffsfenster. Gehört an Schwert, Gegnerklaue, Boss-Attacke.
##
## Vertrag (nicht ändern, Player und Gegner hängen beide daran):
##   - Ist im Ruhezustand komplett aus (monitoring = false). Ein Angriff
##     öffnet das Fenster per `activate()`.
##   - Trifft jede HurtBox pro Aktivierung höchstens EINMAL. Das verhindert,
##     dass ein Schwung mit mehreren Physik-Frames mehrfach Schaden macht.
##   - Kennt nur HurtBox, nicht deren Besitzer.
##
## Layer-Konvention (siehe project.godot [layer_names]):
##   Player-HitBox  -> collision_layer = 16 (player_hitbox), mask = 4  (enemy)
##   Gegner-HitBox  -> collision_layer = 32 (enemy_hitbox),  mask = 2  (player)

## Gemeldet, wenn ein Treffer tatsächlich angenommen wurde.
signal hit_confirmed(target: HurtBox, damage_quarters: int)

## Schaden in Viertelherzen. 2 = ein halbes Herz.
@export var damage_quarters: int = 2
## Länge des Angriffsfensters in Sekunden, wenn `activate()` ohne Wert kommt.
@export var active_duration: float = 0.18

var _active: bool = false
var _already_hit: Array[HurtBox] = []
var _timer: float = 0.0


func _ready() -> void:
	monitoring = false
	monitorable = false
	area_entered.connect(_on_area_entered)
	set_physics_process(false)


func is_active() -> bool:
	return _active


## Öffnet das Angriffsfenster. `duration <= 0` nutzt `active_duration`.
## Trifft bereits überlappende HurtBoxen sofort mit, sonst würde ein Gegner,
## der schon in Reichweite steht, den ersten Schlag nicht abbekommen.
func activate(duration: float = -1.0) -> void:
	_already_hit.clear()
	_active = true
	_timer = active_duration if duration <= 0.0 else duration
	monitoring = true
	set_physics_process(true)
	# Godot liefert area_entered nur bei NEUER Überlappung. Deshalb hier
	# einmal manuell durchgehen, was bereits drinsteht.
	for area: Area3D in get_overlapping_areas():
		_try_hit(area)


func deactivate() -> void:
	_active = false
	_timer = 0.0
	monitoring = false
	set_physics_process(false)
	_already_hit.clear()


func _physics_process(delta: float) -> void:
	if not _active:
		return
	_timer -= delta
	if _timer <= 0.0:
		deactivate()


func _on_area_entered(area: Area3D) -> void:
	_try_hit(area)


func _try_hit(area: Area3D) -> void:
	if not _active:
		return
	var hurt: HurtBox = area as HurtBox
	if hurt == null or _already_hit.has(hurt):
		return
	_already_hit.append(hurt)
	if hurt.receive_hit(damage_quarters, global_position):
		hit_confirmed.emit(hurt, damage_quarters)
