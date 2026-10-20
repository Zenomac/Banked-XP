# Coverage audit — 0.76

Reviewed sources: the RuneScape Wiki calculator data modules for Smithing, Crafting, Fletching, Archaeology, Farming, Firemaking, Cooking, Prayer and Construction, plus the Seeds tables. Existing Herblore sources remain documented in SOURCES.md. Factual recipe records were extracted; wiki Lua code is not bundled or executed by the plugin.

| Skill | Added routes | Scope |
|---|---:|---|
| Smithing | 830 | Smelting, equipment, upgrades, burial routes and miscellaneous material recipes represented in the calculator. Some rows model a complete path from bars rather than one upgrade. |
| Crafting | 567 | Gem cutting, armour, jewellery, battlestaves, pottery and miscellaneous calculator recipes. |
| Fletching | 440 | Bows, stringing, projectiles, intermediate steps and from-scratch calculator routes. |
| Archaeology | 232 | 232 restoration recipes: damaged artefact plus all listed materials. Repaired artefacts do not count as damaged inputs. |
| Farming | 119 | Seed planting and appropriate plant/check-health stages, including banked saplings. No assumed repeat harvest yield. |
| Firemaking | 19 | Standard fixed-XP burn actions for 19 log/root types. Existing Maple bonfire options retained. Other bonfire scaling is not yet modeled. |
| Cooking | 279 | Cooking and preparation recipes with explicit materials and positive fixed XP. Assumes success; not a burn-rate forecast. |
| Construction | 648 | Furniture, Fort processing and building recipes. Site, previous-tier and unlock conditions are not automatically checked. |

Herblore retains 262 routes, including the primal process. Prayer has 30 bundled base bury/scatter entries, plus client parameter discovery and the existing selectable methods. Herbs retain their existing cleaning provider.

## Audit decisions and remaining work

`data/multi-skill-audit.csv` records every considered calculator row and its import/exclusion reason. `data/skill-recipes.json` contains the imported factual inputs, XP, levels and source URL for every new route. These files supersede the older potion-only count reports for the overall plugin; the older reports remain valid for their original potion scope.

Excluded or unmodeled cases include urn-filling XP, special currencies, abstract inputs without a bank-item mapping, expected crop yields, animal growth/traits, repeat harvesting, Char/minigame actions, most non-Maple bonfire scaling, incomplete smithing progress and bank-inaccessible Dungeoneering activities. Some calculator records describe Dungeoneering or conditional methods; they cannot become craftable from the normal bank if their required inputs are unavailable, and the catalog does not assert that the activity permits ordinary bank access.

Separate resource stores are not scanned. All stated ingredients must appear in the normal bank snapshot. Current catalogue sources may lag new game content or naming changes. Imported numeric records were structurally audited and tested; this is not a claim that every linked item page, unlock or live game result was individually verified.

For Farming, the general calculator assumed some harvest quantities. Those records were superseded by Seeds planting/check-health data. Allotments use three seeds per patch; hops use four except jute uses three; bittercap mushroom patches use six spores. Herb estimates use one seed per planting action and exclude Plant Power yield assumptions. Protection payments, growth time and disease risk are not treated as consumable recipe inputs or guaranteed XP.

For Smithing, banked bar recipes and item-upgrade alternatives share the same supply budget. The metal bank is excluded. For Archaeology, materials and damaged artefacts are both mandatory; no restoration XP is attributed to merely owning a repaired artefact.

## Verification

22 local Lua suites pass. Every one of the 3,134 added routes was checked for valid skill/level/input data, zero-stock suppression, availability with direct supplies and the three-level boundary. Representative exact-XP tests cover sapphire cutting and Ork cleaver restoration. Integration covers positive selected totals for all ten skills and prevents shared logs from being allocated twice across skills. One local benchmark completed 100 cached Maple-log multi-skill option calculations in about 0.008 seconds; this is a local mock/API-free result, not a live game frame-rate guarantee.

## Outfit update, 0.77

Optional worn-outfit XP estimates now cover all ten skills. See OUTFITS.md for exact sets, inheritance and unlock-detection limits. Recipe base values and the earlier 3,396-route coverage remain unchanged.
