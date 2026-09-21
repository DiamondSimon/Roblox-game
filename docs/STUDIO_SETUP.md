Current release: **0.3.3**. See [release changes and acceptance checks](RELEASE_0.3.3.md). Open build/SCRAPYARD-0.3.3.rbxlx. Current automated suite: 70 tests; save schema 6. Earlier version-specific details below are historical where superseded.

# Studio V0.3.2 setup

1. Download `build/SCRAPYARD-0.3.2.rbxlx`. Open in Studio with **File → Open from File**. Do not open an archived V0.1/V0.2 build.
2. Press Play / F5. Scripts build the world at runtime, so an empty edit viewport before Play is expected. Runtime BootStatus on ReplicatedStorage should become Ready. If it stays Failed, collect the FIRST startup error in Output.
3. Practice mode is on by default (`StudioPersistence=false`), opens no DataStore and resets on Stop. Fresh players intentionally start empty with no passive income until their first delivery. Follow the tutorial waypoint.
4. For multiplayer, use Studio's local server/test-player controls with two players. Finish the tutorial on both before testing slaps. See TEST_PLAN.md.
5. For persistence, use a separate privately published test universe and deliberately configure its API access plus StudioPersistence only there. Do not test migrated/reset profiles on live production saves. All purchase IDs remain zero and paid buying disabled until separately configured and tested.

Controls: E / touch prompt to pick up, place or interact with stands; F / SLAP for combat; SHOP → and HOME → teleport empty-handed; DROP places held junk back in the world. SHOP arrives in a plaza; walk to the desired stand to open it. Upgrades are no longer bought at home.

The delivered file contains code and engine primitives, no external artwork or plugin dependency. Optional source workflow: default.project.json with Rojo. Build regenerates XML from src; do not edit generated embedded code independently.

Pet cases: SHOP → Pet stand → CASES, review exact odds, confirm Scrap or Cores. PETS provides guaranteed purchases and equip controls. Failed/restricted account-policy checks block random cases without blocking guaranteed pets. Audition the slap effect; this environment did not run Roblox audio.

## 0.3.2 quick testing

Press TEST LAB (bottom left) in practice. Add Scrap/Cores, finish tutorial, toggle pass effects or simulate product rewards. Use Go to stand, then close the menu and interact normally. For case testing select Allowed/Restricted/Actual in Test Lab; overrides work only in nonpersistent Studio. The real paid checkout stays disabled. Enter FOUNDRY or SCRAP032 in REWARDS for one-time code grants.
