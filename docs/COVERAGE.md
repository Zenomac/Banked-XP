# Coverage audit — v0.121

Reviewed on 20 October 2026. This audit covers all ten supported skills, using nine skill-calculator data sets, the Potions/Herb/Seeds/Artefacts indexes, skill overview tables and targeted item creation pages. The nine calculator data sets contained no new rows relative to the earlier import; item pages exposed omissions in those calculators. The Potions index still lists the same 230 linked potion pages.

Added **552 recipe/tier records**, including **159 previously unindexed ingredient names** in the multi-skill catalog. Removed **12 Cooking urn records** that incorrectly treated later urn rewards as immediate recipe XP. There are now **3,676 multi-skill catalog records**, plus the existing **262 potion/primal-process records**, herb cleaning and 30 Prayer base entries. Recipe counts include alternatives and level tiers; they are not counts of unique items.

| Skill | Catalog records | Added | Coverage notes |
|---|---:|---:|---|
| Herblore | 24 | 24 | 24 protean shake tiers, plus 262 existing potion/primal routes and herb cleaning. |
| Smithing | 920 | 90 | Smelting, equipment, upgrades, burial and processing; adds Primal routes, platinum and protean bars. |
| Crafting | 778 | 211 | Gems, jewellery, armour, pottery and equipment; adds protean hides, Cryptbloom and other creation-table omissions. |
| Fletching | 493 | 53 | Bows, bolts, arrows, crossbows and other equipment; adds protean logs, scrimshaws and special equipment. |
| Archaeology | 234 | 0 | 234 damaged-artefact restoration recipes; repaired artefacts do not count as damaged supplies. |
| Farming | 119 | 0 | 119 planting/check-health seed and sapling routes; no assumed repeat harvest yield. |
| Firemaking | 78 | 59 | Logs, incense and pyre-log preparation, and verified protean line/bonfire tiers. |
| Cooking | 306 | 39 | Cooking/preparation, brewing and protean proteins; assumes successful cooking. |
| Prayer | 7 | 7 | 7 incense routes plus 30 existing bury/scatter entries and API discovery. |
| Construction | 717 | 69 | Furniture and Fort processing/building; adds protean planks and concrete nail variants. |

## Accounting and runtime changes

- Protean menus select the current real-level tier. Temporary boosts cannot unlock a higher protean tier.
- Incense recipes retain both Firemaking and Prayer XP and enforce their other-skill requirement. A combined total consumes the supplies once and credits both skills.
- Legacy bury/scatter and log methods share the per-skill supply budget with recipes, preventing the same materials from being consumed twice.
- Pyre-log preparation includes sacred oil; returned containers do not add XP.
- Research and data extraction are offline development work. This release adds no runtime network requests and does not change native tooltip components.

## Explicit limits and remaining gaps

This is a source-based coverage audit, not proof that every RuneScape item or activity is represented. Some overview pages and calculators omit content, and many actions need state that is not available from bank item counts. In particular:

- Unknown protean Firemaking table cells are not interpolated. Unstable logs have sourced Fletching coverage; full unstable Firemaking scaling remains unmodeled. Normal protean bonfires are represented only at sourced tiers; line-burning tiers cover the earlier levels.
- Most non-Maple bonfire/group scaling, pyre cremation, Char/minigame activities and conditional or variable rewards remain unmodeled. Pyre-log *preparation* is supported.
- Urn filling/teleport rewards, special currency exchange, incomplete Smithing progress, variable crop yields, repeat harvesting and player-owned animal traits are not fixed bank recipes.
- Some existing calculator rows concern Dungeoneering or special locations. Ordinary bank supplies do not imply access to that activity. Quest, blueprint, port-scroll, station, membership and site unlocks are not universally detected.
- Construction nail alternatives require enough of one listed nail type; mixed nail stacks and broken-nail waste are not optimized.
- Recipe outputs are not recursively reinvested through every future skilling stage. Totals use a deterministic greedy allocation, not a proof of the global maximum.
- Metal-bank and Archaeology material-storage scans remain experimental. Stored supplies must be detected before Ready XP can include them. Archaeology potential XP can be shown separately.
- New recipe rows were verified against source tables and local mocks, not live crafting of every item.

## Evidence and validation

[Item-level dispositions](audits/coverage-0.121.csv), [new recipe records](audits/additions-0.121.json), and [source retrieval manifest](audits/sources-0.121.json) record the review. Original imported records remain in `banked-xp/data/skill-recipes.json`. Failed candidate URL guesses are retained in the source manifest; they are not treated as evidence that an item exists.

30 local Lua suites pass. Checks include all 3,676 catalog rows with exact/empty supplies and level boundaries, reachability of every new ingredient, Primal batch quantities, dual-skill XP, protean tier selection, cross-skill requirements, shared-stock totals, tooltip regression checks, caches and syntax. No live client validation was performed for v0.121.
