# Mod.io submission draft — v0.129.0

NOT READY TO SUBMIT: supply a real monitored contact email in plugin.json and the listing, complete personal code/provenance review, and finalize the privacy notice. This draft records work completed; it does not certify compliance or approval.

## Suggested summary

Estimate banked XP across ten skills, compare supply-aware recipes, and view totals in skill tooltips. Includes optional detected equipment bonuses. Coverage and storage detection have limitations.

## Description

Banked XP is an independent community planning plugin by Zenomac. Open your bank, then hover a supported item to see an XP estimate. Right-click and select a cyan BXP entry to change the calculation method; this does not craft or withdraw anything. Hover a supported skill or total XP to see aggregate estimates. Open additional supported storage to refresh its quantities.

Settings let you include missing ingredients, level-locked or boostable recipes, ingredient details, worn outfits and equipped tools. Diango-only outfits are not detected. Shared supplies, missing materials and greedy recipe allocation can affect estimates. Totals are not guaranteed maximums or XP/hour rates. Resonant anima currently assumes standard imbuing with Wisdom of Anima disabled. Storage discovery and native layout require live-client verification.

## Contact email

AUTHOR TO COMPLETE: use a monitored address separate from game/mod.io login addresses. Replace example@example.com in the manifest. For local-only Case 1, request private metadata treatment from moderators if desired.

## EULA

Before submission, the author must personally accept the Jagex EULA and incorporated terms. Include the acknowledgement required by the submission page; this draft does not make that acceptance on the author's behalf.

https://legal.jagex.com/docs/terms/eula

## Permissions

No required permissions. Optional chatAccess adds a local reminder about Diango outfit detection; it does not read chat or send messages to players. No HTTP access requested. Add the corresponding permission tag on Mod.io.

## Data protection: Case 1 (local only)

Include the complete current banked-xp/PRIVACY.md disclosure, replacing its publication/contact placeholders before release. It describes data used, purpose, storage, retention and deletion. No external endpoints or developer-held account database exist. Do not invent an overseas data-transfer requirement solely because of the author's residence; confirm any applicable developer obligations with Jagex.

## Submission packaging and review

Use the separate flat Mod.io draft archive: main.lua and plugin.json must be at ZIP root. The complete-folder archive is for local installation, not direct Mod.io submission. Include all required runtime modules and the privacy notice. No PrettyUI or other plugin dependency is declared or required by the current build.

Supply a listing image, appropriate platform selections, screenshots, version and changelog. Perform live checks of hidden/visible divider combinations, native item stats, skills/targets, preference deletion, permission denial and client reload. Confirm mobile/platform usability before claiming support. Freeze the submitted files/listing when a moderator starts review.

## Outstanding owner responsibilities

- Personally review and understand AI-assisted code; tests do not substitute for this.
- Resolve provenance and AI-input permission for any third-party reference plugin code previously supplied (including Menu Entry Swapper/PrettyUI). No permission is assumed from public availability or absence of a runtime dependency.
- Verify rights/attribution for incorporated content and factual Wiki extraction, including applicable source terms.
- Confirm privacy contact, applicable lawful basis, retention/deletion obligations and user rights. No legal certification is claimed.
- No commercial exploitation or alternative plugin licence; maintain/respond to Jagex as required by Schedule 4.
- Obtain moderation approval before public release. Permission requests and menu changes remain reviewable.

Sources checked 20 October 2026:
https://developer.runescape.com/rs/submission/process.html
https://developer.runescape.com/rs/submission/guidelines.html
https://legal.jagex.com/docs/terms/eula
