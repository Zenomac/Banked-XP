# Banked XP — v0.155.0

RuneScape 3 client plugin by **Zenomac**.

Copy this complete `banked-xp` folder into your client plugin directory, then load or reload it. Open your bank to scan supplies. Open the metal bank and Archaeology material storage to attempt their additional scans.

See the [repository README](../README.md) for features, installation and calculation limits; the [complete changelog](../CHANGELOG.md) covers v0.1 through v0.155. Supporting documentation lives in [docs](../docs).

The `.lua` files and `plugin.json` are the plugin code and runtime recipe data. Development documentation is kept outside this install folder. The existing `data` and `tests` directories remain available for development.

Read [PRIVACY.md](PRIVACY.md) for local data use, optional chat permission and clearing saved preferences. Clear preferences in settings before uninstalling; unload the plugin to release session observations. This is a development build, not a claim of Jagex approval.

**v0.155 anima formatting:** The native options-label rendering introduced in v0.154 is confirmed visible in-game. XP text is now centered, with measured nonbreaking-space padding on the final options line to retain its right-edge placement. A missing footer divider uses the existing sprite-rule renderer and follows the cursor. The console prints the executable build version on every load/reload. This release's alignment and divider appearance still need in-game confirmation.
