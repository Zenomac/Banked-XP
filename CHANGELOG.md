# Changelog

Current plugin version: **0.145.0**.

This reconstructed development history starts with the original v0.1 prototype. Entries are based on the saved versioned ZIPs, complete plugin folders, their release notes and source changes. Early experimental builds were not all complete plugin packages. A historical feature or attempted fix is not a claim that it remains in the current build or was verified in the game.

These are development release notes, not backdated Git commits or GitHub release tags. Versions follow the original build labels: v0.1 through v0.105. Historical instructions in older notes may have been superseded.

## v0.145 — Fix owned text initialization

- Remove the unsupported lineSpacing assignment on the plugin-owned text label, which aborted hover layout in v0.144. Use the selected font's default spacing.
- Make both owned-text test fixtures reject lineSpacing writes, matching the reported client error.
- Keep reusable components, native font selection, cursor tracking and bounded timing diagnostics. Live-client latency remains to be confirmed.

## v0.144 — Reusable owned XP text on static parent

- User timing shows layout on frames 2–4, native body visibility only on frames 65–75, and two builds per sample.
- Render tradeable XP through one plugin-owned layer/text pair under static 1477:896. Use the existing shared font and layout plan; leave the native body content, geometry and visibility untouched.
- Keep owned components outside the native undo stack, reuse them across item switches, synchronize cursor position, and hide on restoration/menu opening.
- Drop stale proxies when the parent interface changes; destroy only owned live layers on shutdown. Partial constructor failure cleans up and blocks per-frame allocation retries.
- Local lifecycle tests cover first-draw visibility with an invisible native body, all gods, repeated draws, cursor movement, parent replacement, shutdown and failed construction. Live-client stability and latency are unverified; native-body v0.143 remains a fallback.

## v0.143 — Bounded hover timing diagnostic

- Preserve v0.142 rendering; replace transition-row dumps with a single timing summary per tradeable anima name per plugin load.
- Count frames to selection-ready, layout application and reported body visibility, plus rebuilds and selection events. End after 120 frames or 30 frames following visibility, or on switching items.
- Include cumulative preparation CPU time only if os.clock is available; explicitly label it CPU time, not wall latency. Continue safely without the clock API.
- Local console only: no bank quantities, XP values, account identifiers, persistence or network requests. This is a diagnostic release, not a verified latency fix.

## v0.142 — Commit native text after final layout

- Commit tradeable body content after its font, bounds and clipping containers reach their final values, allowing native text layout to use the completed geometry.
- Keep the unchanged-layout fast path: no repeated content writes on settled hovers.
- Stop exhausted diagnostic probes before reading native component fields.
- Local tests verify that the final content assignment sees the final font/bounds and that 30 subsequent stable draws do not rewrite content. The effect on live-client delay is not measurable locally.

## v0.141 — Prevent delayed-visibility clear/retry cycle

- Reproduce v0.140 clearing XP when the native client moves the body while visibleGlobal is still false.
- Accept our already-owned body text through that transition, with hidden=false and visible parent/title/footer still required.
- Populate the existing body before expanding the frame so text is available during the first layout.
- Preserve shared non-tradeable formatting and stable-hover reuse. Regression fails on v0.140 and passes with this fix; native-client timing remains to be confirmed.

## v0.140 — Shared non-tradeable tooltip configuration

- Remove the separate anima title-label renderer. Tradeable and non-tradeable items now use the same body font selection, hover layout planner, centered information, native heading and right-aligned footer.
- Permit an existing empty native body label only when hidden=false and its parent/title/footer are visible. Do not create components or change visibility flags; live visibility after populating the label remains to be tested.
- Keep stable-layout reuse, validate native title/body changes before reuse, limit tradeable detail inspection to three slots and remove success-probe logging.
- Local regression coverage checks separate title/body, body font parity, direct switches, cursor movement and no repeated component scans on unchanged frames.

## v0.139 — Tradeable anima spacing and stable hover reuse

