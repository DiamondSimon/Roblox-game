# Changelog

## 0.3.0

- Server-driven conveyor with 42-second trip, shredder deletion and feedback; shorter nameplate range, fewer initial items, reclaimable drops.
- Server-selected slaps, knockdown and carried-junk transfer; safe zones, cooldowns, immunity and tutorial protection.
- Empty fresh inventory, persistent short tutorial and yellow world waypoint/beam.
- Eight ground-floor slots in smaller yards; three eight-slot floor upgrades, stairs, and an eight-slot entitlement floor.
- Shared Upgrades/Sell/Spin/Rebirth/Supplies plaza; removed home terminal/annex and standalone HUD upgrades button; added HOME/SHOP teleports.
- Atomic confirmed junk selling, free daily wheel with durable claim, confirmed rebirth reset with permanent +5% per rebirth (max +50%).
- Weaker income/movement upgrades, brighter map and light outlined HUD.
- Schema 3 migration preserves prior machines/currency/receipts and rounds old capacity upward to whole floors.
- 42 passing mock-runtime/package tests; updated balance simulator and complete feature/test documentation. Studio engine acceptance not performed here.


## 0.2.0 — district and progression playtest

- Expanded playable world and yard spacing; added direct haul routes, landmark inspection and restrained environmental motion.
- Lowered starter income to 0.30/sec and retuned all 18 machines. First income upgrade 240. Added controlled movement, capacity and annex branches; later goals scale strongly.
- Added Cores, four active daily contracts with explicit claims, three deterministic cosmetic styles.
- Replaced visible Scrap pack catalog with Core packs, preserved hidden legacy fulfillment, hid oversized Core packs pending more sinks.
- Preserved existing progress through schema 2 migration, currency-tagged receipts and capacity floor. Transaction uncertainty now freezes the session until durable reload.
- Rebuilt compact HUD/right navigation, purchase categories, quest status, upgrade funding progress and full-yard replacement confirmation.
- Added server event instrumentation, economy simulation and regression coverage for new flows.
- No Higgsfield use. Actual Studio/device/live-service acceptance remains pending.

## 0.1.1

Fixed unpublished Studio boot by removing eager DataStore opening; added startup diagnostics and regression checks.

## 0.1.0

Initial playable salvage loop, source repository and generated Studio build.
