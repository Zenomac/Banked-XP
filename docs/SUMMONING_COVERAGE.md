# Summoning coverage — introduced in v0.157

The local catalog contains 105 routes: 94 distinct familiar pouches (praying mantis has six flower recipes and granite lobster has three granite recipes), one blank binding-contract recipe, and three finished-pouch scroll conversions. These records feed the existing ingredient planner, hover display, right-click recipes and eleven-skill summaries. No HTTP requests are made by this feature.

## Data sources

- [RuneHQ Summoning guide](https://www.runehq.com/skill/summoning): pouch names, levels, base infusion XP, charms, shard counts and tertiary ingredients. Retrieved 20 October 2026. Factual values were extracted; prose was not copied.
- [RuneHQ binding contract](https://www.runehq.com/item/binding-contract): 10 XP for an empty contract; pouch, blue charm, 200 shards, two Blood of Orcus and two Hellfire metal. Dagon Bye is required. The level 45 requirement is for the lowest familiar, not blank-contract manufacture.
- [Nightmare muspah pouch](https://runescape.fandom.com/wiki/Nightmare_muspah_pouch): 150 elder energy, rather than spirit shards; elder-charm pouches use this energy input.
- [Praying mantis pouch](https://runescape.fandom.com/wiki/Praying_mantis_pouch): flowers except black and white. Red, yellow, blue, purple, orange and mixed variants are included.
- [Summoning](https://runescape.fandom.com/wiki/Summoning): pouch creation uses the absolute skill level, not a temporary boost.
- [Iron ingot](https://secure.runescape.com/m=itemdb_rs/Iron+ingot/viewitem?obj=47072) and [Steel ingot](https://runescape.wiki/w/Steel_ingot): titan recipes consume ingots. Raw bars are not treated as ingots without preparation.
- [Marigolds](https://runescape.wiki/w/Marigolds): Bull ant tertiary. Limpwurt roots have no Summoning route in this catalog.

The live Wiki main table was blocked from retrieval. In v0.159 the user supplied a saved copy, allowing all 91 regular/elder pouch rows to be audited. This verifies the supplied snapshot, not every other Summoning action or subsequent Wiki revision.

## Calculation boundaries

- Base infusion XP and three verified scroll conversions only. No XP for using familiars, killing monsters to fill binding contracts, or recycling pouches into shards.
- Meerkat and ghast pouches are excluded from infusion because they are acquired rather than infused.
- Quest/mystery requirements are notes, not completion checks. Estimates assume those unlocks are satisfied.
- Granite lobster accepts 500g, 2kg and 5kg pieces as separate direct recipes. No automatic splitting is assumed. Iron/steel titan uses banked ingots; forging them is not chained automatically.
- No charm/shard-saving probabilities, Summoning cape effects, Amlodd bonuses, or Shaman outfit bonuses are added by this change.
- Ingredient and level settings still filter recipes. A skill can be listed as a dual use even if its ingredients or level requirements are currently missing. Selecting it does not bypass those settings or produce XP from missing supplies.
- Per-skill totals represent alternative uses of shared supplies. Combined total XP uses one shared budget. A saved item skill affects its hover/menu, not which skills the summary evaluates.

## Validation

Automated tests cover all imported recipes with full/empty supplies, selected skill persistence, actual ingredient shortages, elder-energy substitution, unboostable infusion levels, cross-skill summary candidates, and existing native hover regressions. Client rendering and item names still need in-game confirmation.

## v0.158 partial review of the requested Wiki page

Requested: https://runescape.wiki/w/Summoning_pouches on 20 October 2026. Direct retrieval was denied (robots/HTTP 403). Search-index excerpts and individual-item references were available, but not the complete current table. No claim of full current-page parity is made.

Confirmed additions:

| Input | Output | Base XP per consumed input | Source |
|---|---|---:|---|
| Granite (2kg) or granite (5kg), plus usual pouch/charm/shards | One granite lobster pouch | 325.6 | [Tip.It pouch entry](https://www.tip.it/runescape/items/view/7201-granite-lobster-pouch), [Wiki granite entry](https://runescape.fandom.com/wiki/Granite) |
| Spirit wolf pouch | Ten howl scrolls | 0.1 | [Wiki howl scroll](https://runescape.fandom.com/wiki/Howl_scroll) |
| Dreadfowl pouch | Ten dreadfowl strike scrolls | 0.1 | [Wiki dreadfowl strike scroll](https://runescape.fandom.com/wiki/Dreadfowl_strike_scroll) |
| Steel titan pouch | Ten steel of legends scrolls | 4.9 | [Wiki steel titan pouch](https://runescape.fandom.com/wiki/Steel_titan_pouch), [Wiki calculator module](https://runescape.wiki/w/Module:Sandbox/User:Hypermice/Module:Skill_calc/Summoning/data) |

Finished pouches are not credited with their original infusion XP. New infusion outputs are not automatically spent again on scrolls by the planner. Voice of Seren's additional scroll yield is not applied. Other scroll conversions remain unverified, especially entries whose pouch and scroll references disagree about creation versus activation XP. A saved HTML/PDF copy of the requested current page is needed to finish the page-wide comparison.

## v0.159 completed audit of supplied HTML

All 86 regular and five elder-charm rows match an exact-input recipe, including level and base creation XP. Multi-row tertiary cells were expanded: Ice titan needs both talismans, Wolpertinger both meats/bones, and Holy scarab all five whirligig shells. An independent factual fixture lives in `banked-xp/tests/data/summoning_wiki.lua`.

Changes: add Jackalope and Holy scarab; change Stranger plant's `Bagged plant 1` to `Bagged plant`; change Forge regent's `Ruby harvest` to `Ruby harvest jar`. Existing creation XP/level/charm/shard counts for the other matched pouch recipes agree with the supplied table.

Coverage decisions for the other tables:

- Two special pouches: Meerkats and Ghast are acquired, not infused from bank supplies; no infusion XP assigned.
- Sixty Dungeoneering pouch entries: dungeon-only materials are outside the ordinary bank planner; no bank XP assigned.
- Seven ancient familiar entries: the page explicitly requires killing the respective monster while carrying a contract. Do not count these kills as banked XP. Crafting blank binding contracts remains supported separately.
- Three pig pouches retained from prior sources; they are not in the supplied regular/elder tables. Existing flower/granite alternatives and scroll conversions are also retained with their separate sources, not claimed as validated by this page.

Uploaded snapshot SHA-256: `07f6993bc3f3690e5b1e243afc52ff153237e7247aa5e4375f5830b7ead5e6a0`.
