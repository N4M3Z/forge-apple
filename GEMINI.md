# GEMINI.md — forge-apple

This directory contains the `forge-apple` module, a platform integration layer for macOS. It provides capabilities for Safari tab management, Apple Music playlist automation, and Calendar + Reminders integration via the `ekctl` CLI.

## Project Overview

`forge-apple` is a **Behaviour** layer module within the `forge-core` three-layer architecture (Identity / Behaviour / Knowledge). It acts as a bridge between the AI agent and native macOS applications.

- **Main Technologies:** AppleScript, Bash, SQLite (iCloud tabs), `jq` (JSON parsing).
- **Core Integrations:**
    - **Safari:** Tab capture (local and iCloud), Reading List, and Bookmarks.
    - **Apple Music:** Idempotent playlist creation and population from JSON specs.
    - **Calendar & Reminders:** Native OS integration via the external `ekctl` dependency.
- **Architecture:** Skills-based interaction. Each capability is exposed via a "Skill" (found in the `skills/` directory) which provides a structured interface for the agent to follow.

## Building and Running

This project consists of shell scripts and AppleScript; there is no compilation or build step.

### Key Commands

- **Verification:** Run `bash bin/safari-tabs.sh --count` to verify basic Safari integration. See `VERIFY.md` for a full checklist.
- **Safari Tab Export:** `bash bin/safari-tabs.sh --export` (Snapshots tabs to markdown).
- **Music Playlists:** `bash bin/music-playlists.sh <spec.json>` (Creates/updates playlists).
- **Calendar/Reminders:** Requires `ekctl` (External dependency). Use `ekctl list events` or `ekctl list reminders`.

### Dependencies

- **macOS:** Required for AppleScript and native DB access.
- **ekctl:** Required for Calendar and Reminders features.
- **jq:** Required for Music automation and URL encoding in the Demo skill.

## Development Conventions

- **Path Resolution:** Always use `Core/bin/paths.sh` as the shared cross-platform path contract.
  ```bash
  eval "$(bash Core/bin/paths.sh)"
  ```
- **Configuration:** Use `defaults.yaml` for default settings. Users can override these by creating a gitignored `config.yaml`.
- **Skills:** Interaction logic is defined in `SKILL.md` files within the `skills/` directory. These files contain instructions, tools, and phases for complex interactions (like the daily `Demo` dashboard).
- **Idempotency:** The `music-playlists.sh` script is idempotent; it deletes and recreates playlists on each run to ensure consistency with the provided JSON spec.
- **Graceful Degradation:** Features requiring `ekctl` should check for its presence and degrade gracefully if missing, still providing Safari and Music capabilities.

## Directory Structure

- `bin/`: Executable shell and AppleScript integration scripts.
- `skills/`: Markdown-based skill definitions for agent interaction.
    - `Demo/`: Today at a Glance dashboard (Calendar, Reminders, Safari).
    - `Music/`: Apple Music playlist automation.
    - `Safari/`: Safari tab and bookmark management.
- `hooks/`: Reserved for event-based triggers (currently empty).
- `module.yaml`: Module metadata and capability flags.
- `defaults.yaml`: Default configuration schema.
- `VERIFY.md`: Post-installation verification steps.
- `INSTALL.md`: Setup and dependency guide.
