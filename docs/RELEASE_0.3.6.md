# SCRAPYARD 0.3.6 — contact, motion and visual identity

Build: `build/SCRAPYARD-0.3.6.rbxlx`. Prior 0.3.5 is preserved. Patch-only version increment. No public Roblox deployment. Save schema remains 7. Economy, rarity gates, passes, paid-random eligibility and durable rewards are unchanged.

## Geometry corrections

| Measurement | World Z / clearance |
|---|---:|
| Deck start / end | -224 / 226 |
| Assembly center | 238 |
| Shaft front | 227 |
| First disc front / center | 228.45 / 229 |
| First hook front = contact = disposal reference | 228.25 |
| Deck to cutting volume gap | 2.25 |
| Mouth front | 227 |
| Feed wall front | 225.5 (sides only) |

Cutter axes now sit at Y=5.8. A conservative full-rotation tooth sweep (3.5 radius plus 1.06066 half-diagonal) remains above the mouth top at Y=1.15 and inside the flared walls. The original base no longer bisects the cutters. Tread centers wrap within deck boundaries minus their 0.3 half-depth. A model's gameplay anchor reaches the contact plane; its visible front can overlap the first tooth region as it is consumed. No cosmetic pull-in delay was added. Effects and removal use the same Part; no deep-center disappearance.

The centered 450-stud deck, eight yards at X=±330 / Z=-210,-70,70,210, roads and equal approach lanes remain fixed. New detail is noncolliding and off the approaches.

## Motion and onboarding

RenderStepped client movement uses synchronized server time and shared position math, including the tutorial marker. Server deadlines, pickup distance, policy checks and ownership remain authoritative. Treads, cutter rotation and fans animate every frame; distant rotors/fans remain culled. No faster server polling was substituted for interpolation. Dropped salvage stays static.

Fresh players start empty. Moving target selection is sent as a BasePart reference; positional updates do not wait for state packets. Pickup immediately guides home; deposit switches to Upgrades. Expiry retargets without waiting for the one-second state loop. Static target and streamed-out target behavior is included in the manual checklist below.

## Presentation and art

Six shops gain varying rear heights, deep service recesses, shelves, sloped fascia, braces, display props and original CYAN sign plates. The shredder gains motor couplers/coolant lines, the crane a cable connected to its moving hoist, and the compactor hydraulic lines. High-tier arrivals trigger short beacon responses; up to three nearby Legendary/Mythic/Secret conveyor items receive shadowless pulsing lights. Common junk remains quiet. Existing tiered arrival audio and server announcements remain.

Custom-asset generation/construction, export metrics and upload status are tracked in `assets/asset-manifest.md`. `AssetConfig` uses model IDs, with zero selecting procedural fallbacks. No generated asset is described as integrated until it is uploaded and used in the game. See `assets/custom/IMPORT.md` for the manual upload/config steps.

## Executed validation

**101 automated checks pass.** Run `python tools/build.py` then `python -m unittest discover -s tests -q`. Regression tests exercise actual Lua via Lupa with narrowly mocked Roblox APIs: geometry bounds, disposal/FX agreement, pre-contact pickup, exact-expiry rejection, math-based validation despite stale proxies, dropped item lifetime, sub-server-tick client interpolation, tutorial tracking/retarget/transitions, and custom-loader failures. Build parity covers every embedded script. Existing economy/security/persistence/UI tests remain in the suite.

The map harness reports 1,318 BaseParts, 0 MeshParts and 8 existing PointLights before client effects/custom imports; 122 descendants in FocalDetail. These are scene-construction counts, not a mobile performance benchmark. New aura lights cap at 3 nearby; burst effects cap at 3 concurrent / 10 pieces each, 0.5-second cleanup. No new bitmap textures. Streaming settings remain unchanged.

## Studio acceptance — NOT RUN in this environment

- Fresh practice, no Test Lab: follow the moving arrow, collect, haul home, deposit, visit Upgrades. Arrow follows continuously; death, target removal and streaming recover correctly.
- Follow junk from spawn to cutters under normal and simulated latency; no visible stepping or replication fighting. Inspect from both sides and above.
- Observe first tooth contact, disappearance, exact-position grinding/sparks; no cutter/tread/floor penetration through a full rotation.
- Two clients contest an item close to expiry: exactly one owner; expired prompt cannot award it. Verify unchanged equal yard access and roads.
- Inspect all storefront signs, tutorial/rarity labels and camera angles; listen to placeholder bundled sounds. Confirm no clipping at phone aspect ratios.
- Run mobile/device emulation and an eight-player session; measure FPS/frame cost, streaming and memory. Per-frame loops and bounded effects are budget choices, not measured performance claims.
- Custom art: inspect each exported model front/back, scale, -Z front/Y up, floor pivot, floating components, materials, simplified collision and mobile performance after import. Model IDs remain 0 until manual upload. Deliberately test a missing/moderated model and deny asset permission; procedural fallback remains usable.

Paid image-generation requests were actually submitted but rejected for plan access; do not interpret a rejected request as a completed paid generation or a credit debit. Four custom assets were separately constructed in Higgsfield 3D Jutsu, inspected and exported; they are not yet uploaded or integrated. The explicit paid generative-model requirement remains blocked.
