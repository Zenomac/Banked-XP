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
