# Release 0.3.4 — fair approaches, moving belt, rebirth rarity unlocks and visual inventory

## Corrected map layout

0.3.3 moved the whole conveyor south, which was the wrong interpretation of the requested shredder fix. This release restores the central lane and extends it alongside all eight yards. Belt bounds are Z=-224 to 226; shredder center is Z=240, at its end. Each intake is X=±304, with a straight approach to the belt at its own yard Z (-210, -70, 70, 210). Thus the nearest belt is the same lateral distance from each yard. Spawn locations also retain equal lateral distance. This is geometric access parity, not a guarantee of equal access to each contested moving item; entry-end players can still intercept items first.

Haul paths now run straight at each yard's Z. The shop plaza and stalls move 100 studs north, together with their spawn and nearby furniture, to keep the hopper separate. The restricted gate moves north as well. Low obstacle bounds are checked across every 14-stud-wide interior approach corridor. Existing containers sit outside these corridors.

Twelve off-road scenery groups add 132 parts: rusted scrap heaps, scattered metal, trees and bushes. They occupy spaces between the four roads, away from the conveyor and bases. Decorations are not collectible inventory. Existing ambient landmarks and outer trees remain.

## Moving conveyor

Visible metal treads move toward the shredder at 11 studs/sec, matching junk motion. The longer full junk transit remains about 42.2 seconds; unwanted junk is deleted at the shredder. Client animation handles streamed tread additions/removals and updates at 20 Hz without moving the solid belt under characters. Shredder rotor effects remain. The shredder has no overhead label.

## Rarity progression

| Rarity | Required rebirths |
|---|---:|
| Common / Uncommon | 0 |
| Rare | 1 |
| Epic | 2 |
| Legendary | 3 |
| Mythic | 5 |
| Secret | 8 |

Requirements are server enforced for belt pickups, reclaiming dropped items, direct carry creation and slap transfers. A locked item stays with the knocked-down victim instead of disappearing or passing to an ineligible attacker. World junk labels show the requirement; collection cards show LOCKED plus the required count. Tutorial waypoints only target eligible salvage. Collection previews show future unlocks. Global spawn weights are unchanged, so locked finds can pass a player and be collected by someone eligible.

Previously owned stored items keep their production and can be sold; this patch does not confiscate existing inventory. Rebirth still clears ordinary inventory. Save schema remains 6; no additional currency conversion occurs.

## Economy and pacing

Large displayed and actual income values from 0.3.3 remain, as do modest upgrades and empty starting yards. First rebirth remains 25 million Scrap. Cost grows 2.5× through rebirth count 3, then 1.65× thereafter. This corrects the old late-stage curve, whose independent-run simulation often exceeded six hours after adding rarity gates.

Formula: floor(25,000,000 × 2.5^min(count,3) × 1.65^max(0,count-3)). Rebirth bonuses stay +5 percentage points each, maximum 10 rebirths. Higher rarity unlocks are the main new reward.

[First-run scenarios](ECONOMY_0.3.4.md) use 200 seeds per scenario and reject locked candidates: median free first rebirth eligibility is 44.8 minutes for new, 29.8 for average and 21.9 for efficient collectors. Average with 25% lost deliveries is 33.6 minutes. These are planning estimates, not measured retention or an optimal engagement claim.

[Later-run results](rebirth-simulation.json) use 200 independent fresh runs at each rebirth level, average collection (first delivery at 75 seconds, then every 75 seconds, three weighted candidates), rarity gates, eight starting slots, one added floor, the documented upgrade sequence, Scrap Rush and permanent rebirth bonus. No pass, pets, selling, PvP, travel physics, inherited protected items or offline earnings. Runs stop at six hours. Results are per run, not cumulative time to that rebirth; real multiplayer scarcity can make progression slower. Reproduce with tools/simulate_rebirths.py. Compare observed first delivery/upgrade/floor/rebirth times in a real playtest before tuning further.

## Visual menus

Junk cards use live 3D ViewportFrame pictures from MachineModelFactory, the same geometry used in the world. Previews appear in selling inventory, sale confirmation, full-yard replacement choices, replacement confirmation and all 30 collection entries. Each preview has its own camera and WorldModel; cards expand to fit the picture, description and action. Pet/case menus retain existing model previews and opening reel. Prices, item names and destructive-action confirmations remain visible. No external image assets or paid generation are required.

## Verification

76 automated tests pass using actual Lua with mocked Roblox APIs. New checks cover equal yard approaches and low-obstacle clearance, rarity thresholds/drop/slap enforcement, model previews in all five junk menus, belt tread motion and streaming removal, and bounded late rebirth cost growth. Existing startup, receipt, migration, pets, tutorial, UI, conveyor expiry and build parity checks remain active. Updated old geometry assertions reflect the corrected layout.

Roblox engine execution and rendered screenshots are unavailable here. Before publishing, open SCRAPYARD-0.3.4.rbxlx and check all eight approach routes, north shop access, moving treads/rotors under StreamingEnabled, junk preview framing at desktop/mobile sizes, and a two-player locked-item slap. Test persistence and real Marketplace flows privately. No public Roblox publishing or paid art generation performed.
