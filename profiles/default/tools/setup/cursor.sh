#!/usr/bin/env bash
# Cursor MCP Tools Setup Script
# Installs MCP servers to Cursor configuration
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
PROFILE_DIR="${PROFILE_DIR:-$HOME/.agent-os/profiles/default}"
MCP_DIR="$PROFILE_DIR/tools/mcp"

# Default values
SCOPE="${SCOPE:-user}"
DRY_RUN="${DRY_RUN:-false}"
VERBOSE="${VERBOSE:-false}"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --scope)
            SCOPE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        --verbose)
            VERBOSE="true"
            shift
            ;;
        -h|--help)
            cat << EOF
Usage: $0 [OPTIONS]

Install MCP servers to Cursor configuration.

Options:
    --scope [user|project]  Installation scope (default: user)
                           user: ~/.cursor/mcp.json (all projects)
                           project: .mcp.json (version controlled)
    --dry-run              Show what would be done without doing it
    --verbose              Show detailed output
    -h, --help             Show this help message

Environment Variables:
    PROJECT_ROOT          Project directory (required for project scope)
    PROFILE_DIR           Profile directory (default: ~/.agent-os/profiles/default)

Examples:
    $0 --scope user
    $0 --scope project --dry-run
    PROJECT_ROOT=/path/to/project $0 --scope project

EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Determine config file path based on scope
if [[ "$SCOPE" == "user" ]]; then
    CONFIG_FILE="$HOME/.cursor/mcp.json"
    CONFIG_SCOPE="user (~/.cursor/mcp.json)"
elif [[ "$SCOPE" == "project" ]]; then
    CONFIG_FILE="$PROJECT_ROOT/.mcp.json"
    CONFIG_SCOPE="project (.mcp.json)"
else
    echo "Error: Invalid scope '$SCOPE'. Must be 'user' or 'project'."
    exit 1
fi

echo "================================================"
echo "  Installing MCP Servers to Cursor"
echo "================================================"
echo ""
echo "Scope: $CONFIG_SCOPE"
echo "MCP definitions: $MCP_DIR"
if [[ "$DRY_RUN" == "true" ]]; then
    echo "Mode: DRY RUN (no changes will be made)"
fi
echo ""

# Check for jq or Python for JSON processing
HAS_JQ=false
HAS_PYTHON=false

if command -v jq &> /dev/null; then
    HAS_JQ=true
    [[ "$VERBOSE" == "true" ]] && echo "Using jq for JSON processing"
elif command -v python3 &> /dev/null; then
    HAS_PYTHON=true
    [[ "$VERBOSE" == "true" ]] && echo "Using Python for JSON processing"
else
    echo "Error: Neither jq nor python3 found. Please install one of them."
    echo "  macOS: brew install jq"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    exit 1
fi

# Check if MCP directory exists
if [[ ! -d "$MCP_DIR" ]]; then
    echo "Error: MCP definitions directory not found: $MCP_DIR"
    exit 1
fi

