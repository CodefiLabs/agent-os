# NPX Installation Quick Reference

## Installation Commands

### Standard Installation

```bash
# From npm (when published)
npx @agent-os/cli

# From GitHub
npx github:CodefiLabs/agent-os
```

### Fork Installation

```bash
# Install from your fork
npx github:your-username/agent-os

# Install from specific branch
npx github:your-username/agent-os#branch-name

# Install with custom repo URL
AGENT_OS_REPO=https://github.com/your-username/agent-os npx @agent-os/cli
```

## Examples

### Alice's Custom Fork

```bash
# Standard fork installation
npx github:alice/agent-os

# Install from development branch
npx github:alice/agent-os#dev

# Install from feature branch
npx github:alice/agent-os#custom-features
```

### Company Internal Fork

```bash
# Private repository (requires authentication)
AGENT_OS_REPO=https://github.com/acme-corp/agent-os npx github:CodefiLabs/agent-os

# With SSH
AGENT_OS_REPO=git@github.com:acme-corp/agent-os.git npx github:CodefiLabs/agent-os
```

### Multiple Installations

```bash
# Stable version
AGENT_OS_BASE_DIR=~/.agent-os-stable npx @agent-os/cli

# Development version from fork
AGENT_OS_BASE_DIR=~/.agent-os-dev AGENT_OS_REPO=https://github.com/your-username/agent-os npx github:your-username/agent-os
```

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `AGENT_OS_REPO` | Git repository URL | `https://github.com/your-username/agent-os` |
| `AGENT_OS_BASE_DIR` | Installation directory | `~/.agent-os` |
| `AGENT_OS_SKIP_CLI` | Skip CLI install prompt | `true` |

## Non-Interactive Installation

```bash
# Skip all prompts
echo "y" | npx @agent-os/cli

# Skip CLI installation
AGENT_OS_SKIP_CLI=true npx @agent-os/cli

# Complete non-interactive
echo "y" | AGENT_OS_SKIP_CLI=true npx github:your-username/agent-os
```

## After Installation

```bash
# Verify installation
agent-os version

# Install in project
cd /path/to/project
agent-os install

# See all commands
agent-os help
```

## Common Workflows

### Developer Testing Fork

```bash
# 1. Install fork
npx github:dev-name/agent-os#experimental

# 2. Verify
agent-os version

# 3. Test in project
cd test-project
agent-os install --dry-run
```

### Team Custom Standards

```bash
# 1. Install company fork
npx github:company/agent-os

# 2. Customize standards
cd ~/.agent-os/profiles/default/standards
# Edit standards files

# 3. Install in all projects
for project in ~/projects/*; do
  cd "$project"
  agent-os install
done
```

### Parallel Versions

```bash
# Stable for production
AGENT_OS_BASE_DIR=~/.agent-os-stable npx @agent-os/cli

# Fork for testing
AGENT_OS_BASE_DIR=~/.agent-os-test npx github:your-username/agent-os#testing

# Use specific version
~/.agent-os-stable/scripts/agent-os install  # In production project
~/.agent-os-test/scripts/agent-os install    # In test project
```

## See Also

- [Full NPX Installation Guide](npx-installation.md)
- [CLI Reference](cli-reference.md)
- [CLI Quick Start](cli-quick-start.md)
