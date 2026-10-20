# Banked XP — v0.147.0

RuneScape 3 client plugin by **Zenomac**.

Copy this complete `banked-xp` folder into your client plugin directory, then load or reload it. Open your bank to scan supplies. Open the metal bank and Archaeology material storage to attempt their additional scans.

See the [repository README](../README.md) for features, installation and calculation limits; the [complete changelog](../CHANGELOG.md) covers v0.1 through v0.147. Supporting documentation lives in [docs](../docs).

The `.lua` files and `plugin.json` are the plugin code and runtime recipe data. Development documentation is kept outside this install folder. The existing `data` and `tests` directories remain available for development.

Read [PRIVACY.md](PRIVACY.md) for local data use, optional chat permission and clearing saved preferences. Clear preferences in settings before uninstalling; unload the plugin to release session observations. This is a development build, not a claim of Jagex approval.

**v0.147 blank-text diagnostic:** Tradeable anima uses one reusable plugin-owned layer and text label under static interface component 1477:896. It shares the normal body font and layout planner, follows the visible native title, and leaves the delayed native body untouched. Owned components are excluded from native undo records and cleaned up on shutdown; interface replacement drops stale references. Timing diagnostics remain enabled. A one-time `[BXP render]` dump reports font and ancestor bounds; v0.146 still rendered blank in-game, and this build gathers evidence without changing the rendering path. Live-client stability and latency require confirmation; v0.143 is the delayed-native-body fallback.
