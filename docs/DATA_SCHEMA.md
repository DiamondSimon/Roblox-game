# Data schema 1

Envelope: `Data`, `Lease = {Token, Expires}`. Release removes Lease.

| Field | Meaning |
|---|---|
| SchemaVersion | 1; unsupported versions fail closed |
| Scrap / LifetimeScrap | Current soft balance / earned passive income |
| Upgrades | Income level 0–20, Slots level 0–7 |
| MachineInventory | Ordered entries: Uid, MachineId, Protected |
| DiscoveredMachines | Set of machine IDs discovered |
| DiscoveredMutations | Reserved for next milestone |
| Receipts | PurchaseId → fixed Scrap grant amount; never casually prune |
| Settings / DailyRewardState / Statistics | Reserved tables |

All owned machines are displayed, so slot assignment is the inventory array position. There is no duplicate PlacedMachines list to reconcile. Add a migration if storage separate from placement is introduced.

Gamepass truth is queried from Roblox and held in player attributes; it is not accepted from clients or saved as purchase truth. Receipt history is bounded by Roblox's per-record size; monitor size before public launch and design archival/ledger migration before heavy-spender records grow too large. Do not delete receipt IDs to save space.

Ordinary progress can lose the latest autosave interval during an abrupt crash. Acknowledged product grants have already been committed. No offline income or trade recovery is present in 0.1.
