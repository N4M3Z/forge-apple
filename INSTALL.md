# forge-apple — Installation

> **For AI agents**: This guide covers installation of forge-apple — the Apple platform adapter (macOS only).

## As part of forge-core (submodule)

Already included as a submodule. No build step required — this module uses shell scripts and AppleScript only.

Ensure the module is listed in `defaults.yaml`:

```yaml
modules:
  - forge-apple    # Platform — Safari, Calendar, Reminders, Music (macOS)
```

## Standalone (manual clone)

```bash
git clone https://github.com/N4M3Z/forge-apple.git
```

> Note: `claude plugin install forge-apple` is not yet available. Install via submodule or manual clone.

## What gets installed

| Component | Purpose |
|-----------|---------|
| `bin/safari-tabs.sh` | Safari tab capture (local + iCloud) |
| `bin/music-playlists.sh` | Apple Music playlist creation and population |
| `bin/music-playlists-fill.sh` | Fill missing tracks in existing playlists |
| `skills/Demo/` | Interactive daily dashboard with OS write-back |
| `skills/Safari/` | Safari tab operations |
| `skills/Music/` | Apple Music playlist automation |

## Dependencies

| Dependency | Required | Install | Purpose |
|-----------|----------|---------|---------|
| macOS | Yes | — | AppleScript, EventKit, Safari CloudTabs.db |
| Homebrew | Recommended | [brew.sh](https://brew.sh/) | Package manager for dependencies below |
| ekctl | Optional | See [ekctl repo](https://github.com/N4M3Z/ekctl) | Calendar + Reminders via EventKit CLI |
| jq | Optional | `brew install jq` | URL encoding for Maps integration in Demo skill |

Without `ekctl`, the module still provides Safari tab capture and Apple Music automation. Calendar and Reminders features require `ekctl`.

### ekctl

`ekctl` provides CLI access to Apple Calendar and Reminders via the EventKit framework. It is macOS-only.

```bash
# After installing ekctl, configure calendar aliases:
ekctl alias set work <calendar-uuid>
ekctl alias set personal <calendar-uuid>
ekctl alias list    # show configured aliases
```

## Configuration

Copy `defaults.yaml` to `config.yaml` and edit. Only override the keys you want to change — `config.yaml` is gitignored.

```yaml
# config.yaml — personal overrides
event_filters:
  - "Cancelled"
  - "Your locale-specific filter here"
```

## Verify

See [VERIFY.md](VERIFY.md) for the post-installation checklist.
