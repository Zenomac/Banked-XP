v0.111: Temporary runtime debugging has been removed. Earlier instructions in this document asking for [BXP total probe], [BXP storage], [BXP artefact], [BXP audit] or [xp-data] console output are historical and no longer apply. Known storage detection, native rendering, calculations and useful error reporting remain active. All 27 current local suites pass.

# Historical v0.96 diagnostics

This document describes the v0.96 diagnostic build. Native skill rendering returned in v0.97; later versions use the renderer described in NATIVE_SKILL_RENDERER.md.

Install the complete folder and reload. Open the bank once to capture supplies. Background work is incremental; its completion prints ten [BXP audit] lines. Then hover a supported skill briefly. [BXP probe] and [BXP frame] lines report the actual skill-tooltip text IDs, fonts, positions and native frame geometry. Each skill is logged once per plugin activation to avoid continuous logging.

Skill tooltips are intentionally unchanged. The removed skill_row module remains absent. Skill probing does not register a Draw callback or mutate native UI. The bank-item tooltip module continues to operate as before.

For a skill that reports zero, matched=0 suggests no recipe mapping for the scanned supplies; a missing level or level-blocked matches indicate eligibility problems; complete=0 with eligible matches suggests missing ingredients/whole batches. A positive complete count with zero XP needs allocation investigation. Prayer and legacy Maple bonfire totals can exist outside engine recipe counts. Unmapped plank/protean names are logged separately. Current coverage and unscanned-container limits still apply.

Validation: all 26 local suites pass. The skill-probe regression verifies Logic-only registration and rejects native UI creation or writes. Construction supply lookup is also exercised without a catalogue match. These mocked tests cannot establish native client crash safety.