- Keep the native title font and its line advance together, remove the extra blank title line, separate the options footer from the body and restore the consumption line.
- Retain unchanged native layouts between draws instead of undoing and rebuilding them every frame. Rebuild when displayed values or edited native geometry/content change; preserve cursor-relative positioning and restoration.
- Resolve tradeable anima before the general 30-row detail scan and cache measurements for eight recent layouts to reduce repeat work when switching items.
- Regression coverage includes direct god-to-god switches, no component scans on unchanged frames, cursor movement, no blank title line and footer clearance. No new native UI children or network calls. In-game smoothness and appearance require confirmation.

## v0.138 — Tradeable anima formatting and measurement cache

- Match the smaller native options font on the existing visible label; restore the original title font on exit.
- Separate limiter, requirement and outfit notes into centered lines; restore bank quantity and base-total context with readable number formatting.
- Leave space for the native title divider and cache font lookup and text measurements across unchanged draws. Cache keys include displayed content, font, spacing and width.
- Continue using existing visible components only. Local tests cover repeated measurement avoidance, all four gods, note separation and font restoration; in-game latency and appearance still require confirmation.

## v0.137 — Observed non-visible middle-row workaround

- User probe establishes visible title/footer but middle label hidden=false and visibleGlobal=false.
- Render tradeable anima details within the existing visible title label, expanding existing frame components only; never create or unhide components on this path.
- Preserve and restore the original title. Test the exact observed visibility state, first/repeated draws, all four gods and stable width.
- All 35 local suites pass. Live stability and appearance remain unverified; v0.134 is the recovery fallback.

## v0.136 — Read-only tradeable hover diagnostics

- Keep v0.135 rendering unchanged; add bounded diagnostic snapshots identifying the blocked native row/title check.
- At most three distinct local console snapshots per tradeable anima per load. No new tooltip components, network requests or account IDs; plugin XP text omitted.
- All 35 local suites pass. This diagnostic build is not a fix or proof of live stability. Hover an affected item and provide the BXP hover probe lines to investigate.

## v0.135 — Native-row tradeable anima trial

- Restore tradeable anima XP only in an existing visible native middle label. Preserve a native tradeable suffix above XP and restore it on exit.
- Create no text, layer or sprite children on the tradeable anima path. Keep missing/hidden native components untouched.
- Preserve client text on item changes and test direct transitions, first/repeated draws and restoration for all four gods with constructors forbidden.
- All 34 local suites pass. Native-client stability/latency are not established; v0.134 remains the recovery fallback.

## v0.134 — Crash recovery

- Revert the v0.130–0.133 item-hover renderer experiments after a reported native-client crash in v0.133. Remove plugin-created text rows and their lifecycle changes.
- Temporarily disable tradeable resonant anima hover augmentation entirely; retain recipes, menu preferences and summary calculations.
- Preserve hidden/occupied native rows. Continue v0.129 visibility protections and privacy features.
- Native crash cause is not established by Lua tests. Regression checks verify that tradeable anima do not modify tooltip geometry/text or create text children. Restart the client before installing this recovery build.

## v0.133 — Reduce blank hover rendering

- Populate XP text before expanding the native frame.
- Retain plugin-owned row styles and geometry between draws instead of restoring them as native state.
- Avoid unchanged owned-row position/size writes and bring the row to the front.
- Add first-matching-draw and text-before-frame regression checks. Live-client latency remains to be verified.

## v0.132 — Clear stale hover state on item changes

- Preserve newly client-written native text when undoing the previous item's layout.
- Clear inactive plugin-owned text and release the previous row when switching between native and plugin-owned rows.
- Test sequential and immediate switches across tradeable anima with different estimates; immediate switching fails on v0.131 and passes after this fix.
- Log title mismatches only after ten consecutive frames, avoiding normal one-frame title lag noise.

## v0.131 — Wrapped tradeable anima titles

- Handle a tradeable suffix occupying the native middle row: preserve it in the title and render XP in a plugin-owned row.
- Preserve other occupied native rows as details; safely handle an absent middle component.
- Add repeated-draw tests for split titles for all four gods and bounded diagnostics for anima catalog/title mismatches.

