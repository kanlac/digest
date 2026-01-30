#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment variables
if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi
OUTPUT_DIR="$PROJECT_DIR/output"
TODAY=$(date +%Y-%m-%d)
OUTPUT_FILE="$OUTPUT_DIR/$TODAY.md"

mkdir -p "$OUTPUT_DIR"

if [ -f "$OUTPUT_FILE" ]; then
  echo "Today's digest already exists: $OUTPUT_FILE"
  exit 0
fi

echo "Generating digest for $TODAY..."

SYSTEM_PROMPT=$(cat "$PROJECT_DIR/prompts/digest.md")
SOURCES_CONFIG=$(cat "$PROJECT_DIR/sources.yaml")

# Build command args array
CMD_ARGS=(claude --print --dangerously-skip-permissions)

# Add source directories
while IFS= read -r p; do
  CMD_ARGS+=(--add-dir "$p")
done < <(grep '^\s*path:' "$PROJECT_DIR/sources.yaml" | sed 's/.*path:\s*//')

CMD_ARGS+=(--append-system-prompt "$SYSTEM_PROMPT")

PROMPT="Please generate today's digest ($TODAY).

Sources config:
$SOURCES_CONFIG

Scan the content at these paths and extract valuable insights."

echo "$PROMPT" | "${CMD_ARGS[@]}" > "$OUTPUT_FILE"

echo "Digest generated: $OUTPUT_FILE"

# Commit and push to GitHub for notifications
cd "$PROJECT_DIR"
git add output/
if ! git diff --cached --quiet; then
  git commit -m "Daily digest $TODAY"
  git push
  echo "Pushed to GitHub."
else
  echo "No changes to push."
fi
