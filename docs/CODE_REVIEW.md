# Review map — v0.129

This map helps the author personally review the implementation. It is not a substitute for that review or Jagex moderation.

| Modules | Responsibility and boundary |
| --- | --- |
| main, hover_layout, native_frame, tooltip_style | Enhance the currently visible bank tooltip. Restore transient geometry on exit. Never force native hidden components visible. Replacement rules belong to this plugin and are click-through. |
| skill_hover, skill_summary | Display estimates within visible skill/total tooltips; allocate shared supplies. No server actions. |
| bank, storage, outfits, hand_equipment | Read exposed local-player inventories and equipment; cache observations. Storage detection is experimental. |
| recipe_engine, recipe_policy, methods | Evaluate recipes and filters. Menu callbacks only set local method preferences or menu pages. |
| api_xp, catalog | Read client object recipe fields; calibrate against bundled data. These are client API accesses, not HTTP requests. |
| settings, settings_ui, privacy | Persist preferences; explicit reset deletes only the three owned keys. Surface deletion failures. |
| startup_notice | Local notification only; requires affirmative optional chat permission. |
| *_recipes, *_data and data/ | Factual reference tables, not executable gameplay actions. Source URLs and readable JSON audit counterparts aid review. Some legacy Lua tables remain densely serialized; this is an outstanding readability improvement. |

No HTTP, player-action injection, external analytics or account-identifier persistence was found in the v0.129 runtime audit. Native visibility writes are confined to plugin-created layers; native decorative geometry still changes, so live validation and moderator assessment remain necessary. Native hidden borders remain hidden; hidden or absent separators receive plugin-owned replacements.

Provenance of earlier third-party reference material is unresolved. The audit does not certify ownership, AI-input permission, legal compliance, cross-platform support, or Jagex approval.
