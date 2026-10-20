# API usage audit — v0.112

The plugin makes no HTTP requests. RuneScape Wiki URLs in the bundled recipe data are references, not fetched endpoints. Recipe XP lookups use client config parameters; inventory, player and UI reads access the local client API. This audit covers the plugin itself, not networking internal to the game client.

## Read scheduling

- Bank counts and slots share a cached read for 25 Logic ticks (approximately half a second), with invalidation for changes. Summary capture reuses those slots.
- Known storage inventory events are queued by storage kind and read once on the next Logic tick. Periodic discovery/refresh is a fallback every 250 Logic ticks (approximately five seconds).
- Outfit inventory reads use their existing 25-tick cache. Recipe discovery remembers observed item IDs; XP validation uses local config data.
- Skill summaries run incrementally in Logic, rather than recalculating in Draw. Existing content/layout caches remain active.
- Skill tooltip discovery now uses the confirmed native paths. The obsolete broad fallback search was removed. Native tooltip work still runs on Draw so it follows the cursor and restores correctly.

## Controlled checks

The API-usage regression test simulated 500 Logic ticks: each of two available storage containers was read twice. A burst of 100 updates for one storage container produced one read on the next tick. A bank snapshot followed by summary slot access produced one GetSlots call. 600 idle skill-hover frames performed 4,800 direct component lookups (eight per frame), with no broad fallback scan. A mocked HTTP object rejects access on these paths.

All 28 suites pass. These tests verify scheduling and cache reuse in controlled mocks, not actual in-game FPS or every client-internal operation. Missing or differently exposed storage containers can require extra discovery lookups. Retaining local UI checks and periodic fallbacks preserves functionality when native UI or inventory events change.
