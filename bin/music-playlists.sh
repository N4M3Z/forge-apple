#!/bin/bash
# music-playlists.sh — create and populate Apple Music playlists from a JSON spec.
# Idempotent — deletes matching playlists, creates fresh, populates from library.
#
# Tracks are matched by searching the Apple Music library. Tracks not in
# the library will show as MISS — add the album to library first, then re-run.
#
# Usage:
#   bash music-playlists.sh playlists.json     # from file
#   bash music-playlists.sh < playlists.json   # from stdin (if no arg)
#
# JSON format:
#   {
#     "folder": "My Folder",           // target folder playlist (empty = top level)
#     "playlists": [
#       {
#         "name": "Playlist Name",
#         "tracks": [
#           { "title": "Display Name", "search": "search query for library" }
#         ]
#       }
#     ]
#   }
#
# Requires: jq, Music.app (macOS)

set -euo pipefail

# Read JSON from file arg or stdin
if [ $# -ge 1 ]; then
  INPUT_FILE="$1"
  if [ ! -f "$INPUT_FILE" ]; then
    echo "ERROR: file not found: $INPUT_FILE" >&2
    exit 1
  fi
  JSON=$(cat "$INPUT_FILE")
else
  JSON=$(cat)
fi

# Validate JSON
if ! echo "$JSON" | jq empty 2>/dev/null; then
  echo "ERROR: invalid JSON input" >&2
  exit 1
fi

FOLDER=$(echo "$JSON" | jq -r '.folder // ""')
PLAYLIST_COUNT=$(echo "$JSON" | jq '.playlists | length')

if [ "$PLAYLIST_COUNT" -eq 0 ]; then
  echo "ERROR: no playlists defined in JSON" >&2
  exit 1
fi

# Collect playlist names for delete + create
NAMES=()
while IFS= read -r name; do
  NAMES+=("$name")
done < <(echo "$JSON" | jq -r '.playlists[].name')

echo "=== Step 1: Delete existing playlists ==="

# Build AppleScript to delete matching playlists
DELETE_SCRIPT='tell application "Music"
  set output to ""
  set allP to every user playlist
  repeat with p in allP
    try
      set n to name of p'

for name in "${NAMES[@]}"; do
  # Escape double quotes for AppleScript
  escaped=$(printf '%s' "$name" | sed 's/"/\\"/g')
  DELETE_SCRIPT+="
      if n is \"${escaped}\" then
        delete p
        set output to output & \"Deleted: \" & n & return
      end if"
done

DELETE_SCRIPT+='
    end try
  end repeat
  if output is "" then return "No matching playlists found."
  return output
end tell'

osascript -e "$DELETE_SCRIPT"

echo ""
echo "=== Step 2: Create playlists ==="

# Build AppleScript to create playlists
if [ -n "$FOLDER" ]; then
  escaped_folder=$(printf '%s' "$FOLDER" | sed 's/"/\\"/g')
  CREATE_SCRIPT="tell application \"Music\"
  set targetFolder to folder playlist \"${escaped_folder}\""
else
  CREATE_SCRIPT='tell application "Music"'
fi

for name in "${NAMES[@]}"; do
  escaped=$(printf '%s' "$name" | sed 's/"/\\"/g')
  if [ -n "$FOLDER" ]; then
    CREATE_SCRIPT+="
  make new playlist at targetFolder with properties {name:\"${escaped}\"}"
  else
    CREATE_SCRIPT+="
  make new playlist with properties {name:\"${escaped}\"}"
  fi
done

CREATE_SCRIPT+="
  return \"Created ${PLAYLIST_COUNT} playlists"
if [ -n "$FOLDER" ]; then
  CREATE_SCRIPT+=" in ${FOLDER}"
fi
CREATE_SCRIPT+="\"
end tell"

osascript -e "$CREATE_SCRIPT"

echo ""
echo "=== Step 3: Populate playlists ==="

# Build AppleScript to find playlists and populate tracks
POPULATE_SCRIPT='tell application "Music"
  set output to ""
  set allP to every user playlist'

# Declare variables for each playlist
for i in $(seq 0 $((PLAYLIST_COUNT - 1))); do
  POPULATE_SCRIPT+="
  set p${i} to missing value"
done

# Find playlists by name
POPULATE_SCRIPT+='
  repeat with p in allP
    try
      set n to name of p'

for i in $(seq 0 $((PLAYLIST_COUNT - 1))); do
  name="${NAMES[$i]}"
  escaped=$(printf '%s' "$name" | sed 's/"/\\"/g')
  POPULATE_SCRIPT+="
      if n is \"${escaped}\" then set p${i} to p"
done

POPULATE_SCRIPT+='
    end try
  end repeat'

# Verify all found
for i in $(seq 0 $((PLAYLIST_COUNT - 1))); do
  name="${NAMES[$i]}"
  escaped=$(printf '%s' "$name" | sed 's/"/\\"/g')
  POPULATE_SCRIPT+="
  if p${i} is missing value then set output to output & \"ERROR: playlist not found: ${escaped}\" & return"
done

# Add tracks to each playlist
for i in $(seq 0 $((PLAYLIST_COUNT - 1))); do
  name="${NAMES[$i]}"
  TRACK_COUNT=$(echo "$JSON" | jq ".playlists[$i].tracks | length")

  for j in $(seq 0 $((TRACK_COUNT - 1))); do
    title=$(echo "$JSON" | jq -r ".playlists[$i].tracks[$j].title")
    search=$(echo "$JSON" | jq -r ".playlists[$i].tracks[$j].search")

    # Escape for AppleScript
    escaped_search=$(printf '%s' "$search" | sed 's/"/\\"/g')
    escaped_title=$(printf '%s' "$title" | sed 's/"/\\"/g')
    # Short name for reporting
    short_name=$(echo "$name" | sed 's/.*— //' | head -c 30)

    POPULATE_SCRIPT+="
  set r to search playlist \"Music\" for \"${escaped_search}\"
  if r is not {} then
    duplicate item 1 of r to p${i}
    set output to output & \"${short_name}: + ${escaped_title}\" & return
  else
    set output to output & \"${short_name}: MISS ${escaped_title}\" & return
  end if"
  done
done

POPULATE_SCRIPT+='
  return output
end tell'

osascript -e "$POPULATE_SCRIPT"

echo ""
echo "=== Step 4: Verify ==="

VERIFY_SCRIPT='tell application "Music"
  set output to ""
  set allP to every user playlist
  repeat with p in allP
    try
      set n to name of p'

for name in "${NAMES[@]}"; do
  escaped=$(printf '%s' "$name" | sed 's/"/\\"/g')
  VERIFY_SCRIPT+="
      if n is \"${escaped}\" then
        set tc to count of tracks of p
        set output to output & n & \" (\" & tc & \" tracks)\" & return
      end if"
done

VERIFY_SCRIPT+='
    end try
  end repeat
  if output is "" then return "ERROR: No matching playlists found!"
  return output
end tell'

osascript -e "$VERIFY_SCRIPT"
