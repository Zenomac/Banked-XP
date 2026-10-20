# Hover performance investigation: 0.47

Compared 0.45 and 0.46. The added decanting bookkeeping did not explain the stall in a pure Lua benchmark. The live client cannot be run in this test environment, so the specific native-client trigger remains unconfirmed.

Repeated work identified and removed:
- Font layout measurements now reuse a single cached result keyed by content, native font metrics and dimensions.
- Border segments update only when geometry changes; border movement follows the cursor separately.
- Recipe search trials copy only their relevant bank ingredients, rather than every bank item.
- Snapshot cache identity uses the inventory container ID when provided, so changing proxy wrappers do not force a full bank read.

Synthetic bank: 1,126 item names, including all recipe inputs and 800 unrelated items. 20 full snapshot refreshes/estimates for Vial of water:

| Version | Seconds |
| --- | ---: |
| 0.45 | 5.446 |
| 0.46 | 5.262 |
| 0.47 | 0.471 |

This measures local Lua work, not game FPS. The 0.47 recipe benchmark is about 11 times faster than 0.46 for this workload. Repeated cached estimates took approximately 0.18 seconds for 100 calls.

The mock native hover test exercised 100 unchanged Draw frames and confirmed no further native font measurement calls or border segment position/size writes. Content/size changes invalidate the layout cache. Cursor movement, text wrapping, independent note lines and restoration passed regression checks. All 251 recipes and the full ingredient/level/settings/shared-selection checks passed.

Test the same item in the beta client to confirm that the reported frame stalls are resolved. Native component resizing still occurs during draw so the client retains control of cursor placement.
