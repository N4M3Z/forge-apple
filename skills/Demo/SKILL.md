---
name: Demo
description: Today at a Glance — calendar events, open reminders, Safari tab count. USE WHEN today, schedule, calendar, reminders, what's on, daily overview, glance, my day, demo.
user_invocable: true
---

# Demo — Today at a Glance

Interactive daily dashboard that **reads from and writes back to** macOS native apps (Calendar, Reminders, Safari, Maps). Designed to showcase deep OS integration.

## Prerequisites

- `ekctl` — EventKit CLI for Calendar and Reminders (install via Homebrew or build from source)
- `safari-tabs.sh` — bundled at `Modules/forge-apple/bin/safari-tabs.sh`
- Configure calendar aliases in `Modules/forge-apple/config.yaml` (copy from `defaults.yaml`)

If `ekctl` is not installed, skip calendar and reminder sections — show only what's available.

---

## Phase 1 — HUD Readout

### 1.1 Determine today's date and time

```bash
date +%Y-%m-%d
date +%H
```

Use the hour to select a greeting:
- 05–11: "Good morning"
- 12–16: "Good afternoon"
- 17–21: "Good evening"
- 22–04: "Late night"

### 1.2 Calendar events

Query each configured calendar for today's events. Read the calendar list from `Modules/forge-apple/defaults.yaml` (or `config.yaml` if present) under the `calendars:` key.

For each calendar alias:

```bash
ekctl list events --calendar <alias> --from <today>T00:00:00Z --to <today>T23:59:59Z
```

Output is JSON with `events` array. Each event has: `title`, `startDate`, `endDate`, `location`, `allDay`.

Filter out events whose title starts with any prefix listed in `event_filters` from `config.yaml` (fallback to `defaults.yaml`).

Sort by start time.

### 1.3 Open reminders

Query each configured reminder list. Read the list names from `defaults.yaml` under `reminders.lists:`.

For each list:

```bash
ekctl list reminders --list <list-name> --completed false
```

Output is JSON with `reminders` array. Each reminder has: `title`, `dueDate`, `id`, `notes`, `priority`.

Classify each reminder:
- **overdue**: dueDate < today (tag with days overdue)
- **today**: dueDate is today
- **tomorrow**: dueDate is tomorrow
- **upcoming**: dueDate within next 7 days
- **no date**: dueDate is null

### 1.4 Safari tab count

```bash
bash "${FORGE_MODULE_ROOT:-Modules/forge-apple}/bin/safari-tabs.sh" --count
```

Parse all lines. Extract device names, per-device counts, and `Total:` line.

### 1.5 Compute day progress

```bash
date +%H:%M
```

Calculate percentage of waking hours elapsed (assume 07:00–23:00 = 16h window). Render a 20-char progress bar:

```
[============--------] 60%
```

### 1.6 Present HUD

Format using ASCII box-drawing characters. Use this exact frame structure:

```
╔══════════════════════════════════════════════════════════╗
║  <Greeting> — <DayName> <YYYY-MM-DD>                    ║
║  Day: [============--------] 60%                        ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║  CALENDAR (N events)                                     ║
║  ── ── ── ── ── ── ── ── ──                              ║
║    09:00  Team standup                                   ║
║    14:00  Client call @ Zoom                             ║
║    (all day)  Company holiday                            ║
║                                                          ║
║  REMINDERS (N open · M overdue)                          ║
║  ── ── ── ── ── ── ── ── ──                              ║
║    ! Fix auth bug                        -3d  [work]     ║
║    ! Deploy staging                      -1d  [work]     ║
║      Write blog post                   today  [tasks]    ║
║      Groceries                                [tasks]    ║
║                                                          ║
║  SAFARI                                                  ║
║  ── ── ── ── ── ── ── ── ──                              ║
║    146 tabs across 5 devices                             ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
```

Formatting rules:
- Prefix overdue reminders with `!`
- Right-align overdue tags (`-Nd`) and list names (`[list]`)
- If calendar is empty, show `No events — clear day`
- If reminders are empty, show `All clear`
- Pad all lines to fill the frame width

---

## Phase 2 — Interactive Actions

