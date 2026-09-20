# V0.3 verification

## Executed locally

`python tools/build.py` packages all current source into SCRAPYARD-0.3.0.rbxlx. `python -m unittest discover -s tests -v`: **42 passing tests**. Source parsing uses Lua via Lupa, not Luau/Roblox execution. The startup harness uses narrow mocked Roblox APIs. `python tools/simulate_economy.py` generates eight synthetic 200-seed progression scenarios from shipped configs.

Coverage includes unpublished startup with no DataStore access; all 18 models; empty starter inventory/zero income; pickup/deposit/upgrade; competing pickup; protected replacement; dynamic eight-slot floors and pass capacity; 3 studs/sec belt motion, expiry and late pickup rejection; tutorial completion; carry/combat teleport blocks; slap range/line-of-sight/safe-zone/tutorial guards, single carry transfer and recovery; reclaimable drops; daily-spin odds boundaries, distance and once/day behavior; sale ownership/protected/duplicate handling; rebirth reset/preservation; schema 1/2 migration; lease contention, unknown schema, save failures and ambiguous transaction/receipt recovery; HUD/menu/waypoint callbacks; exact source parity inside the generated Studio place.

Mocks do not implement rendering, real scheduling/physics, streaming, network replication, DataStore throttling or Marketplace prompts. Tests that cover those APIs assert control flow only, not engine acceptance.

## Studio acceptance (not run here)

1. Open V0.3 and Play without publishing. Confirm bright visible map, eight compact yards, eight pads in your empty ground floor, zero starting currency/income and no base upgrade terminal. Inspect Output for errors.
2. Follow yellow guide. Pick a moving item; return it to green intake; SHOP teleport then walk to Upgrades to finish tutorial. Check guide after death/drop and respawn. Confirm income begins only after deposit.
3. Leave an item on belt: moves toward shredder, disappears at mouth with flash, no lingering prompt. Pick at last instant with two clients: exactly one owner, no duplicate/dead model. Inspect motion smoothness under network latency.
4. Run Studio Test with two players. Both finish tutorial, then approach outside safe zones. F/touch SLAP: victim falls and recovers, one carried item transfers, stored inventory stays. Test cooldown, repeated attacks, facing away, wall obstruction, protected tutorial player, spawn shield, safe shop/yard and disconnect while knocked down.
5. Test HOME/SHOP five-second cooldown, disabled while carrying/in combat, and valid landing heights. Walk up to each stand; move away before purchasing to confirm server rejection.
6. Earn/fund 3,500 Scrap in a test session, buy first floor. Count eight new pads. Walk every stair/landing up and down; check ceiling clearance and upper-floor placement. Repeat through all floors and verify entitlement floor in a separately configured test universe.
7. Sell a stored item and repeat its stale request: only one removal/payout. Confirm protected legacy item cannot be sold. Fill eight slots, replace after confirmation, cancel replacement.
8. Spin at stand: one durable Core award, animation/result match, second request blocked. Close menu mid-animation, leave/rejoin persistent test and retry. Verify UTC day rollover with a controlled test clock, not a production save edit.
9. Rebirth: cancel leaves everything; insufficient Scrap rejects; confirmed eligible reset removes run currency/unprotected inventory/upgrades and collapses floors, preserves Cores/cosmetics/dailies/receipts/pass/discoveries and grants 5% bonus. Repeat stale confirmation cannot reset again without new eligibility.
10. Mobile emulator 390×844 and landscape: no overlap/cut-off objective, currency/buttons readable, scrolling and confirmation accessible, SLAP clear of Roblox jump controls. Test touch pickup and streaming at both extremes of map.
11. Separate published private test universe: migration with schema 1 and 2 fixtures, lease contention, rejoin after transactions and receipt retries. Real-money prompts remain disabled in the shipped build. Never enable production API access merely to test fresh balance.
12. Eight-player session: measure salvage contention, tutorial success, frame/server time and first-upgrade/floor/rebirth pacing. Adjust based on observed results. No FPS/retention target is claimed satisfied by the mock tests.
