# Agent OS CLI Reference

The `agent-os` command-line interface provides a unified way to interact with Agent OS for all installation, configuration, and management tasks.

## Installation

### Global Installation

After installing Agent OS base installation, install the CLI globally:

```bash
~/.agent-os/scripts/install-global.sh
```

Or during base installation, accept the prompt to install globally.

### Manual Usage (Without Global Install)

If not installed globally, you can use the CLI directly:

```bash
~/.agent-os/scripts/agent-os <command> [options]
```

## Commands

### `agent-os install`

Install Agent OS into the current project directory.

**Aliases:** `i`

**Options:**

```bash
--profile NAME                    # Use specified profile (default: from config.yml)
--multi-agent-mode [true|false]   # Enable/disable multi-agent mode
--multi-agent-tool TOOL           # Specify multi-agent tool (claude-code)
--single-agent-mode [true|false]  # Enable/disable single-agent mode
--single-agent-tool TOOL          # Specify single-agent tool
--re-install                      # Delete and reinstall Agent OS
--install-tools [true|false]      # Install MCP tools (default: prompt)
--tools-scope [user|project]      # Tools installation scope (default: user)
--overwrite-all                   # Overwrite all existing files
--overwrite-standards             # Overwrite existing standards
--overwrite-commands              # Overwrite existing commands
--overwrite-agents                # Overwrite existing agents
--overwrite-automations           # Overwrite existing automation files
--overwrite-tools                 # Overwrite existing tools
--dry-run                         # Show what would be done without doing it
--verbose                         # Show detailed output
```

**Examples:**

```bash
# Basic installation
agent-os install

# Install with specific profile
agent-os install --profile rails

# Install with multi-agent mode for Claude Code
agent-os install --multi-agent-mode true --multi-agent-tool claude-code

# Non-interactive installation (for AI agents)
agent-os install --install-tools false

# Dry run to see what would be installed
agent-os install --dry-run

# Reinstall from scratch
agent-os install --re-install
```

**For Claude Code Autonomous Use:**

When Claude Code needs to install Agent OS without user interaction:

```bash
# Install with defaults, skip tool installation
agent-os install --install-tools false

# Install with specific configuration
agent-os install \
  --profile default \
  --multi-agent-mode true \
  --multi-agent-tool claude-code \
  --install-tools false
```

---

### `agent-os update`

Update Agent OS installation in the current project.

**Aliases:** `u`

**Options:**

```bash
--profile NAME                    # Use specified profile
--multi-agent-mode [true|false]   # Enable/disable multi-agent mode
--multi-agent-tool TOOL           # Specify multi-agent tool
--single-agent-mode [true|false]  # Enable/disable single-agent mode
--single-agent-tool TOOL          # Specify single-agent tool
--re-install                      # Delete and reinstall Agent OS
--overwrite-all                   # Overwrite all existing files
--overwrite-standards             # Overwrite existing standards
--overwrite-commands              # Overwrite existing commands
--overwrite-agents                # Overwrite existing agents
--overwrite-automations           # Overwrite existing automation files
--dry-run                         # Show what would be done
--verbose                         # Show detailed output
```

**Examples:**

```bash
# Basic update
agent-os update

# Update and overwrite standards
agent-os update --overwrite-standards

# Update all files
agent-os update --overwrite-all

# Dry run to see what would change
agent-os update --dry-run --verbose
```

---

### `agent-os create-profile`

Create a new custom profile for Agent OS.

**Aliases:** `profile`

**Options:**

```bash
--name NAME                       # Profile name
--inherit-from PROFILE            # Inherit from existing profile
--copy-from PROFILE               # Copy from existing profile
--frameworks FRAMEWORK[,...]      # Frameworks for this profile (comma-separated)
--non-interactive                 # Skip all prompts
```

**Examples:**

```bash
# Interactive profile creation
agent-os create-profile

# Create profile with name
agent-os create-profile --name nextjs-app

# Create profile inheriting from default
agent-os create-profile --name rails-api --inherit-from default

# Non-interactive creation with frameworks
agent-os create-profile \
  --name rails-postgres \
  --inherit-from default \
  --frameworks ruby-on-rails,postgresql \
  --non-interactive
```

