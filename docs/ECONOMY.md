# Initial economy — hypotheses to playtest

The starting radio earns 1 Scrap/sec. A first microwave raises this to 3/sec. Income level 1 costs 100, so after a 30-second first delivery the first upgrade should be affordable around the first minute. Travel and spawn contention can change this; measure in Studio.

Income = sum of base machine income × (1 + 0.15 × income level) × verified 2X pass multiplier.

Income upgrade price = floor(100 × 1.65^level), cap 20. Additional free slot price = floor(250 × 1.8^level), cap 7. Six base slots, up to 13 earned slots, optionally five pass slots, maximum 18. Upgrades multiply base income linearly; repeated upgrades do not compound income exponentially.

All world salvage is free in this milestone. Spawns occur every seven seconds with weighted selection from the catalog, a maximum of twelve world machines and 120-second expiry. The first server batch includes a Rare machine to expose an early collection goal. Full-yard replacement/sale and duplicate sinks are next milestones; a full yard can currently only expand.

Currency packs are fixed 500 / 2,000 / 6,000 and currently disabled. No Robux prices are chosen in code. Soft-currency income stops growing at 1e12; existing balances and paid grants are not truncated. These are initial tunings, not validated retention or revenue projections.
