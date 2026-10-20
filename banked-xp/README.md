# Banked XP — v0.153.0

RuneScape 3 client plugin by **Zenomac**.

Copy this complete `banked-xp` folder into your client plugin directory, then load or reload it. Open your bank to scan supplies. Open the metal bank and Archaeology material storage to attempt their additional scans.

See the [repository README](../README.md) for features, installation and calculation limits; the [complete changelog](../CHANGELOG.md) covers v0.1 through v0.153. Supporting documentation lives in [docs](../docs).

The `.lua` files and `plugin.json` are the plugin code and runtime recipe data. Development documentation is kept outside this install folder. The existing `data` and `tests` directories remain available for development.

Read [PRIVACY.md](PRIVACY.md) for local data use, optional chat permission and clearing saved preferences. Clear preferences in settings before uninstalling; unload the plugin to release session observations. This is a development build, not a claim of Jagex approval.

**v0.153 rendering diagnostic:** The tradeable-anima layer now uses client-assigned component IDs, matching the allocation pattern used by the existing divider renderer. Live-child checks use the exact returned IDs, including after native rebuilds. The cyan outline and two font controls remain temporarily so the in-game result can be compared with v0.152. This is an unconfirmed rendering trial; no extra API requests or per-frame allocations are introduced.
