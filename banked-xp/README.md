# Banked XP — v0.138.0

RuneScape 3 client plugin by **Zenomac**.

Copy this complete `banked-xp` folder into your client plugin directory, then load or reload it. Open your bank to scan supplies. Open the metal bank and Archaeology material storage to attempt their additional scans.

See the [repository README](../README.md) for features, installation and calculation limits; the [complete changelog](../CHANGELOG.md) covers v0.1 through v0.138. Supporting documentation lives in [docs](../docs).

The `.lua` files and `plugin.json` are the plugin code and runtime recipe data. Development documentation is kept outside this install folder. The existing `data` and `tests` directories remain available for development.

Read [PRIVACY.md](PRIVACY.md) for local data use, optional chat permission and clearing saved preferences. Clear preferences in settings before uninstalling; unload the plugin to release session observations. This is a development build, not a claim of Jagex approval.

**v0.138 native-row formatting:** Tradeable anima hovers extend the existing visible title label, because the client reports the middle label as non-visible. No tooltip children are created and the middle label is untouched. The text uses the smaller native options font, separate note lines and cached measurements. Right-click recipes remain available. Live-client stability is not established; v0.134 remains the recovery fallback.