**For Claude Code Autonomous Use:**

```bash
# Create a profile without prompts
agent-os create-profile \
  --name custom-profile \
  --inherit-from default \
  --non-interactive
```

---

### `agent-os create-role`

Create a new implementer, verifier, or researcher role.

**Aliases:** `role`

**Options:**

```bash
--type TYPE                       # Role type (implementer, verifier, researcher)
--name NAME                       # Role name/ID
--profile PROFILE                 # Target profile (default: default)
--description TEXT                # Role description
--your-role TEXT                  # Role definition text
--tools TOOL[,...]                # Tools available to role (comma-separated)
--model MODEL                     # Model to use (sonnet, opus, haiku)
--color COLOR                     # Color for role
--areas AREA[,...]                # Areas of responsibility (comma-separated)
--out-of-scope AREA[,...]         # Example areas outside of responsibility (comma-separated)
--standards PATTERN[,...]         # Standards patterns (comma-separated)
--verified-by VERIFIER[,...]      # Verifier IDs for implementers (comma-separated)
--non-interactive                 # Skip all prompts
```

**Examples:**

```bash
# Interactive role creation
agent-os create-role

# Create implementer role
agent-os create-role --type implementer --name payment-engineer

# Non-interactive implementer creation
agent-os create-role \
  --type implementer \
  --name api-engineer \
  --profile default \
  --description "Handles API endpoints and controllers" \
  --your-role "Implement RESTful API endpoints with proper error handling" \
  --tools "Write,Read,Bash,WebFetch" \
  --model sonnet \
  --color blue \
  --areas "API endpoints,Controllers,Request handling,Response formatting" \
  --out-of-scope "Database migrations,Frontend components,Testing" \
  --standards "global/*,backend/*,testing/*" \
  --verified-by "backend-verifier" \
  --non-interactive

# Create verifier role
agent-os create-role \
  --type verifier \
  --name security-verifier \
  --description "Verifies security best practices" \
  --tools "Read,Grep,Bash" \
  --model sonnet \
  --color red \
  --areas "Authentication,Authorization,Input validation,SQL injection prevention" \
  --standards "global/*,backend/*" \
  --non-interactive
```

**For Claude Code Autonomous Use:**

```bash
# Create a role without any prompts
agent-os create-role \
  --type implementer \
  --name custom-engineer \
  --description "Custom implementation role" \
  --tools "Write,Read,Bash" \
  --model sonnet \
  --color purple \
  --non-interactive
```

---

### `agent-os version`

Show Agent OS version information.

**Aliases:** `v`, `-v`, `--version`

**Examples:**

```bash
agent-os version
agent-os -v
```

**Output:**

```
agent-os version 2.0.2
Installed version: 2.0.2
```

---

### `agent-os help`

Show help information for the CLI.

**Aliases:** `h`, `-h`, `--help`

**Examples:**

```bash
agent-os help
agent-os --help
```

---

## Non-Interactive Mode

For AI agents like Claude Code that need to run commands autonomously, use the `--non-interactive` flag with create commands and appropriate flags to skip prompts:

### Install Without Prompts

```bash
# Skip tool installation prompt
agent-os install --install-tools false

# Specify all configuration
agent-os install \
  --profile default \
  --multi-agent-mode true \
  --multi-agent-tool claude-code \
  --install-tools false
```

### Create Profile Without Prompts

```bash
agent-os create-profile \
  --name my-profile \
  --inherit-from default \
  --frameworks rails,postgresql \
  --non-interactive
```

### Create Role Without Prompts

```bash
agent-os create-role \
  --type implementer \
  --name my-engineer \
  --description "Custom role" \
  --tools "Write,Read,Bash" \
  --model sonnet \
  --color blue \
  --non-interactive
```

---

## Configuration Files

### Base Configuration

Location: `~/.agent-os/config.yml`

