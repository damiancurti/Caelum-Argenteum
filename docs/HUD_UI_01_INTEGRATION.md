# HUD/UI-01 — integration contract

## Purpose

HUD/UI-01 is the shared visual skin for the permanent gameplay HUD and the
Journal. It replaces inherited Doom presentation without creating a second
inventory, statistic or world-state model.

The runtime pack contains 94 independent PNGs:

| Family | Count | Runtime path |
|---|---:|---|
| HUD components | 17 | `graphics/caelum/ui/hud/components` |
| HUD icons | 27 | `graphics/caelum/ui/hud/icons` |
| Journal components | 14 | `graphics/caelum/ui/journal/components` |
| Journal icons | 36 | `graphics/caelum/ui/journal/icons` |

Mockups and layered masters remain art sources and are not loaded by the PK3.
See `ASSET_REGISTER.md` for authorship and license tracking.

## Corrected in 4.29.0l

- HUD-01 frame centers render before the live colored rectangles. Each fill is
  inset to 164 MU, so it remains visible without covering either metal cap.
- Health again exposes its red--gold--green progression; Anima, Adrenaline,
  Lucidity, Air, Load and survival resources retain their authored hues.
- `CaelumText` word spacing increases from six to eight pixels in the Journal
  and secondary menus. Glyph kerning and the compact `CaelumMono` HUD remain
  unchanged.

The colored resource fills were manually accepted during V4.29.0m testing.

## Implemented in 4.29.0x

- Crafts reads the persistent 61-recipe book and reports known totals for the
  16 physical, 16 armor, 20 essence-weapon, 4 amulet and 5 seal recipes.
- The station interface filters that same catalogue; it does not own or copy a
  second recipe list.
- Unknown recipes hide their details and are rejected by play-scope authority.
- Crafts remains read-only in the Journal. Creating an item still requires Use
  on a valid connected station.

## Implemented in 4.29.0y

- Crafts now reports the four appended shield recipes and the unified 65-recipe
  total without changing any earlier recipe index.
- New profiles begin at 0/65; migrated 4.29.0x profiles preserve their exact
  knowledge flags and begin with the four shield entries unknown.

## Implemented in 4.29.0i

- `CaelumStatusBar` replaces the Doom status bar with an empty project-owned
  `BaseStatusBar`. No portrait or face slot exists.
- `CaelumHUDOverlay` continues to read authoritative player state and applies
  HUD-01 frames and nine resource icons to the existing live bars.
- Tab opens `CaelumJournalOverlay`; M opens the native automap.
- The six permanent sections are Inventory, Character, World, Crafts, Quests
  and Reputation.
- Inventory is currently read-only and shows real active weapon/load values.
- Character shows the existing twelve primary attributes.
- Later sections expose their final navigation positions but clearly state
  that their authoritative systems do not exist yet.
- Page, open/closed state and navigation are client-local. No UI navigation
  event touches play state or scans actors in the map.

## Authoritative-state rule

The UI may cache a presentation index after a revision changes, but it may not
own item quantity, equipment, recipes, quest state, reputation, date, time or
weather. Real actions will use validated network events owned by the acting
player. Opening a page or moving its cursor remains local.

## Next interface increments

1. Build a revision-driven visible-row inventory index and equipment slots.
2. Route Use, Equip, Drop and Magic Box actions through existing authoritative
   inventory/equipment events.
3. Add recipe selection/details to Crafts after the owned-item interaction
   pattern is validated, still without duplicating the Workbench transaction.
4. Add Repair/Disassembly, then Quests/Reputation, only when their data models
   become authoritative.
5. Add date, time, weather and a layered map to World with their scheduled
   world systems.
6. Validate keyboard, mouse and controller navigation at 4:3, 16:9 and
   ultrawide resolutions before calling the interface visually final.

## Manual acceptance for 4.29.0l

- No Doom face, Doom arms counter or Doom ammunition panel is visible.
- The nine live resource bars retain correct numeric values, visible resource
  colors and uncropped frames/icons at 4:3 or 16:9.
- Journal word boundaries are visibly clearer without loosening letter pairs
  or changing HUD counter alignment.
- Tab opens and closes the Journal; Escape closes it; arrow keys change all six
  sections; M still toggles the automap when the Journal is closed.
- Inventory and Character values match the debug interface.
- World, Crafts, Quests and Reputation never display invented values.
- Console, pause and save/load menus remain accessible while the Journal is
  closed.
