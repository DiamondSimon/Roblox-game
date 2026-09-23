# Custom assets — manual Roblox import

These are original meshes constructed in Higgsfield 3D Jutsu. Paid image generation was attempted and rejected (`Requires basic plan or higher`). Scene construction succeeded; it is not a claim that a paid generative-model job succeeded. See generation-record.json and asset-manifest.md.

## Files and destinations

| File | AssetConfig key | Runtime maximum dimension |
|---|---|---:|
| reactor.glb | reactor | 5.5 studs |
| pod.glb | pod | 5.5 studs |
| singularity.glb | singularity | 6 studs |
| compactor.glb | compactor | 34 studs |

Each file has three material batches, no image textures, a floor-centered pivot, Y up and -Z front. They are static visual assets. Dimensions/triangles/SHA-256 are verified in export-metrics.json. `scrapyard-heroes.glb` is the full source lineup and includes presentation cameras/lights; **import the four individual files**, not that scene.

1. Open SCRAPYARD-0.3.6.rbxlx in Studio. Use the **3D Importer / Import 3D** command and select one of the four GLBs. Inspect the preview, Y-up orientation and material colors. Do not include any cameras/lights. Repeat for the other files.
2. Import each as a grouped **Model**. Keep the three material MeshParts together. Set all MeshParts Anchored=true, CanCollide=false, CanTouch=false and CanQuery=false. Collectibles use the existing invisible gameplay chassis; the environmental compactor retains the game's simplified collision geometry.
3. Check front/back, no detached surfaces, floor contact and scale. If Studio drops the cyan emissive material, set that batch to Neon and the other batches to Metal before saving. This is a solid-color material set, not a textured mesh.
4. Save each grouped Model to Roblox under the same account/group that owns the experience, or grant the experience access. Copy the **Model asset ID**, not an individual MeshPart's MeshId. Roblox permissions/moderation must allow the experience to load it.
5. Return the four Model IDs with their names. The only asset mapping changes are `reactor.ModelId`, `pod.ModelId`, `singularity.ModelId`, and `compactor.ModelId` in `src/shared/Config/AssetConfig.lua` (or the corresponding ReplicatedStorage module in Studio). All are currently 0. Keep the zero mapping for any asset you reject.
6. Rebuild/reopen or restart Play. Loading is asynchronous; first-spawned collectibles may retain fallbacks until they respawn. The compactor swaps its visual once ready. Check moving salvage, collection/sell previews and carried/deposited art. Test an invalid ID: the map and procedural machines must still work.

The loader scales each model to its configured maximum dimension and normalizes its floor center; manual sizing is only for preview. Collision stays simple. No uploaded IDs are supplied and none of these meshes is currently integrated into the playable build. Studio import/appearance, client asset access and mobile FPS remain acceptance checks.

Source: build_assets.py followed by refine_assets.py and mount_pumps.py in the linked Higgsfield project. tools/export_custom_assets.py bakes transforms, rotates the front onto -Z, centers the floor, and batches by material. No third-party model or trademark source was used.
