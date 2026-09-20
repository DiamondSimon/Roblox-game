> Historical V0.2 reference. V0.3 supersedes this document where behavior differs. Current rules: [V0.3_FEATURES.md](V0.3_FEATURES.md), [ECONOMY_V3.md](ECONOMY_V3.md), [DATA_SCHEMA.md](DATA_SCHEMA.md). In particular: no fresh starter, eight slots per floor, shared shops, free daily wheel and carried-junk combat.

# V0.2 monetization

`MonetizationConfig` holds all IDs and grants. Enabled=false; all IDs=0. No live transaction has been performed in this workspace.

## Passes

- DoubleScrap: permanent 2× passive machine income; verified with UserOwnsGamePassAsync.
- ExtraSlots: permanent five extra positions. Same benefit as V0.1.

VIP, extra fusion queues and double quest rewards are deferred until there is enough implemented value. No stacked 4×/8× earnings, instant best machine, or paid random rewards.

## Developer Products

Core packages configured at 80, 250, 600, 1,400, 3,000. Only 80 and 250 are visible; larger packs are hidden because the first style catalog costs only 220 total. None is purchasable until configured and enabled in a persistent experience. Robux prices are fetched from Roblox on the client and are not hardcoded. A pack always grants its stated fixed Core amount.

## Free and paid Cores

Four daily active quests award up to 40/day. Styles cost 30 / 70 / 120 Cores, unlock permanently and can be re-equipped free. They change the yard sign color and intake lighting. They do not multiply income or roll for random loot. An 80-Core pack can buy Teal or Violet; a 250-Core pack covers all three current styles. More sinks should precede larger paid packs.

## Legacy Scrap products

Audited V0.1 IDs were all zero and storefront disabled. The three old 500 / 2,000 / 6,000 definitions remain hidden under LegacyProducts. If real IDs were configured outside this repository, copy them into those same legacy definitions. Never reuse a Scrap product ID for a Core reward. Fulfillment remains active for mapped legacy IDs even if storefront is off.

## Safety and verification

One PurchaseService owns ProcessReceipt. Rewards and currency-tagged receipt records are persisted together before acknowledging. Unknown products and unavailable profiles return NotProcessedYet. No PromptProductPurchaseFinished grant. Duplicate grants, ambiguous commit results, rejoin and insufficient-funds cases have mocked-service regression checks; actual Marketplace verification is still required.

Owner steps after private save tests: Creator Hub → Creations → this experience → Monetization → Passes / Developer Products. Create only the two passes and desired visible Core packs, copy their real IDs, and provide them for the central config. Configure prices in Creator Hub. Test privately before public availability. Real external-sale test mode may cost Robux.

Official API reference: https://create.roblox.com/docs/production/monetization/developer-products
