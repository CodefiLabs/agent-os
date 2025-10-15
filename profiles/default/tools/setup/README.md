# Agent OS Tools Setup

This directory contains setup scripts for installing MCP servers to various AI coding tools.

## Available Setup Scripts

- [claude-code.sh](./claude-code.sh) - Install MCP servers to Claude Code
- [cursor.sh](./cursor.sh) - Install MCP servers to Cursor

## General Setup Process

1. **Installation**: Run `~/.agent-os/scripts/project-install.sh`
2. **Tool Detection**: Script detects which AI coding tool you're using
3. **Scope Selection**: Choose user or project scope
4. **MCP Installation**: Appropriate setup script installs MCP servers
5. **Verification**: Script validates installation and provides next steps

## Setup Script Behavior

Setup scripts are **idempotent** and **safe to run multiple times**:
- Parse MCP server JSON definitions from `tools/mcp/`
- Check for existing configurations (avoid duplicates)
- Merge new servers into existing `mcpServers` section
- Validate required dependencies
- Detect missing environment variables/secrets
- Provide clear output about what was installed
- Support `--dry-run` mode for testing

## Installation Scopes

### User Scope
Installs to user-level configuration:
- **Claude Code**: `~/.claude.json`
- **Cursor**: `~/.cursor/mcp.json`

**Benefits:**
- Available in all projects
- Personal configuration
- No version control needed

**Use when:**
- You want MCP servers available everywhere
- Working on multiple unrelated projects
- Personal development environment

### Project Scope
Installs to project-level configuration:
- **All tools**: `.mcp.json` in project root

**Benefits:**
- Shared with team via version control
- Consistent across team members
- Project-specific requirements

**Use when:**
- Working on a team project
- Want to version control tool configurations
- Need project-specific MCP servers

## Manual Setup

Run setup scripts manually:

```bash
# Claude Code - user scope
PROJECT_ROOT=$(pwd) bash ~/.agent-os/profiles/default/tools/setup/claude-code.sh --scope user

# Cursor - project scope
PROJECT_ROOT=$(pwd) bash ~/.agent-os/profiles/default/tools/setup/cursor.sh --scope project

# Dry run (see what would be installed)
PROJECT_ROOT=$(pwd) bash ~/.agent-os/profiles/default/tools/setup/claude-code.sh --scope user --dry-run
```

## Environment Variables

Setup scripts use these environment variables:

- `PROJECT_ROOT` - Project directory (required)
- `PROFILE_DIR` - Profile directory (default: `$HOME/.agent-os/profiles/default`)
- `DRY_RUN` - Set to `true` for dry run mode

## Common Prerequisites

- **Node.js and npm** - Required for most MCP servers
- **AI coding tool** - Claude Code, Cursor, etc.
- **API keys/tokens** - For services like GitHub, Brave Search, etc.
- **Bash 4.0+** - For running setup scripts

## Configuration Merging

Setup scripts intelligently merge configurations:

1. **Read existing config** - Parse current `mcpServers` section
2. **Detect duplicates** - Skip servers that already exist
3. **Add new servers** - Only install what's missing
4. **Preserve existing** - Keep all current servers and settings
5. **Write back** - Format JSON properly and save

This ensures running setup scripts multiple times is safe.

## Validation

Setup scripts validate:

- **JSON syntax** - Configuration files are valid JSON
- **Required fields** - All necessary fields present in MCP definitions
- **Dependencies** - Required npm packages available or installable
- **Secrets** - Environment variables for API keys are set
- **Permissions** - Configuration files are writable

## Output

Setup scripts provide:

- **Summary** - Number of servers installed/skipped
- **Details** - What was added vs. what existed
- **Warnings** - Missing secrets or dependencies
- **Next steps** - What to do after installation (restart tool, set secrets)

