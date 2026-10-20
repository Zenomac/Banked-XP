v0.103: Add 4px between the final target Remainder row and the existing progress components, plus 4px additional padding at the bottom of the skill tooltip. Without a target, only the bottom padding applies, including when Archaeology Ready XP is the final row. Native frame and parent clipping height grow with the added space. All changes restore on exit. All 27 local suites pass, including explicit padding and restoration assertions. In-game appearance remains to be checked.

v0.103: Preserve native numeric caption/value rows in their existing vertical order, including Next level, Remainder and Bonus XP. Insert Banked XP (and optional Archaeology Ready XP) immediately before the first Target row; without a target append after the native XP rows. No native XP rows are intentionally omitted. Each numeric line starts with an explicit neutral colour tag, preventing unclosed Bonus XP green from leaking into later lines. Bonus XP remains green; unscanned-storage Banked XP stays red as requested. Neutral colour uses the original current-XP/heading tag when present, otherwise the existing native-style e3d7bf fallback. Existing progress siblings move below the expanded rows. No native children are created. All 27 local suites pass, including unclosed Bonus XP colour tags, extra native XP fields, both target kinds and restoration. In-game appearance still needs verification. This supersedes v0.101's omission of Next level and forced bonus order.

v0.103: Skill tooltips now use this order: heading, Current XP, Bonus XP (when present), next-level Remainder, Banked XP, optional Archaeology Ready XP, native Target Level/XP and target Remainder. Next level is omitted. Existing native target progress siblings are placed below the final text row. Native captions and values are consolidated into the existing Current XP caption/value pair; original text and geometry are restored before the next draw and on shutdown. No native children are created. The renderer discovers optional numeric caption/value pairs among native children 12–48. All 27 local suites pass; target variants, bonus presence, progress placement, optional Ready XP, colours and restoration are covered. Client appearance still needs validation.

v0.103: Compact skill hovers no longer show “(last scan)”. Only the Banked XP numeric value is red for Archaeology when its material storage has never been scanned this session, or Smithing when the metal bank has never been scanned. Captions and other skills retain their native colour. A successful empty scan counts; cached successful scans also retain normal colour. Scan flags reset on game-state changes/reload. Console and detailed storage status remain available. This supersedes earlier suffix instructions below.

v0.103 storage experiment: Open the normal bank, metal bank and Archaeology material storage once each. Look for [BXP storage] scan lines. Recognized storage quantities now feed the recipe planner and skill totals. Unavailable containers use a labelled last scan; all scans reset on game-state changes/reload. Archaeology container discovery still needs in-game confirmation. See STORAGE.md. Complete folder included.

v0.103: Banked XP now follows the optional native Bonus XP row. Archaeology counts potential restoration XP from eligible damaged artefacts even when materials are missing, with a separate Ready XP row for scanned bank materials. Material storage remains unscanned. Stored bonus XP is detected for placement, not added to estimates. Full folder included. See SKILL_TOTALS.md for current behaviour; it supersedes historical release notes below.

v0.103: Skill totals rendering restored using ONLY existing native 1477:923 text components 9/14/15 and frame components 0..8. No UI children are created or destroyed. Native font is retained. Caption/value positions are made absolute during the reversible extension so percentage anchoring cannot displace the two columns differently. The 10px native corners and 1px background fill inset match the observed export. Background summary calculation and audit logging remain enabled. This supersedes earlier recovery/diagnostic statements about rendering being disabled.

v0.103 DIAGNOSTIC BUILD: Native skill tooltip rendering remains DISABLED. A read-only Logic probe logs the matched 1477:923 skill tooltip and its text/frame geometry once per supported skill. Background bank summaries are enabled and print [BXP audit] lines for all ten skills, reporting totals, live level, matching recipes, level-blocked recipes and complete-supply recipes. Direct recipe discovery now applies to all supported skills independently of catalogue first-skill matching. No skill UI components are created, resized, moved or rewritten. Older recovery/no-background statements below are superseded by this paragraph.

v0.103 RECOVERY BUILD: Skill-tab banked XP rendering is DISABLED after a user-reported game crash on hover in v0.94. The skill renderer is a no-op, its native child/frame module is removed, and skill-summary background callbacks are not registered. Bank-item tooltip functionality remains enabled. Earlier release instructions about skill-tab display do not apply to this recovery build. Replace the complete folder while RuneScape is closed, then restart. Local mocked tests cannot establish native-client crash safety.

v0.103: Dedicated native-font skill summary row and reversible native frame extension. Construction recipes are also resolved directly from bank items, independently of catalogue first-skill matching. Zero Construction summaries report detected planks/frames/logs and skill level to console under [BXP Construction]. Protean planks remain unsupported; no XP is guessed.

v0.103: Handles the observed 1477:923 separate Remainder caption. If the adjacent child is a visible numeric value, appends Banked XP to the caption and the total to the value, expands both and restores both. All 26 local suites pass plus focused caption/value regression. In-client visibility remains unconfirmed.

v0.103: Expanded skill discovery to exported hover-display/listener and tooltip-param roots, supports readable text proxies without LABEL type, and reserves diagnostics for the actual STATS source and XP text instead of bank-item chatter. Diagnostic client confirmation still required.

v0.103: Skill tooltip direct dynamic-child discovery, independent native skill heading and XP-details labels, and bounded Skill hover probe console diagnostics. Keeps high-XP summary calculation from v0.90. Open bank once to scan, then hover a supported skill.

