# Archaeology — v0.97

Audited all 231 restoration rows on https://runescape.wiki/w/Artefacts on 20 October 2026 against shipped XP, levels and required inputs. Added Teleportation crystal (damaged); corrected the Ninbaradari mural requirement from level 88 to 82. Existing Spear of Annihilation component routes are retained. No excavation XP or repaired-artefact repeat restoration XP is added.

Damaged artefacts show potential base XP even when bank restoration materials are insufficient. Craftable XP stays limited by banked supplies and uses zero when nothing can be restored. Level visibility settings still apply; a preview does not add unavailable recipes to the right-click menu. The tooltip states that materials stored in Archaeology material storage are not scanned. Recipe ingredients follow the existing hover toggle.

Both outfits are supported. Archaeologist pieces grant 1% each and 6% for the complete set. Master archaeologist pieces inherit confirmed corresponding regular-piece bonuses; its complete set has the documented minimum 1% when regular ownership is unconfirmed. The full master outfit restores an artefact in 4.8 seconds rather than 6 seconds. This is a duration note, not an XP multiplier or an XP/hour prediction. Diango-only ownership remains unconfirmed; reclaim regular pieces into the backpack to establish evidence for the current session.

Sources:
- https://runescape.wiki/w/Archaeologist%27s_outfit
- https://runescape.wiki/w/Master_archaeologist%27s_outfit
- https://runescape.wiki/w/Artefacts

Validation: 25 existing local suites pass, plus a focused Archaeology suite covering zero-material previews, complete supply batches, potential/base XP separation, both full outfits, elite ownership evidence, restoration time and teleportation crystal lookup. Source audit validates all 231 rows. Live client behavior still needs confirmation.
