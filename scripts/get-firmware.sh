#!/usr/bin/env bash
#
# Download the firmware from the most recent ZMK build for the current branch.
# If a build is still running, waits for it to finish first.
#
#   ./scripts/get-firmware.sh
#
# Results land in ./firmware/ (gitignored).

set -euo pipefail

WORKFLOW="build.yml"
OUT_DIR="firmware"

cd "$(git rev-parse --show-toplevel)"

command -v gh >/dev/null 2>&1 || {
    echo "error: gh CLI not found — install with: brew install gh" >&2
    exit 1
}
gh auth status >/dev/null 2>&1 || {
    echo "error: gh is not authenticated — run: gh auth login" >&2
    exit 1
}

branch=$(git rev-parse --abbrev-ref HEAD)
local_sha=$(git rev-parse HEAD)

# Newest run on this branch, whatever state it's in.
info=$(gh run list --workflow "$WORKFLOW" --branch "$branch" --limit 1 \
    --json databaseId,status,conclusion,headSha \
    --jq '.[] | "\(.databaseId)|\(.status)|\(.conclusion)|\(.headSha)"')

[ -n "$info" ] || {
    echo "error: no builds found for branch '$branch' — have you pushed?" >&2
    exit 1
}

IFS='|' read -r run_id status conclusion run_sha <<<"$info"

# Warn if the newest build predates what's in the working tree.
if [ "$run_sha" != "$local_sha" ]; then
    echo "note: newest build is for commit ${run_sha:0:7}, but HEAD is ${local_sha:0:7}"
    echo "      push your latest commit if you want that built instead."
    echo
fi
if ! git diff --quiet 2>/dev/null; then
    echo "note: you have uncommitted changes — they are NOT in this build."
    echo
fi

if [ "$status" != "completed" ]; then
    echo "build $run_id is $status — waiting for it to finish..."
    if ! gh run watch "$run_id" --exit-status >/dev/null 2>&1; then
        echo "error: build failed — $(gh run view "$run_id" --json url --jq .url)" >&2
        exit 1
    fi
elif [ "$conclusion" != "success" ]; then
    echo "error: latest build concluded '$conclusion' — $(gh run view "$run_id" --json url --jq .url)" >&2
    exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

gh run download "$run_id" -D "$tmp" >/dev/null

# gh nests each artifact in its own subdirectory; find wherever the .uf2s landed.
src=$(find "$tmp" -name '*.uf2' -print -quit | xargs -r dirname)
[ -n "$src" ] || {
    echo "error: no .uf2 files in the build artifacts" >&2
    exit 1
}

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"
cp "$src"/*.uf2 "$OUT_DIR"/

echo "downloaded build $run_id — $(git log -1 --format='%h %s' "$run_sha" 2>/dev/null || echo "${run_sha:0:7}")"
echo
for f in "$OUT_DIR"/*.uf2; do
    printf '  %-45s %s\n' "$(basename "$f")" "$(du -h "$f" | cut -f1)"
done
