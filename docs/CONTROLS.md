# CONTROLS — Alexle Realm

Stand: 2026-09-15  
Quelle: game/project.godot, Abschnitt [input]. Diese Datei ist abgeleitet, nicht gesetzt —
bei Änderungen an der Input-Map muss sie neu erzeugt werden.

## Tastatur und Maus

| Aktion | Taste | Action-Name |
|--------|-------|-------------|
| Vorwärts gehen | W | `move_forward` |
| Zurück gehen | S | `move_back` |
| Nach links gehen | A | `move_left` |
| Nach rechts gehen | D | `move_right` |
| Sprinten | Shift | `sprint` |
| Springen | Leertaste | `jump` |
| Interagieren | E | `interact` |
| Angreifen | Linke Maustaste | `attack` |
| Blocken | Rechte Maustaste | `block` |
| Item benutzen | F | `use_item` |
| Ziel aufschalten | Q | `lock_on` |
| Pause | Escape | `pause` |
| Karte | M | `toggle_map` |

## Gamepad

| Aktion | Xbox-Taste | Action-Name |
|--------|-----------|-------------|
| Vorwärts gehen | Linker Stick oben | `move_forward` |
| Zurück gehen | Linker Stick unten | `move_back` |
| Nach links gehen | Linker Stick links | `move_left` |
| Nach rechts gehen | Linker Stick rechts | `move_right` |
| Sprinten | Linker Stick gedrückt | `sprint` |
| Springen | A | `jump` |
| Interagieren | B | `interact` |
| Angreifen | X | `attack` |
| Blocken | RB | `block` |
| Item benutzen | Y | `use_item` |
| Ziel aufschalten | LB | `lock_on` |
| Pause | Start/Menu | `pause` |
| Karte | Back/View | `toggle_map` |

## Kamera

Die Kamera wird mit der Maus gesteuert — bewege die Maus, um die Blickrichtung zu ändern. Am Gamepad wird der rechte Stick zur Kamerakontrolle verwendet. Die Maus-Sensitivität kann im Optionsmenü angepasst werden.

## Vollständige Action-Liste

| Action-Name | Deadzone | Gebundene Events |
|------------|----------|-----------------|
| `move_forward` | 0.2 | 2 |
| `move_back` | 0.2 | 2 |
| `move_left` | 0.2 | 2 |
| `move_right` | 0.2 | 2 |
| `sprint` | 0.5 | 2 |
| `jump` | 0.5 | 2 |
| `interact` | 0.5 | 2 |
| `attack` | 0.5 | 2 |
| `block` | 0.5 | 2 |
| `use_item` | 0.5 | 2 |
| `lock_on` | 0.5 | 2 |
| `pause` | 0.5 | 2 |
| `toggle_map` | 0.5 | 2 |

## Nicht belegt

Alle definierten Actions haben mindestens ein Event.
