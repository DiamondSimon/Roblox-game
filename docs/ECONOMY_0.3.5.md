# 0.3.5 monetization stress test

100 seeds per scenario per rebirth level. Independent fresh runs at each level; levels 1–9 include the permanent rebirth bonus. No inherited Scrap or junk. First delivery 75 seconds, then every 75 seconds, best of three weighted candidates with eligibility checks. One purchase per delivery: Income, Speed, Carry, Floors, Income, Speed, Carry, then save. Maximum six-hour horizon. Pets are assumed already owned (not purchased during the run). These are scenario estimates, not real retention or optimal strategies.

Temporary boost lasts 15 minutes; expires offline in the actual game. Sustained stress deliberately assumes unlimited Core funding for continuous boosts, best pet, all passes, +8 slots, continuous server income, and maximum 2× eligible rare weighting on every roll. Real multiplayer luck sponsorship is round-robin, so this is optimistic. Event and server income use max(), not multiplication; personal luck pass and temporary luck do not stack, and combined personal/server luck caps at 2×. No paid item bypasses rarity requirements.

| Scenario | First upgrade | First floor | First rebirth | Scrap/sec at first rebirth |
|---|---:|---:|---:|---:|
| FREE | 3.8m | 12.5m | 30.0m | 34,720 |
| 2X | 2.5m | 8.8m | 20.0m | 51,128 |
| VIP | 3.8m | 11.2m | 27.5m | 37,481 |
| 2X + VIP | 2.5m | 8.8m | 20.0m | 56,286 |
| 2X + VIP + best pet | 2.5m | 7.5m | 17.5m | 63,447 |
| Paid + pet + 15m income | 2.5m | 6.2m | 12.5m | 86,863 |
| Maximum sustained stress | 2.5m | 6.2m | 11.2m | 111,670 |

## Subsequent run medians

| Starting rebirth | Free run | Sustained maximum run | Cost |
|---|---:|---:|---:|
| 0 | 30.0m | 11.2m | 25,000,000 |
| 1 | 31.2m | 11.2m | 62,500,000 |
| 2 | 38.8m | 13.8m | 156,250,000 |
| 3 | 51.2m | 17.5m | 390,625,000 |
| 4 | 65.0m | 21.2m | 644,531,250 |
| 5 | 77.5m | 23.8m | 1,063,476,562 |
| 6 | 98.8m | 30.6m | 1,754,736,328 |
| 7 | 124.4m | 38.8m | 2,895,314,941 |
| 8 | 155.0m | 46.9m | 4,777,269,653 |
| 9 | 192.5m | 60.0m | 7,882,494,927 |

Summing independent medians is only a rough full-progression indicator, not a median of complete player histories. Free estimate: 14.4 hours; sustained maximum: 4.6 hours.

The formula-only maximum at rebirth 10 is 2 × 1.15 × 1.20 × 1.50 × 2 × 1.25 = 10.35 times unupgraded base production, before the +60% income-upgrade cap. Capacity and luck advantages alter the inventory separately. First-run maximum without a rebirth bonus is 6.9× before income upgrades. No five-minute complete-progression result in these scenarios. This does not prove an optimized live strategy cannot outperform the model.