## v0.130 — Tradeable anima hover compatibility

- Normalize tradeable/tradable anima spelling, markup and whitespace without combining untradeable inventory.
- Provide a plugin-owned, click-through XP row when the native middle row is absent or hidden; preserve native visibility.
- Add regressions for all four gods and wrapped tradeable hover titles. No recipe XP changes.

## v0.129 — Guideline preparation

- Preserve native frame/divider visibility; missing or hidden dividers use plugin-owned, click-through sprites.
- Optional local chat notice now fails closed if permission checks are unavailable.
- Add explicit saved-preference deletion with failure reporting and memory reset.
- Include privacy/permissions documentation, submission draft and outstanding owner review checklist.
- Separate full-folder install packaging from flat Mod.io draft packaging. No moderation approval claimed.

## v0.128

Add untradeable resonant anima of Bik, Ful, Wen and Jas alongside the tradeable variants. Normalize standard imbuing to one dinarrow plus three anima for 19 Fletching XP, supporting partial stacks and shared-supply totals. Preserve raw dinarrow-preparation routes for each variant. Anima-only banks retain an informational hover without adding unavailable XP or menu choices. Estimates explicitly assume Wisdom of Anima is disabled; its alternate mode is not detected. All 33 local Lua suites pass. No native layout or runtime network changes.

## v0.127

Center the preserved native stat/description block beneath the XP section, using its stable measured width. Center full-width description lines while retaining narrower native stat-column spacing. The options footer retains its native alignment. Keeps the v0.126 baseline that stops horizontal growth. All 32 local suites pass, including centered description geometry and footer alignment during 100 client-interleaved redraws. Live-client confirmation remains pending.

## v0.126

Stabilize equipment/ammunition hover geometry across client relayouts between Draw callbacks. Retain native header dimensions, detail-block offsets, frame inset and clipping-container geometry for the active tooltip; clear the baseline when the tooltip ends or its item/content changes. This prevents client-adjusted stat positions from becoming the next layout baseline. A client-interleaved regression fails on v0.125 and passes 100 redraws with stable width and offsets in v0.126. All 32 local suites pass; in-game confirmation remains pending.

## v0.125

Fix horizontal expansion and stat displacement in equipment/ammunition hovers such as Dinarrows. Capture native detail positions and dimensions before resizing parent containers, then use that snapshot for the translated stat block. Previously percentage-anchored rows were measured after parent expansion and grew again. A new regression fails against v0.124 and passes 100 consecutive redraws with stable width and offsets; native anchors restore afterward. All 32 local Lua suites pass. Live client confirmation remains pending.

## v0.124

Retain an informational hover for specialist arrow tips when no recipe passes the availability filters. Shows per-arrow XP and missing-supply or level information. Unavailable recipes remain excluded from right-click choices and skill totals. Regression checks cover all three tip families with only tips in the bank and the unowned-ingredient setting disabled. All 32 local Lua suites pass. Live-client confirmation remains pending.

## v0.123

Updated black stone, deathspore and splintering arrow-tip recipes against current creation tables. Replaced seven records with 31 direct/preparation routes covering elder headless shafts and seven feather types. Supports partial ammunition stacks, legacy elder headless-arrow naming and singular tip aliases. Counts only remaining feathering/tipping XP and requires all supplies. Black stone recipe unlock remains a player prerequisite. All 32 local Lua suites pass; no native UI or runtime network changes.

## v0.122

Verified battlestaves, arrowheads, Fort frames and Ascension fragment routes against item creation tables. Replaced 64 older records with 75 direct/preparation records. Added compatibility between Headless arrow/Headless shaft and Arrow shaft/Shaft names. Ammunition assembly accounts for partial stacks, preserves remaining preparation XP and distinguishes Ascension fragments from shards. Corrected the Maple frame requirement to three refined planks, Dark arrow level to 70 and Elder rune arrow XP to 18.7 per arrow. Existing ingredient-ownership filters remain in force; Fort building still requires wall segments. All 31 local Lua suites pass. No new runtime network calls or native UI changes.

## v0.121

