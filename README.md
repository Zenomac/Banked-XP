# Banked XP

RuneScape 3 client plugin by **Zenomac**. Current version: **0.123.0**.

Shows banked XP estimates and supply-aware recipe choices for Herblore, Smithing, Crafting, Fletching, Archaeology, Farming, Firemaking, Cooking, Prayer and Construction. Coverage varies by item and method.

## Install

1. Download or clone this repository.
2. Copy the complete `banked-xp` folder into your client plugin directory.
3. Load or reload the plugin using your client's plugin controls.
4. Open your bank to scan supplies. Skill summaries calculate in the background.

The repository root is not the plugin folder: use the nested `banked-xp` directory.

## Features

- Bank-item hover XP estimates and selectable recipe methods.
- Supply-aware ingredient checks and shared method preferences.
- Level and optional boost filtering, with level-locked hover previews and coloured requirement warnings.
- Detected worn outfit and supported equipped-tool bonuses.
- Per-skill banked XP in native skill tooltips, above target information.
- Combined Banked XP below Bonus XP when hovering total XP, sharing supplies across skills.
- Archaeology artefact potential XP and separate supply-limited Ready XP.
- Experimental metal-bank and Archaeology material-storage scanning.

## Storage scanning

Open the normal bank, metal bank and Archaeology material storage once after loading. Recognized storage contents feed the recipe planner. Scan status remains available in relevant item details; unscanned storage makes the affected XP number red.

Metal-bank access uses the documented container. Archaeology container discovery still requires in-game verification. Unavailable containers can use their last session scan, which may become stale. Unscanned storage makes the affected skill's Banked XP number red. Diango-only outfits are not detected.

## Calculation limits

Totals use supported recipes and a deterministic greedy allocation of shared supplies within each skill. They are estimates, not a guaranteed global optimum or XP/hour claim. Different individual skill totals represent alternative uses of shared items. The total-XP hover instead uses one shared supply budget across supported skills; it includes Archaeology artefact potential assuming missing materials will be obtained. Stored bonus XP is not applied to the estimates.

## Version history

The current plugin version is **0.123.0**. [Complete changelog — v0.1 through v0.123](CHANGELOG.md) use the version in which each change was introduced. Historical entries may describe behavior superseded by later fixes; current usage is documented above.

## Development

The installable plugin, reference data and 29 Lua test suites are under [banked-xp](banked-xp). Development and audit documentation lives in [docs](docs); the complete version history lives in [CHANGELOG.md](CHANGELOG.md). Run each test in a separate Lua 5.4 process from that directory, for example:

```sh
cd banked-xp
for test in tests/*.lua; do lua "$test" || exit 1; done
```

All 29 local suites pass for this version. Native client appearance and API availability require live testing.

See the [API usage audit](docs/API_USAGE.md), [skill totals](docs/SKILL_TOTALS.md), [storage](docs/STORAGE.md) and [sources](docs/SOURCES.md) for details.

