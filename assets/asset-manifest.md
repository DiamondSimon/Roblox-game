# Current asset status — 0.3.6

Four original custom assets were **constructed and rendered in Higgsfield 3D Jutsu**, then exported to GLB. These are authored Blender meshes, not outputs from a paid text/image generative model. The paid image requests were attempted for all four assets and rejected with `Requires basic plan or higher` (no job IDs). The text-to-3D route required a `generate_3d` tool not exposed in this session. See `custom/generation-record.json` for request outcomes. No successful paid-generation debit is claimed.

Project: https://higgsfield.ai/3d-jutsu/5532cfef-15bb-4a4a-934a-3f0b34634c6e — committed revision 3. Original source is `custom/build_assets.py`, followed by `custom/refine_assets.py` and `custom/mount_pumps.py`. This is original industrial art, with no imported third-party model or branded design.

| Asset | Verified triangles | Material batches | Textures | Dimensions, metres X/Y/Z | Generated / constructed | Exported | Uploaded to Roblox | Integrated |
|---|---:|---:|---:|---|---|---|---|---|
| reactor | 3,008 | 3 | 0 | 2.4 × 2.82 × 1.9 | Constructed | Yes | No | No |
| pod | 3,382 | 3 | 0 | 2.2497 × 2.7 × 2.22 | Constructed | Yes | No | No |
| singularity | 2,492 | 3 | 0 | 2.5 × 2.75 × 1.8 | Constructed | Yes | No | No |
| compactor | 3,848 | 3 | 0 | 3.15 × 3.46 × 2.52 | Constructed | Yes | No | No |

Delivery files: `custom/reactor.glb`, `custom/pod.glb`, `custom/singularity.glb`, `custom/compactor.glb`. Import instructions: `custom/IMPORT.md`. Each export is three material-batched meshes, normalized to a floor-center pivot, Y up, -Z front. The source Blender scene has separate editable mechanical pieces; delivery merges by material for fewer MeshParts. Actual triangle counts, bounds, hashes, scene references and zero-texture status are verified by tests/test_custom_exports.py. No triangle/texture budget is inferred from a prompt.

Visual inspection: the first rendered lineup exposed a protruding Alien Pod capsule; replaced it with a tapered inner capsule and reduced gloss/emission. The corrected front lineup and a rear inspection were reviewed; the rear view revealed unsupported compactor pump housings, corrected with column mounting brackets in revision 3. Materials are deliberately texture-free dark steel, oxidized ochre and cyan, without photorealistic wear or bitmap branding. No obvious disconnected geometry in the inspected presentation; Roblox importer rendering, normals, emissive behavior, collisions and mobile FPS remain unverified. These are first custom assets ready for import, not a declaration of final production art approval.

`AssetConfig.lua` contains model ID mappings for these assets (plus future UFO). IDs are all 0. `CustomAssetService` caches permitted uploaded models asynchronously, sanitizes geometry, and retains procedural fallbacks on zero IDs/import failures. Its compactor overlay keeps simplified existing collision. Until IDs are supplied, the playable game still uses procedural collectible and landmark art. No uploaded/integrated status is claimed.

Runtime map details in 0.3.6 use original code-built primitives and native CYAN sign plates, not externally generated decals. No new audio asset IDs. Bundled placeholder timbres still need listening tests.

---

## Historical asset notes

# Asset manifest

No external assets or Roblox asset IDs yet. All map and collectible meshes in 0.1 are procedural Roblox Parts built by WorldService and MachineService. No trademarked car models, third-party scripts or unlicensed audio were imported.

Next: one Fusion Crusher hero. Record source, tool/model, date, rights, local file, triangle count, textures, dimensions, pivot, collision approach and uploaded Roblox asset ID before use.

## 0.3.1 additions

All 12 new scrap types, 9 companion species, pet cases and the detailed shredder are code-built Roblox primitives. No purchased models, generated art or external mesh dependencies. Slap sound reuses Roblox bundled `rbxasset://sounds/impact_water.mp3`, trimmed and pitched by AudioConfig. No external audio uploaded or asset license claimed; engine playback/timbre requires Studio acceptance.

## 0.3.2 presentation

Pet pictures are ViewportFrame renders of the shipped pet factory, not external thumbnails. The case reel uses those same models. New vegetation, benches, shop fixtures and service clutter are Roblox primitives. No new external audio or images.

## 0.3.5 operational landmarks and credit decision

IndustrialWorld creates a compactor, furnace/stacks, scrap mountain and mechanical dressing from anchored Parts. Pivots use explicit world coordinates; only the decorative press moves, without collisions. Client effects have distance/cleanup limits. MachineModelFactory adds a small rarity core. No textures/meshes imported.

Higgsfield model search (2026-09-22, read-only) found Meshy image_to_3d and Meta sam_3_3d. Neither was submitted. No prompt-generated result, GLB, Roblox Asset ID or credit debit exists for this patch. Hero asset brief for a later import: stylized cyan-core recycling compactor, dark steel body, yellow guards, rust accents, broad clean silhouette, separate static frame and moving ram, no trademarks. Target <=8,000 triangles, <=2 materials, <=1024 textures, floor-centered pivot, simplified anchored collision hulls, ~34×30×32 Roblox studs after import. Validate actual exported counts, orientation, pivots and mobile rendering before claiming those budgets met.

AudioConfig: motor uses bundled action_swim.mp3 (0.08 volume, 0.35 speed); grind uses impact_water.mp3 (0.5, 0.55); rare cue uses electronicpingshort.wav (0.3, tier-dependent pitch). These are temporary bundled timbres, not custom industrial recordings. No external sound IDs, generated audio or licenses claimed. Studio availability/listening checks outstanding.
