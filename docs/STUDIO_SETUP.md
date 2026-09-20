# Studio test — V0.2.0

Download build/SCRAPYARD-0.2.0.rbxlx → File → Open from File → F5 / Play. Close the old place to avoid testing the wrong version. Practice mode needs no publishing and always starts fresh. The map is built on Play.

## First 5 minutes

1. Confirm top-left shows 0 Cores and income +0.30/sec, one machine/four slots, and right-side Shop / Upgrades / Quests / Collection.
2. Walk from your spawn through your gate along the direct concrete path to the conveyor. Time this trip; expected ~18–25 seconds without speed upgrades.
3. Pick up a machine and bring it to your green intake. Note your first-delivery time and updated income.
4. Keep delivering. At 240 Scrap, stand by your amber terminal and buy Income efficiency. Tell us the elapsed time and which machines you collected. Average modeled first purchase is ~3.6 minutes, not a guarantee.
5. Deliver five total machines. If full, choose and confirm replacement at intake. Open Quests and claim 10 Cores. A second claim must award nothing.

## Exploration and styles

Inspect the crane station (-86,-88), tower station (108,240), and depot station (-45,280), using X/Z coordinates. Claim its 10 Cores. Buy two upgrades for another 8 Cores or deliver two Rare+ for 12. At 30 Cores open Shop → Styles → Foundry Teal. Confirm balance drops by 30 and your yard sign/intake changes color. Re-equipping must be free.

## Phone and multiplayer gates

Use Studio's device emulator in portrait and landscape. Confirm currency cards and four right buttons fit, menus scroll, claim/close buttons are tappable and carrying controls remain usable. Send a screenshot of each problematic layout.

Use Test → Server & Clients with two clients. Verify distinct yards, race for one machine (only one wins), try the other player's terminal/intake (must fail), carry then reset character (carry removed), leave/rejoin where persistence is enabled. The mocked two-player test is not a network test.

## Persistent test

Publish as a separate private test experience; max players 8. Published servers use real storage automatically. Studio remains practice unless GameConfig.StudioPersistence=true and Game Settings → Security → Studio Access to API Services is enabled on this private test experience. Do not test against a production economy.

Earn Cores, claim once, buy a style, wait 35 seconds, leave and rejoin. Verify currency, style, inventory, upgrades and claimed quest survive. Use an old schema-1 private test save to verify migration; never reset its data. A retired server lease can take up to 180 seconds to expire. Close old V0.1 servers before testing V0.2 saves.

Purchase setup remains in MONETIZATION.md; no IDs are needed for this free gameplay test. Errors: open Output, send the first full red error plus version and what action caused it.
