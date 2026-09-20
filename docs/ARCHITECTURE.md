# V0.2 architecture

ServerMain owns startup/player lifecycle; startup errors log tracebacks and fail explicitly. PlayerDataService lazily opens storage only for persistent operations, owns leases and serializes writes. ProfileSchema handles fresh defaults and migration. EconomyConfig is the source for upgrade costs, benefits and caps; MachineConfig defines base incomes and spawn weights.

GameplayService owns pickup/carry/deposit/replacement, upgrade validation, passive income, spawn lifecycle and server action routing. YardService owns allocation/capacity/style. QuestService owns UTC daily progress and atomic reward claims. CoreShopService owns exact-price cosmetic unlock/equip. PurchaseService owns the only ProcessReceipt callback and verified pass benefits. TelemetryService provides best-effort Roblox custom events and session milestone deduplication.

Remote requests: Sync, Upgrade, Replace, DiscardCarry, ClaimQuest, CoreShop, and allowlisted Telemetry. Clients cannot provide reward amounts or paid ownership. Mutable game actions are server validated and rate-limited. In-world inspection/upgrade/intake prompts require player proximity; upgrades/intake also require the player's own yard. Replacement IDs must belong to this inventory and must not be protected. No cross-player ownership transfer exists.

ClientMain owns the currency HUD, right navigation and modal pages. Environment owns tagged cosmetic animation. No public dev-grant remote; `tools/simulate_economy.py` is the isolated developer economy utility.

Telemetry records joined/yard, first pickup/placement/upgrade, first quest claim/free Cores, ShopOpened, PassPrompted, CorePurchasePrompted, verified PassPurchased, committed CorePurchaseCompleted, Played5/10/20Minutes, PlayerLeft. Client shop/prompt events are intent-only (untrusted, allowlisted, session-deduplicated); grant events are server-side. APIs are pcall-protected, disabled in Studio, never block economy. No external analytics or personal payload collection. Delivery/dashboard behavior needs a published test.

Distance and minimum haul-time checks deter basic abuse but are not a full movement anti-cheat. Large-scale remote spam, physics/network latency, mobile performance and live analytics/Marketplace remain release gates. This milestone does not implement theft or multi-profile transfer transactions.
