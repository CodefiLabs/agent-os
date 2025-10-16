# Agent OS Installation Guide

Multiple installation methods to fit your workflow.

## Quick Install (Recommended)

### NPX Installation

The fastest way to get started:

```bash
# Install from npm (when published to npm registry)
npx @agent-os/cli

# Install from GitHub (current method)
npx github:CodefiLabs/agent-os
```

This single command:
- ✓ Installs Agent OS to `~/.agent-os/`
- ✓ Makes all scripts executable
- ✓ Offers to install `agent-os` CLI globally
- ✓ Shows next steps

**See:** [NPX Installation Guide](docs/npx-installation.md)

---

## Install from Fork

Perfect for teams with custom standards or workflows:

```bash
# Install from your fork
npx github:your-username/agent-os

# Install from specific branch
npx github:your-username/agent-os#branch-name

# Install with environment variable
AGENT_OS_REPO=https://github.com/your-username/agent-os npx @agent-os/cli
```

**Examples:**

```bash
# Company fork
npx github:acme-corp/agent-os

# Developer fork with custom features
npx github:alice/agent-os#custom-features

# Multiple versions
AGENT_OS_BASE_DIR=~/.agent-os-stable npx @agent-os/cli
AGENT_OS_BASE_DIR=~/.agent-os-dev npx github:your-username/agent-os#dev
```

**See:** [NPX Quick Reference](docs/npx-quick-reference.md)

---

## Traditional Installation

### Using curl

```bash
# For Claude Code
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup/base.sh | bash -s -- --claude-code

# For Cursor
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup/base.sh | bash -s -- --cursor

# For both
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup/base.sh | bash -s -- --claude-code --cursor
```

### Manual Git Clone

```bash
# Clone repository
git clone https://github.com/CodefiLabs/agent-os ~/.agent-os

# Make scripts executable
chmod +x ~/.agent-os/scripts/*.sh
chmod +x ~/.agent-os/scripts/agent-os

# Install CLI globally (optional)
~/.agent-os/scripts/install-global.sh
```

---

## Global CLI Installation

After base installation, optionally install the `agent-os` command globally:

```bash
~/.agent-os/scripts/install-global.sh
```

This creates a symlink in `~/.local/bin/` or `/usr/local/bin/` so you can run:

```bash
agent-os install
agent-os update
agent-os create-profile
agent-os help
```

**See:** [CLI Reference](docs/cli-reference.md)

---

## After Installation

### 1. Verify Installation

```bash
agent-os version
# Or: ~/.agent-os/scripts/agent-os version
```

### 2. Navigate to Your Project

```bash
cd /path/to/your/project
```

### 3. Install Agent OS in Project

```bash
agent-os install
```

This installs:
- `agent-os/` - Standards, workflows, roles
- `.claude/` - Commands and agents (if using Claude Code)
- `.github/workflows/` - GitHub Actions (optional)

---

## Installation Methods Comparison

| Method | Command | Speed | Use Case |
|--------|---------|-------|----------|
| **NPX (Standard)** | `npx @agent-os/cli` | ⚡️ Fastest | Quick setup, one command |
| **NPX (GitHub)** | `npx github:CodefiLabs/agent-os` | ⚡️ Fast | Current standard method |
| **NPX (Fork)** | `npx github:user/agent-os` | ⚡️ Fast | Custom fork/branch |
| **curl** | `curl ... \| bash` | ⚡️ Fast | Traditional install |
| **Git Clone** | `git clone ...` | 🐢 Slower | Development/contribution |

---

## Non-Interactive Installation

For scripts, CI/CD, or AI agents:

### NPX

```bash
# Skip prompts
echo "y" | npx @agent-os/cli

# Or skip CLI installation
AGENT_OS_SKIP_CLI=true npx @agent-os/cli
```

### CLI Commands

```bash
# Install without prompts
agent-os install --install-tools false

# Create profile without prompts
agent-os create-profile --name custom --non-interactive

# Create role without prompts
agent-os create-role --type implementer --name api-engineer --non-interactive
```

---

## Environment Variables

