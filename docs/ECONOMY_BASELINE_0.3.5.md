# V0.3.5 economy scenarios

Generated from current Lua configs with 200 seeded runs per scenario over 60 minutes. These are synthetic planning cases, not retention or observed players.

Fresh inventory and balances are empty. New / Average / Efficient first deliveries: 90 / 65 / 50 seconds; later deliveries every 100 / 75 / 55 seconds, selecting among 1 / 3 / 6 weighted samples. Capacity fills then weakest items are replaced. One upgrade per delivery using this policy: Income, Speed, Carry, Floors, Income, Speed, Carry, then save for rebirth. Shop visits are folded into the assumed intervals; no additional teleport delay is modeled. Movement upgrade benefits are not modeled. No machine sale income, pet ownership/case purchases, paid Core income, or protected starter. These baseline scenarios sample the full 30-item catalog but reject items locked above rebirth zero. A sample with no eligible item yields no delivery. Pet multipliers and case expected bonuses are documented separately in RELEASE_0.3.1.md. Scrap Rush is included at its shipped server timing (+25% for the final two minutes of each ten-minute cycle). One-time reward codes and collection gifts grant only Cores and are not modeled as Scrap. Free spin adds only Cores. Rebirth eligibility is recorded without actually resetting the run.

Eight-player scarcity and PvP are not engine-simulated. The loss stress case discards 25% of attempted deliveries; it does not model a PvP equilibrium. Selection can overestimate contested-server income.

| Scenario | First upgrade median | First floor median | Rebirth eligible median | Rebirth reached within hour |
|---|---:|---:|---:|---:|
| New / free / 0% loss | 4.8 min | 18.2 min | 44.8 min | 199/200 |
| New / 2X / 0% loss | 4.8 min | 13.2 min | 31.5 min | 200/200 |
| Average / free / 0% loss | 3.6 min | 12.3 min | 29.8 min | 200/200 |
| Average / free / 25% loss | 3.6 min | 13.6 min | 33.6 min | 200/200 |
| Average / 2X / 0% loss | 2.3 min | 8.6 min | 21.1 min | 200/200 |
| Average / 2X / 25% loss | 3.6 min | 9.8 min | 23.6 min | 200/200 |
| Efficient / free / 0% loss | 2.7 min | 9.1 min | 21.9 min | 200/200 |
| Efficient / 2X / 0% loss | 1.8 min | 6.3 min | 15.5 min | 200/200 |

## Exact tuning

Income = sum(base machine income) × (1 + 0.06 × income level) × (1 + 0.05 × rebirth count) × pass multiplier. Rebirth capped at 10; pass multiplier 1 or 2. No starter income. Walking 16 → 18, carrying 12 → 14 in +0.5 increments. Eight ground spots; each of three floor upgrades adds eight; the extra-space pass adds a whole eight-slot floor, maximum 40 slots.

| Upgrade | Base Scrap | Price growth | Max levels |
|---|---:|---:|---:|
| Income | 180000 | 2.1 | 10 |
| Speed | 360000 | 1.7 | 4 |
| Carry | 420000 | 1.75 | 4 |
| Floors | 3500000 | 3 | 3 |

Free UTC daily spin: 5 Cores (60%), 10 (30%), 20 (10%); expected reward 8 Cores/day. Four daily quests still offer up to 40/day, so max 60/day and expected 48/day with all contracts. Cosmetics cost 30, 70 and 120 (220 total); average-budget estimate ~4.6 full daily sets, not a guarantee of random outcomes. No paid rerolls.

Selling: one-time Scrap = base income × 20, forfeiting passive production. Without multipliers, keeping the machine earns the same amount in 20 seconds; selling is for liquidating unwanted inventory, not an income upgrade. Values are configured in MachineConfig.

First rebirth requires 25,000,000 unspent Scrap; next cost floor(25,000,000 × 2.5^min(rebirths,3) × 1.65^max(0,rebirths-3)). Rebirth resets run progress as documented in V0.3_FEATURES.md. These initial costs need real playtest tuning; no promised optimal pacing.
