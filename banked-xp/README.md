# Banked XP — v0.149.0

RuneScape 3 client plugin by **Zenomac**.

Copy this complete `banked-xp` folder into your client plugin directory, then load or reload it. Open your bank to scan supplies. Open the metal bank and Archaeology material storage to attempt their additional scans.

See the [repository README](../README.md) for features, installation and calculation limits; the [complete changelog](../CHANGELOG.md) covers v0.1 through v0.149. Supporting documentation lives in [docs](../docs).

The `.lua` files and `plugin.json` are the plugin code and runtime recipe data. Development documentation is kept outside this install folder. The existing `data` and `tests` directories remain available for development.

Read [PRIVACY.md](PRIVACY.md) for local data use, optional chat permission and clearing saved preferences. Clear preferences in settings before uninstalling; unload the plugin to release session observations. This is a development build, not a claim of Jagex approval.

**v0.149 tooltip content layer trial:** Tradeable anima uses one reusable plugin-owned layer inside static tooltip content container 1477:902, alongside the native text. It uses bounded category 148 (v0.148 used an oversized ID and could not create the layer), the normal body font and layout planner, and follows the native title. Every reuse checks live child membership before accessing owned components, including when the client rebuilds children under an unchanged parent. Timing and one-time render diagnostics remain enabled. In-game appearance and stability still require confirmation.
