# SCRAPYARD — V0.3.5 playtest build

Moving salvage, shredder pressure, slap-and-steal combat, compact multi-floor yards, a shared shop district, guided onboarding, free daily wheel and rebirths.

## Play

Open **build/SCRAPYARD-0.3.5.rbxlx** in Roblox Studio (File → Open from File), then Play. The map generates at runtime. No plugins, publishing or DataStore API access are required for practice mode. Practice progress resets when you stop.

1. Start with an empty eight-slot yard, 0 Scrap and 0 Cores. Follow the yellow waypoint to the conveyor; hold E or tap a junk prompt.
2. Carry the junk home and use the green intake. Teleports cannot transport carried junk. Stored junk generates Scrap.
3. Tap **SHOP →**, walk up to the **Upgrades** stand and interact to finish the tutorial. Buy upgrades when affordable; there is no base upgrade terminal or standalone HUD upgrade button.
4. The same district has **Sell**, **Spin**, **Rebirth** and **Supplies** stands. **HOME →** returns you to your yard.
5. After the tutorial, use **F / SLAP** with empty hands near another player to knock them down and take carried junk. Yards and the shop district are safe zones. Stored junk cannot be stolen.

## New in 0.3.5

Endpoint-aligned shredder with restrained effects; operational compactor, furnace and scrap-mountain landmarks; warm daylight; VIP and shared eligible luck passes; four timed Core boosts; exact luck odds and account eligibility; stronger rebirth panels. Existing yard/conveyor coordinates are preserved.

Use **TEST LAB** in Studio practice to fund the features and simulate shop rewards without Robux. This is not a real checkout test.

## Previous 0.3.1 additions

Slap impact audio; nine collectible/equippable pets (+3% to +20% passive income); three case tiers bought with Scrap or Cores, exact odds and eligibility checks; guaranteed pet purchases; 30 scrap types (12 newly modeled); detailed twin-shaft shredder. Pets persist through rebirth. All documentation is committed in this GitHub repository.

## Systems and documentation

- [0.3.5 complete documentation](docs/RELEASE_0.3.5.md): everything changed, test controls, rewards, data migration and acceptance checklist.

- [0.3.1 complete release documentation](docs/RELEASE_0.3.1.md): case prices/odds, pet catalog, audio, models, policy handling, migration and validation.
- [Patch-only versioning](docs/VERSIONING.md): next release is 0.3.6.
- [Current economy scenarios](docs/ECONOMY_0.3.5.md).

- [Complete V0.3 feature rules](docs/V0.3_FEATURES.md): timings, controls, map, combat, floors, shops, tutorial, spin and rebirth behavior.
- [Previous V0.3 economy scenarios](docs/ECONOMY_V3.md): historical tuning baseline.
- [Data schema](docs/DATA_SCHEMA.md): schema 1–6 → 7 migration and preserved progress.
- [Architecture](docs/ARCHITECTURE.md): ownership and server validation.
- [Test plan](docs/TEST_PLAN.md): automated scope and remaining Studio checks.
- [Studio setup](docs/STUDIO_SETUP.md): opening this exact build and testing with two players.
- [Changelog](CHANGELOG.md) and [roadmap](docs/ROADMAP.md).

## Build and checks

```sh
python -m pip install -r requirements-dev.txt
python tools/build.py
python -m unittest discover -s tests -v
python tools/simulate_economy.py
python tools/simulate_rebirths.py
python tools/simulate_monetization.py
```

87 automated tests pass using actual Lua source and mocked Roblox APIs, including source-to-place parity. The tests do not run the Roblox engine or render screenshots. Physical knockdown, stair traversal, networking, mobile layouts, live DataStore and Marketplace acceptance still require Studio/published testing. No measured FPS or player-retention claims.

All paid purchase IDs remain 0 and monetization is disabled. Core cosmetics, guaranteed pets and the free daily spin work in practice mode. Random cases also require a successful account eligibility check. DataStore name remains SCRAPYARD_Alpha_v1. Earlier builds and explicitly marked historical documents are retained for regression/history; use V0.3.5. Higgsfield inspected read-only; no credits spent or public publishing performed.
