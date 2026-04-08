# dry-claude-plugin

A Claude Code plugin that analyzes your session interactions and identifies repeatable patterns that can be automated as skills, hooks, sub-agents, or slash commands.

Stop repeating yourself. Let Claude find the patterns for you.

## How It Works

When you invoke `/dry:analyze`, the plugin prompts Claude to reflect on everything that happened in the current session and identify:

- **Tool sequence patterns** — same sequence of tools used repeatedly
- **Prompt patterns** — similar requests phrased differently
- **Workflow patterns** — multi-step processes with the same structure
- **Configuration patterns** — repeated setup or environment checks
- **Error recovery patterns** — same debugging approach reused

For each pattern, it recommends the best automation mechanism (skill, hook, sub-agent, or slash command) and walks you through implementing the ones you approve.

## Installation

### From GitHub

```bash
claude plugin install fahadmustafa/dry-claude-plugin
```

### For development

```bash
git clone https://github.com/fahadmustafa/dry-claude-plugin.git
claude --plugin-dir ./dry-claude-plugin
```

## Usage

Run a session as normal. When you want to check for repeatable patterns:

```
/dry:analyze
```

You can optionally focus the analysis on a specific area:

```
/dry:analyze testing workflows
```

The plugin will:
1. Scan the session for repeating patterns
2. Present a structured report with recommendations
3. Walk you through each one — implement, dismiss, modify, or skip
4. For approved patterns, ask where to scaffold them (plugin or current project)
5. Generate the automation files

### Example Output

```
### Pattern 1: Component Test Setup

Type: workflow
Evidence: Created test file, added imports, wrote describe block, added setup/teardown — done 4 times for different components
Frequency: 4 times this session
Recommended mechanism: Skill
Why: Multi-step process requiring Claude reasoning, varies by component
Complexity: Simple

---

Implement / Dismiss / Modify / Skip?
```

## Pattern History

The plugin remembers patterns across sessions. Dismissed patterns won't be recommended again. Skipped patterns may resurface in future sessions. History is stored locally in your Claude Code plugin data directory.

## Architecture

```
dry-claude-plugin/
├── skills/analyze/         # Core analysis skill + classification guide
├── agents/                 # Pattern scaffolder sub-agent
├── hooks/                  # SessionStart hook for loading history
└── scripts/                # History loader script
```

- **`/dry:analyze`** — The main skill. Analyzes the session and presents recommendations.
- **`pattern-scaffolder`** — Sub-agent that generates correctly structured plugin files when you approve a pattern.
- **SessionStart hook** — Loads your pattern history so dismissed patterns aren't re-recommended.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `claude --plugin-dir .`
5. Submit a pull request

## License

MIT
