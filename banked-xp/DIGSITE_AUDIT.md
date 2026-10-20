# Digsite and excavation audit — v0.97

Reviewed the current Archaeology dig-site list, the combined excavation-hotspot table (110 rows, including duplicate plot variants and event/quest sites), and 113 linked digsite/hotspot pages. All fetches succeeded. The combined table contains 234 distinct item names: 229 non-event finds, including the soul beacon components, and five Harvest Hollow event finds. Source-table damaged artefact links were checked on each linked page. The nine principal sites are Kharid-et, Infernal Source, Everlight, Moonrise, Senntisten, Stormguard Citadel, Daemonheim, Warforge and Orthen. The overview also covers the Guild tutorial and quest/event plots outside these sites.

The existing restoration catalogue already contained all eight names in the supplied screenshots. Missing tooltips are therefore not proof of missing recipes. A native title with a newline or <br> could fail the exact item-name guard; the guard now ignores whitespace while continuing to verify the hovered item. Adjacent parentheses in folded-arm figurine names are normalized for recipe and bank-stock matching. Existing level and boost visibility preferences still apply: this release does not expose recipes above the configured level range.

Added the level-86 Soul beacon restoration: 9,333.3 base Archaeology XP, one Damaged soul beacon, 30 White marble, 30 White oak and 5 Greater ensouled bars. A damaged base plus a damaged core can supply the prerequisite beacon after the Tree of Balance combination step. These are consumed together; the component combination adds no XP. The quest-progress requirement is shown but not automatically verified. The five Mystery remains event finds (Soiled storybook, Polished horn, Dusty snow globe, Ruined letter and Strange coins) have no standard restoration entry and are explicitly excluded from restoration XP.

Audit files:
- data/archaeology-hotspot-audit.csv: each plot/item mapping and coverage/exclusion.
- data/archaeology-page-audit.csv: all 113 reviewed source pages.

Sources reviewed 20 October 2026:
- https://runescape.wiki/w/Archaeology_dig_sites
- https://runescape.wiki/w/Excavation_hotspots
- https://runescape.wiki/w/Artefacts
- https://runescape.wiki/w/Soul_beacon
- https://runescape.wiki/w/Damaged_soul_beacon_(base)
- https://runescape.wiki/w/Damaged_soul_beacon_(core)

Validation: all 26 local Lua suites pass, including all eight screenshot lookups and empty-material previews, paired beacon supplies/missing core, adjacent-parentheses matching, wrapped native headings and previous outfit/tooltip regressions. Every non-event item in the combined hotspot table maps to a restoration recipe or the beacon preparation. Client validation remains necessary; bank-only material visibility and Diango ownership limitations are unchanged.
