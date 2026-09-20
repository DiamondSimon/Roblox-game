# Purchase foundation — disabled until tested

All IDs are in ReplicatedStorage/Shared/Config/MonetizationConfig. Enabled=false and Id=0 are safe defaults. The client only offers configured, enabled purchases in persistent mode and retrieves current Roblox prices; it never displays made-up prices.

Prepared passes: DoubleScrap (2× passive income), ExtraSlots (+5 display slots). Prepared Developer Products: 500, 2,000 and 6,000 Scrap. No VIP or extra fusion slot is sold until its promised benefit exists.

## Owner setup

1. Publish a private test experience and verify its saves.
2. In Creator Hub → Creations → your experience → Monetization → Passes, create the two passes and copy their IDs. Configure their prices there.
3. In Monetization → Developer Products, create the three fixed Scrap packs and copy their IDs. Use products for this same experience.
4. Supply all five IDs. Update the central config and rebuild the place. Enable the catalog only in the test build when ready to test it.
5. Verify pass entitlements immediately after purchase and on a fresh join. Verify a repeatable product grants the exact amount once, persists across rejoin and survives simulated duplicate callback / save failure.
6. Only make products available to the public after the full game and purchase test gates pass.

One server script assigns MarketplaceService.ProcessReceipt. The handler returns NotProcessedYet if the profile is unavailable, the product is unknown or the durable write fails. It acknowledges only an existing durable receipt or an atomic reward-and-marker write. It continues fulfilling configured old products even when the storefront is disabled; never remove an old product mapping while receipts might remain pending. PromptProductPurchaseFinished is not used for fulfillment.

No paid luck, randomized rewards, timed server boosts, emergency shields, event summons or subscriptions are offered. Those require separate recovery and policy design. Real purchases are not verified in this workspace, and Roblox external-sales test mode can cost actual Robux.

Official reference checked for this milestone: https://create.roblox.com/docs/production/monetization/developer-products