Customize installation with environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `AGENT_OS_REPO` | Git repository URL | `https://github.com/CodefiLabs/agent-os` |
| `AGENT_OS_BASE_DIR` | Installation directory | `~/.agent-os` |
| `AGENT_OS_SKIP_CLI` | Skip CLI install prompt | `false` |

**Examples:**

```bash
# Install from custom repository
AGENT_OS_REPO=https://github.com/your-username/agent-os npx @agent-os/cli

# Install to custom directory
AGENT_OS_BASE_DIR=/custom/path npx @agent-os/cli

# Non-interactive
AGENT_OS_SKIP_CLI=true npx @agent-os/cli
```

---

## Updating Agent OS

### Update Base Installation

```bash
# NPX (overwrite existing)
npx @agent-os/cli
# Answer "y" when prompted

# Or force reinstall
rm -rf ~/.agent-os && npx @agent-os/cli
```

### Update Project Installation

```bash
cd /path/to/project
agent-os update
```

With selective overwrites:

```bash
agent-os update --overwrite-agents
agent-os update --overwrite-standards
agent-os update --overwrite-all
```

---

## Platform Support

### Supported Platforms

- ✅ macOS (Apple Silicon and Intel)
- ✅ Linux (Ubuntu, Debian, Fedora, etc.)
- ⚠️ Windows WSL (Windows Subsystem for Linux)

### Requirements

- Bash 4.0+
- Git
- curl
- Node.js 14+ (for NPX installation only)

### Check Requirements

```bash
bash --version    # Should be 4.0+
git --version     # Any recent version
curl --version    # Any recent version
node --version    # 14.0+ (for NPX only)
```

---

## Installation Locations

### Base Installation

```
~/.agent-os/
├── config.yml              # Base configuration
├── scripts/                # Installation and management scripts
├── profiles/
│   └── default/            # Default profile
│       ├── agents/         # Agent definitions
│       ├── commands/       # Slash commands
│       ├── roles/          # Role definitions
│       ├── standards/      # Coding standards
│       ├── workflows/      # Workflow instructions
│       ├── tools/          # MCP server configs
│       └── automations/    # CI/CD workflows
```

### Project Installation

```
project/
├── .agent-os/
│   ├── config.yml          # Project configuration
│   ├── standards/          # Project standards (customizable)
│   └── roles/              # Role definitions
├── .claude/                # Claude Code integration
│   ├── agents/             # Compiled agents
│   └── commands/           # Compiled commands
└── .github/workflows/      # GitHub Actions (optional)
```

---

## Troubleshooting

### NPX: Command not found

Install Node.js:

```bash
# macOS
brew install node

# Linux
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Permission denied

Make scripts executable:

```bash
chmod +x ~/.agent-os/scripts/agent-os
chmod +x ~/.agent-os/scripts/*.sh
```

### agent-os: command not found

Add to PATH or reinstall CLI:

```bash
# Add to PATH
export PATH="$HOME/.local/bin:$PATH"

# Or reinstall CLI
~/.agent-os/scripts/install-global.sh
```

### Installation fails

Try manual installation:

```bash
# Remove partial installation
rm -rf ~/.agent-os

# Clone manually
git clone https://github.com/CodefiLabs/agent-os ~/.agent-os

# Make executable
chmod +x ~/.agent-os/scripts/*.sh
chmod +x ~/.agent-os/scripts/agent-os

# Install CLI
~/.agent-os/scripts/install-global.sh
```

---

## Next Steps

After installation:

1. **Customize Standards** (optional)
   ```bash
   cd ~/.agent-os/profiles/default/standards
   # Edit standards files
   ```

2. **Install in Project**
   ```bash
   cd /path/to/project
   agent-os install
   ```

3. **Create Custom Profile** (optional)
   ```bash
   agent-os create-profile --name my-profile
   ```

4. **Read Documentation**
   - [CLI Reference](docs/cli-reference.md)
   - [Development Workflow](CLAUDE.md#development-workflow)
   - [NPX Installation](docs/npx-installation.md)

---

## Getting Help

- **Documentation**: https://buildermethods.com/agent-os
- **Issues**: https://github.com/CodefiLabs/agent-os/issues
- **CLI Help**: `agent-os help`
- **Version**: `agent-os version`
