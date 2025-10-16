# Testing NPX Installation

Guide for testing the NPX installation locally before publishing.

## Prerequisites

- Node.js 14+
- npm or npx

## Local Testing

### Test 1: Direct Script Execution

```bash
# From the repository root
bash scripts/npx-install.sh
```

Expected:
- Detects "local" installation source
- Copies files from current directory to ~/.agent-os
- Prompts for global CLI installation
- Shows success message

### Test 2: Simulated NPX Environment

```bash
# Create a temp directory to simulate npx
mkdir -p /tmp/test-npx/node_modules/@agent-os/cli
cp -R . /tmp/test-npx/node_modules/@agent-os/cli/

# Run from simulated npx location
cd /tmp/test-npx/node_modules/@agent-os/cli
bash scripts/npx-install.sh

# Cleanup
rm -rf /tmp/test-npx
```

Expected:
- Detects "npm" installation source
- Copies files to ~/.agent-os
- Success message

### Test 3: GitHub NPX (Real)

```bash
# Test with actual npx (requires pushing to GitHub first)
npx github:CodefiLabs/agent-os

# Or from your fork
npx github:your-username/agent-os
```

Expected:
- NPX clones repository to temp directory
- Executes scripts/npx-install.sh
- Detects "github" installation source
- Copies to ~/.agent-os
- Prompts for CLI installation

### Test 4: With Environment Variables

```bash
# Custom repository
AGENT_OS_REPO=https://github.com/your-username/agent-os bash scripts/npx-install.sh

# Custom base directory
AGENT_OS_BASE_DIR=/tmp/test-agent-os bash scripts/npx-install.sh

# Skip CLI installation
AGENT_OS_SKIP_CLI=true bash scripts/npx-install.sh
```

### Test 5: Non-Interactive Mode

```bash
# Pipe "y" to simulate user accepting prompts
echo "y" | bash scripts/npx-install.sh

# Or skip with environment variable
AGENT_OS_SKIP_CLI=true bash scripts/npx-install.sh
```

## Verification Steps

After any test:

```bash
# 1. Check installation exists
ls -la ~/.agent-os/

# 2. Check scripts are executable
ls -la ~/.agent-os/scripts/

# 3. Check CLI works
~/.agent-os/scripts/agent-os version

# 4. If global CLI installed
agent-os version

# 5. Check config
cat ~/.agent-os/config.yml
```

## Common Issues

### "rsync: command not found"

The script falls back to `cp` if rsync is not available:

```bash
# Install rsync (optional)
brew install rsync  # macOS
apt-get install rsync  # Linux
```

### Permission Errors

```bash
# Fix permissions
chmod +x ~/.agent-os/scripts/*.sh
chmod +x ~/.agent-os/scripts/agent-os
```

### Existing Installation

Remove before testing:

```bash
rm -rf ~/.agent-os
```

## Testing Package Publishing

Before publishing to npm:

### 1. Pack Locally

```bash
# Create a tarball
npm pack

# This creates: agent-os-cli-2.0.4.tgz
```

### 2. Test Installation from Tarball

```bash
# Install globally from tarball
npm install -g ./agent-os-cli-2.0.4.tgz

# Verify
agent-os version

# Cleanup
npm uninstall -g @agent-os/cli
rm agent-os-cli-2.0.4.tgz
```

### 3. Test NPX from Tarball

```bash
npx ./agent-os-cli-2.0.4.tgz
```

## Testing Workflow

Recommended testing sequence before release:

```bash
# 1. Clean slate
rm -rf ~/.agent-os

# 2. Test local execution
bash scripts/npx-install.sh

# 3. Verify installation
agent-os version

# 4. Test in a project
cd /tmp/test-project
agent-os install --dry-run

# 5. Clean up
rm -rf ~/.agent-os

# 6. Test GitHub npx (if pushed)
npx github:CodefiLabs/agent-os

# 7. Verify again
agent-os version

# 8. Test with fork
npx github:your-username/agent-os
```

## Debugging

Enable verbose output:

```bash
# Add debug output to script
bash -x scripts/npx-install.sh

# Check what npx is doing
npx --loglevel=silly github:CodefiLabs/agent-os
```

Check detection:

```bash
# Add this to npx-install.sh temporarily:
echo "DEBUG: Source detected as: $source"
echo "DEBUG: Script dir: $script_dir"
echo "DEBUG: Package dir: $package_dir"
```

## See Also

- [NPX Installation Guide](npx-installation.md)
- [NPX Quick Reference](npx-quick-reference.md)
- [CLI Reference](cli-reference.md)
