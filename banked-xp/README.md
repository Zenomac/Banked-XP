# Banked XP — v0.142.0

RuneScape 3 client plugin by **Zenomac**.

Copy this complete `banked-xp` folder into your client plugin directory, then load or reload it. Open your bank to scan supplies. Open the metal bank and Archaeology material storage to attempt their additional scans.

See the [repository README](../README.md) for features, installation and calculation limits; the [complete changelog](../CHANGELOG.md) covers v0.1 through v0.142. Supporting documentation lives in [docs](../docs).

The `.lua` files and `plugin.json` are the plugin code and runtime recipe data. Development documentation is kept outside this install folder. The existing `data` and `tests` directories remain available for development.

Read [PRIVACY.md](PRIVACY.md) for local data use, optional chat permission and clearing saved preferences. Clear preferences in settings before uninstalling; unload the plugin to release session observations. This is a development build, not a claim of Jagex approval.

**v0.142 shared native layout:** Tradeable anima uses the same existing body label, font selection and layout planner as non-tradeable items. An empty or plugin-owned label is eligible only when its hidden flag is false and its parent/title/footer are visible. Content is populated before frame expansion, then committed after the final font and bounds are set; it is retained through delayed visibility updates. No visibility flags are changed and no components are created. Stable tradeable hovers reuse their applied layout. Live rendering of the populated body label still needs confirmation; v0.134 remains the recovery fallback.
