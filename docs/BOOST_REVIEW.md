# Temporary skill boost review — 2026-10-20 UTC

All 29 skill pages, Temporary skill boost, Advanced pulse core and the dedicated extreme-potion pages were retrieved. The table distinguishes practical portable level boosts from conditional, invisible, point-restoring and area-only effects. A single maximum would be misleading across those different actions.

| Skill | Strong portable source | Level increase | Pulse-core published maximum (non-Ironman) |
| --- | --- | --- | --- |
| Agility | Stamina potion / spicy stew | +6 | 7 |
| Archaeology | Archaeology potion | +3 | 8 |
| Attack | Elder overload potion | 5 + floor(0.17 * base level) | 7 |
| Constitution | Constitution cape | +1 | 7 |
| Construction | Spicy stew + Prifddinas crystal saw + sculpting chisel | up to +12 combined | 7 |
| Cooking | Extreme cooking potion | XP-scaled, up to +17 | 7 |
| Crafting | Orange spicy stew | up to +6 | 7 |
| Defence | Elder overload potion | 5 + floor(0.17 * base level) | 7 |
| Divination | Extreme divination | XP-scaled, up to +17 | 11 |
| Dungeoneering | Dungeoneering cape | +1 | 8 |
| Farming | Brown spicy stew | up to +6 | 8 |
| Firemaking | Orange spicy stew | up to +6 | 8 |
| Fishing | Brown spicy stew | up to +6 | 11 |
| Fletching | Orange spicy stew | up to +6 | 8 |
| Herblore | Brown spicy stew | up to +6 | 8 |
| Hunter | Extreme hunter | XP-scaled, up to +17 | 7 |
| Invention | Extreme invention | XP-scaled, up to +17 | None |
| Magic | Elder overload potion | 5 + floor(0.17 * base level) | 7 |
| Mining | Brown spicy stew | up to +6 | 12 |
| Necromancy | Elder overload potion | 5 + floor(0.17 * base level) | 8 |
| Prayer | Wendlewick ale (m) | 3 + floor(0.01 * base level) | 7 |
| Ranged | Elder overload potion | 5 + floor(0.17 * base level) | 7 |
| Runecrafting | Extreme runecrafting | 3 + floor(0.15 * base level) | 7 |
| Slayer | Wilder pie | +6 | 8 |
| Smithing | Orange spicy stew | up to +6 | 8 |
| Strength | Elder overload potion | 5 + floor(0.17 * base level) | 7 |
| Summoning | Musaberry | +2 | 7 |
| Thieving | Yellow spicy stew | up to +6 | 7 |
| Woodcutting | Brown spicy stew | up to +6 | 12 |

The skill-specific conditions and exact source URLs are in data/boost-review.csv and data/boost-review.json. Pulse-core maxima above come from the dedicated Advanced pulse core page; older skill pages disagree with some maxima. Its scaling with current skill level is not fully specified there, so the plugin does not invent a scaling formula or promise that every player receives the published maximum. Ironmen cannot receive pulse-core level buffs. Already active, visible boosts are read from the client gameplay level as before.

## What this build calculates

Banked XP currently has recipe-level gating for Herblore only. The new boost preview uses the peak +6 brown spicy stew assumption, which is compatible with Ironman accounts. It is a conditional planning estimate: Evil Dave quest progression, boost supplies, random roll, duration, membership and per-recipe quest unlocks are not verified. Each preview says which boost is needed. Toggle off by default. It can reveal boostable recipes beyond the previous 1-2-level preview window, without changing that separate setting.

The boost ceiling is base level +6, never already-boosted current level +6. Stronger boosts currently active in the client are respected for ordinary recipes. All six master cape variants and all 11 improved material-saving variants use real levels. A boosted 120 never grants a master cape perk. Base XP and ingredient quantities are unchanged; no XP multiplier is introduced. Existing bank supply filtering still applies.

The all-skill review prepares future recipe support; it does not add crafting systems for the other 28 skills or apply invisible/area-only effects to ordinary bank recipes. Prayer XP methods and Maple Firemaking estimates are unchanged. No network access or 29-skill scan occurs while hovering.

Sources: https://runescape.wiki/w/Temporary_skill_boost ; https://runescape.wiki/w/Advanced_pulse_core ; https://runescape.wiki/w/Spicy_stew ; https://runescape.wiki/w/Herblore ; https://runescape.wiki/w/Extreme_cooking_potion ; https://runescape.wiki/w/Extreme_hunter ; https://runescape.wiki/w/Extreme_divination ; https://runescape.wiki/w/Extreme_invention ; each named skill page.
