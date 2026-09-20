# V0.2 validation

Run build then `python -m unittest discover -s tests -v`. Local checks cover source/XML consistency, economy formulas, map/server startup, every machine factory, unpublished practice mode, income/upgrade loop, leases/save failures, old schema preservation, receipt retry/deduplication, Cores, claim replay/UTC rollover, styles, protected replacement, ownership/distance rejection, distinct yards/contested pickups and client menu callbacks.

The UI test executes callbacks against API stubs; it does not render text or verify touch hit targets. The two-player test simulates shared server state; it does not exercise Roblox networking or physics. The map test checks distances and generated instances, not collision navigation. Environment animation source parses; visual effects require the engine.

Economy simulator: 200 seeded runs for each new/average/efficient scenario with and without 2X, plus a greedy-efficient 2X policy. Explicit schedules, selection strategy and purchase assumptions appear in ECONOMY_V2.md. These are not measured player retention or statistically calibrated forecasts.

## Acceptance gates still required

- Actual Studio startup/render and timed first haul/first upgrade.
- Phone portrait/landscape layout, touch, streaming and frame rate.
- Two actual clients racing, carrying, respawning and leaving.
- Published schema migration, daily reset, durable claim/style replay.
- Owner-configured low-cost real products, pass entitlements and current prices.
- Published Roblox analytics event delivery and usefulness.
- Route collision and eight-player salvage supply/competition.

Do not mark V0.2 fully accepted or ready to sell until the relevant checks pass. No fake audio IDs, generated assets, public publication or paid generation performed.
