# forge-apple

Apple platform integration for macOS — Safari tab capture, Apple Music playlists, Calendar and Reminders via `ekctl`. Shell scripts + AppleScript, no Rust.

## Scripts

| Script | Purpose |
|--------|---------|
| `bin/safari-tabs.sh` | Tab capture (local via AppleScript, iCloud via CloudTabs.db) |
| `bin/music-playlists.sh` | Create + populate Apple Music playlists |
| `bin/music-playlists-fill.sh` | Fill missing tracks after adding albums |

## Skills (3)

Demo (interactive daily dashboard), Music (playlist automation), Safari (tab capture)

## Code Style

- `#!/usr/bin/env bash` + `set -euo pipefail`
- Double-quote all variables, use `command` prefix for aliased commands
- `shellcheck` clean
- AppleScript blocks via heredoc: `<<'APPLESCRIPT'`

## Configuration

- `defaults.yaml` — calendar aliases, reminder lists, event filters
- `config.yaml` (gitignored) — personal overrides

## Dependencies

- macOS (AppleScript, SQLite for CloudTabs.db)
- `ekctl` (optional) — Calendar + Reminders
- `jq` (optional) — URL encoding for Maps integration
