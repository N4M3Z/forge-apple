---
name: Music
description: Apple Music playlist automation via AppleScript (macOS). USE WHEN apple music, playlist, playlists, music automation, create playlist, scene soundtrack.
user_invocable: true
---

# Music

Apple Music playlist automation for macOS. Creates and populates playlists from a JSON spec via AppleScript.

## Workflow

1. The AI prepares a JSON playlist spec (from user request, scene description, or manual track list)
2. Writes the JSON to a temp file
3. Runs `music-playlists.sh` with the spec
4. Reports results (tracks added, tracks missing from library)

For scene-based playlists, the AI selects appropriate tracks based on the scene description and writes the JSON. For manual playlists, the user provides track names directly.

## Operations

| Operation | File | Description |
|-----------|------|-------------|
| Create Playlists | `CreatePlaylists.md` | Delete + recreate playlists, populate from track definitions |

To retry missing tracks after adding albums to the library, re-run CreatePlaylists with the same JSON spec. The script is idempotent — it deletes and recreates playlists each run.

## Tools

- `bin/music-playlists.sh` — data-driven playlist creation and population (reads JSON spec)

## JSON Spec Format

```json
{
  "folder": "My Playlist Folder",
  "playlists": [
    {
      "name": "Playlist Name",
      "tracks": [
        { "title": "Display Name", "search": "artist + title search query" }
      ]
    }
  ]
}
```

- `folder` — target folder playlist in Music.app (empty string = top level, folder must exist)
- `search` — Apple Music library search query (artist name + track title works best)

## Requirements

- macOS with Music.app
- `jq` — JSON parsing (`brew install jq`)

## Limitations

- Music.app must be running (AppleScript)
- Tracks are matched by searching the Apple Music library — they must be added to the library first
- Track matching uses the `search` field; ambiguous matches may pick the wrong track (first result wins)
- Playlist folder must exist before running — create the target folder in Music.app first

When the user asks for a Music operation, read the matching operation file and follow its instructions.
