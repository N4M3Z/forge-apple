#!/bin/bash
set -euo pipefail

# Safari Tab Snapshot — exports local + cloud tabs
# Usage: safari-tabs.sh [--count|--export]
# Default: --count (compact summary)

MODE="${1:---count}"
CLOUD_DB="$HOME/Library/Safari/CloudTabs.db"

get_local_tabs() {
    osascript -e '
    tell application "Safari"
        set output to ""
        repeat with w from 1 to (count of windows)
            repeat with t from 1 to (count of tabs of window w)
                set tabName to name of tab t of window w
                set tabURL to URL of tab t of window w
                set output to output & tabName & "\t" & tabURL & linefeed
            end repeat
        end repeat
    end tell
    return output
    ' 2>/dev/null || true
}

get_cloud_tabs() {
    if [ -f "$CLOUD_DB" ]; then
        sqlite3 -separator $'\t' "$CLOUD_DB" "
            SELECT d.device_name, t.title, t.url
            FROM cloud_tabs t
            JOIN cloud_tab_devices d ON t.device_uuid = d.device_uuid
            ORDER BY d.device_name, t.title;
        " 2>/dev/null || true
    fi
}

case "$MODE" in
    --count)
        local_count=$(get_local_tabs | grep -c $'\t' || echo 0)
        echo "Local: ${local_count} tabs"
        if [ -f "$CLOUD_DB" ]; then
            sqlite3 "$CLOUD_DB" "
                SELECT d.device_name, COUNT(t.tab_uuid)
                FROM cloud_tabs t
                JOIN cloud_tab_devices d ON t.device_uuid = d.device_uuid
                GROUP BY d.device_name;
            " 2>/dev/null | while IFS='|' read -r device count; do
                echo "${device}: ${count} tabs"
            done || true
        fi
        if [ -f "$CLOUD_DB" ]; then
            total_cloud=$(sqlite3 "$CLOUD_DB" "SELECT COUNT(*) FROM cloud_tabs;" 2>/dev/null || echo 0)
        else
            total_cloud=0
        fi
        echo "Total: $((local_count + total_cloud)) tabs"
        ;;
    --export)
        echo "## Local Tabs"
        # Process substitution avoids subshell — variables persist
        while IFS=$'\t' read -r title url; do
            [ -n "$title" ] && [ -n "$url" ] && echo "- [${title}](${url})"
        done < <(get_local_tabs)

        echo ""

        current_device=""
        while IFS=$'\t' read -r device title url; do
            if [ "$device" != "$current_device" ]; then
                echo ""
                echo "## ${device}"
                current_device="$device"
            fi
            [ -n "$title" ] && [ -n "$url" ] && echo "- [${title}](${url})"
        done < <(get_cloud_tabs)
        ;;
    -h|--help)
        echo "Safari Tab Snapshot — exports local + cloud tabs"
        echo ""
        echo "Usage: safari-tabs.sh [--count|--export|--help]"
        echo ""
        echo "Options:"
        echo "  --count   Compact summary of tab counts per device (default)"
        echo "  --export  Full markdown export: [Title](URL) grouped by device"
        echo "  --help    Show this help message"
        exit 0
        ;;
    *)
        echo "Usage: safari-tabs.sh [--count|--export|--help]"
        exit 1
        ;;
esac
