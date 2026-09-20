# SCRAPYARD

**0.1.0 — first playable loop, ready for Studio testing. Not a public-release MVP.**

Find salvage, carry it home, earn Scrap, and upgrade an industrial yard. Eight players share a central salvage strip.

## Open and play

1. Download `build/SCRAPYARD-0.1.0.rbxlx` from this repository (open the file on GitHub, then choose **Download raw file**).
2. In Roblox Studio, choose **File → Open from File** and open it.
3. Press **Play / F5**. Use Play, not Run: the game needs a player character. The map generates when the server starts, so an empty edit view is expected.
4. Your yard starts with a radio generating Scrap. Walk to the central conveyor, hold **E** at a machine (or tap its prompt), and return to your green **Machine intake** pad. Use its prompt to place the machine.
5. At 100 Scrap, use your amber **Upgrade terminal**, then choose **Income tuning**.

Studio defaults to **practice mode**. Progress resets after Stop; purchases are disabled. You do not need to publish or configure API access for this first playtest.

## Included

- Procedural industrial map: eight named yards, conveyor, freight containers, gantries, worklights, atmosphere.
- 18 data-driven machines, seven rarity colors, category-based blockout models and rare announcements.
- Server-validated pickup, carry, placement, capacity, income, upgrades; death/disconnect carry cleanup.
- Amber industrial HUD, workshop, collection index and disabled shop; touch-compatible prompts and buttons.
- DataStore session leases, retries, autosaves, save validation and shutdown release.
- One atomic developer-product receipt handler, durable receipt deduplication, verified gamepass entitlements.
- Two prepared passes and three fixed Scrap products. IDs are zero, never invented.

## Source map

| Location | Responsibility |
|---|---|
| `src/shared/Config` | Machine catalog, economy, game settings, purchase IDs |
| `src/server/Services/PlayerDataService.lua` | Profile ownership, persistence, atomic writes |
| `WorldService.lua`, `YardService.lua`, `MachineService.lua` | Environment, yard assignment, collectible presentation |
| `GameplayService.lua` | Server gameplay rules, income and spawning |
| `PurchaseService.lua` | Receipt processing and entitlements |
| `src/client/ClientMain.client.lua` | HUD, panels, current product prices and prompts |
| `tools/build.py` | Deterministic source-to-Studio XML build |
| `tests/test_core.py` | Executable module tests with mocked Roblox services |

## Development

Python 3 is sufficient to build the place:

```sh
python tools/build.py
```

Optional Rojo workflow: use `default.project.json`. The packaged XML build requires no Studio plugins.

Run the unit checks:

```sh
python -m pip install -r requirements-dev.txt
python tests/test_core.py
```

These tests execute Lua-compatible Luau modules with faked Roblox services. They are not Roblox engine, rendering, network, touch-device or real Marketplace tests. See `docs/TEST_PLAN.md` for required Studio tests.

## Current scope

Stealing, fusion, mutation effects, events, daily rewards, sale/removal of placed machines, analytics delivery, custom meshes and sound are not implemented. Collection discovery is implemented. Income is online only. Machines automatically occupy the next display slot. Save schema intentionally uses one authoritative inventory, not two separately mutable copies of ownership.

Do not publicly launch or sell products yet. First complete the private Studio and published-server checklist, then implement the next gameplay milestones. No profitability or performance claim has been validated.

See `docs/STUDIO_SETUP.md`, `docs/ARCHITECTURE.md`, `docs/MONETIZATION.md`, and `docs/ROADMAP.md`.
