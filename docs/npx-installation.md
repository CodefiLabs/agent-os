# NPX Installation Guide

Agent OS can be installed using `npx` for quick, one-command installation without manual git cloning.

## Standard Installation

### Using Published NPM Package (When Available)

Once Agent OS is published to npm:

```bash
npx @agent-os/cli
```

This will:
1. Download the package
2. Install Agent OS to `~/.agent-os/`
3. Prompt to install `agent-os` command globally
4. Show next steps

### Using GitHub Repository (Current Method)

Until the package is published, install directly from GitHub:

```bash
npx github:CodefiLabs/agent-os
```

Or with explicit repository URL:

```bash
AGENT_OS_REPO=https://github.com/CodefiLabs/agent-os npx github:CodefiLabs/agent-os
```

## Fork Installation

### Installing from Your Fork

To install from your own fork of Agent OS:

```bash
# Using GitHub username/repo format
npx github:your-username/agent-os

# Or with explicit repository URL
AGENT_OS_REPO=https://github.com/your-username/agent-os npx github:CodefiLabs/agent-os
```

**Example:**

```bash
# Installing from a fork by user "alice"
npx github:alice/agent-os

# Or with environment variable
AGENT_OS_REPO=https://github.com/alice/agent-os npx github:CodefiLabs/agent-os
```

### Installing from a Specific Branch

```bash
AGENT_OS_REPO=https://github.com/your-username/agent-os npx github:your-username/agent-os#branch-name
```

**Example:**

```bash
# Installing from "custom-features" branch
npx github:alice/agent-os#custom-features
```

## Non-Interactive Installation

For automated scripts or CI/CD pipelines:

```bash
# Skip interactive prompts
echo "y" | npx @agent-os/cli

# Or suppress global CLI installation prompt
AGENT_OS_SKIP_CLI=true npx @agent-os/cli
```

## Environment Variables

The installation script respects these environment variables:

### `AGENT_OS_REPO`

Override the GitHub repository URL:

```bash
AGENT_OS_REPO=https://github.com/your-username/agent-os npx @agent-os/cli
```

### `AGENT_OS_SKIP_CLI`

Skip global CLI installation prompt:

```bash
AGENT_OS_SKIP_CLI=true npx @agent-os/cli
```

### `AGENT_OS_BASE_DIR`

Install to custom directory instead of `~/.agent-os`:

```bash
AGENT_OS_BASE_DIR=/custom/path npx @agent-os/cli
```

## Installation Methods Comparison

| Method | Command | Use Case |
|--------|---------|----------|
| **NPM** | `npx @agent-os/cli` | Standard installation (when published) |
| **GitHub** | `npx github:CodefiLabs/agent-os` | Install from main repository |
| **Fork** | `npx github:username/agent-os` | Install from your fork |
| **Branch** | `npx github:username/agent-os#branch` | Install specific branch |
| **Custom** | `AGENT_OS_REPO=... npx ...` | Install from any git URL |

## What Gets Installed

The NPX installation:

1. **Base Installation** to `~/.agent-os/`
   - Scripts
   - Profiles
   - Standards
   - Workflows
   - Agents
   - Roles
   - Tools
   - Automations

2. **Global CLI** (optional)
   - Symlink to `~/.local/bin/agent-os` or `/usr/local/bin/agent-os`
   - Available system-wide

## After Installation

### Verify Installation

```bash
# Check agent-os command is available
agent-os version

# Or use direct path
~/.agent-os/scripts/agent-os version
```

### Install in Project

Navigate to your project and run:

```bash
cd /path/to/project
agent-os install
```

## Updating Agent OS

To update your base installation:

### From NPM (When Published)

```bash
npx @agent-os/cli
```

Answer "y" when prompted to overwrite existing installation.

### From GitHub

```bash
npx github:CodefiLabs/agent-os
```

### From Your Fork

```bash
npx github:your-username/agent-os
```

## Troubleshooting

### "Command not found: npx"

Install Node.js and npm:

```bash
# macOS
brew install node

# Linux (Ubuntu/Debian)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### "Permission denied"

Ensure scripts are executable:

```bash
chmod +x ~/.agent-os/scripts/agent-os
chmod +x ~/.agent-os/scripts/*.sh
```

### "Existing installation found"

You'll be prompted to overwrite. Answer "y" to proceed or "n" to cancel.

To force overwrite without prompt:

```bash
rm -rf ~/.agent-os && npx @agent-os/cli
```

## Advanced Usage

### Installing Multiple Versions

Install to different directories:

```bash
# Stable version
AGENT_OS_BASE_DIR=~/.agent-os-stable npx @agent-os/cli

# Development version
AGENT_OS_BASE_DIR=~/.agent-os-dev AGENT_OS_REPO=https://github.com/your-username/agent-os npx github:your-username/agent-os#dev
```

### Custom Installation Script

Create a wrapper script:

```bash
#!/bin/bash
# install-agent-os.sh

# Configuration
export AGENT_OS_REPO="https://github.com/your-username/agent-os"
export AGENT_OS_SKIP_CLI=false

# Install
npx github:your-username/agent-os

# Post-install customization
~/.agent-os/scripts/create-profile.sh --name custom-profile --non-interactive
```

## For Package Maintainers

### Publishing to NPM

To publish Agent OS to npm:

```bash
# Login to npm
npm login

# Publish package
npm publish --access public
```

### Scoped Package

If using a scoped package (e.g., `@agent-os/cli`):

```bash
npm publish --access public
```

Users can then install with:

```bash
npx @agent-os/cli
```

## See Also

- [CLI Reference](cli-reference.md)
- [Installation Guide](../README.md#installation)
- [CLI Quick Start](cli-quick-start.md)
