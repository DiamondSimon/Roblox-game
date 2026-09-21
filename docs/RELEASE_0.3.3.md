# Release 0.3.3 — conveyor relocation, readable landmarks, larger economy

## Map correction

0.3.2 extended the conveyor but left its original centerline placement. This release moves the complete conveyor district 130 studs south: belt center Z=183, pickup start Z=70, shredder center Z=310. Hopper, rollers, rails, lights, plaza and all shredder components move together in ConveyorAssembly. Actual junk spawn/movement/deletion use the relocated start/end, with the same 5.7 studs/sec travel and approximately 42-second full transit. Haul paths and the tutorial fallback lead to the new lane. The shredder has no overhead text. The train rails remain beyond the shredder at Z=325/333.

World point-of-interest labels use a vertical world-space offset based on half the structure height plus seven studs, with AlwaysOnTop enabled. Shop titles sit at Y=22 above Y=14 canopies; the daily wheel title is higher to separate it from the Spin title. Warehouse, water-tower and restricted-gate names now anchor above their roofs. Machine labels override the default offset separately.

## Economy

Actual currency values changed, not just display text. Common machine income is 1,000 times its former value; higher rarities have progressively larger rewards. Spawn rarity budgets are unchanged.

| Rarity | Base income per second |
|---|---:|
| Common | 300–1,000 |
| Uncommon | 1,800–2,700 |
| Rare | 5,500–7,500 |
| Epic | 17,500–20,000 |
| Legendary | 50,000–60,000 |
| Mythic | 300,000–360,000 |
| Secret | 2,750,000–3,500,000 |

First income upgrade costs 180,000 Scrap (25% cheaper relative to Common income). Walking/carrying upgrades start at 360,000/420,000; floors at 3.5 million; first rebirth at 25 million, growing by 2.5 each rebirth. Upgrade bonuses and caps remain modest. Selling pays 20 seconds of base income. Scrap pet/case prices and legacy Scrap product grants scale by 1,000; Core prices, odds and grants stay unchanged. Studio TEST LAB grants 100 million Scrap. Currency ceiling rises to 1 quadrillion; HUD supports K/M/B/T and formatted income rates.

Schema 5 → 6 converts saved Scrap, LifetimeScrap and historical Scrap receipt amounts by 1,000 once. Core balances/receipts, inventory, pets, upgrades and permanent progression are preserved. Fresh players still start empty with zero currency. Durable receipt merges migrate legacy units before applying missing grants, retaining receipt deduplication. Older builds reject schema 6: do not deploy an old build over migrated production saves.

## Inspiration and evidence

Reviewed 21 September 2026:

- [Steal a Brainrot](https://www.roblox.com/games/109983668079237/Steal-a-Brainrot): collectible income, competition and rebirth loop.
- [Steal An Egg](https://www.roblox.com/games/107778070777162/Steal-An-Egg): rare collectible income and base upgrades.
- [Spin a Baddie description archived by Rolimon’s](https://www.rolimons.com/game/79305036070450): placement/sale income, rare rolls and rebirth benefits. Its direct Roblox page returned Title Unavailable during review.

These descriptions support the general design inspiration, not exact competitor rates or retention claims. SCRAPYARD's numbers are our own tuning: visible earnings from the first delivery, large rarity jumps, then expensive upgrades and repeated rebirth goals. See [economy simulation](ECONOMY_0.3.3.md) for all assumptions and eight scenarios. Median free-player first rebirth eligibility: new 29.8 minutes, average 16.1, efficient 10.9. Rare finds can accelerate this substantially. The model does not simulate Roblox physics, contention or observed retention.

## Checks and Studio acceptance

70 automated tests execute actual Lua through mocked Roblox APIs, including source/place parity, relocated geometry and moving salvage, label roof clearance, income/price ladder, one-time save conversion and late legacy receipt merging. Earlier purchase, policy, tutorial, combat and case tests remain covered with updated currency fixtures. Build generated with tools/build.py; eight seeded economy scenarios use 200 runs each.

Roblox Studio is not available here. Before publishing, open the exact 0.3.3 place and check camera views at all six stalls and both tall landmarks; verify junk reaches the south shredder, no old conveyor remains, and two-player carrying routes are clear. Inspect mobile label overlap and HUD values at K/M/B/T sizes. Persistent migration/Marketplace/networking still need private Studio acceptance. No paid generation or public Roblox publishing performed.
