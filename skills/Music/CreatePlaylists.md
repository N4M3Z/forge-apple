# Create Playlists

Idempotent playlist creation for Apple Music. Deletes existing playlists matching the naming pattern, recreates them inside the target folder, then populates with tracks from the library.

## Steps

1. Run the creation script:
   ```bash
   bash "${FORGE_MODULE_ROOT:-Modules/forge-apple}/bin/music-playlists.sh"
   ```

2. The script executes four phases via AppleScript:
   - **Delete** existing playlists matching the configured prefix
   - **Create** empty playlists inside the target folder
   - **Populate** each playlist by searching the library for artist + title
   - **Verify** final playlist contents and track counts

3. Review the output:
   - `+` lines indicate tracks found and added
   - `MISS` lines indicate tracks not in the library — add the album first, then run `FillMissing`

4. Report results to the user: how many playlists created, how many tracks added, how many missing.

## Notes

- The script is idempotent — safe to re-run at any time
- Playlist folder must already exist in Music.app (create manually if needed)
- Track search is by artist name + track title; first match wins
- Some tracks have fallback artist name searches for aliases
- Missing tracks should be resolved by adding the album to Apple Music library, then running `FillMissing`
