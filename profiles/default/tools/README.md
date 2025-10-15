# Agent OS Tools

This directory contains pre-configured MCP (Model Context Protocol) server definitions for Agent OS projects.

## Overview

Agent OS tools enable seamless integration of MCP servers with your AI coding environment, providing:

- Pre-configured MCP server definitions for common integrations
- Automated installation to Claude Code, Cursor, and other AI tools
- Team-shareable configurations via version control
- Consistent tool setup across projects and team members

## What are MCP Servers?

Model Context Protocol (MCP) is an open standard that allows AI assistants to connect to external data sources and tools. MCP servers provide:

- **Resources**: Contextual information and data for AI models
- **Tools**: Functions that AI models can execute
- **Prompts**: Templated workflows and messages

Popular MCP servers enable AI assistants to:
- Access GitHub repositories, issues, and pull requests
- Query databases (SQLite, PostgreSQL, etc.)
- Search the web (Brave Search, Tavily)
- Read documentation (MDN, DevDocs)
- Maintain persistent memory across sessions
- Perform enhanced filesystem operations

## Available MCP Servers

Agent OS provides pre-configured definitions for:

- **github** - GitHub repository integration for code reading, issue management, PR operations
- **filesystem** - Enhanced file operations beyond standard tools
- **web-search** - Web search capabilities (Brave Search, Tavily)
- **database** - Database access and querying (SQLite, PostgreSQL)
- **memory** - Persistent context and memory across sessions

Each server configuration includes:
- Installation commands
- Required environment variables and secrets
- Capabilities and features
- Documentation links

See `tools/mcp/` for individual server definitions.

## Installation Scopes

MCP servers can be installed at different scopes:

### User Scope (Recommended for Personal Use)
Installs to your user configuration (`~/.claude.json` or `~/.cursor/mcp.json`).
- Available in all projects
- Not version-controlled
- Personal configuration

### Project Scope (Recommended for Teams)
Installs to project configuration (`.mcp.json` in project root).
- Shared with team via version control
- Consistent across team members
- Project-specific configuration

## Installation

MCP servers are installed automatically when you run:

```bash
~/.agent-os/scripts/project-install.sh
```

You'll be prompted to install tools and choose a scope.

### Manual Installation

To install MCP servers manually:

```bash
# Install to user scope (all projects)
PROJECT_ROOT=$(pwd) bash ~/.agent-os/profiles/default/tools/setup/claude-code.sh --scope user

# Install to project scope (team-shared)
PROJECT_ROOT=$(pwd) bash ~/.agent-os/profiles/default/tools/setup/cursor.sh --scope project
```

### Installation Options

```bash
# Install with specific scope
~/.agent-os/scripts/project-install.sh --install-tools --tools-scope user

# Dry run (see what would be installed)
~/.agent-os/scripts/project-install.sh --install-tools --dry-run

# Update existing tools
~/.agent-os/scripts/project-update.sh --overwrite-tools
```

## Supported AI Coding Tools

- **Claude Code** - Installs to `~/.claude.json` or `.mcp.json`
- **Cursor** - Installs to `~/.cursor/mcp.json` or `.mcp.json`

The installation scripts automatically detect which tool you're using and apply the correct configuration.

## Configuration Format

Each MCP server is defined in a JSON file with this structure:

```json
{
  "server_id": "server-name",
  "description": "What this server does",
  "command": "executable-command",
  "args": ["arg1", "arg2"],
  "env": {
    "API_KEY": "${API_KEY}"
  },
  "transport": "stdio",
  "install_command": "npm install -g package-name",
  "required_secrets": ["API_KEY"],
  "capabilities": ["resources", "tools"],
  "tags": ["category", "purpose"],
  "documentation_url": "https://..."
}
```

## Custom MCP Servers

You can add your own MCP server definitions to `tools/mcp/custom/`:

1. Create a JSON file following the format above
2. Run the setup script to install it
3. (Optional) Commit to version control to share with team

## Environment Variables and Secrets

MCP servers often require API keys or tokens. The setup scripts will:
- Detect required secrets from `required_secrets` field
- Check if they're already set in your environment
- Prompt you to add them if missing
- Never commit secrets to version control

### Setting Secrets

For user scope installations:
```bash
# Add to your shell profile (~/.bashrc, ~/.zshrc, etc.)
export GITHUB_TOKEN="your-token-here"
export TAVILY_API_KEY="your-key-here"
```

For project scope installations:
```bash
# Create .env file (add to .gitignore!)
echo "GITHUB_TOKEN=your-token-here" >> .env
echo ".env" >> .gitignore
```

## Updating MCP Servers

Update MCP server configurations:

```bash
~/.agent-os/scripts/project-update.sh --overwrite-tools
```

This will:
- Update server definitions from the profile
- Preserve your existing servers
- Merge new configurations

## Troubleshooting

### Server not appearing in AI tool

1. **Restart the AI tool** - MCP configurations are loaded on startup
2. **Check configuration file** - Verify the server appears in `~/.claude.json` or `~/.cursor/mcp.json`
3. **Validate JSON** - Ensure the configuration file is valid JSON
4. **Check logs** - Look for errors in the AI tool's logs

### Missing dependencies

Some MCP servers require Node.js packages:

```bash
# Install globally
npm install -g @modelcontextprotocol/server-github

# Or use npx (no installation needed)
# The setup scripts use npx by default
```

### Authentication errors

1. **Verify secrets are set** - Run `echo $GITHUB_TOKEN` etc.
2. **Check secret names** - Must match exactly (case-sensitive)
3. **Restart your shell** - After adding to shell profile
4. **Test the API key** - Verify it's valid with the service

### Server not working

1. **Check server logs** - AI tools usually show MCP server logs
2. **Test manually** - Try running the command directly
3. **Verify transport** - Currently only `stdio` is supported
4. **Check permissions** - Ensure executable has proper permissions

## Custom Profiles

Different profiles can include different MCP server sets:

```bash
# Create a custom profile
~/.agent-os/scripts/create-profile.sh --name my-profile

# Add custom MCP servers
mkdir -p ~/.agent-os/profiles/my-profile/tools/mcp/
# Add your JSON files

# Install with custom profile
~/.agent-os/scripts/project-install.sh --profile my-profile
```

## Security Best Practices

1. **Never commit secrets** to version control
   - Add `.env` files to `.gitignore`
   - Use environment variables for API keys

2. **Use minimal permissions** for API tokens
   - GitHub: Use fine-grained tokens with only needed scopes
   - Other services: Follow principle of least privilege

3. **Rotate credentials regularly**
   - Update API keys periodically
   - Revoke unused tokens

4. **Review server capabilities** before installing
   - Understand what data the server can access
   - Check server source code if concerned

## Additional Resources

- **MCP Specification**: https://modelcontextprotocol.io/specification/2025-06-18
- **MCP Server List**: https://github.com/modelcontextprotocol/servers
- **Claude Code MCP Docs**: https://docs.claude.com/en/docs/claude-code/mcp
- **Agent OS Documentation**: See `CLAUDE.md` in project root

## Contributing

To add a new MCP server definition:

1. Create a JSON file in `profiles/default/tools/mcp/`
2. Follow the configuration format above
3. Test installation with `--dry-run`
4. Submit a pull request

See `tools/setup/README.md` for setup script development guidelines.
