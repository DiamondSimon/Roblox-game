# SCRAPYARD 0.3.2 — disposal lane, case presentation and test lab

Source, generated Studio place, tests and this documentation are committed together on GitHub. Patch increment: 0.3.1 → 0.3.2. Next release: 0.3.3. Save schema is now 5, independently of the release version.

## Shredder placement correction

The complete shredder now lives in a dedicated `ShredderAssembly` at the far end of an extended conveyor, centered at **(0, 1, 180)**. Previously its center was z=76, inside the central activity area. Every housing, motor, rotor, tooth, service deck, rail and control is translated together; there is no leftover center-map shredder. No BillboardGui/text is attached to the shredder assembly.

The belt runs from z=-60 to z=166. The flared feed starts around z=167 and feeds the cutters; junk is consumed at z=180. Belt speed is now 5.7 studs/sec, retaining approximately 42.1 seconds of pickup opportunity rather than lengthening the timer with the new belt. Server deadline validation, single pickup ownership, dropped-item expiry and shred effects remain unchanged. The plaza extends under the full disposal lane. The hopper still feeds the opposite end.

## Pet pictures and animated openings

Cases now show **rendered 3D pet previews** in the case browser and individual odds view. The owned/guaranteed-pet cards also have pictures, rarity-colored accent strips and readable descriptions. These previews use the actual species model factory through ViewportFrame + WorldModel + dedicated camera; there are no missing thumbnail IDs or external image dependencies.

A successful case transaction sends a CaseResult containing its case and awarded pet. A full-screen opening overlay scrolls an 18-card horizontal reel underneath a fixed gold marker, easing to a stop over four seconds. Slot 15 contains the already saved prize and finishes exactly centered. Each tile contains a pet picture, name and rarity. The remaining tiles are decorative examples sampled using that case's weights; they are not extra awarded pets or additional purchases. The existing disclosed purchase odds remain authoritative.

After landing, the winner's name, rarity and bonus appear. SKIP ANIMATION / CONTINUE closes the overlay and opens the pet collection. Skipping, closing or disconnecting never rerolls or awards twice: the debit and pet were committed before animation began. The reel makes no additional network purchase/grant calls. No deliberate near-miss substitution or hidden odds adjustment is used. Guaranteed pet purchases retain their immediate result rather than pretending to be random cases.

## Studio Test Lab

The **TEST LAB** button is shown only when the server reports a loaded, nonpersistent Studio practice session. Every action independently checks RunService:IsStudio(), Data:IsPersistent()==false, a loaded profile and server action cooldown. Published servers and Studio sessions with persistent data enabled reject the actions even if a client manually fires the remote. There are no live admin IDs, backdoor passwords or client-only permission checks.

| Control | Effect in practice only |
|---|---|
| +100,000 Scrap | Funds upgrades, floors, rebirth and Scrap cases |
| +1,000 Cores | Funds cases and cosmetics |
| 32 slots + 8 machines | Replaces practice inventory with eight sample machines and builds three upper floors |
| Finish tutorial | Enables post-tutorial gameplay tests |
| Reset daily claims | Resets practice spin and daily quest state |
| Toggle test pass | Toggles 2X Scrap or the additional eight-slot floor |
| Simulate product | Grants each configured Core pack, including hidden packs, through shared receipt fulfillment |
| Case eligibility Allowed / Restricted / Actual | Simulates either eligibility outcome only in nonpersistent Studio, or restores real policy lookup |
| Go to stand | Teleports to interaction distance of each shop; carried junk must be put down first |

The normal Supplies pass/product buttons also offer **SIMULATE • NO ROBUX CHARGE** in Studio practice. Real and simulated products share PurchaseService:Grant, including receipt-marker idempotency. The simulator uses isolated `studio:` receipt IDs and never calls a paid checkout. Legacy Scrap grants are accepted by the practice handler for their configured keys; Core products have visible Test Lab buttons.

This menu tests in-game rewards and behavior. It does **not** prove Roblox checkout, actual ownership verification, real Robux charges, refunds or published receipt delivery. All real purchase IDs remain zero/disabled. Test controls and simulated pet eligibility cannot affect a saved live account. Stop/Play resets the practice profile.

### Suggested test sequence

Open TEST LAB → add Scrap/Cores → finish tutorial → go to Pet stand → set test eligibility Allowed if needed → close Lab and interact with the stand → inspect pictures/odds → open each case in each currency. Use Restricted to verify denial/guaranteed fallback, then Actual to restore the account policy. Use Supplies simulation buttons to test pass effects and Core packs. Reset daily claims to replay the wheel. Fund a rebirth and confirm pets/claims persist while run progress resets.

