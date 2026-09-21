# V0.3.1 architecture

ServerMain controls boot, character spawning, profile/yard lifecycle, respawn immunity and death/disconnect drops. Lazy DataStore opening remains critical for unpublished Studio practice startup.

| Module | Responsibility |
|---|---|
| GameplayService | Weighted salvage, timed belt motion/expiry, carry ownership, deposits, upgrades, income ticks, state and remote routing |
| ProgressionService | Server target selection/knockdown/theft, safe zones, teleports, tutorial targets, spin/sale/rebirth transactions and shop prompts |
| WorldService | Map, shop district, shredder, eight compact yards, dynamic floor geometry |
| YardService | Ownership, derived capacity, rendering inventory, cosmetics, floor refresh |
| PlayerDataService / ProfileSchema | Lease/session serialization, transactions, migrations, validation |
| QuestService / CoreShopService | UTC contracts/claims and exact-price cosmetic ownership |
| PurchaseService | Verified passes and idempotent receipt fulfillment; refresh floors on entitlement changes |
| ClientMain | Responsive HUD, menus, confirmations, wheel result animation, keyboard/touch slap input |
| Waypoints | Local arrow/beam, respawn reconnect, shred/slap flashes |
| Environment | Distance-limited fan, hoist and shredder rotor visuals |

Remote actions: Sync, Teleport(Home/Shop), Slap(no target argument), Upgrade(config key), Replace(owned UID), DiscardCarry, Spin(no reward argument), Sell(owned UID), Rebirth(true after UI confirmation), ClaimQuest, CoreShop and allowlisted Telemetry. Client input never determines prices, rewards, capacity, hit targets or inventory ownership.

State includes balances, inventory, income, capacity, upgrade levels, daily contracts, cosmetics, discoveries, persistence mode, tutorial stage/objective/waypoint, daily-spin status, rebirth count/cost and stun state. Server-to-client Open messages originate at validated physical shop prompts. Transactions serialize on the data session; no cross-profile persisted transaction is required because slaps only move transient carried junk.

Security scope: checks cover range, hit cone, line-of-sight, safe zones, state/cooldowns, deadline eligibility and duplicate UIDs/rewards. Minimal haul-time plausibility checks remain; full anti-speedhack/anti-teleport movement auditing is not implemented. Client visuals are not authoritative. Automated mocks verify logic but cannot prove Roblox replication, physics or performance.

PetService owns policy caching, durable pet purchases/equipment, one-use case offer tokens and equipped attributes. PetConfig defines exact odds, bonuses and guaranteed prices; PetModelFactory builds species silhouettes; Pets.client.lua animates cosmetic companions. AudioConfig configures confirmed-hit spatial audio handled by Waypoints. New remotes: BuyCase({Case,Currency,Token}), BuyPet(id), EquipPet(id/empty). Pet state includes ownership/equipment, current bonus, case eligibility and offer token.
