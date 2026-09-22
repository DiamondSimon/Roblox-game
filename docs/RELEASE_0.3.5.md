# SCRAPYARD 0.3.5 — operational scrapyard and stronger progression purchases

## Delivery

Open `build/SCRAPYARD-0.3.5.rbxlx`. Source, tests, simulations and this release are committed together. 0.3.4 remains archived and is not overwritten (SHA-256 `6215682d633320f888873eb21f927d5d14ed69a4460ed8dde0ed738727900b4b`). Save schema is now 7. Marketplace IDs remain 0 and purchases remain disabled until real IDs are configured. Studio TEST LAB can simulate the new benefits without charging Robux.

## Conveyor and shredder — one coherent system

Only the shredder assembly moves in this patch. The belt, hopper, shops, approach roads and all eight yards retain their 0.3.4 coordinates. The 450-stud belt deck runs from Z=-224 to Z=226. Its physical termination now exactly touches the receiving edge of the 24-stud-long shredder base: center Z=238, front Z=226. The complete cutters, walls, motors and service platforms follow this adjustment. There is no text above the shredder.

Junk starts at Z=-224, moves toward positive Z at 11 studs/sec, and reaches the cutter throat at Z=238 after exactly 42 seconds. At expiration the server explicitly pivots the model to that throat before deletion, then broadcasts destruction effects at the same physical machine. Late pickups are rejected using the same expiry. Dropped junk still expires after 25 seconds without a shredder effect. Existing equal yard-to-belt access and approach-corridor tests remain active.

## World quality and motion

Added a framed vehicle compactor with moving hydraulic press, a furnace with two tall smokestacks and warm opening, a layered scrap mountain with a cyan recycling core, stored pipes, barrels and utility cabinets. Enlarged the existing moving magnetic head for a stronger crane silhouette. These occupy off-road gaps between the existing approaches. No terrain expansion or yard relocation.

One client scheduler handles presses, warning beacons, steam outlets and motor ambience. Presses are noncolliding decorations; motion runs at 10 Hz within 170 studs. Existing fans, crane and 20 Hz belt/rotor animation remain. Steam is disabled at distance. Sparks use a maximum of three concurrent bursts (at most 30 tiny anchored parts), with short cleanup timers and a 150-stud cutoff. No independent scripts per prop, external textures or physics debris.

Shredder additions: flashing beacons, subtle exhaust, nearby motor loop, eight destruction sparks and short grinding fallback. Rare+ spawns receive colored sparks and neon model cores; Epic+ adds a short cue; Legendary/Mythic/Secret retain server announcements, with lower-pitched high-tier cues. Common and Uncommon spawns stay quiet. Scrap Rush announces its start, changes beacon cadence and flashes belt treads.

Lighting moves to readable late afternoon (16.5), warm atmospheric haze, restrained bloom and saturation. Shadow fill remains bright enough for silhouettes. No FPS or engine-rendered screenshot claims: Studio checks are still required.

Audio uses bundled Roblox files as temporary, pitch-adjusted timbres. Motor/swim and grinding/impact fallbacks are not bespoke industrial recordings. All files, volumes and pitch choices are in AudioConfig; playback, asset availability and timbre must be listened to in Studio before launch. No copyrighted recordings or invented asset IDs were added.

## Permanent passes

| Pass | Benefit |
|---|---|
| 2X Earnings | 2× all passive machine income |
| Extra Yard Space | One permanent eight-slot bonus floor, existing maximum 40 slots |
| VIP | 1.15× income, visible gold VIP yard sign/intake, 5 Cores per UTC day |
| Salvage Luck | 1.5× eligible Uncommon+ weight on the owner's sponsored luck rolls |

No extra pet slot, pet-luck multiplier, paid rare-machine product or paid spin was added. VIP claims use an atomic persisted day marker and survive rebirth. VIP does not increase movement speed. The existing 3–20% pet bonus and +5 percentage points per rebirth remain.

Pass cards show benefits, PERMANENT status, recognizable symbols for the main earnings/VIP/luck passes, owned state and MarketplaceService prices. No Robux prices or product IDs are fabricated. Core packages (80, 250, 600, 1,400, 3,000) now appear in their separate tab, with exact received quantities. All actual checkout still requires configured IDs, monetization enabled and persistent sessions. Studio simulations are explicitly labeled.

## Core sinks and durable timers

| Boost | Core price | Duration | Effect |
|---|---:|---:|---|
| Personal income | 30 | 15 minutes | 2× income |
| Personal luck | 25 | 15 minutes | Same 1.5× eligible weighting as the luck pass |
| Server luck | 80 | 15 minutes | 1.5× Uncommon+ weighting on eligible sponsored rolls |
| Server Scrap | 100 | 15 minutes | 1.25× passive income for the server |

Buy at the Supplies stand through its BOOSTS tab. Core debit and expiry timestamp commit together. Timers use UTC wall time and continue offline; rebirth preserves them. Buying an already active boost is rejected without charging and does not extend its duration. Personal luck and permanent luck use the same benefit rather than multiplying. Personal plus server luck caps at 2× weighting. Server Scrap and Scrap Rush use the larger effect rather than multiplying.

Successful server boosts announce the buyer's display name. The buyer's durable expiry restores the remaining server benefit on rejoin, including joining a different server; it never starts a fresh 15-minute duration. The original server can retain its remaining benefit too. This intentional social carryover cannot extend the saved expiration. Other players do not permanently receive a saved entitlement.

