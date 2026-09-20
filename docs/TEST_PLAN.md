# Verification and next gate

## Automated checks performed

11 tests pass: source parse, catalog/economy checks, failed load, competing lease, release/rejoin, expired-lease write rejection, failed-save recovery, receipt deduplication/rejoin, receipt retry, ambiguous receipt recovery after autosave, unsupported schema preservation. Tests use Python/Lupa and mocked Roblox services; they do not run Studio or Roblox networking.

The generated place is XML-parsed and checked for all embedded source scripts. No Studio render or device benchmark has been performed.

## Required Studio / private experience tests

- Play: one assigned yard, one starter radio, increasing Scrap.
- Collect and deliver: prompt works with keyboard and touch; machine follows player; owned count increments once; income changes.
- Full capacity: additional pickup refused, storage upgrade creates capacity.
- Income upgrade: charges once, fails with insufficient funds, increases income by 15% of base, respects cap.
- Two clients: distinct yards; simultaneous pickup yields only one carried model; other players cannot deposit into or upgrade your yard.
- Reset while carrying; leave while carrying: model removed, no ghost owner, normal speed on respawn.
- Phone portrait/landscape: HUD, modal, prices and prompts remain readable; controls not obstructed; measure actual frame rate.
- Published private game: collect/upgrade, wait 35 seconds, rejoin, verify restore.
- Fail DataStore/unknown schema: no writable default profile; no overwrite.
- Configured low-cost test product: one grant, correct current price, persistence, reconnect and duplicate receipt recovery.
- Configured passes: verified entitlement activates and survives fresh server join.

## Known release blockers

No stealing, fusion, mutation system, full-yard item replacement, retention systems, analytics delivery, custom hero meshes, audio, movement auditing or mobile performance profiling. Purchase IDs remain unset. First playable foundation must not be described as the complete commercial MVP.
