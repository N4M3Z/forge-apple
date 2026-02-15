---
name: Music
description: Apple Music playlist automation via AppleScript (macOS). USE WHEN apple music, playlist, playlists, music automation, create playlist, fill missing tracks.
user_invocable: true
---

# Music

Apple Music playlist automation for macOS. Creates, populates, and maintains playlists via AppleScript.

## Operations

| Operation | File | Description |
|-----------|------|-------------|
| Create Playlists | `CreatePlaylists.md` | Delete + recreate playlists, populate from track definitions |
| Fill Missing | `FillMissing.md` | Retry tracks that were missing on last run |

## Tools

- `bin/music-playlists.sh` — idempotent playlist creation and population
- `bin/music-playlists-fill.sh` — fill missing tracks after adding albums to library

## Limitations

- Music.app must be running (AppleScript)
- Tracks are matched by searching the Apple Music library — they must be added to the library first
- Track matching uses artist + title search; ambiguous matches may pick the wrong track
- Playlist folder structure must exist before running — create the target folder in Music.app first

When the user asks for a Music operation, read the matching operation file and follow its instructions.
