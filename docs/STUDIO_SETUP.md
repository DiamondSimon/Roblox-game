# Studio setup — version 0.1.1

## First test (no publishing)

Download the `.rbxlx` in `build/`. In Studio use File → Open from File. Press F5 / Play. The map appears at runtime. The player begins at an assigned yard; the radio generates 1 Scrap/sec. Collect a free machine from central salvage and place it at your own intake. Use the upgrade terminal after earning 100 Scrap.

Use the Test tab's server/client simulation with two players to check distinct yards and contested pickups. Names of Studio controls may vary by version; choose the mode that starts one server with two clients. Use the device emulator for a narrow phone viewport.

## Test durable saves

1. Use File → Publish to Roblox As to create a **separate private test experience** named SCRAPYARD Test. Keep access private in Creator Hub. Do not enable public access.
2. Set maximum players to 8 in experience/place settings.
3. Test by joining the published experience through the Roblox app. Published servers use real DataStores automatically. Studio's practice flag has no effect on live servers.
4. Pick up and place a machine, buy an upgrade, wait 35 seconds, leave, and rejoin. Verify inventory and upgrades restore. Scrap should retain the saved balance plus income earned after the rejoin; offline income is not implemented.
5. For Studio DataStore tests only: in Game Settings → Security, enable **Studio Access to API Services** on this separate test experience. In Explorer, go to ReplicatedStorage → Shared → Config → GameConfig and set `StudioPersistence = true`. Never point Studio at a production economy for destructive tests.

If a save fails to load, the server disconnects the player instead of creating an empty replacement. A crashed session can take up to 180 seconds to expire. Retry after that interval.

## Configure purchases only after persistence passes

Follow `MONETIZATION.md`. Use products owned by this same experience. Supply the actual IDs so the source and packaged place can be updated consistently. Do not simply paste product IDs into unrelated scripts.

## Report a problem

Open Studio's Output panel (usually Window or View → Output, depending on layout). Send the **first red error in full**, including script name and line, and describe what you did immediately before it. For layout issues, send a screenshot and the device/viewport used. Always identify this version as **0.1.1**.

Do not test different source versions and old place builds together. The XML embeds the exact source from the same milestone.
