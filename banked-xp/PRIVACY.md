# Banked XP: local data and permissions

Version 0.145.0. Updated 20 October 2026. Independent community plugin by Zenomac; not an assertion of Jagex endorsement or approval.

## Publication status and contact

This notice describes the development build. Publication is blocked until the author supplies a monitored contact email and completes their legal and provenance review. The manifest's example@example.com is a placeholder, not a working support or privacy address. Do not submit this placeholder to Mod.io.

## What the plugin reads and why

Banked XP reads your API-exposed bank, backpack, worn equipment, recognized metal/Archaeology storage, skill levels and XP, and relevant visible tooltip text. It uses these to estimate XP, available recipes, required levels and detected equipment bonuses. Recipe definitions come from bundled public factual data and client configuration. Optional chat access adds a local Diango reminder; the plugin does not read chat history or send chat messages to other players.

The plugin does not collect account credentials, character identifiers, other-player profiles or chat conversations. It has no HTTP calls, analytics, remote server, advertising or payment functionality. No information is transmitted to Zenomac or another external endpoint by the plugin. Developer-console errors can be retained by the client; review logs before voluntarily sharing them.

## Storage and retention

Gameplay observations and calculated totals are held in memory during operation. Unload the plugin or close the client to release that plugin instance's memory. No bank quantities, skill XP or outfit ownership records are saved by the plugin to PersistentDB.

Only settings and selected recipe preferences persist locally, under xpSettingsV1, xpMethodsV1 and xpSharedMethodsV2. The client isolates these records per plugin; preferences may be shared between characters using the same device/client type. They remain until cleared. Local client files and backups remain subject to the user's device security and Jagex's client behavior.

## Clearing your data

Open Banked XP settings and activate **Clear saved preferences (resets settings).** This deletes the three saved preference records and restores defaults in memory. It immediately unticks itself. Check the developer console for success or failure; retry if deletion fails. Then disable/unload Banked XP to release session observations. Perform this before uninstalling. Deleting only the plugin folder is not a verified way to erase the client's persistent database. Other running client instances can retain old preferences; close those before clearing.

You can stop processing by disabling the plugin. The developer has no remotely held player database to export or delete. The author must supply contact details and confirm the applicable lawful basis and user-rights wording before public release. Jagex's processing of account data is separate from this plugin's local processing.

## Permissions

Required permissions: none. Optional chatAccess: one local informational Diango reminder after activation/login when permission is granted. Refusing access leaves XP estimates available. No HTTP permission or network endpoints are requested. Permission checks fail closed if unavailable.

## Terms

Use is subject to the Jagex EULA, including Schedule 4, applicable plugin guidelines, and mod.io terms where applicable. This document does not impose an alternative plugin licence.

- https://legal.jagex.com/docs/terms/eula
- https://developer.runescape.com/rs/submission/guidelines.html
- https://developer.runescape.com/rs/submission/process.html
