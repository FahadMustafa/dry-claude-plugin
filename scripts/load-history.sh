#!/usr/bin/env bash

# Loads the analyze skill description and pattern history into session context.
# Called by the SessionStart hook.

set -euo pipefail

# Determine plugin root from script location as fallback
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
DATA_DIR="${CLAUDE_PLUGIN_DATA:-}"

# Escape for JSON
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

# Build skill awareness context
SKILL_INFO="The following skill is available from the dry plugin:\n\n"
SKILL_INFO+="- dry:analyze - Analyzes your current session to identify repeatable interaction patterns (tool sequences, prompts, workflows, config, error recovery) and recommends automating them as skills, hooks, sub-agents, or slash commands. Invoke with /dry:analyze\n"

# Add pattern history if available
HISTORY_INFO=""
if [ -n "$DATA_DIR" ] && [ -f "${DATA_DIR}/history.jsonl" ]; then
  HISTORY_FILE="${DATA_DIR}/history.jsonl"
  LINE_COUNT=$(wc -l < "$HISTORY_FILE")

  if [ "$LINE_COUNT" -gt 0 ]; then
    APPROVED=$(grep -c '"approved"' "$HISTORY_FILE" || true)
    DISMISSED=$(grep -c '"dismissed"' "$HISTORY_FILE" || true)
    SKIPPED=$(grep -c '"skipped"' "$HISTORY_FILE" || true)

    DISMISSED_NAMES=$(grep '"dismissed"' "$HISTORY_FILE" | sed 's/.*"pattern_name":"\([^"]*\)".*/\1/' | sort -u | tr '\n' ', ' | sed 's/,$//' || true)
    SKIPPED_NAMES=$(grep '"skipped"' "$HISTORY_FILE" | sed 's/.*"pattern_name":"\([^"]*\)".*/\1/' | sort -u | tr '\n' ', ' | sed 's/,$//' || true)

    HISTORY_INFO="\n\nDRY Pattern History: ${LINE_COUNT} patterns across prior sessions. ${APPROVED} approved, ${DISMISSED} dismissed, ${SKIPPED} skipped."

    if [ -n "$DISMISSED_NAMES" ]; then
      HISTORY_INFO="${HISTORY_INFO} Dismissed (do NOT recommend again): ${DISMISSED_NAMES}."
    fi

    if [ -n "$SKIPPED_NAMES" ]; then
      HISTORY_INFO="${HISTORY_INFO} Previously skipped (may re-recommend): ${SKIPPED_NAMES}."
    fi
  fi
fi

CONTEXT="${SKILL_INFO}${HISTORY_INFO}"
ESCAPED=$(escape_for_json "$CONTEXT")

# Output in Claude Code format
printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$ESCAPED"

exit 0
