# forge-apple

Apple platform integration for macOS. Provides Safari tab capture, Apple Music playlist automation, and Calendar + Reminders management via `ekctl`.

## Status

| Capability | Status | Tool |
|-----------|--------|------|
| Safari tabs | Implemented | `bin/safari-tabs.sh` (AppleScript + SQLite) |
| Calendar | Implemented | `ekctl` (EventKit) — external dependency |
| Reminders | Implemented | `ekctl` (EventKit) — external dependency |
| Apple Music | Implemented | `bin/music-playlists.sh` (AppleScript) |

> `ekctl` is an external CLI tool, not bundled with this module. See [INSTALL.md](INSTALL.md) for installation.

## Layer

**Behaviour** — part of forge-core's three-layer architecture (Identity / Behaviour / Knowledge). No active hooks yet (`events: []`).

## Layout

```
forge-apple/
├── .claude-plugin/plugin.json    # Claude Code plugin registration
├── bin/
│   ├── safari-tabs.sh            # Tab capture (local via AppleScript, iCloud via CloudTabs.db)
│   └── music-playlists.sh        # Create + populate Apple Music playlists from JSON spec
├── hooks/
│   └── hooks.json                # Empty — no active hooks
├── skills/
│   ├── Demo/
│   │   └── SKILL.md              # /Demo — interactive daily dashboard with OS write-back
│   ├── Music/
│   │   ├── SKILL.md              # /Music — Apple Music playlist automation
│   │   └── CreatePlaylists.md    # Operation: create + populate playlists from JSON
│   └── Safari/
│       ├── SKILL.md              # /Safari — tab capture, Reading List, bookmarks
│       └── CaptureTabs.md        # Operation: snapshot tabs to dated archive
├── defaults.yaml                 # Default configuration (calendars, reminders, filters)
├── module.yaml                   # Module metadata
├── LICENSE                       # EUPL v1.2
├── CONTRIBUTING.md               # Development guidelines
├── INSTALL.md                    # Installation guide
└── VERIFY.md                     # Post-install verification
```

## Skills

| Skill | Purpose |
|-------|---------|
| `Demo` | Interactive daily dashboard — calendar, reminders, Safari tabs. Supports write-back: triage reminders, block focus time, create reminders, open routes in Maps. |
| `Music` | Apple Music playlist automation — create and populate playlists from a JSON spec via AppleScript. |
| `Safari` | Tab capture, Reading List, and bookmark operations (macOS). |

### Safari tab capture

Snapshots all open Safari tabs — local Mac windows and iCloud tabs from other devices — into a dated markdown archive. The `surface` binary (forge-reflect) reads these archives for its Rediscovery pool.

```bash
bash bin/safari-tabs.sh --export   # markdown output: [Title](URL) grouped by device
bash bin/safari-tabs.sh --count    # summary counts only
```

- Local tabs require Safari to be running (AppleScript)
- Cloud tabs read `~/Library/Safari/CloudTabs.db` (SQLite, no Safari needed)

### Apple Music playlists

Creates and populates Apple Music playlists from a JSON spec via AppleScript. The AI prepares the spec (from scene descriptions, mood requests, or manual track lists), the script executes it. Tracks are matched by searching the Apple Music library — albums must be added to the library first.

```bash
bash bin/music-playlists.sh playlists.json   # idempotent: delete + create + populate
```

- Music.app must be running
- Playlist folder must exist in Music.app
- Requires `jq` for JSON parsing (`brew install jq`)

## Calendar and Reminders

When `ekctl` is installed, forge-apple provides full Calendar and Reminders integration:

```bash
ekctl list calendars                                          # all calendars + reminder lists
ekctl list events --calendar work --from 2026-02-03 --to 2026-02-07
ekctl list reminders --list tasks --completed false
ekctl add event --calendar <alias> --title "..." --start <iso> --end <iso>
ekctl add reminder --list <alias> --title "..." [--due <iso>] [--priority 1|5|9]
ekctl complete reminder <uuid>
ekctl delete event <uuid>
ekctl alias set <name> <calendar-uuid>                        # register a friendly alias
```

### Calendar aliases

The `calendar` field in output contains an **ekctl alias name**. Configure via `ekctl alias set <name> <calendar-uuid>`. Common examples: `work`, `personal`, `family`, `holidays`.

## Configuration

Override defaults by creating `config.yaml` (gitignored) with only the keys you want to change. See `defaults.yaml` for the full schema.

Key settings:
- `calendars` — ekctl calendar aliases to query
- `reminders.lists` — reminder list names to display
- `event_filters` — title prefixes to filter out (e.g. cancelled events, sync artifacts)
- `safari_tabs` — enable/disable Safari tab count in the Demo skill