After presenting the HUD, offer the user a menu of available actions using the Question tool. Present only actions that are relevant to the current data (e.g., don't offer triage if there are no overdue reminders).

### 2.1 Action Menu

Ask the user (allow multiple selections):

**Available actions based on today's data:**

Build the option list dynamically from these candidates:

| Condition | Action label | Description |
|-----------|-------------|-------------|
| Any overdue reminders exist | **Triage overdue reminders** | Review each overdue item — complete, reschedule to today, or skip |
| Always | **Add a reminder** | Quick-create a reminder from the CLI — pushed to Reminders.app |
| Always | **Block focus time** | Create a calendar event for a focus/deep-work block |
| Any reminder or event has a location or address in notes | **Open route in Maps** | Launch Apple Maps with driving directions |
| Safari tabs > 50 | **Snapshot Safari tabs** | Export all open tabs to markdown for archival |
| Always | **Skip — just the glance** | No actions, end here |

### 2.2 Triage Overdue Reminders

For each overdue reminder, present a question with these options:
- **Complete it** — mark as done
- **Reschedule to today** — delete and recreate with today's due date
- **Reschedule to tomorrow** — delete and recreate with tomorrow's due date
- **Skip** — leave as-is

Execute the chosen action:

**Complete:**
```bash
ekctl complete reminder <reminder-id>
```

**Reschedule:**
```bash
ekctl delete reminder <reminder-id>
ekctl add reminder --list <list-alias> --title "<title>" --due <new-date>T09:00:00 --priority <priority> --notes "<notes>"
```

After processing all overdue items, report a summary: "Completed N, rescheduled M, skipped K."

### 2.3 Add a Reminder

Ask the user for:
- Title (required)
- List (offer configured lists from defaults.yaml, default to `reminders.default`)
- Due date (optional — offer "today", "tomorrow", "next week", or custom)
- Priority (optional — high/medium/low/none)

```bash
ekctl add reminder --list <list> --title "<title>" [--due <date>T09:00:00] [--priority <0-9>]
```

Confirm creation with the reminder details.

### 2.4 Block Focus Time

Ask the user for:
- What they'll work on (becomes event title, prefixed with "Focus: ")
- Duration (offer 1h, 2h, 3h — default 2h)
- When (offer "now", "after next event", "this afternoon", or custom time)
- Calendar (offer configured calendars, default to first one)

```bash
ekctl add event --calendar <cal> --title "Focus: <topic>" --start <start> --end <end> --notes "Created by Forge demo"
```

Confirm creation. The event should immediately appear in Calendar.app.

### 2.5 Open Route in Maps

Scan reminders and events for location data:
- Event `location` field
- Reminder `notes` containing Apple Maps URLs (`maps.apple.com`) or Waze URLs
- Reminder `notes` containing addresses

Present found locations and let the user pick one.

**IMPORTANT — Use `maps://` scheme and percent-encode parameters:**

1. Use the `maps://` URL scheme — this opens Maps.app directly, bypassing Safari.
2. Non-ASCII characters (á, č, ě, ř, š, ú, ž, etc.) must be percent-encoded or the URL will silently fail. Use `jq` for encoding.

If the reminder/event contains a full `maps.apple.com` URL, rewrite the scheme:
```bash
# Extract saddr/daddr from the existing URL, then re-encode:
saddr=$(printf '%s' '<source>' | jq -sRr @uri)
daddr=$(printf '%s' '<destination>' | jq -sRr @uri)
open "maps://?saddr=${saddr}&daddr=${daddr}&dirflg=d"
```

If constructing from a destination name or address:
```bash
daddr=$(printf '%s' '<destination>' | jq -sRr @uri)
open "maps://?daddr=${daddr}&dirflg=d"
```

This opens Maps.app directly with driving directions — no Safari window.

### 2.6 Snapshot Safari Tabs

Run the full export:

```bash
bash "${FORGE_MODULE_ROOT:-Modules/forge-apple}/bin/safari-tabs.sh" --export
```

Save the output. Report the count and offer to show the full list.

---

## Phase 3 — Closing Summary

After all selected actions are complete, present a brief recap:

```
╔══════════════════════════════════════════════════════════╗
║  Actions taken:                                          ║
║    + Completed 2 reminders                               ║
║    + Rescheduled 1 reminder to today                     ║
║    + Created focus block: 14:00–16:00 "Focus: TLP work"  ║
║    + Opened route to destination in Maps                  ║
╚══════════════════════════════════════════════════════════╝
```

If no actions were taken, skip this section.

---

## Notes

- All data is local — no remote API calls
- If `ekctl` is missing, say so and offer only Safari tab count
- Calendar aliases must match names from `ekctl alias list`
- Reminder list names must match `ekctl list calendars` output
- When rescheduling reminders, preserve the original `notes` and `priority` fields
- The HUD frame width should adapt to the longest content line (minimum 58 chars)
- Use the Question tool for all interactive choices — never assume user intent for write operations
- If an `ekctl` command fails mid-triage (e.g. `ekctl complete` returns an error), report the failure for that specific item, skip it, and continue with the remaining items. Do not abort the entire triage.
