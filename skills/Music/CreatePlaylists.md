# Create Playlists

Data-driven playlist creation for Apple Music. Reads a JSON spec, deletes existing playlists matching the names, recreates them inside the target folder, and populates with tracks from the library.

## Steps

1. Prepare a JSON playlist spec. Either the user provides track names, or the AI selects tracks based on a scene/mood description.

   Example spec:
   ```json
   {
     "folder": "My Playlists",
     "playlists": [
       {
         "name": "Focus — Deep Work",
         "tracks": [
           { "title": "Nuvole Bianche", "search": "Nuvole Bianche Ludovico Einaudi" },
           { "title": "Experience", "search": "Experience Ludovico Einaudi" }
         ]
       }
     ]
   }
   ```

   The `search` field should include artist name + track title for best matching. The `title` field is used for human-readable reporting only.

2. Write the JSON to a temp file and run:
   ```bash
   bash "${FORGE_MODULE_ROOT:-Modules/forge-apple}/bin/music-playlists.sh" /tmp/playlists.json
   ```

3. The script executes four phases via AppleScript:
   - **Delete** existing playlists matching the configured names
   - **Create** empty playlists inside the target folder
   - **Populate** each playlist by searching the library for each track's `search` query
   - **Verify** final playlist contents and track counts

4. Review the output:
   - `+` lines indicate tracks found and added
   - `MISS` lines indicate tracks not in the library — the user should add the album first, then re-run

5. Report results to the user: how many playlists created, how many tracks added, how many missing.

## Notes

- The script is idempotent — safe to re-run at any time (deletes + recreates)
- To retry missing tracks: add the album to Apple Music library, then re-run with the same JSON
- Playlist folder must already exist in Music.app (create manually if needed)
- Track search uses first match; include artist name in `search` to reduce ambiguity
- `folder` can be empty string to create playlists at the top level
