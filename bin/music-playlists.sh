#!/bin/bash
# Recreate Exodus 3.8-3.13 Apple Music playlists from scene files.
# Idempotent — deletes existing playlists, creates fresh inside "Setting - TTRPG".
#
# Tracks are matched by searching the Apple Music library. Tracks not in
# the library will show as MISS — add the album to library first, then
# either re-run this script or run music-playlists-fill.sh.
#
# Usage: bash Hooks/music-playlists.sh

set -euo pipefail

echo "=== Step 1: Delete existing Exodus playlists ==="
osascript <<'APPLESCRIPT'
tell application "Music"
  set output to ""
  set allP to every user playlist
  repeat with p in allP
    try
      set n to name of p
      if n starts with "Exodus 3." then
        delete p
        set output to output & "Deleted: " & n & return
      end if
    end try
  end repeat
  if output is "" then return "No existing Exodus playlists found."
  return output
end tell
APPLESCRIPT

echo ""
echo "=== Step 2: Create playlists inside Setting - TTRPG ==="
osascript <<'APPLESCRIPT'
tell application "Music"
  set ttrpg to folder playlist "Setting - TTRPG"
  make new playlist at ttrpg with properties {name:"Exodus 3.8 — The Harp Awakens"}
  make new playlist at ttrpg with properties {name:"Exodus 3.9 — Walking the Void"}
  make new playlist at ttrpg with properties {name:"Exodus 3.10 — Monidan's Rescue"}
  make new playlist at ttrpg with properties {name:"Exodus 3.11 — Avernus War Zone"}
  make new playlist at ttrpg with properties {name:"Exodus 3.12 — Audience with Asmodeus"}
  make new playlist at ttrpg with properties {name:"Exodus 3.13 — The Wasting Tower"}
  return "Created 6 playlists in Setting - TTRPG"
end tell
APPLESCRIPT

