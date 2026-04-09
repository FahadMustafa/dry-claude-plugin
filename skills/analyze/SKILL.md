---
name: analyze
description: "Use when you want to identify repeatable patterns in your current Claude Code session that could be automated as skills, hooks, sub-agents, or slash commands."
user-invocable: true
---

# DRY Session Analyzer

You are analyzing the current session to identify interaction patterns that repeat and could be generalized into reusable automation. Your goal is to find the "DRY violations" — places where the user or Claude are repeating themselves.

## Step 1: Session Scan

Review everything that has happened in this session. Look for these pattern types:

**Tool Sequence Patterns**: The same sequence of tools used repeatedly. Example: Read file -> Grep for pattern -> Edit file, done 3+ times with similar intent.

**Prompt Patterns**: Similar user requests phrased differently across the session. Example: The user keeps asking to "check if X follows the project conventions" in different contexts.

**Workflow Patterns**: Multi-step processes that follow the same structure. Example: Create file -> write boilerplate -> add to index -> run tests, repeated for each new component.

**Configuration Patterns**: Repeated setup, environment checks, or project context gathering. Example: Checking git status + branch + recent commits at the start of each task.

**Error Recovery Patterns**: The same debugging or fix approach used multiple times. Example: Read error -> check imports -> fix path -> re-run, repeated for similar import issues.

If the user provided a focus area via `$ARGUMENTS`, prioritize patterns related to that area.

## Step 2: Pattern Report

For each pattern found, present it in this format:

```
### Pattern [N]: [Short descriptive name]

**Type**: [tool_sequence | prompt | workflow | config | error_recovery]
**Evidence**: [Specific examples from this session — quote or reference actual interactions]
**Frequency**: [How many times it appeared, or signals suggesting it recurs across sessions]
**Recommended mechanism**: [Skill | Hook | Sub-agent | Slash Command]
**Why this mechanism**: [1-2 sentences explaining the fit, referencing the classification guide]
**Complexity**: [Simple | Moderate | Complex]
```

Refer to the classification guide in `classification-guide.md` when deciding the mechanism.

If no patterns are found, say so honestly. Not every session has automation opportunities.

## Step 3: Check Pattern History

Before presenting recommendations, check if any patterns have been previously identified. Look for prior pattern history that was loaded at session start. If a pattern was previously dismissed, do not recommend it again. If a pattern was previously approved but not yet implemented, flag it as a reminder.

## Step 4: Interactive Refinement

After presenting all recommendations, walk through each one individually:

For each pattern, ask the user:
1. **Implement** — Generate the automation files now
2. **Dismiss** — Skip this one (won't be recommended again)
3. **Modify** — Adjust the recommendation (different mechanism, different scope, etc.)
4. **Skip** — Not now, but keep it for future sessions

If the user chooses **Implement**, ask where to scaffold:
- **This plugin** (`${CLAUDE_PLUGIN_ROOT}/`) — adds to the dry-claude-plugin itself, available globally
- **Current project** (`.claude/` in working directory) — project-specific automation

Then delegate the implementation to the `pattern-scaffolder` sub-agent with:
- The pattern description and evidence
- The chosen mechanism type
- The target location
- Any modifications the user requested

If the user chooses **Dismiss** or **Skip**, record the decision.

## Step 5: Persist Decisions

After processing all recommendations, append each decision to `${CLAUDE_PLUGIN_DATA}/history.jsonl` using this format:

```json
{"timestamp": "<ISO8601>", "pattern_name": "<name>", "pattern_type": "<type>", "mechanism": "<mechanism>", "decision": "<approved|dismissed|skipped>", "target": "<plugin|project|null>", "description": "<brief description>"}
```

Create the file if it doesn't exist. Create the `${CLAUDE_PLUGIN_DATA}` directory if needed.

Summarize what was done at the end: how many patterns found, how many implemented, how many dismissed.
