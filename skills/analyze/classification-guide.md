# Pattern Classification Guide

Use this guide to determine which Claude Code automation mechanism best fits an identified pattern.

## Decision Tree

```
Is the pattern triggered by a specific event (file save, session start, tool use)?
├── Yes → Is it deterministic (same input = same action, no reasoning needed)?
│   ├── Yes → HOOK
│   └── No → Does it need its own isolated context?
│       ├── Yes → SUB-AGENT (with hook trigger)
│       └── No → SKILL (with hook trigger)
└── No → Is it invoked by the user on demand?
    ├── Yes → Does it require multi-step reasoning or tool use?
    │   ├── Yes → Does it need isolated context or parallel execution?
    │   │   ├── Yes → SUB-AGENT
    │   │   └── No → SKILL
    │   └── No → SLASH COMMAND
    └── No → Not a good automation candidate
```

## Mechanism Reference

### Skill
**Best for**: Multi-step workflows, analysis tasks, creative processes, context-dependent operations

**Characteristics**:
- Needs Claude's reasoning to execute
- Involves multiple tool calls in sequence
- Benefits from reference material or supporting files
- Output varies based on context
- User invokes it intentionally

**Examples**:
- Code review with project-specific standards
- Migration planning that adapts to codebase structure
- Test generation based on implementation patterns
- Architecture analysis with recommendations

**File structure**: `skills/<name>/SKILL.md` with optional supporting files

### Hook
**Best for**: Automatic triggers, validation, linting, environment setup, logging

**Characteristics**:
- Fires on a specific event (SessionStart, PostToolUse, PreToolUse, etc.)
- Deterministic — same trigger produces same action
- No user interaction needed during execution
- Runs a shell command or makes an HTTP request
- Fast execution (should not block the user)

**Examples**:
- Auto-lint after file writes
- Block dangerous commands before execution
- Log tool usage for analytics
- Set up environment variables at session start
- Validate file formats after creation

**File structure**: Entry in `hooks/hooks.json` pointing to a script

### Sub-agent
**Best for**: Isolated complex tasks, parallel work, specialized expertise

**Characteristics**:
- Needs its own context window (independent reasoning)
- Can run in parallel with other work
- Has a focused, well-defined scope
- Benefits from restricted tool access
- May need worktree isolation for file operations

**Examples**:
- Security review of a specific module
- Performance analysis running alongside development
- Documentation generation for completed features
- Test writing that shouldn't pollute main context

**File structure**: `agents/<name>.md` with frontmatter

### Slash Command
**Best for**: Simple one-shot prompts, quick utilities, legacy format

**Characteristics**:
- Short, direct instruction
- Minimal logic — mostly a prompt template
- No supporting files needed
- Quick to execute

**Examples**:
- Generate a commit message
- Explain the current file
- Summarize recent changes
- Quick formatting task

**File structure**: `commands/<name>.md`

**Note**: Skills are preferred over slash commands for new development. Slash commands are the legacy format.

## Anti-patterns: When NOT to Automate

- **One-off tasks**: If it happened once and is unlikely to recur, don't automate it
- **Highly variable workflows**: If the pattern changes significantly each time, a skill may over-constrain it
- **Simple operations**: If it's faster to type than to invoke a command, skip it
- **Context-dependent judgment**: If the "pattern" is really just good engineering judgment applied to different situations, it's not automatable
- **Premature abstraction**: If you've only seen the pattern twice, wait for a third occurrence before automating
