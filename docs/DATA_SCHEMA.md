# Schema 2 — V0.2

Store name unchanged: SCRAPYARD_Alpha_v1. Keys: player_<UserId>. Envelope: Data and expiring Lease. No resets.

| Field | Authority / meaning |
|---|---|
| SchemaVersion | 2; migrate 1, reject unknown versions |
| Scrap, LifetimeScrap | Preserved balance / lifetime passive income |
| Cores | New nonnegative hybrid premium balance, initially 0 |
| Upgrades | Income, Slots preserved; Speed, Carry, Expansion default 0 |
| CapacityFloor | For migrated players, old base 6 + old Slots level; fresh 0 |
| MachineInventory | Ordered Uid, MachineId, Protected entries; preserved |
| DiscoveredMachines / Mutations | Preserved discovery sets |
| QuestState | UTC Day; Progress, Claimed, Inspected maps |
| Cosmetics | Owned map; Equipped key (Default initially) |
| Receipts | PurchaseId → {Currency, Amount}; numeric old receipts become Scrap records |
| Settings, DailyRewardState, Statistics | Preserved reserved fields |

All owned inventory is placed sequentially. Capacity, Scrap/sec and paid pass benefits are derived; no second mutable ownership list. Capacity = max(legacy floor, 4 + Slots×2 + Expansion×2) + 5 for verified capacity pass, capped at 24. Existing machines remain visible even if entitlement verification is temporarily unavailable.

Legacy income levels through 20 and slot levels through 7 remain valid even though new purchase caps are lower (Income 10, Slots 4). They are not clamped or refunded. UI marks levels beyond the new cap as maxed. Old balances can still afford immediate purchases; fresh-economy timing applies to new/reset practice sessions only.

UpdateAsync migration runs during lease acquisition. Unsupported or corrupt versions fail closed instead of creating defaults. The 180-second lease, 30-second autosave and shutdown release remain. Currency is online only; the latest ordinary autosave interval may be lost after an abrupt crash.

Core purchases, quest claims, style unlocks and equip changes use serialized atomic profile commits. Failed/ambiguous transactional writes freeze the session and disconnect for durable reload; read-only storefront and autosave cannot overwrite an uncertain spend. Numeric and tagged receipt replay are retained. Monitor total profile size; receipt IDs are never casually deleted.

Do not run old server versions against migrated profiles: schema 1 code rejects schema 2. Shut down old private test servers when publishing V0.2. Archive/restore procedures must retain the complete envelope and receipt history.