## Additional simulator features

### Equip Best

One click equips the highest-bonus owned pet. Counts do not stack and unowned pets cannot be selected. Ties use the stable catalog order. Existing single-pet bonus rules and persistent equipment remain.

### Collection milestone gifts

| Unique scrap discoveries | One-time Core gift |
|---:|---:|
| 5 | 10 |
| 15 | 25 |
| 30 | 50 |

The REWARDS menu shows progress bars and claim readiness. Only server-recorded discoveries qualify. Claim marker and Core grant share one transaction. Repeated requests and rebirth cannot repeat a claimed gift. Milestones are lifetime collection goals, separate from daily quests.

### Redeemable release codes

`FOUNDRY` grants 20 Cores; `SCRAP032` grants 15 Cores, once per profile per code. Entry ignores case and whitespace. Unknown/already redeemed codes grant nothing. Codes and milestone claims persist through rebirth/rejoin. The two codes and all milestones supply 120 Cores total as one-time rewards; this is separate from daily income.

Redeemable codes are a familiar Roblox pattern, also advertised on the official [Criminality game page](https://www.roblox.com/games/4588604953/Criminality) and [Beatball game page](https://www.roblox.com/games/105452889569708/Beatball). Collection gifts, timed boosts and Equip Best were selected as familiar simulator/tycoon features fitting SCRAPYARD, without copying branded art or asserting their effect on retention.

### Scrap Rush

A server-wide event grants **+25% passive Scrap for two minutes every ten minutes**. The first event begins eight minutes after server start. A HUD badge shows the countdown and switches to the active bonus. It does not change case odds, sell prices, Core rewards, upgrade prices or movement speed. Full-cycle average income uplift is 5% if a player remains for the whole cycle with otherwise constant production. Pets, rebirth and passes multiply normally with the temporary event factor. Timing is server-owned and does not follow a client's clock.

## UI and map detail

- Pet previews and rarity strips, larger modals, outlined gradient buttons, stronger currency/notification contrast and revised HUD spacing.
- Dedicated case-opening presentation with a center marker, saved-winner reveal and skip action.
- Rewards/code panel with progress bars; Studio Test Lab; Equip Best and timed-event badge.
- Additional trees outside the yards, planter beds/shrubs, shop sidewalks/bollards, benches, service pallets/crates and conveyor guide lights.
- Decorations stay outside the shop entrances and the defined direct haul routes. Shop safe-zone behavior remains.

The UI and map are assembled from code-built Roblox primitives/UI elements. No Higgsfield generation or external art purchases were used. The spatial layout and preview construction are checked programmatically; this environment cannot render Roblox screenshots. Mobile raster layout, real 3D appearance, shadows and frame time remain Studio acceptance items.

## Data and validation

Schema 4 → 5 adds `Rewards={Codes={},Milestones={}}`, preserving all prior data. Fresh profiles get empty claim maps. Rebirthed profiles retain those maps and their discovered collection. Existing schemas migrate through the same chain. Unknown future schemas fail closed.

**65 automated tests pass.** Coverage now includes complete shredder translation/no overhead text/belt connection, Studio action rejection in live or persistent modes, pass/product simulation and duplicate fulfillment, practice policy isolation, daily/tutorial/loadout controls, code/milestone idempotency across rebirth, Scrap Rush timing/income, Equip Best ownership, schema-4 migration, preview cameras, reel winner position/skip behavior and Test Lab/code-entry callbacks. Existing save, receipt, gameplay, pet, combat and package parity tests remain passing.

The harness executes actual Lua source with mocked Roblox APIs; it is not a Roblox renderer, scheduler, physics engine or Marketplace server. Test status therefore does not promise zero defects. Remaining in-engine checks:

1. Walk along the belt and visually confirm its full path into the far-end shredder. Check that no shredder text or components remain at the old center position.
2. Open cases at 390×844, desktop and landscape. Confirm previews are recognizable, text/odds/buttons fit, reel stays clipped and the final pet lands under the marker. Skip mid-scroll and rejoin after award.
3. Listen to slap audio; test two-player combat, pet following and all upgraded-floor stairs around the added scenery.
4. Exercise the Test Lab only in practice, then verify it is absent/rejected in a separately published server and persistent Studio test session.
5. Use a separately configured private universe for real checkout, policy and durable receipt tests before enabling paid IDs.
6. Run an eight-player session to measure rendering/network cost, event balance, delivery contention and retention funnel behavior. No performance or retention results are claimed from the mocked tests.
