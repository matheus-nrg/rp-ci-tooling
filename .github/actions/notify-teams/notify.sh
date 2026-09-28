#!/usr/bin/env bash
# Kept as a file rather than inline in action.yml so openapi-checks can run it
# through its own action path: a `uses: ./...` inside a composite resolves
# against the caller's workspace, not this repo.

if [ -z "$WEBHOOK_URL" ]; then
  echo "No Teams webhook URL set - notification skipped." >> "$GITHUB_STEP_SUMMARY"
  exit 0
fi

if jq -se 'length == 1 and (.[0] | type) == "object"' <<< "$MESSAGE" > /dev/null 2>&1; then
  payload="$MESSAGE"
else
  payload=$(jq -n --arg text "$MESSAGE" '{text: $text}')
fi

curl -sSf --max-time 30 -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$payload" \
  || echo "Teams notification failed - see the run log." >> "$GITHUB_STEP_SUMMARY"
