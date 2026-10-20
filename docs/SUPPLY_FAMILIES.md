# Battlestaves, arrowheads, frames and Ascension fragments — v0.122

Verified against RuneScape Wiki item creation tables on 20 October 2026. Replaced 64 catalog records with 75 direct and preparation routes; the multi-skill catalog now contains 3,687 records. This is a targeted correction to v0.121, not a claim of exhaustive game coverage.

- **Battlestaves:** elemental and Armadyl orb attachment, plus supported skeletal upgrades using a shade skull. A battlestaff alone cannot earn Crafting XP without its other ingredients.
- **Arrowheads:** current arrow creation requirements and XP, with headless-shaft and supported raw-shaft/feather routes. Assembly is counted per arrow, including stacks smaller than the table's usual 15-arrow batch. The current `Headless shaft` name and older `Headless arrow` name share one inventory key; `Arrow shaft` and `Shaft` do too. Dark arrows require level 70; elder rune arrows give 18.7 XP each.
- **Frames:** refined-plank-to-frame recipes and existing Fort building choices. Maple frames require three refined Maple planks. Building recipes require the listed frame count and stone wall segments; owning frames alone does not imply a complete build. Site, blueprint and quest access are still external requirements.
- **Ascension fragments:** fragment arrows from bronze arrows, fragment bolts from bronze bolts, and supported remaining preparation stages. Fragments remain distinct from Ascension shards. Direct conversion awards 0.5 Fletching XP per fragment; already-earned preparation XP is not counted again.

“Show options for ingredients not currently owned” still controls unavailable recipe choices. With it disabled, a tooltip can remain hidden when no complete recipe is available. This release does not override that setting or assume missing ingredients.

## Sources and checks

See [replacement records](audits/supply-families-0.122.json) for per-recipe source URLs. Main references include [Arrowheads](https://runescape.wiki/w/Arrowheads), [Headless shaft](https://runescape.wiki/w/Headless_shaft), [Maple frame](https://runescape.wiki/w/Maple_frame), [Fort Forinthry](https://runescape.wiki/w/Fort_Forinthry), [Fragment arrows](https://runescape.wiki/w/Fragment_arrows), and [Fragment bolts](https://runescape.wiki/w/Fragment_bolts).

All 31 local Lua suites pass, including current/legacy ingredient names, one-item and partial ammunition stacks, missing supplies, per-stage XP, all catalog rows and hover/menu policy reachability. No live client verification was performed. No runtime network requests or native tooltip changes were added.

## Specialist arrow tips — v0.123

Black stone, deathspore and splintering arrow tips now use verified per-arrow routes: 12.6, 20 and 20 Fletching XP respectively, at levels 92, 95 and 95. One tip and one elder headless shaft make one arrow. Partial stacks are supported. Elder shafts with regular, yellow, red, blue, stripy, orange or wimpy feathers can also be used, adding the remaining 1 XP of feathering per shaft. Existing headless shafts do not earn that preparation XP again.

The old Elder headless arrow name resolves to Elder headless shaft. Singular tip names resolve to their plural item names. Missing supplies still follow the existing visibility setting. Black stone arrow creation requires the recipe unlock, which is not detected automatically.

Sources: [Black stone arrows](https://runescape.wiki/w/Black_stone_arrows), [Deathspore arrows](https://runescape.wiki/w/Deathspore_arrows), [Splintering arrows](https://runescape.wiki/w/Splintering_arrows), [Elder headless shaft](https://runescape.wiki/w/Elder_headless_shaft). [Replacement records](audits/arrow-tips-0.123.json) retain source URLs and quantities. Seven older records were replaced with 31 direct/preparation routes; the multi-skill catalog contains 3,711 records. All 32 local Lua suites pass; live client verification remains outstanding.

## Arrow-tip hover visibility — v0.124

Black stone, deathspore and splintering arrow tips now retain an informational preview when availability filters leave no selectable recipe. The preview reports per-arrow XP and the recipe's supply/level information. Missing supplies do not add XP to skill totals, and unavailable choices remain hidden in the right-click menu. This is a scoped exception to hiding the entire hover when no recipe is available; other item families retain their existing behavior. All three tip-only bank cases are covered by local regression checks. Live-client confirmation is still required.

## Resonant anima — v0.128

Both tradeable and untradeable resonant anima of Bik, Ful, Wen and Jas are recognized. Standard imbuing requires level 95 Fletching and consumes one dinarrow plus three corresponding anima for 19 base XP. Jas creates Jas dragonbane arrows; conversion to demonbane arrows is a separate Magic process, outside this plugin's supported skills.

The variants remain separate ingredients and share the available dinarrow budget. Partial stacks are supported; leftover anima below three do not count as an arrow. Existing preparation routes from dinarrow materials remain available, with only remaining-stage XP included. Anima-only banks display an informational preview with missing ingredients while contributing zero ready XP.

These estimates assume **Wisdom of Anima is disabled**. That mode uses different costs and much lower XP and is not automatically detected. See the creation tables for [Bik](https://runescape.wiki/w/Bik_arrow), [Ful](https://runescape.wiki/w/Ful_arrow), [Wen](https://runescape.wiki/w/Wen_arrow), and [Jas dragonbane](https://runescape.wiki/w/Jas_dragonbane_arrow) arrows. [Audited records](audits/resonant-anima-0.128.json) document the 16 direct/preparation routes. All 33 local suites pass; live-client confirmation is pending.
