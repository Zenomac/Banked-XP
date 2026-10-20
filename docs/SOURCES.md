# Sources and data scope

Checked 2026-10-20 UTC.

Primary catalog: https://runescape.wiki/w/Potions

Each of its 230 distinct linked potion pages was fetched and its Herblore creation tables parsed. The authoritative inputs, output quantities, XP, level and other requirements come from those linked creation tables, rather than inferring quantities from the overview. Each record retains its exact source URL in `wiki_recipes.lua` and `data/creation-records.json`. `data/coverage.csv` lists every page and active route count. Unfinished preparation inputs are separately recorded in `data/preparation-records.json`.

303 creation tables were collected. Forty Dungeoneering tables are audit-only because their items are not normal bank supplies. Overload's cumulative from-scratch table is audit-only to avoid crediting already-earned XP. Eleven identical speed-only alternatives are merged. The resulting active catalog has 251 distinct routes for 190 bankable potion entries. Alternative materials, improved recipes and conditional master-cape batch yields remain separate.

Examples of corrected values from linked creation tables: Extended super antifire, perfect juju variants, juju blessings and alternative elder overload salve recipes. No values are copied from the superseded selected-recipe tables.

Herb cleaning: https://runescape.wiki/w/Herb and https://runescape.wiki/w/Herblore_training . Existing cleaning records include standard, Habitat, quest and Daemonheim herbs. Daemonheim cleaning names do not create bank potion routes.

Prayer and Maple methods: https://runescape.wiki/w/Bonfire ; https://runescape.wiki/w/Altar ; https://runescape.wiki/w/Gilded_altar ; https://runescape.wiki/w/Ectofuntus .

Client API documentation:
- https://developer.runescape.com/rs/game/config/objtype.html
- https://developer.runescape.com/rs/game/inventory.html
- https://developer.runescape.com/rs/game/minimenu.html
- https://developer.runescape.com/rs/core/persistentdb.html
- https://developer.runescape.com/rs/game/config/fonttype.html
- https://developer.runescape.com/rs/ui/common_types.html

Client recipe XP scaling is accepted only after method/output/quantity calibration against known data. Do not infer Archaeology XP from restoration DBRow column 3: it is a sprite field.

RuneScape Wiki contributors are credited for the recipe data and source pages. No article prose or images are bundled; the included records contain factual recipe fields and source links.

Settings API: https://developer.runescape.com/rs/core/events.html ; https://developer.runescape.com/rs/ui/interactive_components/check.html ; https://developer.runescape.com/rs/ui/stylesheets.html .

Temporary boosts checked 2026-10-20: see BOOST_REVIEW.md and data/boost-review.csv for all 29 skill URLs and limitations. Herblore master cape and improved recipes use real levels; the Herblore wiki explicitly disallows improved-recipe benefits via boosts.

0.51 skill tooltip integration: player-supplied component registry (STATS__TOOLTIP 20971536, STATS__FRAME_LAYER 20971537); official API component, component collection, interface and events documentation at https://developer.runescape.com/rs/ui/interface.html , https://developer.runescape.com/rs/ui/component_collection.html , https://developer.runescape.com/rs/core/events.html . No new skill XP catalog claimed.

Menu coloring/order review: https://developer.runescape.com/rs/game/config/objtype.html (no display-name color property), https://developer.runescape.com/rs/game/minimenu.html (subjectText, reversed API priority, Add and Swap). Runtime native menu formatting takes precedence over yellow fallback.

Primal additions: https://runescape.wiki/w/Template:Primal_extract/creation ; https://runescape.wiki/w/Primal_fruit_pulp ; indexed wiki recipe module https://runescape.wiki/w/Module:Sandbox/User:Spondy/spondyAu and fruit yield table https://runescape.wiki/w/User:Cyberslas/Sandbox. Checked 2026-10-20.

## Multi-skill expansion, reviewed 2026-10-20

- https://runescape.wiki/w/Module:Skill_calc/Smithing/data
- https://runescape.wiki/w/Module:Skill_calc/Crafting/data
- https://runescape.wiki/w/Module:Skill_calc/Fletching/data
- https://runescape.wiki/w/Module:Skill_calc/Archaeology/data
- https://runescape.wiki/w/Module:Skill_calc/Farming/data
- https://runescape.wiki/w/Module:Skill_calc/Firemaking/data
- https://runescape.wiki/w/Module:Skill_calc/Cooking/data
- https://runescape.wiki/w/Module:Skill_calc/Prayer/data
- https://runescape.wiki/w/Module:Skill_calc/Construction/data
- https://runescape.wiki/w/Seeds — planting and check-health values, excluding variable harvest XP.

The full source modules were reviewed and factual recipe records extracted. No claim is made to have reviewed all documentation or every linked item page on the Wiki. See COVERAGE.md for exclusions and model assumptions.

## Outfit review, 2026-10-20

- https://runescape.wiki/w/Botanist's_outfit
- https://runescape.wiki/w/Blacksmith's_outfit
- https://runescape.wiki/w/Artisan's_outfit
- https://runescape.wiki/w/Fletcher's_outfit
- https://runescape.wiki/w/Archaeologist's_outfit
- https://runescape.wiki/w/Farmer's_outfit
- https://runescape.wiki/w/Fired_up_set
- https://runescape.wiki/w/Sous_chef's_outfit
- https://runescape.wiki/w/First_age_outfit
- https://runescape.wiki/w/Constructor's_outfit
- https://runescape.wiki/w/Master_archaeologist's_outfit
- https://runescape.wiki/w/Master_farmer_outfit
- https://runescape.wiki/w/Master_constructor's_outfit
- https://developer.runescape.com/rs/game/inventory.html
- https://developer.runescape.com/rs/core/events.html
- https://developer.runescape.com/rs/game/config/vartype.html — only transmitted variables are available; no verified per-outfit unlock mapping is assumed.

Skilling hand equipment sources and calculation limits: see HAND_EQUIPMENT.md.

Startup notice API: https://developer.runescape.com/rs/game/chat.html ; https://developer.runescape.com/rs/game/player.html ; https://developer.runescape.com/rs/core/events.html

Archaeology restoration and outfit audit: see ARCHAEOLOGY.md.

Digsite/hotspot coverage and sources: see DIGSITE_AUDIT.md and both archaeology audit CSVs.

## v0.121 coverage audit

See [coverage](COVERAGE.md) and [retrieval manifest](audits/sources-0.121.json) for the 20 October 2026 Wiki review. Extracted factual recipe records and source URLs are in [the additions file](audits/additions-0.121.json); no Wiki implementation code is bundled.
