# SCRAPYARD 0.3.1 — pets, audio and salvage expansion

This document, source, tests and Studio build are committed together in GitHub. Release increments are patch-only from this point: 0.3.0 → 0.3.1 → 0.3.2. Earlier published filenames/history are retained. Save schema numbering is independent of release numbering.

## Pet workshop

The sixth stand in the shared shop district sells immediately opened pet cases for either Scrap or Cores. Inspect all individual outcomes, rarities, bonuses and exact odds, then confirm the chosen currency. One transaction charges the displayed amount and grants one pet. There is no unopened-case inventory. The HUD PETS button opens your collection; equip/unequip works anywhere, but buying requires being within 15 studs of the Pet stand. The shop safe zone now extends 140 studs from its arrival point to include this stall.

One equipped pet applies a passive multiplier to machine earnings: **final income = previous machine/upgrade/rebirth/pass income × (1 + equipped pet bonus)**. Bonuses range from 3% to 20%. Pets do not create Scrap when your yard is empty. Copies are counted, but do not stack bonuses or convert to currency. A newly received stronger pet auto-equips; equal/weaker pets do not override the current pet. Manually select a different owned pet or unequip from PETS. Pets cannot be slapped away, sold, traded or lost on rebirth.

Each equipped companion is visible following its owner. Nine distinct primitive models feature species-specific ears, tails, wings, eyes and colors. Client motion interpolates at 20Hz, bobs gently and culls beyond 180 studs. Models are cosmetic and noncolliding; the server owns bonus calculations and equipped identity. Models disappear/reappear with owner availability/respawn/streaming and clean up on leave.

## Catalog

| Pet | Rarity | Passive bonus | Guaranteed Scrap price |
|---|---|---:|---:|
| Bolt Mouse | Common | +3% | 1,200 |
| Tin Cat | Uncommon | +5% | 1,800 |
| Spring Dog | Rare | +8% | 3,000 |
| Magnet Fox | Rare | +8% | 7,000 |
| Welding Owl | Epic | +12% | 9,000 |
| Steel Tiger | Legendary | +16% | 35,000 |
| Plasma Dragon | Epic | +12% | 14,000 |
| Crane Griffin | Legendary | +16% | 65,000 |
| Cosmic Serpent | Mythic | +20% | 140,000 |

Guaranteed purchases give that exact pet for Scrap, with no random outcome. Already-owned pets cannot be bought again through the guaranteed path. This also provides access when random cases are unavailable for the account.

## Cases

| Case | Scrap OR Cores | Individual outcomes | Mean bonus of one draw |
|---|---|---|---:|
| Salvage Case | 500 Scrap OR 25 Cores | Bolt Mouse 60%; Tin Cat 30%; Spring Dog 10% | +4.1% |
| Industrial Case | 3,500 Scrap OR 100 Cores | Magnet Fox 60%; Welding Owl 30%; Steel Tiger 10% | +10% |
| Prototype Case | 15,000 Scrap OR 300 Cores | Plasma Dragon 60%; Crane Griffin 35%; Cosmic Serpent 5% | +13.8% |

Better tiers have higher minimum and average bonuses. These expectations describe a single draw, not additional income from every subsequent case. Owning duplicates or already having a stronger pet can make a later case provide no income improvement. There is no pity system, luck modifier or hidden change to odds. Every case has three outcomes totaling exactly 100%; odds remain fixed because duplicate copies are allowed. Collection limit is 10,000 copies per pet; a case is blocked before charging if any possible outcome is at the limit.

## Random purchase eligibility and transaction safety

Cores can be purchased, and legacy Scrap products exist, so both currencies use the same conservative server eligibility check. PolicyService must explicitly return ArePaidRandomItemsRestricted=false. Missing policy, API errors or restricted responses block cases without charging. A five-minute policy cache is refreshed on expiry; reopening the Pet stand retries failed checks after 30 seconds. The server rechecks data and distance after a policy request yields. The UI explains that guaranteed pets remain available. There is no trading.

Each case offer carries a server-generated token. A successful purchase attempt consumes it before the save begins, so repeating the same confirmation cannot charge twice. Random selection happens once before Data:Commit; retries save the same result. Charge and award share one profile write. Ambiguous transaction failure freezes the session and requires rejoin rather than risking duplicate rewards or overwriting a successful save. No real-money product ID is enabled by this release.

