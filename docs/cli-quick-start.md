# Agent OS CLI Quick Start

Quick reference for the `agent-os` command-line interface.

## Installation

```bash
# Install base Agent OS
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup/base.sh | bash

# Install CLI globally (optional)
~/.agent-os/scripts/install-global.sh
```

## Common Commands

### Install in Project

```bash
cd /path/to/project
agent-os install
```

### Update Project Installation

```bash
agent-os update
```

### Create Custom Profile

```bash
agent-os create-profile --name my-profile
```

### Create Custom Role

```bash
agent-os create-role --type implementer --name custom-engineer
```

## For Claude Code (Non-Interactive)

### Install Without Prompts

```bash
# Basic installation
agent-os install --install-tools false

# With specific configuration
agent-os install \
  --profile default \
  --multi-agent-mode true \
  --multi-agent-tool claude-code \
  --install-tools false
```

### Update Without Prompts

```bash
# Update with overwriting specific files
agent-os update --overwrite-agents

# Update everything
agent-os update --overwrite-all
```

### Create Profile Non-Interactively

```bash
agent-os create-profile \
  --name custom-profile \
  --inherit-from default \
  --frameworks rails,postgresql \
  --non-interactive
```

### Create Role Non-Interactively

```bash
agent-os create-role \
  --type implementer \
  --name my-engineer \
  --description "Custom implementation role" \
  --tools "Write,Read,Bash" \
  --model sonnet \
  --color purple \
  --areas "API endpoints,Controllers" \
  --standards "global/*,backend/*" \
  --non-interactive
```

## Flags Reference

### Common Flags

- `--dry-run` - Preview changes without applying
- `--verbose` - Show detailed output
- `--non-interactive` - Skip all prompts (for AI agents)

### Installation Flags

- `--profile NAME` - Use specific profile
- `--multi-agent-mode [true|false]` - Enable multi-agent mode
- `--multi-agent-tool TOOL` - Specify tool (claude-code)
- `--install-tools [true|false]` - Install MCP tools
- `--tools-scope [user|project]` - Tool installation scope

### Update Flags

- `--overwrite-all` - Overwrite all files
- `--overwrite-standards` - Overwrite standards only
- `--overwrite-commands` - Overwrite commands only
- `--overwrite-agents` - Overwrite agents only
- `--overwrite-automations` - Overwrite automations only

## Get Help

```bash
# General help
agent-os help

# Command aliases
agent-os h
agent-os --help

# Version information
agent-os version
agent-os -v
```

## Direct Script Usage (Without Global Install)

If CLI is not installed globally:

```bash
~/.agent-os/scripts/agent-os install
~/.agent-os/scripts/agent-os update
~/.agent-os/scripts/agent-os create-profile
~/.agent-os/scripts/agent-os create-role
```

## Documentation

- [Full CLI Reference](cli-reference.md)
- [CLAUDE.md](../CLAUDE.md)
- [Agent OS Documentation](https://buildermethods.com/agent-os)
