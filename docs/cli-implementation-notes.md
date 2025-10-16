# Agent OS CLI Implementation Notes

## Overview

The `agent-os` CLI provides a unified command-line interface for all Agent OS operations. It wraps existing bash scripts with a clean, consistent interface.

## Architecture

### Script Structure

```
~/.agent-os/scripts/
├── agent-os              # Main CLI entry point
├── install-global.sh     # Global installation script
├── project-install.sh    # Project installation (called by CLI)
├── project-update.sh     # Project update (called by CLI)
├── create-profile.sh     # Profile creation (called by CLI)
├── create-role.sh        # Role creation (called by CLI)
└── common-functions.sh   # Shared utilities
```

### CLI Installation

When installed globally:
```
~/.local/bin/agent-os -> ~/.agent-os/scripts/agent-os (symlink)
```

The CLI resolves symlinks to find the actual script location, ensuring it can find related scripts regardless of how it's invoked.

## Key Implementation Details

### Symlink Resolution

The CLI uses a standard bash pattern to resolve symlinks:

```bash
SOURCE="${BASH_SOURCE[0]}"
while [[ -L "$SOURCE" ]]; do
    SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
```

This ensures `SCRIPT_DIR` always points to `~/.agent-os/scripts/` whether the CLI is:
- Run directly: `~/.agent-os/scripts/agent-os`
- Run via symlink: `/usr/local/bin/agent-os`
- Run via relative path: `./agent-os`

### Command Routing

Commands are routed to existing scripts using `exec`:

```bash
case $command in
    install|i)
        exec "$SCRIPT_DIR/project-install.sh" "$@"
        ;;
    update|u)
        exec "$SCRIPT_DIR/project-update.sh" "$@"
        ;;
esac
```

Using `exec` replaces the current process with the target script, ensuring:
- Exit codes propagate correctly
- No unnecessary shell nesting
- Clean process tree

### Execute Permissions

Execute permissions are set at multiple points to ensure reliability:

1. **Base Installation** (`base-install.sh`):
   ```bash
   chmod +x "$BASE_DIR/scripts/"*.sh
   chmod +x "$BASE_DIR/scripts/agent-os"
   ```

2. **Global Installation** (`install-global.sh`):
   ```bash
   chmod +x "$CLI_SOURCE"
   ln -s "$CLI_SOURCE" "$INSTALL_PATH"
   ```

### Non-Interactive Mode

All commands support non-interactive execution for AI agents:

- Scripts check `[[ -t 0 ]]` to detect if stdin is a terminal
- Flags like `--non-interactive` explicitly skip prompts
- Boolean flags support both forms: `--flag` and `--flag true/false`

## Command Reference

### install

Routes to: `project-install.sh`

Installs Agent OS into current project directory.

### update

Routes to: `project-update.sh`

Updates existing Agent OS installation.

### create-profile

Routes to: `create-profile.sh`

Creates a new profile in `~/.agent-os/profiles/`.

### create-role

Routes to: `create-role.sh`

Creates a new role in profile's `roles/` directory and generates corresponding agent.

### version

Implemented in CLI, reads version from:
- Hardcoded `VERSION` variable in CLI script
- `~/.agent-os/config.yml` for installed version

### help

Implemented in CLI, displays comprehensive help text.

## Testing

### Manual Testing

```bash
# Test direct execution
~/.agent-os/scripts/agent-os version

# Test via symlink
agent-os version

# Test command routing
agent-os install --dry-run

# Test non-interactive mode
agent-os install --install-tools false
```

### Automated Testing

```bash
# Syntax validation
bash -n scripts/agent-os
bash -n scripts/install-global.sh

# Symlink resolution test
ln -s /path/to/agent-os /tmp/test-link
/tmp/test-link version  # Should work
```

## Common Issues and Solutions

### "Permission denied" when running CLI

**Cause**: Script not executable

**Solution**:
```bash
chmod +x ~/.agent-os/scripts/agent-os
```

### "No such file or directory" for project-install.sh

**Cause**: Symlink not resolved correctly

**Solution**: This is fixed in the current implementation with symlink resolution loop.

### "agent-os: command not found"

**Cause**: Not in PATH or not installed globally

**Solutions**:
1. Add to PATH:
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

2. Use direct path:
   ```bash
   ~/.agent-os/scripts/agent-os install
   ```

3. Reinstall globally:
   ```bash
   ~/.agent-os/scripts/install-global.sh
   ```

## Future Enhancements

Potential improvements for future versions:

1. **Shell Completion**: Add bash/zsh completion scripts
2. **Config Command**: `agent-os config` to view/edit configuration
3. **Status Command**: `agent-os status` to check installation state
4. **Doctor Command**: `agent-os doctor` to diagnose issues
5. **Self-Update**: `agent-os self-update` to update CLI itself

## Development Guidelines

When modifying the CLI:

1. **Preserve backward compatibility**: Existing scripts should continue working
2. **Test symlink execution**: Always test via symlink, not just direct execution
3. **Validate syntax**: Run `bash -n scripts/agent-os` before committing
4. **Update documentation**: Keep CLI reference in sync with changes
5. **Maintain non-interactive support**: AI agents depend on this

## Related Documentation

- [CLI Reference](cli-reference.md) - Complete command documentation
- [CLI Quick Start](cli-quick-start.md) - Quick reference guide
- [CLAUDE.md](../CLAUDE.md) - Project instructions for Claude Code
- [Bash Style Guide](bash-style-guide.md) - Bash scripting standards