References: [Roblox paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items) and [PolicyService](https://create.roblox.com/docs/reference/engine/classes/PolicyService). Exact individual odds are visible before either currency confirmation; eligibility is enforced on the server.

## Slap sound

A confirmed SlapFX event now plays a short spatial impact sound at the victim. It uses Roblox-bundled `rbxasset://sounds/impact_water.mp3`, pitched to 1.8× and cut at 0.22 seconds, volume 0.7, maximum audible distance 65 studs. It is a provisional splat/impact treatment rather than a custom uploaded hand-slap recording. No unverified external audio ID or upload permission is needed. Configuration lives in AudioConfig; sound and visual effect clean up together. Misses do not emit a hit sound. The mock suite verifies the playback call; actual timbre/volume/first-hit loading must be auditioned in Studio.

## More salvage and improved shredder

Twelve new scrap types bring the catalog to 30: Burnt Toaster, Washing Machine, Rusty Refrigerator, Desk Fan, Mechanic Toolbox, Tire Stack, Chemical Drum, V8 Engine Block, Satellite Dish, Arcade Cabinet, Cargo Drone and Jet Turbine. Each new type has a distinct primitive silhouette/detail construction in MachineService, including drums, handles, tire rings, engine banks, dish/receiver, arcade controls, rotors and turbine blades. Existing IDs and inventory stay valid.

Spawn weights are normalized within each rarity to preserve the previous aggregate rarity chances. Individual old-item chances change because more items share the pool. All new junk supports the existing conveyor/carry/place/sell/collection paths.

| New scrap | Rarity | Base Scrap/sec | Sell value |
|---|---|---:|---:|
| Burnt Toaster | Common | 0.4 | 8 |
| Washing Machine | Common | 0.75 | 15 |
| Rusty Refrigerator | Uncommon | 1.3 | 26 |
| Desk Fan | Common | 0.5 | 10 |
| Mechanic Toolbox | Common | 0.7 | 14 |
| Tire Stack | Common | 0.45 | 9 |
| Chemical Drum | Uncommon | 1.4 | 28 |
| V8 Engine Block | Rare | 2.8 | 56 |
| Satellite Dish | Rare | 2.4 | 48 |
| Arcade Cabinet | Epic | 3.8 | 76 |
| Cargo Drone | Legendary | 5.5 | 110 |
| Jet Turbine | Mythic | 8.2 | 164 |

The shredder now has two counter-rotating shaft models, fourteen cutter discs and 84 hook teeth, ribbed drive motors, flared feed walls, service decks, safety rails, striped warning beam, control box, stop button and status lamp. Rotation moves the entire shaft assembly locally, including teeth, and is distance-limited. Conveyor timing and authoritative deletion remain unchanged: 3 studs/sec, 42-second full trip. The control box/stop button are visual details, not player-operable stop controls. Rotor parts do not collide with players.

## Persistence and rebirth

Schema 3 migrates to **schema 4** by adding `Pets={Owned={},Equipped=""}`. Earlier schemas still migrate through the existing chain. No starter pet or junk is granted, and no prior currency, inventory, floor, quest, spin, receipt, rebirth or collection data is reset. Pet IDs/counts and equipped ownership are validated. Pets and their bonuses survive rebirth, while existing run-reset rules remain. Verified equipped identity is republished on join for companion rendering.

## Validation

**54 automated checks passed** using actual Lua modules plus mocked Roblox services, including all 30 scrap models, nine pet models, client companion lifecycle, slap audio invocation, rarity budgets, case outcome boundaries, token replay, prices/currencies, policy failure/recovery, out-of-range purchase rejection, direct guaranteed purchases, single-pet income math, rebirth preservation, schema migration and ambiguous durable awards. XML source parity confirms the Studio file embeds current source.

Additional balance scenarios use the expanded catalog; ECONOMY_0.3.1.md documents assumptions. These are not observed player behavior. Roblox engine rendering, real spatial audio, PolicyService behavior on test accounts, animation smoothness and published persistence still need Studio/private-universe acceptance.

### Studio acceptance additions

1. Listen to a confirmed hit nearby and at 65+ studs; misses must not sound. Adjust AudioConfig after listening if desired.
2. SHOP → Pet stand: review all odds; buy once using each currency; confirm exact debit, reveal and stronger-pet auto-equip. Repeat the same request token: no second debit.
3. Equip every species, unequip, respawn, teleport and observe with two clients. Check no collisions with carried junk or stairs.
4. Confirm duplicates increase copy count without stacking bonuses; empty yard remains zero income.
5. Test restricted/error PolicyService paths in a separate test environment: random buttons unavailable, guaranteed purchases work, retry after API recovery. Never bypass live eligibility.
6. Persistent private test: rejoin after buying/equipping and after rebirth; verify pets and currency. Simulate failed save responses before enabling any paid product IDs.
7. Inspect new scrap silhouettes on conveyor and floor, both rotating cutter assemblies and readability of the new stand on phone layouts.
