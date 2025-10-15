#!/usr/bin/env bash
# GitHub Labels Setup Script for Agent OS
# Creates labels for all commands and agents in .claude/ directory
set -euo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"

echo "================================================"
echo "  Creating GitHub Labels for Agent OS"
echo "================================================"
echo ""

# Check prerequisites
if ! command -v gh &> /dev/null; then
    echo "⚠️  GitHub CLI (gh) not found."
    echo "   Install: https://cli.github.com/"
    echo ""
    echo "Skipping label creation."
    exit 0
fi

# Verify GitHub authentication
if ! gh auth status &> /dev/null; then
    echo "⚠️  Not authenticated with GitHub CLI."
    echo "   Run: gh auth login"
    exit 0
fi

# Check if .claude directory exists
if [[ ! -d "$PROJECT_ROOT/.claude" ]]; then
    echo "⚠️  .claude directory not found in project."
    echo "   Labels can only be created after Agent OS is installed."
    echo "   Run project installation first, then run this script."
    exit 0
fi

echo "Searching for commands and agents in .claude/..."
echo ""

COMMANDS_COUNT=0
AGENTS_COUNT=0

# Create labels for ALL commands (recursively)
if [[ -d "$PROJECT_ROOT/.claude/commands" ]]; then
    echo "Creating labels for commands..."

    while IFS= read -r -d '' cmd_file; do
        # Get relative path from .claude/commands/
        rel_path="${cmd_file#$PROJECT_ROOT/.claude/commands/}"
        # Remove .md extension
        rel_path="${rel_path%.md}"
        # Convert path separators to colons
        label="command:${rel_path//\//:}"

        # Create label
        if gh label create "$label" --description "Agent OS command: $rel_path" --color "0366d6" --force 2>/dev/null; then
            echo "  ✓ $label"
            ((COMMANDS_COUNT++)) || true
        else
            echo "  ⚠️  Could not create: $label"
        fi
    done < <(find "$PROJECT_ROOT/.claude/commands" -name "*.md" -type f -print0 2>/dev/null || true)

    echo ""
fi

# Create labels for ALL agents (recursively)
if [[ -d "$PROJECT_ROOT/.claude/agents" ]]; then
    echo "Creating labels for agents..."

    while IFS= read -r -d '' agent_file; do
        # Get relative path from .claude/agents/
        rel_path="${agent_file#$PROJECT_ROOT/.claude/agents/}"
        # Remove .md extension
        rel_path="${rel_path%.md}"
        # Convert path separators to colons
        label="agent:${rel_path//\//:}"

        # Create label
        if gh label create "$label" --description "Agent OS agent: $rel_path" --color "d73a4a" --force 2>/dev/null; then
            echo "  ✓ $label"
            ((AGENTS_COUNT++)) || true
        else
            echo "  ⚠️  Could not create: $label"
        fi
    done < <(find "$PROJECT_ROOT/.claude/agents" -name "*.md" -type f -print0 2>/dev/null || true)

    echo ""
fi

# Create workflow management labels
echo "Creating workflow management labels..."

if gh label create "working-agent" --description "Agent OS: Work in progress" --color "fbca04" --force 2>/dev/null; then
    echo "  ✓ working-agent"
else
    echo "  ⚠️  Could not create: working-agent"
fi

if gh label create "review-agent" --description "Agent OS: Ready for review" --color "0e8a16" --force 2>/dev/null; then
    echo "  ✓ review-agent"
else
    echo "  ⚠️  Could not create: review-agent"
fi

if gh label create "errored-agent" --description "Agent OS: Error occurred" --color "d93f0b" --force 2>/dev/null; then
    echo "  ✓ errored-agent"
else
    echo "  ⚠️  Could not create: errored-agent"
fi

echo ""
echo "================================================"
echo "  Label Creation Summary"
echo "================================================"
echo ""
echo "  Commands: $COMMANDS_COUNT labels created"
echo "  Agents:   $AGENTS_COUNT labels created"
echo "  Workflow: 3 management labels created"
echo ""

if [[ $COMMANDS_COUNT -eq 0 ]] && [[ $AGENTS_COUNT -eq 0 ]]; then
    echo "⚠️  Warning: No command or agent labels were created."
    echo "   This might mean:"
    echo "   - .claude/commands/ or .claude/agents/ directories are empty"
    echo "   - Agent OS installation is incomplete"
    echo "   - Multi-agent mode is not enabled"
    echo ""
fi

echo "✓ Label creation complete!"
echo ""
echo "You can now use these labels on issues to trigger Agent OS workflows."
echo ""