Example output:
```
================================================
  Installing MCP Servers to Claude Code
================================================

Scope: user (~/.claude.json)

Processing MCP server definitions...
✓ github - added
✓ filesystem - added
⊘ web-search - skipped (already installed)
✓ database - added
✓ memory - added

Summary:
✓ Installed 4 new MCP servers
⊘ Skipped 1 existing server

⚠️  Missing required secrets:
  - GITHUB_TOKEN (for github server)
  - TAVILY_API_KEY (for web-search server)

Add these to your environment:
  export GITHUB_TOKEN="your-token-here"
  export TAVILY_API_KEY="your-key-here"

Restart Claude Code to load new MCP servers.
```

## Troubleshooting

### Script fails with "jq: command not found"

Install `jq` for JSON parsing:

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# Or use Python fallback
# Scripts automatically detect and use Python if jq unavailable
```

### "Permission denied" errors

Configuration files may be read-only:

```bash
# Make writable
chmod u+w ~/.claude.json
```

### "Invalid JSON" errors

Existing configuration may be malformed:

```bash
# Validate with jq
jq empty ~/.claude.json

# Fix formatting
jq . ~/.claude.json > ~/.claude.json.tmp
mv ~/.claude.json.tmp ~/.claude.json
```

### Servers not appearing in AI tool

1. **Restart the tool** - Configurations load on startup
2. **Check file location** - Verify correct config file path
3. **Validate JSON** - Ensure proper formatting
4. **Check logs** - Look for MCP server errors

## Developing Setup Scripts

When creating or modifying setup scripts:

### Follow Existing Patterns

Look at `profiles/default/automations/github/setup.sh` for reference:
- Check prerequisites
- Validate environment
- Provide clear output
- Support dry-run mode
- Be idempotent

### Use Common Functions

Source from `scripts/common-functions.sh`:
```bash
source "$SCRIPT_DIR/../../../scripts/common-functions.sh"
print_status "Message"
print_error "Error"
print_verbose "Details"
```

### Handle Errors Gracefully

```bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# But catch expected failures
if ! command -v jq &> /dev/null; then
    # Fallback to Python or warn user
fi
```

### Test Thoroughly

```bash
# Test dry run
./setup/claude-code.sh --scope user --dry-run

# Test with existing config
./setup/claude-code.sh --scope user

# Test with empty config
./setup/claude-code.sh --scope user

# Test with malformed config
./setup/claude-code.sh --scope user
```

### Document

- Add comments for complex logic
- Update this README
- Add examples to main tools README

## Architecture Notes

### Why Separate Scripts?

Each AI tool has different configuration locations and formats:
- Claude Code: `~/.claude.json` with `mcpServers` object
- Cursor: `~/.cursor/mcp.json` with `mcpServers` object

While similar now, they may diverge. Separate scripts allow:
- Tool-specific logic and validation
- Different configuration merging strategies
- Independent updates and maintenance

### JSON Parsing Strategy

Scripts use `jq` for JSON operations:
- Parse existing configurations
- Merge new servers
- Format output properly

Fallback to Python's `json` module if `jq` unavailable.

### Why Not Use MCP CLI?

Tools like Claude Code have `claude mcp add` commands, but:
- Not all AI tools have CLIs
- Batch installation is easier with scripts
- Pre-configured definitions ensure consistency
- Scripts can validate and provide better error messages
- Team sharing via version control is simpler

## Contributing

To add support for a new AI tool:

1. Create `tools/setup/newtool.sh`
2. Follow existing script patterns
3. Document configuration file location and format
4. Add to this README
5. Update main `tools/README.md`
6. Test with `--dry-run` and real installations

## Additional Resources

- **MCP Specification**: https://modelcontextprotocol.io/specification/2025-06-18
- **Claude Code Setup**: https://docs.claude.com/en/docs/claude-code/mcp
- **Cursor MCP Integration**: https://docs.cursor.com/context/model-context-protocol
- **Agent OS Scripts**: See `scripts/` directory
