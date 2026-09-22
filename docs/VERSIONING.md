# Release versioning

Per project owner instruction, increment only the final component by one for each release: **0.3.5 → 0.3.6 → 0.3.7**. Do not jump minor versions for feature releases. Existing 0.1/0.2/0.3 artifacts and commit history remain unchanged.

Update GameConfig.Version, server/client version labels, build output path, build-parity test path, CI artifact path, README and changelog together. Commit source, tests, documentation and generated Studio place together to GitHub. Save SchemaVersion is independent and changes only when the persisted shape needs migration; 0.3.5 uses schema 7.