echo ""
echo "=== Step 3: Populate playlists ==="
osascript <<'APPLESCRIPT'
tell application "Music"
  set output to ""

  -- Find playlists by iterating (avoids folder lookup issues)
  set allP to every user playlist
  set p38 to missing value
  set p39 to missing value
  set p310 to missing value
  set p311 to missing value
  set p312 to missing value
  set p313 to missing value

  repeat with p in allP
    try
      set n to name of p
      if n is "Exodus 3.8 — The Harp Awakens" then set p38 to p
      if n is "Exodus 3.9 — Walking the Void" then set p39 to p
      if n is "Exodus 3.10 — Monidan's Rescue" then set p310 to p
      if n is "Exodus 3.11 — Avernus War Zone" then set p311 to p
      if n is "Exodus 3.12 — Audience with Asmodeus" then set p312 to p
      if n is "Exodus 3.13 — The Wasting Tower" then set p313 to p
    end try
  end repeat

  -- Sanity check
  if p38 is missing value then set output to output & "ERROR: 3.8 playlist not found" & return
  if p39 is missing value then set output to output & "ERROR: 3.9 playlist not found" & return
  if p310 is missing value then set output to output & "ERROR: 3.10 playlist not found" & return
  if p311 is missing value then set output to output & "ERROR: 3.11 playlist not found" & return
  if p312 is missing value then set output to output & "ERROR: 3.12 playlist not found" & return
  if p313 is missing value then set output to output & "ERROR: 3.13 playlist not found" & return

  -- === 3.8: The Harp Awakens ===
  -- Scene: WINDMILLS, MEETING NEIL, THE ALGORITHM (all TENET OST)
  set r to search playlist "Music" for "WINDMILLS Ludwig Göransson"
  if r is not {} then
    duplicate item 1 of r to p38
    set output to output & "3.8: + WINDMILLS" & return
  else
    set output to output & "3.8: MISS WINDMILLS" & return
  end if
  set r to search playlist "Music" for "MEETING NEIL Ludwig Göransson"
  if r is not {} then
    duplicate item 1 of r to p38
    set output to output & "3.8: + MEETING NEIL" & return
  else
    set output to output & "3.8: MISS MEETING NEIL" & return
  end if
  set r to search playlist "Music" for "THE ALGORITHM Ludwig Göransson"
  if r is not {} then
    duplicate item 1 of r to p38
    set output to output & "3.8: + THE ALGORITHM" & return
  else
    set output to output & "3.8: MISS THE ALGORITHM" & return
  end if

  -- === 3.9: Walking the Void ===
  -- Scene: Annihilation OST (header), Heptapod B, Under the Skin, Nebulous Dawn
  set r to search playlist "Music" for "The Alien Ben Salisbury"
  if r is not {} then
    duplicate item 1 of r to p39
    set output to output & "3.9: + The Alien (Annihilation)" & return
  else
    set output to output & "3.9: MISS Annihilation" & return
  end if
  set r to search playlist "Music" for "Heptapod B"
  if r is not {} then
    duplicate item 1 of r to p39
    set output to output & "3.9: + Heptapod B" & return
  else
    set output to output & "3.9: MISS Heptapod B" & return
  end if
  set r to search playlist "Music" for "Mica Levi"
  if r is not {} then
    duplicate item 1 of r to p39
    set output to output & "3.9: + " & (name of item 1 of r) & " (Under the Skin)" & return
  else
    set output to output & "3.9: MISS Under the Skin (not in library)" & return
  end if
  set r to search playlist "Music" for "Nebulous Dawn"
  if r is not {} then
    duplicate item 1 of r to p39
    set output to output & "3.9: + Nebulous Dawn" & return
  else
    set output to output & "3.9: MISS Nebulous Dawn (not in library)" & return
  end if

  -- === 3.10: Monidan's Rescue ===
  -- Scene: Sicario OST (header), The Beast, Melancholia Main Theme, Says
  set r to search playlist "Music" for "The Beast Johann"
  if r is not {} then
    duplicate item 1 of r to p310
    set output to output & "3.10: + The Beast (Sicario)" & return
  else
    set output to output & "3.10: MISS The Beast" & return
  end if
  set r to search playlist "Music" for "Melancholia"
  if r is not {} then
    duplicate item 1 of r to p310
    set output to output & "3.10: + " & (name of item 1 of r) & " (Melancholia)" & return
  else
    set output to output & "3.10: MISS Melancholia (not in library)" & return
  end if
  set r to search playlist "Music" for "Says Nils Frahm"
  if r is not {} then
    duplicate item 1 of r to p310
    set output to output & "3.10: + Says" & return
  else
    set output to output & "3.10: MISS Says" & return
  end if

  -- === 3.11: Avernus War Zone ===
  -- Scene: God of War (header), Brothers in Arms, Supermarine, The Oil
  set r to search playlist "Music" for "God of War Bear McCreary"
  if r is not {} then
    duplicate item 1 of r to p311
    set output to output & "3.11: + God of War" & return
  else
    set output to output & "3.11: MISS God of War" & return
  end if
  set r to search playlist "Music" for "Brothers in Arms Holkenborg"
  if r is {} then set r to search playlist "Music" for "Brothers in Arms Junkie XL"
  if r is not {} then
    duplicate item 1 of r to p311
    set output to output & "3.11: + Brothers in Arms" & return
  else
    set output to output & "3.11: MISS Brothers in Arms (not in library)" & return
  end if
  set r to search playlist "Music" for "Supermarine"
  if r is not {} then
    duplicate item 1 of r to p311
    set output to output & "3.11: + Supermarine" & return
  else
    set output to output & "3.11: MISS Supermarine (not in library)" & return
  end if
  set oilFound to false
  set r to search playlist "Music" for "Johann Johannsson"
  if r is not {} then
    repeat with t in r
      if (name of t) is "The Oil" then
        duplicate t to p311
        set output to output & "3.11: + The Oil (Sicario)" & return
        set oilFound to true
        exit repeat
      end if
    end repeat
  end if
  if not oilFound then set output to output & "3.11: MISS The Oil (not in library)" & return

  -- === 3.12: Audience with Asmodeus ===
  -- Scene: Sea Wall, Arrival, Wallace, Creation
  set r to search playlist "Music" for "Sea Wall Hans Zimmer"
  if r is not {} then
    duplicate item 1 of r to p312
    set output to output & "3.12: + Sea Wall" & return
  else
    set output to output & "3.12: MISS Sea Wall" & return
  end if
  set r to search playlist "Music" for "Arrival Johann"
  if r is not {} then
    duplicate item 1 of r to p312
    set output to output & "3.12: + Arrival" & return
  else
    set output to output & "3.12: MISS Arrival" & return
  end if
  set r to search playlist "Music" for "Wallace Hans Zimmer"
  if r is not {} then
    duplicate item 1 of r to p312
    set output to output & "3.12: + Wallace" & return
  else
    set output to output & "3.12: MISS Wallace" & return
  end if
  set r to search playlist "Music" for "Creation Mica Levi"
  if r is not {} then
    duplicate item 1 of r to p312
    set output to output & "3.12: + Creation" & return
  else
    set output to output & "3.12: MISS Creation (not in library)" & return
  end if

  -- === 3.13: The Wasting Tower ===
  -- Scene: Metropolis (header), Black Needle, 200 Days, Mortal Shell OST, Hringrás
  set r to search playlist "Music" for "Atrium Carceri"
  if r is not {} then
    repeat with t in r
      set n to name of t
      if n is "Black Needle" then
        duplicate t to p313
        set output to output & "3.13: + Black Needle" & return
      end if
      if n is "200 Days" then
        duplicate t to p313
        set output to output & "3.13: + 200 Days" & return
      end if
      if n is "The Gargantuan Tower" then
        duplicate t to p313
        set output to output & "3.13: + The Gargantuan Tower (Mortal Shell)" & return
      end if
    end repeat
  end if
  set r to search playlist "Music" for "Danheim"
  if r is not {} then
    repeat with t in r
      if (name of t) is "Hringras" or (name of t) is "Hringrás" then
        duplicate t to p313
        set output to output & "3.13: + Hringras" & return
        exit repeat
      end if
    end repeat
  end if

  return output
end tell
APPLESCRIPT

echo ""
echo "=== Step 4: Verify ==="
osascript <<'APPLESCRIPT'
tell application "Music"
  set output to ""
  set allP to every user playlist
  repeat with p in allP
    try
      set n to name of p
      if n starts with "Exodus 3." then
        set tc to count of tracks of p
        set output to output & n & " (" & tc & " tracks)" & return
      end if
    end try
  end repeat
  if output is "" then return "ERROR: No Exodus playlists found!"
  return output
end tell
APPLESCRIPT
