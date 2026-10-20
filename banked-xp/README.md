# Banked XP — v0.161.0

RuneScape 3 client plugin by **Zenomac**.

Copy this complete `banked-xp` folder into your client plugin directory, then load or reload it. Open your bank to scan supplies. Open the metal bank and Archaeology material storage to attempt their additional scans.

See the [repository README](../README.md) for features, installation and calculation limits; the [complete changelog](../CHANGELOG.md) covers v0.1 through v0.161. Supporting documentation lives in [docs](../docs).

The `.lua` files and `plugin.json` are the plugin code and runtime recipe data. Development documentation is kept outside this install folder. The existing `data` and `tests` directories remain available for development.

Read [PRIVACY.md](PRIVACY.md) for local data use, optional chat permission and clearing saved preferences. Clear preferences in settings before uninstalling; unload the plugin to release session observations. This is a development build, not a claim of Jagex approval.

**v0.156 anima formatting:** Centered XP text and right-edge options retain the confirmed native-label rendering. The footer divider is now anchored to the options-line start using wrapped body lines and native configured line spacing, rather than the height of the padded combined string. The console prints the running build version on each load/reload.

**v0.157 Summoning:** Adds pouch-infusion and blank binding-contract recipes. Shared ingredients have saved **BXP: Use <skill>** menu choices and a **Dual-use:** hover note. Skill choices affect the item display, while summaries continue evaluating all supported uses. See the repository coverage document for exclusions.

**v0.158 pouch review:** Added direct granite lobster recipes for 2kg and 5kg granite, and verified scroll conversion for Spirit wolf, Dreadfowl and Steel titan pouches. XP for conversion is per consumed pouch, not per resulting scroll. The linked Wiki main table was blocked; this is a partial sourced review, not a complete current-page audit.

**v0.159 complete supplied-page audit:** All 86 regular and five elder pouch rows now match the saved Wiki table for level, creation XP, charm, shards/energy, and tertiary ingredients. Added Jackalope and Holy scarab; corrected Bagged plant and Ruby harvest jar. Holy scarab requires all five shell types. Dungeon-only and kill-dependent familiar creation remain outside bank-only estimates.

**v0.160 settings layout:** Compact row spacing and padding keep all seven controls, including Clear saved preferences, inside the native settings window. Native fonts and checkbox sizes are unchanged.

**v0.161 settings action:** Clear saved preferences is now a native button centered at the bottom, below the six settings and outfit note.
