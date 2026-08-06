#!/bin/bash
# Fetches current or historical IBKR build versions.
#
# Usage:
#   ./ibkr-version.sh                        list current versions (both channels)
#   ./ibkr-version.sh latest|stable          print current version for one channel
#   ./ibkr-version.sh history [latest|stable] list versions from GitHub releases
#
# Override the GitHub repo used for history with IBKR_DOCKER_REPO=owner/repo.
# Defaults to the origin remote of this repo, then extrange/ibkr-docker.

set -euo pipefail

CHANNELS=(latest stable)
IBKR_BASE="https://download2.interactivebrokers.com/installers/ibgateway"

detect_repo() {
    git remote get-url origin 2>/dev/null \
        | sed 's|.*github\.com[:/]\(.*\)\.git|\1|; s|.*github\.com[:/]\(.*\)|\1|' \
        || echo "extrange/ibkr-docker"
}

fetch_current() {
    local channel="$1"
    local res
    res=$(curl -fsSL "${IBKR_BASE}/${channel}-standalone/version.json")
    sed 's/.*"buildVersion":"\([^"]*\)".*/\1/' <<< "$res"
}

list_history() {
    local channel_filter="${1:-}"
    local repo="${IBKR_DOCKER_REPO:-$(detect_repo)}"
    printf "Releases from %s:\n\n" "$repo" >&2

    curl -fsSL "https://api.github.com/repos/${repo}/releases?per_page=100" \
        | python3 -c "
import json, sys
releases = json.load(sys.stdin)
cf = sys.argv[1] if len(sys.argv) > 1 else ''
rows = []
for r in releases:
    tag = r['tag_name']
    date = r['published_at'][:10]
    parts = tag.rsplit('-', 1)
    if len(parts) == 2:
        version, channel = parts
        if not cf or channel == cf:
            rows.append((date, channel, version))
rows.sort(reverse=True)
for date, channel, version in rows:
    print(f'{date}  {channel:<8}  {version}')
" "$channel_filter"
}

usage() {
    sed -n '2,8p' "$0" | sed 's/^# \?//' >&2
    exit 1
}

case "${1:-}" in
    "")
        for channel in "${CHANNELS[@]}"; do
            printf "%-8s %s\n" "${channel}:" "$(fetch_current "$channel")"
        done
        ;;
    latest|stable)
        fetch_current "$1"
        ;;
    history)
        list_history "${2:-}"
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        usage
        ;;
esac
