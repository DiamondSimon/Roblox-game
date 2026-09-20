# Architecture

ServerMain loads data before spawning a character, allocates one of eight yards, starts centralized income/spawn loops, and installs the single receipt callback. The client requests actions; it never sends currency, ownership or item values.

The server creates Remotes/Game. Accepted client requests are `Sync`, `DiscardCarry`, and `Upgrade` with a validated `Income` or `Slots` key. Pickup and intake are server-handled ProximityPrompts. All proximity-dependent actions check a living character and distance; action requests are rate-limited. Successful pickup removes the world entry before attaching its model. There is one carry record per player.

WorldService generates inexpensive anchored Parts. MachineService generates category-based temporary art with a shared model factory, avoiding per-item scripts. GameplayService owns state transitions. YardService owns allocation and visual reconstruction. ClientMain owns the mobile-friendly interface; move its panels into controller modules when the next milestone grows them.

## Authority and limits

Distance checks and a minimum haul-time check reject basic prompt/teleport abuse, but are not a complete movement anti-cheat. Robust movement validation, remote abuse load tests, and latency testing remain release gates. Prompt hold duration is not a secure theft timer; stealing will need a separately validated server timer.

## Persistence

Each player has one `player_<UserId>` DataStore record with `Data` and an expiring `Lease`. UpdateAsync atomically acquires a 180-second session lease; autosaves renew it every 30 seconds. A session stops gameplay near lease expiry. Different active session tokens cannot overwrite a profile. Read/validation failures never fall back to writable defaults.

All gameplay mutations are non-yielding. Commit sets Busy, snapshots the profile, applies a non-yielding transform, and writes it atomically. Gameplay skips Busy sessions. Developer product rewards and receipt amounts live in the same record. Durable receipts missing from memory are merged on later saves to handle an ambiguous committed write followed by an error. Unknown receipts remain pending.

## Deliberate milestone boundaries

No cross-player ownership transfer exists yet. Stealing must use a durable transfer journal with recovery before it can move saved inventory between two profiles; two unrelated saves are not an atomic transfer. Paid-content protection must persist through every grant, mutation, fusion and theft path. No paid random rewards or luck boosts are enabled.

## Reproducibility

Source is authoritative. `tools/build.py` rebuilds the XML place. GitHub Actions parses source, runs module tests, builds the place and uploads a build artifact. Studio runtime validation is still required and is not replaced by CI.
