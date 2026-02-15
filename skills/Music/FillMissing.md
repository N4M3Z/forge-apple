# Fill Missing Tracks

Retry adding tracks that were reported as MISS during playlist creation. Run this after adding the required albums to your Apple Music library.

## Steps

1. Run the fill script:
   ```bash
   bash "${FORGE_MODULE_ROOT:-Modules/forge-apple}/bin/music-playlists-fill.sh"
   ```

2. The script searches for previously missing tracks and adds them to the correct playlists.

3. Review the output:
   - `+` lines indicate tracks found and added
   - `MISS` lines indicate tracks still not in the library — the output includes which album to add

4. Report results: how many of the missing tracks were filled.

## Notes

- Only targets known missing tracks — does not re-run full playlist creation
- Safe to run multiple times; duplicate tracks may be added if a track was already filled
- If all tracks are still missing, the output will suggest specific albums to add
- For a full rebuild (delete + recreate + populate), use `CreatePlaylists` instead
