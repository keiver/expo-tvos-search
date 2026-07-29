#!/bin/bash
# Runs npm run build before git commit to catch type errors locally.
# Configured as a PreToolUse hook on Bash commands.

COMMAND=$(echo "$1" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$COMMAND" ] && COMMAND=$(jq -r '.tool_input.command // empty')

# Only intercept git commit commands
if ! echo "$COMMAND" | grep -qE '^\s*git\s+commit'; then
  exit 0
fi

echo "Running build before commit..." >&2
npm run build 2>&1
BUILD_EXIT=$?

if [ $BUILD_EXIT -ne 0 ]; then
  echo "Build failed. Fix type errors before committing." >&2
  exit 2
fi

exit 0
