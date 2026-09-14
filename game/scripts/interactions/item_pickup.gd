class_name ItemPickup
extends Interactable
## Aufsammelbarer Gegenstand: Schlüssel, Herz-Container oder Heiltrank.
##
## Bei `auto_pickup = false` (Standard) läuft alles über die normale
## Interactable-Tür (E-Taste, InteractRange). Bei `auto_pickup = true`
## erkennt das Objekt zusätzlich Berührung durch den Player und ruft dann
## dieselbe `interact()`-Eintrittstür selbst auf — es gibt also weiterhin nur
## einen Wirkungspfad.

@export var item_id: String = "key_generic"
@export var item_count: int = 1
## Wenn true, wird bei Berührung durch den Player ohne Tastendruck eingesammelt.
@export var auto_pickup: bool = false
@export var is_heart_container: bool = false
@export var heal_quarters: int = 0


func _ready() -> void:
	super._ready()
	if auto_pickup:
		# Muss selbst suchen können, um body_entered ohne Tastendruck zu bekommen.
		collision_mask = 2
		monitoring = true
		body_entered.connect(_on_body_entered)


func _perform_interaction(_interactor: Node3D) -> void:
	if is_heart_container:
		GameState.add_heart_container()
	else:
		GameState.add_item(item_id, item_count)
	if heal_quarters > 0:
		GameState.heal(heal_quarters)
	visible = false
	monitoring = false


func _restore_consumed_state() -> void:
	visible = false
	monitoring = false


func _on_body_entered(body: Node3D) -> void:
	if not auto_pickup or not body.is_in_group("player"):
		return
	interact(body)
