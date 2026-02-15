---
name: Safari
description: Safari automation — tab capture, Reading List, and bookmark operations (macOS). USE WHEN safari, capture tabs, snapshot tabs, save tabs, archive tabs, reading list, bookmarks.
user_invocable: true
---

# Safari

Safari automation for macOS. Manages tabs, Reading List, and bookmarks via AppleScript and SQLite.

## Operations

| Operation | File | Description |
|-----------|------|-------------|
| Capture Tabs | `CaptureTabs.md` | Snapshot local + iCloud tabs into a dated archive |

## Tools

- `bin/safari-tabs.sh` — tab export script (AppleScript for local, CloudTabs.db for iCloud)
- `~/Library/Safari/CloudTabs.db` — iCloud tabs SQLite database
- `~/Library/Safari/Bookmarks.plist` — Reading List and bookmarks (binary plist)

## Limitations

- Local tabs require Safari to be running
- Reading List: can add items via AppleScript, cannot remove programmatically (iCloud sync overwrites plist edits)
- Cloud tab close requests require valid CloudKit CKRecord blobs — not safe to fabricate

When the user asks for a Safari operation, read the matching operation file and follow its instructions.