# Initialize config file if it doesn't exist
if [[ ! -f "$CONFIG_FILE" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would create new config file: $CONFIG_FILE"
    else
        mkdir -p "$(dirname "$CONFIG_FILE")"
        echo '{"mcpServers":{}}' > "$CONFIG_FILE"
        echo "Created new config file: $CONFIG_FILE"
        echo ""
    fi
fi

# Read existing config or initialize empty
if [[ -f "$CONFIG_FILE" ]] && [[ "$DRY_RUN" == "false" ]]; then
    if [[ "$HAS_JQ" == "true" ]]; then
        EXISTING_CONFIG=$(cat "$CONFIG_FILE")
        # Ensure mcpServers exists
        if ! echo "$EXISTING_CONFIG" | jq -e '.mcpServers' > /dev/null 2>&1; then
            EXISTING_CONFIG=$(echo "$EXISTING_CONFIG" | jq '. + {mcpServers: {}}')
            echo "$EXISTING_CONFIG" > "$CONFIG_FILE"
        fi
    else
        EXISTING_CONFIG=$(python3 -c "
import json, sys
try:
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)
    if 'mcpServers' not in config:
        config['mcpServers'] = {}
    print(json.dumps(config))
except:
    print('{\"mcpServers\":{}}')
")
    fi
else
    EXISTING_CONFIG='{"mcpServers":{}}'
fi

# Process MCP server definitions
echo "Processing MCP server definitions..."
echo ""

ADDED_COUNT=0
SKIPPED_COUNT=0
MISSING_SECRETS=()

# Find all JSON files in MCP directory (including custom subdirectory)
while IFS= read -r -d '' mcp_file; do
    [[ "$VERBOSE" == "true" ]] && echo "Reading: $mcp_file"

    # Parse MCP definition
    if [[ "$HAS_JQ" == "true" ]]; then
        SERVER_ID=$(jq -r '.server_id' "$mcp_file")
        DESCRIPTION=$(jq -r '.description' "$mcp_file")
        COMMAND=$(jq -r '.command' "$mcp_file")
        ARGS=$(jq -c '.args' "$mcp_file")
        ENV=$(jq -c '.env' "$mcp_file")
        REQUIRED_SECRETS=$(jq -r '.required_secrets[]?' "$mcp_file")
    else
        SERVER_DATA=$(python3 -c "
import json
with open('$mcp_file', 'r') as f:
    data = json.load(f)
print(json.dumps({
    'server_id': data['server_id'],
    'description': data.get('description', ''),
    'command': data['command'],
    'args': data.get('args', []),
    'env': data.get('env', {}),
    'required_secrets': data.get('required_secrets', [])
}))
")
        SERVER_ID=$(echo "$SERVER_DATA" | python3 -c "import json, sys; print(json.load(sys.stdin)['server_id'])")
        DESCRIPTION=$(echo "$SERVER_DATA" | python3 -c "import json, sys; print(json.load(sys.stdin)['description'])")
        COMMAND=$(echo "$SERVER_DATA" | python3 -c "import json, sys; print(json.load(sys.stdin)['command'])")
        ARGS=$(echo "$SERVER_DATA" | python3 -c "import json, sys; print(json.dumps(json.load(sys.stdin)['args']))")
        ENV=$(echo "$SERVER_DATA" | python3 -c "import json, sys; print(json.dumps(json.load(sys.stdin)['env']))")
        REQUIRED_SECRETS=$(echo "$SERVER_DATA" | python3 -c "import json, sys; [print(s) for s in json.load(sys.stdin)['required_secrets']]")
    fi

    # Check if server already exists
    if [[ "$HAS_JQ" == "true" ]]; then
        EXISTS=$(echo "$EXISTING_CONFIG" | jq -e ".mcpServers.\"$SERVER_ID\"" > /dev/null 2>&1 && echo "true" || echo "false")
    else
        EXISTS=$(python3 -c "
import json, sys
config = json.loads('$EXISTING_CONFIG')
print('true' if '$SERVER_ID' in config.get('mcpServers', {}) else 'false')
")
    fi

    if [[ "$EXISTS" == "true" ]]; then
        echo "⊘ $SERVER_ID - skipped (already installed)"
        ((SKIPPED_COUNT++)) || true
        continue
    fi

    # Check for missing secrets
    for secret in $REQUIRED_SECRETS; do
        if [[ -z "${!secret:-}" ]]; then
            MISSING_SECRETS+=("$secret (for $SERVER_ID server)")
        fi
    done

    # Add server to config
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "✓ $SERVER_ID - would be added"
        ((ADDED_COUNT++)) || true
    else
        if [[ "$HAS_JQ" == "true" ]]; then
            EXISTING_CONFIG=$(echo "$EXISTING_CONFIG" | jq \
                --arg id "$SERVER_ID" \
                --arg cmd "$COMMAND" \
                --argjson args "$ARGS" \
                --argjson env "$ENV" \
                '.mcpServers[$id] = {command: $cmd, args: $args, env: $env}')
        else
            EXISTING_CONFIG=$(python3 -c "
import json, sys
config = json.loads('$EXISTING_CONFIG')
config['mcpServers']['$SERVER_ID'] = {
    'command': '$COMMAND',
    'args': json.loads('$ARGS'),
    'env': json.loads('$ENV')
}
print(json.dumps(config, indent=2))
")
        fi
        echo "✓ $SERVER_ID - added"
        ((ADDED_COUNT++)) || true
    fi

done < <(find "$MCP_DIR" -name "*.json" -type f -print0)

# Write updated config
if [[ "$DRY_RUN" == "false" ]] && [[ $ADDED_COUNT -gt 0 ]]; then
    if [[ "$HAS_JQ" == "true" ]]; then
        echo "$EXISTING_CONFIG" | jq '.' > "$CONFIG_FILE"
    else
        echo "$EXISTING_CONFIG" > "$CONFIG_FILE"
    fi
fi

# Summary
echo ""
echo "Summary:"
if [[ $ADDED_COUNT -gt 0 ]]; then
    echo "✓ Installed $ADDED_COUNT new MCP server(s)"
fi
if [[ $SKIPPED_COUNT -gt 0 ]]; then
    echo "⊘ Skipped $SKIPPED_COUNT existing server(s)"
fi

# Warn about missing secrets
if [[ ${#MISSING_SECRETS[@]} -gt 0 ]]; then
    echo ""
    echo "⚠️  Missing required secrets:"
    for secret in "${MISSING_SECRETS[@]}"; do
        echo "  - $secret"
    done
    echo ""
    echo "Add these to your environment:"
    for secret in "${MISSING_SECRETS[@]}"; do
        secret_name=$(echo "$secret" | cut -d' ' -f1)
        echo "  export $secret_name=\"your-value-here\""
    done
fi

# Next steps
if [[ "$DRY_RUN" == "false" ]] && [[ $ADDED_COUNT -gt 0 ]]; then
    echo ""
    echo "Next steps:"
    echo "  1. Restart Cursor to load new MCP servers"
    if [[ ${#MISSING_SECRETS[@]} -gt 0 ]]; then
        echo "  2. Set required environment variables (see above)"
        echo "  3. Add secrets to your shell profile (~/.bashrc, ~/.zshrc, etc.)"
    fi
fi

echo ""
echo "================================================"

exit 0
