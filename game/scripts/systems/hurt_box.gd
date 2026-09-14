class_name HurtBox
extends Area3D
## Verwundbare Zone. Gehört an jedes Ding, das Schaden nehmen kann.
##
## Vertrag (nicht ändern, Player und Gegner hängen beide daran):
##   - Die HurtBox entscheidet NICHT über Schadensfolgen. Sie meldet den
##     Treffer per `hit_received` an ihren Besitzer.
##   - I-Frames, Tod, Knockback und Animation sind Sache des Besitzers.
##   - `receive_hit` ist die einzige öffentliche Eintrittstür. HitBox ruft sie.
##
## Layer-Konvention (siehe project.godot [layer_names]):
##   Player-HurtBox  -> collision_layer = 2  (player)
##   Gegner-HurtBox  -> collision_layer = 4  (enemy)

## Wird bei jedem angenommenen Treffer ausgelöst.
## `from_position` erlaubt dem Besitzer, Knockback-Richtung zu bestimmen.
signal hit_received(damage_quarters: int, from_position: Vector3)

## Wenn false, ignoriert die HurtBox alle Treffer. Der Besitzer schaltet das
## während I-Frames oder im Todeszustand um.
@export var vulnerable: bool = true


func _ready() -> void:
	# Eine HurtBox sucht nicht selbst, sie wird gefunden.
	monitoring = false
	monitorable = true


## Von HitBox aufgerufen. Gibt true zurück, wenn der Treffer angenommen wurde;
## damit kann die HitBox zwischen "getroffen" und "ignoriert" unterscheiden.
func receive_hit(damage_quarters: int, from_position: Vector3) -> bool:
	if not vulnerable or damage_quarters <= 0:
		return false
	hit_received.emit(damage_quarters, from_position)
	return true


func set_vulnerable(value: bool) -> void:
	vulnerable = value
