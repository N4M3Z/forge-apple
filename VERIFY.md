# forge-apple — Verification

> **For AI agents**: Complete this checklist after installation. Safari checks should always pass on macOS. Calendar and Reminders checks require `ekctl`.

## Safari (no external dependencies)

```bash
bash Modules/forge-apple/bin/safari-tabs.sh --count
# Should output tab counts (local + cloud devices)
# Requires Safari to be running for local tabs
```

## Apple Music (no external dependencies)

```bash
# Verify scripts exist and are executable
ls -la Modules/forge-apple/bin/music-playlists.sh
ls -la Modules/forge-apple/bin/music-playlists-fill.sh
# Actual execution requires Music.app running and playlists configured
```

## Calendar and Reminders (requires ekctl)

> Skip this section if `ekctl` is not installed. The module degrades gracefully without it.

```bash
command -v ekctl && echo "ekctl available" || echo "SKIP: ekctl not installed"
```

### Calendar access

```bash
ekctl list calendars
# Should list available calendars with UUIDs
```

### Reminders access

```bash
ekctl list reminders --list tasks --completed false
# Should list open reminders from the configured list
```

## Expected results

- Safari tab capture works (if Safari is running)
- Music scripts exist and are executable
- If `ekctl` is installed: calendar aliases configured, reminder lists accessible
- If `ekctl` is not installed: Safari and Music features still work independently
