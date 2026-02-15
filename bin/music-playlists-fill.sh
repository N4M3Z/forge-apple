#!/bin/bash
# Fill missing tracks into existing Exodus playlists.
# Run after adding albums to your Apple Music library.
#
# Currently missing (as of 2026-02-06):
#   - Under the Skin (Mica Levi)  → 3.9 + 3.12
#   - Zeit (Tangerine Dream)      → 3.9
#   - Sicario (Jóhann Jóhannsson) → 3.11
#
# Usage: bash Hooks/music-playlists-fill.sh

set -euo pipefail

osascript <<'APPLESCRIPT'
tell application "Music"
  set output to ""
  set added to 0

  -- Find playlists by iterating (avoids folder lookup issues)
  set allP to every user playlist
  set p39 to missing value
  set p311 to missing value
  set p312 to missing value

  repeat with p in allP
    try
      set n to name of p
      if n is "Exodus 3.9 — Walking the Void" then set p39 to p
      if n is "Exodus 3.11 — Avernus War Zone" then set p311 to p
      if n is "Exodus 3.12 — Audience with Asmodeus" then set p312 to p
    end try
  end repeat

  if p39 is missing value then return "ERROR: Exodus 3.9 playlist not found"
  if p311 is missing value then return "ERROR: Exodus 3.11 playlist not found"
  if p312 is missing value then return "ERROR: Exodus 3.12 playlist not found"

  -- 3.9: Nebulous Dawn (Tangerine Dream / Zeit)
  set r to search playlist "Music" for "Nebulous Dawn"
  if r is not {} then
    duplicate item 1 of r to p39
    set output to output & "3.9: + Nebulous Dawn" & return
    set added to added + 1
  else
    set output to output & "3.9: MISS Nebulous Dawn — add Zeit by Tangerine Dream to library" & return
  end if

  -- 3.9: Under the Skin (Mica Levi)
  set r to search playlist "Music" for "Mica Levi"
  if r is not {} then
    duplicate item 1 of r to p39
    set output to output & "3.9: + " & (name of item 1 of r) & " (Under the Skin)" & return
    set added to added + 1
  else
    set output to output & "3.9: MISS Under the Skin — add the album to library" & return
  end if

  -- 3.11: The Oil (Jóhann Jóhannsson / Sicario)
  set oilFound to false
  set r to search playlist "Music" for "Johann Johannsson"
  if r is not {} then
    repeat with t in r
      if (name of t) is "The Oil" then
        duplicate t to p311
        set output to output & "3.11: + The Oil (Sicario)" & return
        set added to added + 1
        set oilFound to true
        exit repeat
      end if
    end repeat
  end if
  if not oilFound then set output to output & "3.11: MISS The Oil — add Sicario OST to library" & return

  -- 3.12: Creation (Mica Levi / Under the Skin)
  set r to search playlist "Music" for "Creation Mica Levi"
  if r is {} then set r to search playlist "Music" for "Creation Under Skin"
  if r is not {} then
    duplicate item 1 of r to p312
    set output to output & "3.12: + " & (name of item 1 of r) & " (Creation)" & return
    set added to added + 1
  else
    set output to output & "3.12: MISS Creation — add Under the Skin OST to library" & return
  end if

  set output to output & return & "Added " & added & " of 4 missing tracks."
  return output
end tell
APPLESCRIPT