```yaml
version: 2.0.2
multi_agent_mode: true
multi_agent_tool: claude-code
single_agent_mode: false
single_agent_tool: ""
profile: default
```

### Project Configuration

Location: `[project]/.agent-os/config.yml`

```yaml
version: 2.0.2
profile: default
multi_agent_mode: true
multi_agent_tool: claude-code
single_agent_mode: false
single_agent_tool: ""
```

---

## Common Workflows

### First-Time Setup

```bash
# 1. Install Agent OS base
curl -sSL https://raw.githubusercontent.com/CodefiLabs/agent-os/main/setup/base.sh | bash

# 2. Install CLI globally (if not done during base install)
~/.agent-os/scripts/install-global.sh

# 3. Navigate to project
cd /path/to/project

# 4. Install in project
agent-os install
```

### Creating Custom Profile for Framework

```bash
# 1. Create profile
agent-os create-profile --name rails-api --inherit-from default

# 2. Add custom implementer roles
agent-os create-role --type implementer --name graphql-engineer

# 3. Install in project with new profile
agent-os install --profile rails-api
```

### Updating Agent OS

```bash
# Check what would change
agent-os update --dry-run

# Update with overwriting standards
agent-os update --overwrite-standards

# Full update with all overwrites
agent-os update --overwrite-all
```

---

## Exit Codes

- `0` - Success
- `1` - Error (invalid arguments, missing installation, etc.)

---

## Environment Variables

The CLI respects the following environment variables:

- `AGENT_OS_BASE_DIR` - Override base installation directory (default: `~/.agent-os`)
- `VERBOSE` - Enable verbose output (set to `true`)
- `DRY_RUN` - Enable dry-run mode (set to `true`)

**Examples:**

```bash
# Use custom base directory
AGENT_OS_BASE_DIR=/custom/path agent-os install

# Enable verbose output
VERBOSE=true agent-os update

# Dry run mode
DRY_RUN=true agent-os install
```

---

## Troubleshooting

### Command Not Found

If `agent-os` command is not found after installation:

1. Check if CLI is installed:
   ```bash
   ls -la ~/.local/bin/agent-os
   ```

2. Add to PATH if needed:
   ```bash
   # For bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc

   # For zsh
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. Use direct path as fallback:
   ```bash
   ~/.agent-os/scripts/agent-os install
   ```

### Permission Denied

If you get permission errors:

```bash
# Make CLI executable
chmod +x ~/.agent-os/scripts/agent-os

# Reinstall global CLI
~/.agent-os/scripts/install-global.sh
```

### Base Installation Not Found

If CLI reports missing base installation:

```bash
# Verify base installation
ls -la ~/.agent-os/

# Reinstall if needed
curl -sSL https://raw.githubusercontent.com/CodefiLabs/agent-os/main/setup/base.sh | bash
```

---

## For AI Agents (Claude Code)

When Claude Code needs to use Agent OS autonomously:

### Guidelines

1. **Always use non-interactive flags** to prevent prompts
2. **Specify all required configuration** via flags
3. **Use `--dry-run` first** when uncertain about changes
4. **Check command exit codes** to verify success

### Example Usage Pattern

```bash
# 1. Check if already installed
if [[ -d .agent-os ]]; then
  # Update existing installation
  agent-os update --overwrite-agents
else
  # Fresh installation
  agent-os install --install-tools false
fi

# 2. Create custom role if needed
agent-os create-role \
  --type implementer \
  --name custom-engineer \
  --description "Handles custom functionality" \
  --tools "Write,Read,Bash" \
  --model sonnet \
  --color purple \
  --non-interactive

# 3. Verify success
if [[ $? -eq 0 ]]; then
  echo "Success"
else
  echo "Failed"
fi
```

---

## See Also

- [Agent OS Documentation](https://buildermethods.com/agent-os)
- [CLAUDE.md](../CLAUDE.md) - Project instructions for Claude Code
- [Installation Guide](../README.md#installation)
- [Bash Style Guide](bash-style-guide.md)
