# Capture Tabs

Snapshot all open Safari tabs — local Mac windows and iCloud tabs from other devices — into a dated markdown archive. Surface's Rediscovery pool reads these archives.

## Steps

1. Run the capture script:
   ```bash
   bash "${FORGE_MODULE_ROOT:-Modules/forge-apple}/bin/safari-tabs.sh" --export
   ```

2. Save the output to the archive directory:
   - Path: `Resources/Archives/Safari Tab Snapshot YYYY-MM-DD.md` (resolve via user root)
   - If a snapshot for today already exists, overwrite it

3. Run `--count` mode and show the user a summary:
   ```bash
   bash "${FORGE_MODULE_ROOT:-Modules/forge-apple}/bin/safari-tabs.sh" --count
   ```

4. Report what was captured and where it was saved.

## Notes

- Requires Safari to be running for local tabs (AppleScript)
- Cloud tabs come from `~/Library/Safari/CloudTabs.db` (SQLite, no Safari needed)
- The archive format is markdown links: `- [Title](URL)` grouped by device
- Surface reads the most recent archive matching prefix "Safari Tab Snapshot"
