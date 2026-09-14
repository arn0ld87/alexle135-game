extends Node
## Globaler Signal-Bus (Autoload "EventBus").
##
## Zweck: Systeme entkoppeln. UI hört auf Signale, statt den Player zu kennen.
## Regel: Hier stehen NUR Signal-Deklarationen und keine Logik. Wer Logik
## braucht, gehört nach GameState oder in das jeweilige System.
##
## Namenskonvention: <subjekt>_<vergangenheitsform>.

# --- Lebensenergie und Tod -------------------------------------------------
## Aktuelle und maximale Gesundheit in Viertelherzen.
signal health_changed(current_quarters: int, max_quarters: int)
signal player_damaged(amount_quarters: int)
signal player_died
signal player_respawned

# --- Währung, Items, Inventar ---------------------------------------------
signal packets_changed(total: int)
signal item_acquired(item_id: String, count: int)
signal item_equipped(item_id: String)
signal inventory_changed

# --- Weltzustand -----------------------------------------------------------
## Persistente Weltflags (Kiste geöffnet, Tür entriegelt, Boss besiegt ...).
signal flag_changed(flag_id: String, value: bool)
signal checkpoint_reached(checkpoint_id: String)

# --- Interaktion und Dialog ------------------------------------------------
## Der Player betritt/verlässt die Reichweite eines Interactable.
signal interaction_available(prompt_text: String)
signal interaction_unavailable
## Dialog anfordern. `lines` sind fertige Anzeigezeilen.
signal dialogue_requested(speaker: String, lines: PackedStringArray)
signal dialogue_advanced(line_index: int)
signal dialogue_finished

# --- Quests ----------------------------------------------------------------
signal quest_started(quest_id: String)
signal quest_step_changed(quest_id: String, step: int)
signal quest_completed(quest_id: String)

# --- Kampf -----------------------------------------------------------------
signal enemy_died(enemy_id: String)
signal hit_landed(target: Node3D, damage_quarters: int)

# --- Persistenz und Ablauf -------------------------------------------------
signal game_saved(slot: int)
signal game_loaded(slot: int)
signal toast_requested(message: String)
