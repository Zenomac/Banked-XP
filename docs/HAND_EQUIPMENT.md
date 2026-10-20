# Skilling hand equipment — v0.81

The new “Include skilling hand equipment” setting defaults on. Actual WORN equipment is observed using the existing equipment cache, outside tooltip Draw. Bank ownership, toolbelt membership and backpack possession do not imply an active tool. Removing a tool removes its effect after the equipment cache refresh. Outfit and tool settings are independent.

## Applied XP

All five sculpting chisel appearances provide +1% Construction XP when equipped. The bonus adds to the Constructor outfit: 1,000 base XP with a full 6% outfit and chisel becomes 1,070 XP. Base XP and craftable quantities remain visible and unchanged. Skill-level banked XP summaries include the same additive bonus.

## Recognized tools and explanatory hover notes

- Artificer's measure: conditional XP stacks and resource saving/duplication.
- Orthen furnace core: conditional Furnace Core XP buff.
- Balarak's sash brush and dragon/crystal/Imcando/Time and Space/Tony mattocks: excavation effects, not restoration XP.
- Crystal chisel: eligible extra gems; not a general Crafting XP multiplier.
- Crystal knife: extra shafts and strung-bow procs; proc XP excluded.
- Fenshell knife: resource saving; faster actions only for Fenmoor totems.
- Crystal hammer: double progress, not flat Smithing XP.
- Hammer-tron/enhanced hammer-tron and pyro-matic/enhanced pyro-matic: Invention tools, not flat skill XP.
- Crystal tinderbox: increased fire-spirit chances.
- Farmer's/combined Catalyst fragments: herb-patch benefits.

Augmented variants of recognized names are recognized; unknown augmentation perks and charge state are not assumed. Conditional effects are explained but excluded from totals: no verified live buff-stack mapping is available. Resource-saving loops, random extra outputs, excavation rates, fire-spirit rewards and Invention item XP are not forecast. Gathering-only equipment for skills outside the plugin's ten supported skills is outside this release's scope. No XP/hour estimates are introduced.

## Validation

24 local Lua suites pass, including all five chisel forms, additive stacking, unchanged base XP and quantities, unequipped tools, conditional effects, settings and existing tooltip regressions. These are mocked API tests, not in-client validation.

## Primary references

- https://runescape.wiki/w/Skilling_main_hands
- https://runescape.wiki/w/Skilling_off-hands
- https://runescape.wiki/w/Sculpting_chisel
- https://runescape.wiki/w/Artificer%27s_measure
- https://runescape.wiki/w/Orthen_furnace_core
- https://runescape.wiki/w/Balarak%27s_sash_brush
- https://runescape.wiki/w/Crystal_chisel
- https://runescape.wiki/w/Crystal_knife
- https://runescape.wiki/w/Fenshell_knife
- https://runescape.wiki/w/Crystal_hammer
- https://runescape.wiki/w/Crystal_tinderbox
- https://runescape.wiki/w/Farmer%27s_Catalyst_fragment

Reviewed 20 October 2026. Individual pages were used to resolve overview shorthand, especially conditional bonuses and affected methods.
