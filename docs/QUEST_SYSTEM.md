> Historical V0.2 reference. V0.3 supersedes this document where behavior differs. Current rules: [V0.3_FEATURES.md](V0.3_FEATURES.md), [ECONOMY_V3.md](ECONOMY_V3.md), [DATA_SCHEMA.md](DATA_SCHEMA.md). In particular: no fresh starter, eight slots per floor, shared shops, free daily wheel and carried-junk combat.

# Daily quests and Cores

`QuestConfig.Daily` is the authoritative catalog. QuestService updates progress from server gameplay, never from client-supplied counts.

| Quest | Target | Cores |
|---|---:|---:|
| Delivered machines | 5 | 10 |
| Delivered Rare or higher | 2 | 12 |
| Purchased upgrades | 2 | 8 |
| Distinct inspected landmarks | 3 | 10 |

The same four configurable contracts repeat daily. Reset uses floor(server Unix time / 86400), i.e. midnight UTC. No timezone/client-clock authority. Progress is capped at target and normally autosaved every 30 seconds. Inspecting the same landmark repeatedly does not count; its prompt verifies server distance. Delivery counts only after placement/replacement. A new rare discovery is not required for the rare delivery quest.

A completed contract exposes CLAIM in the quest menu. Claim verifies ID, completion, day and unclaimed state, then persists the Core reward and claim marker in one profile write before success feedback. Repeat requests cannot double-award. If a durable result is uncertain, freeze the session and require rejoin; do not let later autosaves overwrite a potentially successful transaction. Practice claims work in memory but reset on Stop.

FirstQuestCompleted is currently logged upon successful claim, not the earlier instant the target is reached. FirstCoresEarned logs that first quest reward. Quest indicators derive from server snapshots. Day rollover drops unfinished/unclaimed prior-day progress; this is explicit daily-contract behavior.

Later: rotating contract pools, weekly contracts, discovery milestones, event participation. No quests for unimplemented theft, defense or fusion.