v0.103: High-XP bank estimates directly below Remainder in supported skill tooltips. Independent per-skill supply budgets; item menu choices do not control totals. Open bank to scan. See SKILL_TOTALS.md for assumptions and limits.

v0.103 diagnostic build: bounded [BXP artefact] console messages identify catalogue, level/supply eligibility, missing native components and native title matching. Hover each affected damaged artefact, then inspect console. No new chat permission and no XP-rule changes.

v0.103: Full digsite/hotspot audit, soul beacon restoration and component pairing, wrapped title and folded-arm figurine name fixes. See DIGSITE_AUDIT.md and data audit CSVs.

v0.103: Archaeology restoration audit and damaged-artefact previews, plus master outfit restoration-time notes. See ARCHAEOLOGY.md.

v0.103: Shortened all six setting labels and added periods. Preferences and calculation behavior are unchanged.

v0.103: Removed author credit from settings (manifest author remains Zenomac). Added a muted Diango ownership note directly below the worn outfit toggle. Uses a native Museo Sans italic variant if exposed by the client; otherwise retains the readable native font. No unsupported HTML italic tags.

v0.103: Chat access is OPTIONAL. A failed/unavailable notification cannot prevent core XP startup. Supersedes required-chat-access installation instructions in earlier release notes. Grant optional chat access only if you want the local Diango notice.

v0.103: Diango notice waits for chat initialization, checks chat permission, and reports delivery/errors in the developer console. If no message appears, allow chatAccess and inspect the console lines beginning [banked-xp] Diango. API acceptance confirms queueing, not visibility in the selected chat tab.

v0.103: A local chat notice explains that Diango-stored outfits are not detected. Appears on activation in-game and each new sign-in; deferred while logged out. Requires chatAccess for Chat.AddMessage. Reclaim regular outfit pieces into your backpack to confirm ownership for this session. No Diango scanning was added.

v0.103: Equipped skilling tools; additive sculpting chisel XP; conditional tool effect notes. See HAND_EQUIPMENT.md for supported tools and limits.

# Banked XP 0.76 — by Zenomac

Banked base XP estimates and supply-aware recipe choices for Herblore, Smithing, Crafting, Fletching, Archaeology, Farming, Firemaking, Cooking, Prayer and Construction.

Replace the entire `banked-xp` folder with this folder, then reload the plugin. Keep this directory name. This is a development build.

Hover a supported bank item for the selected recipe, base XP, craftable quantity and limiting supplies. Right-click to select a cyan `BXP:` method. Cancel stays below plugin entries. Native tooltip fonts and frame styling are retained. Settings control missing-supply recipes, level previews, potential boosts and full recipe details.

## Coverage

The build contains 3,396 recipe routes: the existing 262 Herblore/primal routes and 3,134 additional routes. Thirty bundled base Prayer values supplement the client-first Prayer provider. See `COVERAGE.md` and `data/multi-skill-audit.csv` for the exact scope and exclusions. This is broad catalog coverage, not support for every RuneScape item or activity.

## Calculation rules

- Base XP remains visible. With Include worn outfit XP bonuses enabled, the heading and skill summary also include the detected outfit bonus. Stored bonus XP and random production benefits remain excluded.
- Each recipe checks its actual skill. The existing three-level preview boundary and settings apply across skills. Recipes requiring an actual level cannot be unlocked by a temporary boost.
- Hover estimates are alternatives. Do not add several alternative hover totals together.
- Skill summaries allocate selected routes from one shared bank budget across skills. The planner is greedy, not a global maximum-XP optimizer. Produced outputs are not automatically chained into more recipes.
- Recipes with unknown output counts show actions, avoiding invented production quantities. Explicit batch yields use the documented quantity.
- Cooking estimates assume successful cooking. Gem cutting can fail for certain low-tier gems. Farming uses planting XP and, where applicable, one successful check-health action; variable harvest XP is excluded.
- Only the normal bank snapshot is scanned. The metal bank, Archaeology material storage, seed bag, toolbelt and other separate stores are not merged. Tool, quest, site and activity prerequisites may need manual verification.
- Boost previews currently use the documented +6 spicy-stew assumption for applicable skills and +3 Archaeology potion, in addition to current levels. Special combinations, extreme cooking scaling, pulse cores and location-only boosts are not modeled as universal unlocks.

All 23 local test suites pass, including per-route supplies/levels, a ten-skill shared-bank integration test and prior tooltip regressions. Live client rendering and every item-name alias still require in-game verification.

## Outfit detection — 0.77

Include worn outfit XP bonuses is enabled by default and can be disabled in settings. Outfit-adjusted totals are labeled, and base totals/unit XP remain visible. An owned outfit that is not equipped never increases XP.

Ownership evidence comes from positive bank, backpack and equipped-item observations within the current session. To register a regular outfit stored only with Diango, reclaim its pieces into your backpack once while the plugin is enabled. This also allows the plugin to confirm inherited XP when you wear a supported elite outfit. Unconfirmed inherited bonuses are excluded and labeled; Diango-only unlock flags are not guessed. See OUTFITS.md.

0.78: Only the active +N% token is colored: red at zero, orange below the full set, green at the full 6% (5% Firemaking). An owned but unworn outfit shows red +0% and a separate uncolored available percentage.

0.79: Removed the separate available outfit bonus line; the colored active percentage remains.

0.103: Outfit parentheses show the number of missing detected pieces: (N not owned), or (N not worn) when the complete regular set is confirmed owned. Fully worn sets show (0 not worn). Ownership refers to observed pieces; Diango-only unlock evidence remains unconfirmed.