Free progression remains useful: full daily contracts pay 40 Cores after Rare access; first-run players can complete 28 while the Rare contract is locked. The free spin averages 8/day, so daily expected budgets are 36 initially, 48 after Rare access, and 5 more with VIP. Codes and collection gifts are additional one-time rewards. A small boost is roughly one daily set; larger shared boosts take multiple sets. No quest reward inflation was necessary.

## Shared luck, exact odds and eligibility

The conveyor is contested, not a private loot award. Every other spawn is an unchanged FREE roll. The other rolls rotate sponsorship across connected players; an eligible sponsor's pass/boost can improve weighting among their unlocked rarities. Server luck affects those eligible sponsored rolls. Higher locked tiers still appear aspirationally; boosts never override collection gates. Luck purchase descriptions must not imply exclusive ownership or a guaranteed item.

An odds screen lists all 30 items and numerical FREE, PERSONAL, SERVER and BOTH roll percentages. Players can inspect every rebirth level before confirming Core luck or opening the pass purchase prompt. Percentages derive from the same shared SalvageOdds weight function as the server, including the 2× cap. Rounding is to five decimals; displayed rounded totals may differ slightly from 100%. Displayed distributions describe that sponsored roll, not the guaranteed probability of collecting an item in multiplayer.

PolicyService is reused with fail-closed eligibility. Luck spending and pass effects are disabled for restricted/unknown accounts. Normal free rolls continue for all players. Enhanced rolls carry PaidLuck provenance; ineligible users cannot pick those up. Provenance survives drops and slap transfers. Transfers also require both players' IsPaidItemTradingAllowed permission; dropped paid-origin salvage records its owner, preventing drop/reclaim from bypassing transfer restrictions. Expired policy caches disable enhanced access until refreshed. This patch does not add any trading of stored junk.

Reference checked 22 September 2026: [Roblox paid random items guidance](https://create.roblox.com/docs/production/monetization/paid-random-items), including paid odds modifiers and PolicyService treatment. Private published acceptance with restricted and unrestricted Player Emulator settings remains necessary before enabling purchases.

## Rebirth and UI

The rebirth panel now shows current → next count, current → next permanent income bonus, exact cost, funding percentage, an actual model preview for newly unlocked tiers, and explicit RESET/KEEP cards. Existing confirmation remains mandatory. World item labels spell out REQUIRES REBIRTH instead of the abbreviated RB label. Selling, replacement and collection retain actual model pictures and now use compact currency formatting.

Right-side navigation is preserved; HOME/SHOP controls remain at the top. Supplies has separate PASSES / CORES / BOOSTS / STYLES tabs. VIP daily claims live in Rewards. TEST LAB can toggle all four passes and increment test rebirths (nonpersistent Studio only). No new normal-player development menu.

## Save changes

Schema 6 → 7 adds `Boosts={}` (UTC expiry per configured key) and `VIPDay=-1`. No repeat Scrap conversion. Inventory, balances, pets, cosmetics, claims and receipt markers remain. Schema 5 and earlier still pass through the earlier currency migration exactly once. Boost and VIP transactions use the existing durable commit/freeze-on-ambiguous-error behavior, with validation of boost names and finite nonnegative expiries. Older builds reject schema 7; preserve a pre-migration backup if testing rollback.

## Economy validation

[Monetization scenarios](ECONOMY_0.3.5.md), [first-run baseline](ECONOMY_BASELINE_0.3.5.md), `monetization-simulation.json`, `economy-simulation.json` and `rebirth-simulation.json` document the assumptions and results. Run all three tools/simulate_*.py scripts.

The new simulation tests FREE, 2X, VIP, 2X+VIP, best pet combinations, one 15-minute boost and sustained maximum stress at every rebirth level. It records first upgrade, first floor, next rebirth and ending Scrap/sec. Maximum stress assumes all rolls receive maximum eligible luck, unlimited boost funding and extra space, so it is deliberately more favorable than the shipped alternating/sponsored luck. Median first rebirth: average free ~30 minutes; sustained maximum ~11.2 minutes. Sum of independent median runs: ~14.4 hours free versus ~4.6 hours maximum. This is a planning comparison, not an optimal-retention claim or a median of complete histories. No five-minute completion in these scenarios; actual multiplayer competition, optimized strategies, paid adoption and retention require playtesting.

## Asset/credit decision

Higgsfield 3D model capabilities were inspected read-only. No generation submitted and no credits spent. Current mechanical landmarks use primitives because known scale, separated moving components and predictable collision are immediately usable in the place. An imported hero mesh would still need Roblox upload, texture/polygon/collision review and an owned asset ID, which cannot be completed in this environment. See assets/asset-manifest.md for briefs and budgets. No generated mesh or GLB import is claimed.

## Checks and remaining acceptance

87 automated tests pass against actual Lua with mocked Roblox APIs, plus source/build parity. Coverage includes the entire previous suite, exact belt/throat alignment, unchanged yards, approach clearance, VIP income/theme/daily deduplication, Core debit and expiry, no active-duration stacking, income-stack ceiling, invalid requests, migration/ambiguous saves, normalized luck weights/caps, restricted pickups/slaps/drops, odds/boost/rebirth UI execution and distance-culled press animation.

Roblox Studio cannot run in this environment. Test the exact 0.3.5 place in Studio for geometry, all approach and shop routes, streamed animation, mobile card layout, audio quality, low-end device FPS, 2-player luck transfer rules, real persistence and configured Marketplace checkout. Do not treat mocked execution as a Roblox physics/render/performance test. No public Roblox publishing performed.
