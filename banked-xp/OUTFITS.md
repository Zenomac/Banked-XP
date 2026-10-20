# Skilling outfit XP — 0.77

The new Include worn outfit XP bonuses setting is on by default. Switch it off to retain base-only display. Outfits do not alter level requirements, available supplies, craftable quantity, or the underlying base-XP recipe cache.

## Supported outfits

| Skill | Regular XP set | Full bonus |
|---|---|---:|
| Herblore | Botanist's outfit | 6% |
| Smithing | Blacksmith's outfit | 6% |
| Crafting | Artisan's outfit | 6% |
| Fletching | Fletcher's outfit | 6% |
| Archaeology | Archaeologist's outfit | 6% |
| Farming | Farmer's outfit | 6% |
| Firemaking | Ring of fire + Flame gloves | 5% |
| Cooking | Sous chef's outfit | 6% |
| Prayer | First age outfit | 6% |
| Construction | Constructor's outfit | 6% |

Regular five-piece sets give 1% per piece and another 1% for the full set. Firemaking's items give 2% individually and another 1% together. Modified headpieces count as the corresponding regular piece, without counting twice. Cooking gauntlets can replace the sous chef's mitts when ownership of the mitts is confirmed.

Supported elite inheritance: master archaeologist; master, animal, crop and tree farmer; full master constructor with confirmed regular constructor ownership. The master archaeologist's full set has a documented intrinsic 1% even without confirmed regular pieces; the display uses that minimum and labels unconfirmed additional inheritance. It never assumes the full 6% from merely owning an elite outfit.

## What ownership means

Only physical items observed in the normal bank, backpack or real equipment container are treated as confirmed ownership. The plugin remembers those observations for this session and clears them on game-state/session changes. Equipment is refreshed outside Draw, on inventory notifications or at most every 25 client logic ticks (about half a second). Cosmetics do not count as equipped items.

There is no verified outfit-unlock variable map in this build. Ownership stored only with Diango, in the costume room or in another unscanned store remains unknown. An unknown unlock is not equivalent to not unlocked: inherited XP is conservatively excluded and labeled. Reclaim the underlying regular outfit into the backpack once to supply evidence. Revisit the bank after reload to refresh bank ownership observations.

Wearing a standard set directly confirms those pieces and applies the appropriate bonus. Owning an unworn standard outfit shows an available-outfit note, without increasing the total. The plugin does not automatically equip items or choose outfits the player is not wearing.

## Display and calculation

The item hover heading is marked with outfit when adjusted. Base total and base unit XP stay visible. Skill summaries apply the current per-skill outfit percentage once to their preserved base totals; equipment changes therefore do not compound adjustments. These are estimates; game rounding per action may differ slightly.

Only the documented XP percentage is modeled. Factory outfit effects on unfinished potions, seed/bone/material saving, extra doses, random production, modified headpiece resource perks, silverhawk substitutions, brawling gloves, DXP, stored bonus XP, avatar/aura/pulse-core effects and activity-specific XP exclusions are not added by this module.

## Validation

23 local suites pass. Outfit tests cover all ten skills, partial/full sets, Firemaking's special percentages, modified headpieces, cooking-gauntlet substitution, elite inheritance with/without ownership evidence, equipment removal, setting persistence, session reset, unchanged base values and absence of inventory scans during drawing. Hover and skill-summary integration verify clear labeling and no repeated bonus application. Live game ownership flags and actual XP outcomes still require client confirmation.

0.78: Only the active +N% token is colored: red at zero, orange below the full set, green at the full 6% (5% Firemaking). An owned but unworn outfit shows red +0% and a separate uncolored available percentage.

0.79: Removed the separate available outfit bonus line; the colored active percentage remains.

0.80: Outfit parentheses show the number of missing detected pieces: (N not owned), or (N not worn) when the complete regular set is confirmed owned. Fully worn sets show (0 not worn). Ownership refers to observed pieces; Diango-only unlock evidence remains unconfirmed.