Audited all ten supported skills against calculator indexes and targeted creation tables. Added 552 recipe/level-tier records, including Primal Smithing, platinum smelting, incense, pyre-log preparation, proteans, brewing, scrimshaws and equipment; 159 new ingredient names are indexed. Removed 12 Cooking urn reward records that were not immediate recipe XP. Protean menus select the current real-level tier. Incense retains both skills' XP without duplicating supplies, and legacy Prayer/log methods share recipe budgets. Updated coverage documentation with item-level dispositions and explicit remaining gaps. All 30 local Lua suites pass; live game verification remains outstanding. No runtime network calls added.

## v0.120

Removed the standalone Level Required warning from recipe hovers. The existing [Lv ###] suffix on the method now carries the warning colour: orange for 1–4 missing levels, red for 5 or more. Targeted level-policy and syntax checks pass.

## v0.119

Removed the duplicate standalone Lv ### note from level-locked recipe hovers. The coloured Level Required warning remains.

## v0.118

Keep an informational recipe hover when recipes are hidden solely by their level requirements. The closest required-level recipe is previewed, respecting ingredient visibility settings. Missing levels show “Level Required: ###” in orange for gaps of 1–4 and red for gaps of 5 or more; cape/unboostable routes use the base level. Preview fallback recipes are not added to selectable methods or usable banked XP summaries. All 29 suites pass, including requirement colour boundaries.

## v0.117

Preserve native non-Herblore detail blocks beneath XP information instead of stacking and centering each label. Native stat fonts, alignments, widths, heights and relative row/column offsets are retained; the block moves together below the XP section. Potion layout remains as before. Added native stat-preservation coverage; hover and Lua syntax checks pass. Live equipment appearance still requires confirmation.

## v0.116

Audited 6,638 recipe/input combinations. Contextual menu labels omit ingredient tags repeating the clicked item, covering 613 combinations including 11 refined-item cases. Distinct ingredient, method and requirement tags remain. Added a full-catalog contextual-label audit; targeted label, shared-selection and Lua syntax checks pass.

## v0.115

Also remove standalone log ingredient tags at menu presentation, covering labels supplied outside the current recipe generator. Current Maple-log recipe labels were verified clean locally; live rendering still needs confirmation.

## v0.114

Removed redundant log ingredient tags such as [Maple logs] from recipe method labels. Other ingredient tags and meaningful variant labels remain.

## v0.113

Changed the word “selected” in the active recipe/method menu entry to green. Brackets and surrounding recipe colours retain their existing styling.

## v0.112

Audited client API usage: runtime code makes no HTTP requests. Removed the obsolete broad total-tooltip fallback search, reused cached bank slots for summary capture, coalesced storage inventory events once per Logic tick and reduced periodic storage fallback polling to 250 Logic ticks (approximately five seconds). Event-driven updates remain enabled. Added API-usage regression coverage; all 28 suites pass. These checks use mocks, not live client profiling.

## v0.111

Removed temporary total-tooltip probes, artefact tracing, disabled item-config diagnostics, storage-discovery logs, API recipe-verification chatter and bank-audit counters/scans. Normal hover and startup diagnostic messages are gone; useful failures still report errors. Calculations, API recipe validation, known storage detection, hovers and the optional Diango chat notice remain active. Removed the obsolete probe test and corrected archived main.lua paths in reload tests to resolve the current module. All 27 remaining suites pass.

## v0.110

The v0.109 client screenshot confirms the total-XP Banked XP row now appears. Removed the extra 4px bottom padding from that dedicated text tooltip so adding the XP row preserves its original native inset. Individual skill-tooltip spacing is unchanged. Focused hover geometry, colour and restoration regressions pass.

## v0.109

Targeted the live-captured total-XP label at 1486:14:0:0 (font 27, 125×32). Static text 15 was a zero-sized template, so v0.108 did not find the rendered text. The renderer now prefers the exact dynamic child, excludes zero-sized templates and expands dynamic text layer 14 with the native frame. Added row spacing is derived from native text height and measured line count. All 28 suites pass, including the captured shape; in-game rendering still requires confirmation.

## v0.108

Added a dedicated total-XP renderer for TEXT_TOOLTIP interface 1486, discovered in the exported component registry after probes only found individual skills at 1477:923. Recognizes Total XP content in static text 14/15 and extends the existing RS3 static background/border sprites. Preserves native corners, resets added text colour and restores all changes on exit. Added 1486 roots to the read-only probe. All 28 local suites pass; actual client visibility remains to be confirmed.

## v0.107

The v0.106 client probe saw visible roots but no Total XP text. Added bounded direct ComponentCollection:GetChild category lookup and a throttled read-only Draw-phase sample alongside Logic sampling. Probe lines identify their phase and child path. Existing rendering is unchanged; the location of the native total-XP text remains unresolved pending the new capture.

## v0.106

Added an isolated, read-only Logic probe for nested total-XP components after v0.105 produced no match messages. It inspects known shared hover roots and the Stats tooltip/frame/source roots through bounded iteration and direct child lookup. Reports initial scan counts, visible text and reserved Total XP matches. Probe initialization and scan errors are isolated from existing hovers. No new rendering behavior or UI allocations are introduced; locating the actual native total-XP tooltip remains pending client logs.

## v0.105

Expanded total-XP hover discovery to the exported tooltip/info/hover roots, scanning both static text and dynamic children 0–64. Discovery is throttled and a working root is reused. Read-only [BXP total probe] messages identify matched text and frame failures. Rendering proceeds only with the established 10px-corner native frame shape. This addresses the missing v0.104 display path; actual client visibility is still unconfirmed.

## v0.104

Added Banked XP beneath Bonus XP in the total-XP hover (or beneath Total XP without a bonus row). The combined estimate uses one shared supply budget across supported skills and includes the same Archaeology artefact-potential assumption. Calculation stays incremental on Logic; Draw uses completed results. Native text/frame components are reused, with neutral added text, storage-warning colours, bottom padding and reversible edits.

## v0.103

Add 4px between the final target Remainder row and the existing progress components, plus 4px additional padding at the bottom of the skill tooltip. Without a target, only the bottom padding applies, including when Archaeology Ready XP is the final row. Native frame and parent clipping height grow with the added space. All changes restore on exit. All 27 local suites pass, including explicit padding and restoration assertions. In-game appearance remains to be checked.

## v0.102

Preserve native numeric caption/value rows in their existing vertical order, including Next level, Remainder and Bonus XP. Insert Banked XP (and optional Archaeology Ready XP) immediately before the first Target row; without a target append after the native XP rows. No native XP rows are intentionally omitted. Each numeric line starts with an explicit neutral colour tag, preventing unclosed Bonus XP green from leaking into later lines. Bonus XP remains green; unscanned-storage Banked XP stays red as requested. Neutral colour uses the original current-XP/heading tag when present, otherwise the existing native-style e3d7bf fallback. Existing progress siblings move below the expanded rows. No native children are created. All 27 local suites pass, including unclosed Bonus XP colour tags, extra native XP fields, both target kinds and restoration. In-game appearance still needs verification. This supersedes v0.101's omission of Next level and forced bonus order.

## v0.101

Skill tooltips now use this order: heading, Current XP, Bonus XP (when present), next-level Remainder, Banked XP, optional Archaeology Ready XP, native Target Level/XP and target Remainder. Next level is omitted. Existing native target progress siblings are placed below the final text row. Native captions and values are consolidated into the existing Current XP caption/value pair; original text and geometry are restored before the next draw and on shutdown. No native children are created. The renderer discovers optional numeric caption/value pairs among native children 12–48. All 27 local suites pass; target variants, bonus presence, progress placement, optional Ready XP, colours and restoration are covered. Client appearance still needs validation.

## v0.100

Compact skill hovers no longer show “(last scan)”. Only the Banked XP numeric value is red for Archaeology when its material storage has never been scanned this session, or Smithing when the metal bank has never been scanned. Captions and other skills retain their native colour. A successful empty scan counts; cached successful scans also retain normal colour. Scan flags reset on game-state changes/reload. Console and detailed storage status remain available. This supersedes earlier suffix instructions below.

## v0.99

storage experiment: Open the normal bank, metal bank and Archaeology material storage once each. Look for [BXP storage] scan lines. Recognized storage quantities now feed the recipe planner and skill totals. Unavailable containers use a labelled last scan; all scans reset on game-state changes/reload. Archaeology container discovery still needs in-game confirmation. See STORAGE.md. Complete folder included.

## v0.98

Banked XP now follows the optional native Bonus XP row. Archaeology counts potential restoration XP from eligible damaged artefacts even when materials are missing, with a separate Ready XP row for scanned bank materials. Material storage remains unscanned. Stored bonus XP is detected for placement, not added to estimates. Full folder included. See SKILL_TOTALS.md for current behaviour; it supersedes historical release notes below.

## v0.97

Skill totals rendering restored using ONLY existing native 1477:923 text components 9/14/15 and frame components 0..8. No UI children are created or destroyed. Native font is retained. Caption/value positions are made absolute during the reversible extension so percentage anchoring cannot displace the two columns differently. The 10px native corners and 1px background fill inset match the observed export. Background summary calculation and audit logging remain enabled. This supersedes earlier recovery/diagnostic statements about rendering being disabled.

## v0.96

DIAGNOSTIC BUILD: Native skill tooltip rendering remains DISABLED. A read-only Logic probe logs the matched 1477:923 skill tooltip and its text/frame geometry once per supported skill. Background bank summaries are enabled and print [BXP audit] lines for all ten skills, reporting totals, live level, matching recipes, level-blocked recipes and complete-supply recipes. Direct recipe discovery now applies to all supported skills independently of catalogue first-skill matching. No skill UI components are created, resized, moved or rewritten. Older recovery/no-background statements below are superseded by this paragraph.

## v0.95

RECOVERY BUILD: Skill-tab banked XP rendering is DISABLED after a user-reported game crash on hover in v0.94. The skill renderer is a no-op, its native child/frame module is removed, and skill-summary background callbacks are not registered. Bank-item tooltip functionality remains enabled. Earlier release instructions about skill-tab display do not apply to this recovery build. Replace the complete folder while RuneScape is closed, then restart. Local mocked tests cannot establish native-client crash safety.

## v0.94

Dedicated native-font skill summary row and reversible native frame extension. Construction recipes are also resolved directly from bank items, independently of catalogue first-skill matching. Zero Construction summaries report detected planks/frames/logs and skill level to console under [BXP Construction]. Protean planks remain unsupported; no XP is guessed.

## v0.93

Handles the observed 1477:923 separate Remainder caption. If the adjacent child is a visible numeric value, appends Banked XP to the caption and the total to the value, expands both and restores both. All 26 local suites pass plus focused caption/value regression. In-client visibility remains unconfirmed.

## v0.92

Expanded skill discovery to exported hover-display/listener and tooltip-param roots, supports readable text proxies without LABEL type, and reserves diagnostics for the actual STATS source and XP text instead of bank-item chatter. Diagnostic client confirmation still required.

## v0.91

Skill tooltip direct dynamic-child discovery, independent native skill heading and XP-details labels, and bounded Skill hover probe console diagnostics. Keeps high-XP summary calculation from v0.90. Open bank once to scan, then hover a supported skill.

## v0.90

High-XP bank estimates directly below Remainder in supported skill tooltips. Independent per-skill supply budgets; item menu choices do not control totals. Open bank to scan. See SKILL_TOTALS.md for assumptions and limits.

## v0.89

diagnostic build: bounded [BXP artefact] console messages identify catalogue, level/supply eligibility, missing native components and native title matching. Hover each affected damaged artefact, then inspect console. No new chat permission and no XP-rule changes.

## v0.88

Full digsite/hotspot audit, soul beacon restoration and component pairing, wrapped title and folded-arm figurine name fixes. See DIGSITE_AUDIT.md and data audit CSVs.

## v0.87

Archaeology restoration audit and damaged-artefact previews, plus master outfit restoration-time notes. See ARCHAEOLOGY.md.

## v0.86

Shortened all six setting labels and added periods. Preferences and calculation behavior are unchanged.

## v0.85

Removed author credit from settings (manifest author remains Zenomac). Added a muted Diango ownership note directly below the worn outfit toggle. Uses a native Museo Sans italic variant if exposed by the client; otherwise retains the readable native font. No unsupported HTML italic tags.

## v0.84

Chat access is OPTIONAL. A failed/unavailable notification cannot prevent core XP startup. Supersedes required-chat-access installation instructions in earlier release notes. Grant optional chat access only if you want the local Diango notice.

## v0.83

Diango notice waits for chat initialization, checks chat permission, and reports delivery/errors in the developer console. If no message appears, allow chatAccess and inspect the console lines beginning [banked-xp] Diango. API acceptance confirms queueing, not visibility in the selected chat tab.

## v0.82

A local chat notice explains that Diango-stored outfits are not detected. Appears on activation in-game and each new sign-in; deferred while logged out. Requires chatAccess for Chat.AddMessage. Reclaim regular outfit pieces into your backpack to confirm ownership for this session. No Diango scanning was added.

## v0.81

Equipped skilling tools; additive sculpting chisel XP; conditional tool effect notes. See HAND_EQUIPMENT.md for supported tools and limits.

## v0.80

Added missing-owned and missing-worn piece counts to outfit information.

## v0.79

Removed the separate available outfit bonus line.

## v0.78

Coloured only the active bonus percentage red, orange or green according to detected bonuses.

## v0.77

Added detected worn skilling outfit XP bonuses.

## v0.76

Expanded banked-XP recipe coverage to all ten supported skills and documented coverage and planning limits.

## v0.75

Set author metadata to Zenomac and added the then-current settings credit.

## v0.74

Added primal extract yields and primal fruit pulping recipes.

## v0.73

Recognized Cancel by its native action type and normalized its position after recipe entries.

## v0.72

Changed right-click prefixes to cyan BXP followed by a colon.

## v0.71

Used native menu subject-text colours for potion names and adjusted Cancel placement.

## v0.70

Matched plugin text to native effect/footer fonts and measured each section using its own font.

## v0.69

Expanded trailing-empty-stat normalization to whitespace, newlines and mixed break-tag variants.

## v0.68

Removed the hand-drawn border and separator fallback in favour of native artwork.

## v0.67

Trimmed trailing empty potion-description rows and tightened the effects-to-divider gap.

## v0.66

Normalized the options footer to a single measured line and limited inherited bottom padding.

## v0.65

Extended dividers to the inner border.

## v0.64

Reused the observed native fill, corners and edge sprites for the expanded item-tooltip frame.

## v0.63

Used the observed native separator IDs to suppress both unwanted separator sprites.

## v0.62

Restored the native background and added a read-only frame probe for the remaining divider.

## v0.61

Suppressed the plugin hover when no recipe survives the active availability filters.

## v0.60

Tried a replacement background for potion-effect tooltips; this experimental path was later removed in v0.62.

## v0.59

Extended native separator suppression to additional tooltip branches.

## v0.58

Restored the options footer’s native alignment while keeping the other text centered.

## v0.57

Centered text throughout enhanced item tooltips.

## v0.56

Adjusted native potion-effect dividers and conditionally centered stat-boosting potion information.

## v0.55

Audited terminal potion families and suppressed plugin hovers for finished products with no downstream recipes.

## v0.54

Expanded discovery of native skill-tooltip roots after the first skill-tab display did not appear.

## v0.53

Made normalization explicitly single-valued and replaced coroutine scanning with incremental Logic jobs.

## v0.52

Corrected string-normalization calls for the strict client binding and preserved original scan errors.

## v0.51

Introduced cached skill-tab banked XP for the supported Herblore, Prayer and Firemaking catalog.

## v0.50

Added the recipe-on-hover setting and compacted the settings layout.

## v0.49

Shortened right-click method labels and added full recipe information to the hover limiter.

## v0.48

Added optional boost-reachable recipes and documented conditional skill-boost assumptions.

## v0.47

Added cached hover layout, recipe-planning reductions and stable bank-container snapshot caching.

## v0.46

Separated requirements and limiters onto their own lines; made the decanting qualifier conditional.

## v0.45

Added underlevel-recipe settings and the next-unlock level countdown.

## v0.44

Replaced ingredient-presence checks with whole-batch supply validation across potion recipes.

## v0.43

Added the native settings page and a toggle for recipes with missing ingredients.

## v0.42

Hid level tags when the player meets the recipe requirement.

## v0.41

Corrected all master-cape recipe prerequisites to an effective level requirement of 120.

## v0.40

Unified level filtering across potion routes and suppressed inferior recipe variants when applicable.

## v0.39

Added shared compatible method preferences across related items.

## v0.38

Added live Herblore level filtering and excluded recipes at least three levels above the player.

## v0.37

Replaced numbered route labels with ingredient-based descriptions.

## v0.36

Expanded the Wiki potion catalog to 251 crafting routes from 190 bankable potion entries.

## v0.35

Added secondary-ingredient and supply hovers derived from the existing recipe graph.

## v0.34

Restored native cursor following and preserved client-updated positions during layout cleanup.

## v0.33

Avoided unsupported native-label property writes that caused the client new_index error.

## v0.32

Protected optional native-component lookups and restored missing hovers with a footer fallback.

## v0.31

Measured native-font layout for wrapped recipe information, native descriptions and the options footer.

## v0.30

Added unfinished-potion finishing and supported potion upgrades, including dose pooling after manual decanting.

## v0.29

Added persistent right-click method selection, Prayer methods and Maple bonfire choices.

## v0.28

Added a hybrid API-first recipe XP provider with bundled fallbacks and calibration checks.

## v0.27

Added herb cleaning and clean-herb potion potential across standard, Habitat and additional herb records.

## v0.26

Added restoration table identity and column-type diagnostics rather than assuming an XP column.

## v0.25

Added API-backed base Prayer XP for eligible bones and ashes, plus restoration-data diagnostics.

## v0.24

Read-only item-config diagnostics for bones, ashes, artefacts, herbs and potions; active coverage remained Maple logs.

## v0.23

Further native tooltip trim and corner refinement before expanding item coverage.

## v0.22

Further native tooltip border and corner layout refinement.

## v0.21

Revised hover-layer outlines and divider drawing for the expanded native tooltip.

## v0.20

Complete-folder development package with a manifest; continued native trim and border experiments for Maple logs.

## v0.19

Expanded additional clipping containers and refined native divider handling.

## v0.18

Expanded the native backing layer with the XP details.

## v0.17

Added method, bank quantity and per-log XP details beneath the Firemaking total.

## v0.16

Captured original container heights before resizing to avoid repeated growth from inherited anchors.

## v0.15

Restored and expanded native content-frame artwork previously mistaken for a separator.

## v0.14

Used native Size and Pos value objects for reversible layout edits.

## v0.13

Used frame-piece geometry rather than assumed dynamic-ID order to resize the background.

## v0.12

Separator visibility and left-alignment experiment for the native XP row.

## v0.11

Native fill and segmented border resizing to follow the expanded row.

## v0.10

Expanded the native middle row and moved the options footer below it, restoring layout on exit.

## v0.9

Native middle-row text experiment using the existing tooltip label, with reversible content edits.

## v0.8

Experimental native hover-text integration instead of a separate overlay.

## v0.7

Narrow attached-layout experiment aligned with the estimated native tooltip bounds.

## v0.6

Smaller plain font, tighter row spacing and reduced padding.

## v0.5

Native-inspired colours and font-config discovery for the hover.

## v0.4

Replaced the GroupBox with a plain layer and measured background to address extra framing and clipping.

## v0.3

Compact five-row XP box below the native item tooltip, supported-item filtering and thousands separators.

## v0.2

Cursor-following XP hover prototype with separate text rows and a click-through overlay.

## v0.1

Initial developer-world prototype for bank access and UI testing.
