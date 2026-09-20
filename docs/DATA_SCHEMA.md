# Save schema 3

Storage key remains `player_<UserId>` in `SCRAPYARD_Alpha_v1`; outer record `{Data, Lease}` is unchanged. Fresh Studio practice sessions remain memory-only. Persistent load/save uses UpdateAsync leases; unknown schemas fail closed.

New fields: `Upgrades.Floors` (0–3), `Rebirths` (0–10), `RunDelivered`, `TutorialStage` (1 pickup / 2 return / 3 shop / 4 complete), `SpinState={Day=-1,Reward=0}`. Fresh inventory and discoveries are empty. Balances and all upgrade levels start at zero. Capacity is derived, never client-authoritative: eight times (1 + Floors + verified ExtraSlots entitlement).

Schema 1 first migrates to schema 2 with the existing receipt/currency/quest/cosmetic migration. Schema 2 then computes old capacity as max(CapacityFloor, 4 + 2×Slots + 2×Expansion, inventory count), rounds it upward to eight-slot floors, and installs schema 3 fields. Old machines, UIDs, protected flags, Scrap, Cores, income/movement upgrades, cosmetics, receipts and discoveries remain. Historical Slots and Expansion fields remain for compatibility but are no longer purchasable. Existing players with machines get tutorial stage 4; empty migrated profiles get stage 1. Old high income levels (up to 20) remain valid, but only ten levels can be newly bought.

Spin marker + Cores, sale removal + Scrap, and rebirth reset + permanent increment each share a single profile transaction. Busy blocks competing mutations. Ambiguous transaction writes deactivate the session and require durable reload, preventing overwrite or repeat rewards. Receipts retain existing idempotency and ambiguous-write merging behavior. Autosave remains every 30 seconds; nontransactional pickup/deposit/upgrade progress can be lost on an unexpected server crash before autosave, as in V0.2.

Paid ownership stays in Roblox Marketplace and is verified server-side; it is never reset by rebirth. Protected legacy items survive rebirth and cannot be sold/replaced. No paid stored-machine products currently exist. Carried/world junk is transient, not saved to a profile. Disconnect drops carried junk only while that server remains alive. Teleport/slap cooldowns and immunity are transient server tables, cleared on leave.

See V0.3_FEATURES.md for the exact reset-preserve list. Reverting to a schema-2 build after migrating persistent saves is unsupported; use a separate test universe for acceptance.
