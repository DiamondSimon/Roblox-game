# SCRAPYARD — V0.2 playtest build

Larger industrial district, slower major progression, movement upgrades, daily quests, earnable Cores and a clean right-side menu. The user confirmed V0.1.1 gameplay works; V0.2 is ready for the next Studio acceptance test. No Higgsfield credits used. No public publishing performed.

## Play

Download **build/SCRAPYARD-0.2.0.rbxlx**, open it in Studio with File → Open from File, then press F5 / Play. Map generation happens at runtime. Practice mode requires no publishing or DataStore API access and resets on Stop.

1. Start at your named yard with 0 Scrap, 0 Cores, no bought upgrades and a 0.30/sec radio.
2. Follow the direct concrete haul path toward CENTRAL SALVAGE. The expected fresh walk is roughly 18–23 seconds, depending on yard/target and route.
3. Hold E or tap a machine, carry it home, and use your teal intake pad. If full, explicitly select/confirm a replaceable machine. The protected starter cannot be replaced.
4. At 240 Scrap, buy Income efficiency while standing near your yard's amber terminal. You can browse upgrades from the right-hand menu anywhere.
5. Open QUESTS, complete an active contract, and claim Cores. SHOP → STYLES contains three permanent exact-price cosmetic choices. SHOP → PASSES / CORES is prepared but real purchases remain disabled.

## What changed

- World floor 350×350 → 1000×880 studs; eight larger fenced lots, direct haul paths, cross roads, freight areas, crane, water tower, depot and future gates.
- Income rebalanced; five upgrade branches: Income, Capacity, Walking, Carrying, Expansion.
- Four daily quests, UTC reset, durable Core claims; no paid random rewards.
- Cosmetic Core spending and Core pack receipt support, retaining hidden old Scrap fulfillment definitions.
- Compact currency HUD; right-side Shop, Upgrades, Quests and Collection; progress/claim indicators.
- Centralized client fan/hoist animations, restrained steam, warm lighting and spawn-label animation.
- Schema 1→2 migration preserving existing Scrap, machines, receipts and upgrades. Existing players are not fresh-economy test cases.

## Source and tools

Shared Config modules define economy/catalog/quests/shop. Server Services own data, schema, gameplay, quests, Core shop, purchases, world, yards and telemetry. ClientMain is the UI; Environment owns non-gameplay animation. All IDs remain zero. DataStore name remains `SCRAPYARD_Alpha_v1` intentionally.

```sh
python -m pip install -r requirements-dev.txt
python tools/build.py
python -m unittest discover -s tests -v
python tools/simulate_economy.py
```

Optional Rojo project: `default.project.json`. The XML file works without plugins. Archived old builds remain only for regression reproduction; use 0.2.0.

## Verification status

Automated module, startup, transaction, gameplay, client-callback and packaged-source checks pass. Six modeled progression scenarios plus an efficient 2X stress policy are documented in `docs/ECONOMY_V2.md`. These are simulated assumptions, not actual retention results.

**V0.2 acceptance is pending:** actual Studio rendering, phone portrait/landscape, two-client networking/physics, published persistence and configured Marketplace tests cannot run in this workspace. Follow `docs/STUDIO_SETUP.md` and `docs/TEST_PLAN.md`. No claim of measured FPS, optimal retention or profitability.

Stealing, security mechanics, functional fusion, events, licensed audio and custom hero assets are later work. Their upgrades/passes are not sold. Higgsfield requires explicit approval after this systems phase.
