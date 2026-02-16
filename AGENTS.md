# forge-apple

Apple platform integration for macOS — Safari tab capture, Apple Music playlists, Calendar and Reminders via `ekctl`. Shell scripts + AppleScript, no Rust.

## Build / Lint / Test

No build step — the project is pure shell scripts and AppleScript.

### Lint

```bash
shellcheck bin/*.sh              # lint all scripts — must pass with zero warnings
shellcheck bin/safari-tabs.sh    # lint a single script
```

Install shellcheck: `brew install shellcheck`

### Test

No automated test suite. AppleScript requires a macOS GUI session, so testing is manual.

```bash
bash bin/safari-tabs.sh --count          # quick smoke test, no side effects
bash bin/safari-tabs.sh --export         # full export, requires Safari running
bash bin/music-playlists.sh spec.json    # requires Music.app running + jq installed
```

### Pre-commit checklist

1. `shellcheck bin/*.sh` — must be clean (zero warnings)
2. Smoke test on macOS — there is no CI

## Project Layout

```
forge-apple/
├── bin/                        # Executable scripts
│   ├── safari-tabs.sh          # Tab capture (local AppleScript + iCloud SQLite)
│   └── music-playlists.sh      # Create + populate Apple Music playlists from JSON
├── skills/                     # AI skill definitions (index + operation pattern)
│   ├── Demo/SKILL.md           # /Demo — interactive daily dashboard
│   ├── Music/                  # /Music — playlist automation
│   │   ├── SKILL.md
│   │   └── CreatePlaylists.md
│   └── Safari/                 # /Safari — tab capture
│       ├── SKILL.md
│       └── CaptureTabs.md
├── hooks/hooks.json            # Event hooks (currently empty)
├── defaults.yaml               # Default config (tracked in git)
├── config.yaml                 # Personal overrides (gitignored)
└── module.yaml                 # Module metadata + version
```

## Skills

| Skill | Purpose |
|-------|---------|
| Demo  | Interactive daily dashboard — calendar, reminders, Safari tabs, write-back actions |
| Music | Apple Music playlist automation from JSON specs |
| Safari | Tab capture, Reading List, bookmarks |

Skills follow the index + operation pattern:

- `SKILL.md` — index with YAML frontmatter: `name`, `description` (with `USE WHEN` triggers), `user_invocable: true`
- `OperationName.md` — step-by-step instructions; scripts in `bin/` do the actual work

## Code Style

### Shell Scripts

**Header** — every script starts with:

```bash
#!/bin/bash
set -euo pipefail
```

**Variable quoting** — double-quote all variable expansions: `"$VAR"`, never bare `$VAR`.

**Command prefix** — use `command` for builtins that macOS may alias with `-i`: `command rm`, `command cp`, `command mv`.

**Error output** — errors and diagnostics go to stderr:

```bash
echo "ERROR: file not found: $path" >&2
exit 1
```

**Graceful degradation** — suppress errors from optional/fallible external tools:

```bash
osascript -e '...' 2>/dev/null || true
sqlite3 "$DB" "..." 2>/dev/null || true
```

**Process substitution** — use `< <(...)` instead of pipes when the loop body must modify outer-scope variables:

```bash
while IFS=$'\t' read -r title url; do
    [ -n "$title" ] && [ -n "$url" ] && echo "- [${title}](${url})"
done < <(get_local_tabs)
```

**Arrays** — populate via `while IFS= read -r` loops from command output:

```bash
NAMES=()
while IFS= read -r name; do
    NAMES+=("$name")
done < <(echo "$JSON" | jq -r '.playlists[].name')
```

### AppleScript

AppleScript is invoked via `osascript`. Two patterns exist:

1. **Dynamic scripts** (current codebase default): build the script as a bash string variable, escape embedded double quotes with `sed 's/"/\\"/g'`, execute via `osascript -e "$SCRIPT"`.

2. **Static scripts** (preferred for new simple/read-only scripts): use a heredoc with single-quoted delimiter to prevent shell interpolation:

```bash
osascript <<'APPLESCRIPT'
tell application "Safari"
    -- ...
end tell
APPLESCRIPT
```

### Naming Conventions

| Element | Convention | Examples |
|---------|-----------|----------|
| Scripts | `kebab-case.sh` | `safari-tabs.sh`, `music-playlists.sh` |
| Shell variables | `UPPER_SNAKE_CASE` | `CLOUD_DB`, `PLAYLIST_COUNT`, `INPUT_FILE` |
| Shell functions | `lower_snake_case` | `get_local_tabs`, `get_cloud_tabs` |
| Skill directories | `PascalCase/` | `Demo/`, `Music/`, `Safari/` |
| Operation files | `PascalCase.md` | `CreatePlaylists.md`, `CaptureTabs.md` |

### Formatting

- No trailing whitespace; files end with a newline
- YAML files: 2-space indentation
- Shell scripts: match surrounding code (2 or 4 spaces)
- AppleScript blocks: 2-space or 4-space indentation (match context)
- Comments above the code they describe, not inline

## Configuration

Two-tier YAML configuration:

| File | Tracked | Purpose |
|------|---------|---------|
| `defaults.yaml` | Yes | Shipped defaults — keep values generic |
| `config.yaml` | No (gitignored) | Personal / locale-specific overrides |

When adding configurable values, add a generic default to `defaults.yaml` with a comment. Users create `config.yaml` with only the keys they want to change.

Key fields: `calendars`, `reminders.default`, `reminders.lists`, `event_filters`, `safari_tabs`, `music.folder`.

## Dependencies

| Tool | Required | Install | Used by |
|------|----------|---------|---------|
| macOS | Yes | — | AppleScript, SQLite |
| `jq` | For music | `brew install jq` | `music-playlists.sh` JSON parsing |
| `ekctl` | For calendar/reminders | See INSTALL.md | Demo skill, Calendar + Reminders |
| `shellcheck` | For development | `brew install shellcheck` | Linting |

New features must degrade gracefully when optional dependencies are missing.

## Architecture

- **Layer**: Behaviour (forge-core three-layer: Identity / Behaviour / Knowledge)
- **Plugin**: Registered via `.claude-plugin/plugin.json`
- **Hooks**: None active (`hooks.json` is empty)
- **Events**: None emitted (`module.yaml` has `events: []`)
- **Path resolution**: Use `Core/bin/paths.sh` for cross-module paths — do not re-implement
- **No CI**: AppleScript requires a GUI session; run `shellcheck` locally before committing
