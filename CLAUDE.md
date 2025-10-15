# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is Agent OS?

Agent OS is a system for spec-driven agentic development that transforms AI coding agents into productive developers through structured workflows. It provides standards, workflows, and specialized agents that capture coding conventions and guide AI agents to ship quality code consistently.

Agent OS operates in two modes:
- **Multi-agent mode**: For tools like Claude Code that support subagents - orchestrates multiple specialized agents autonomously
- **Single-agent mode**: For tools without subagent support - delivers step-by-step prompts to a single agent

## Architecture Overview

### Directory Structure

```
agent-os/
├── config.yml              # Version, mode settings, profile configuration
├── scripts/                # Installation and setup scripts
│   ├── base-install.sh     # Install Agent OS base installation
│   ├── project-install.sh  # Install into project codebase
│   ├── project-update.sh   # Update existing project installation
│   ├── create-profile.sh   # Create custom profiles
│   ├── create-role.sh      # Create custom implementer/verifier roles
│   └── common-functions.sh # Shared utilities (YAML parsing, colors, etc.)
└── profiles/
    └── default/            # Default profile (customizable)
        ├── agents/         # Subagent definitions (.md files with frontmatter)
        │   ├── specification/  # Spec workflow agents
        │   └── templates/      # Agent templates
        ├── commands/       # Slash commands for Claude Code/Cursor
        │   ├── multi-agent/   # Multi-agent mode commands
        │   └── single-agent/  # Single-agent mode commands
        ├── roles/          # Implementer and verifier role definitions
        │   ├── implementers.yml  # Specialized implementation agents
        │   └── verifiers.yml     # Verification agents
        ├── standards/      # Coding standards and conventions
        │   ├── global/     # Cross-cutting standards (tech stack, code style)
        │   ├── backend/    # Backend-specific standards
        │   ├── frontend/   # Frontend-specific standards
        │   └── testing/    # Testing standards
        └── workflows/      # Workflow instruction files
            └── specification/  # Spec creation workflows
```

### Key Concepts

**Profiles**: Complete sets of agents, commands, standards, and workflows. The `default` profile is provided, and you can create custom profiles for different project types (e.g., ruby-on-rails, nextjs-app).

**Agents**: Specialized subagents defined in `.md` files with YAML frontmatter specifying their name, description, tools, model, and color. Examples:
- `spec-writer`: Creates detailed specifications
- `spec-researcher`: Gathers requirements through user questions
- `database-engineer`: Handles migrations and models
- `api-engineer`: Implements API endpoints
- `ui-designer`: Creates UI components and styling

**Roles**: Defined in YAML files (`implementers.yml`, `verifiers.yml`) that map agents to their areas of responsibility and specify which verifiers validate their work.

**Workflows**: Reusable instruction files (`.md`) that agents include via double-brace syntax like `{{workflows/specification/write-spec}}`.

**Commands**: Slash commands (e.g., `/new-spec`, `/create-spec`, `/implement-spec`) that trigger multi-phase workflows.

## Installation Commands

### Base Installation
Installs Agent OS to a location on your system (typically `~/.agent-os/`) where standards can be customized:

```bash
# Claude Code support
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup/base.sh | bash -s -- --claude-code

# Cursor support
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup/base.sh | bash -s -- --cursor

# Both
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup/base.sh | bash -s -- --claude-code --cursor
```

### Project Installation
Copies Agent OS into a project's `.agent-os/` directory. Must be run from project root:

```bash
# If base installation is in home directory
~/.agent-os/scripts/project-install.sh

# With custom profile
~/.agent-os/scripts/project-install.sh --profile custom-profile-name

# Override mode settings
~/.agent-os/scripts/project-install.sh --multi-agent-mode true --multi-agent-tool claude-code

# Overwrite specific files during reinstall
~/.agent-os/scripts/project-install.sh --overwrite-standards --overwrite-agents
```

### Project Update
Updates an existing project installation with latest Agent OS version:

```bash
~/.agent-os/scripts/project-update.sh

# With options
~/.agent-os/scripts/project-update.sh --overwrite-standards --profile default
```

## Development Workflow

### Creating a New Feature Spec

Agent OS uses a spec-driven development workflow:

1. **Initialize spec** - Run `/new-spec` (multi-agent) or provide feature description
   - Creates dated folder: `agent-os/specs/YYYY-MM-DD-feature-name/`
   - Gathers requirements through questions
   - Collects visual assets if provided

2. **Create detailed spec** - Run `/create-spec`
   - Generates `spec.md` with requirements, user stories, technical approach
   - Creates `tasks.md` with task groups and subtasks
   - Searches for reusable code before specifying new components

3. **Implement spec** - Run `/implement-spec` (multi-agent mode)
   - Assigns task groups to specialized implementer agents
   - Each implementer works on their area (database, API, UI, tests)
   - Verifier agents validate implementations
   - Produces final verification report

### Key Spec Files

Created in `agent-os/specs/[date-spec-name]/`:

```
YYYY-MM-DD-feature-name/
├── spec.md                    # Main specification document
├── tasks.md                   # Task groups and subtasks (checked off as completed)
├── planning/
│   ├── requirements.md        # Gathered requirements from user
│   ├── visuals/               # Screenshots, mockups, designs
│   └── task-assignments.yml   # Maps task groups to implementer agents
├── implementation/
│   └── [numbered reports].md  # Implementation reports from each agent
└── verification/
    ├── [verifier reports].md  # Verification reports from verifier agents
    └── final-verification.md  # Final verification and completion report
```

## Working with Agents

### Agent File Structure

Agents are defined as Markdown files with YAML frontmatter:

```markdown
---
name: agent-name
description: What this agent does
tools: Write, Read, Bash, WebFetch
color: purple
model: opus
---

You are a [role description]. Your role is to [responsibilities].

{{workflows/path/to/workflow}}

## Your Standards

{{standards/relevant/*}}
```

### Template Syntax

Agents use double-brace template syntax to include content:
- `{{workflows/path/file}}` - Include workflow instructions
- `{{standards/global/*}}` - Include all files in standards/global/
- `{{standards/backend/*}}` - Include all backend standards

### Creating Custom Roles

Use the provided script to create new implementer, verifier, or researcher roles:

```bash
~/.agent-os/scripts/create-role.sh --type implementer --name custom-engineer
~/.agent-os/scripts/create-role.sh --type verifier --name custom-verifier
~/.agent-os/scripts/create-role.sh --type researcher --name custom-researcher
```

This creates the role definition in YAML and generates the corresponding agent file.

**Available Templates:**
- `implementer.md` - For agents that implement features and write code
- `verifier.md` - For agents that verify and validate implementations
- `researcher.md` - For agents that gather information and conduct research (e.g., web search researchers, codebase analyzers, pattern finders)

## Standards and Conventions

### Customizing Standards

Standards are located in `profiles/[profile]/standards/` and define:
- **global/**: Tech stack, code style conventions, best practices
- **backend/**: Backend-specific patterns and conventions
- **frontend/**: UI/UX patterns, component structure
- **testing/**: Test coverage requirements, testing patterns

When you install Agent OS into a project, these standards are copied to `[project]/.agent-os/standards/` where they can be customized per-project.

### YAML Configuration Files

Agent OS uses YAML extensively for configuration:

**config.yml** - Base installation settings:
```yaml
version: 2.0.0
multi_agent_mode: true
multi_agent_tool: claude-code
profile: default
```

**implementers.yml** - Implementer role definitions:
```yaml
implementers:
  - id: database-engineer
    description: Handles migrations, models, schemas
    tools: Write, Read, Bash, WebFetch
    areas_of_responsibility: [...]
    standards: [global/*, backend/*, testing/*]
    verified_by: [backend-verifier]
```

**verifiers.yml** - Verifier role definitions with verification responsibilities.

## Common Development Tasks

### Testing Changes to Scripts

When modifying installation scripts:
```bash
# Test in dry-run mode first
./scripts/project-install.sh --dry-run --verbose

# Test with specific options
./scripts/project-install.sh --profile default --multi-agent-mode true --dry-run
```

### Adding New Commands

Commands are organized by mode:
- Multi-agent: `profiles/[profile]/commands/[command-name]/multi-agent/`
- Single-agent: `profiles/[profile]/commands/[command-name]/single-agent/`

Each command directory should contain the command definition file (`.md` for Claude Code, `.mdown` for Cursor).

### Creating Custom Profiles

```bash
~/.agent-os/scripts/create-profile.sh --name custom-profile

# Then customize the generated profile's standards, agents, and workflows
```

Profiles allow different sets of standards for different project types (e.g., Rails vs. Next.js projects).

## Important Implementation Notes

### Agent Delegation Pattern

In multi-agent mode, the main agent should delegate work to specialized subagents:

```markdown
### PHASE 1: Initialize
Use the **spec-initializer** subagent to initialize a new spec.
Provide the subagent with: [details]

### PHASE 2: Research
After spec-initializer completes, immediately use the **spec-researcher** subagent.
```

This preserves the main agent's context and allows specialized agents to focus on their specific tasks.

### Task Completion Tracking

Tasks in `tasks.md` use checkboxes:
```markdown
- [ ] Parent task description
  - [ ] Subtask 1
  - [ ] Subtask 2
```

Implementer agents check off tasks as they complete them and document their work in numbered implementation reports.

### Workflow Phases

All major workflows follow a multi-phase structure:
1. Initialization/Planning
2. Execution (often delegated to subagents)
3. Verification
4. Reporting/Completion

Each phase should complete fully before moving to the next.

## Version Management

Current version: **2.0.2** (as of 2025-10-09)

The version is tracked in `config.yml` and affects:
- Installation script behavior
- Available features and commands
- Agent definitions and capabilities

Check the CHANGELOG.md for version history and upgrade instructions.

## Key Files Reference

- `config.yml` - Configuration for multi/single agent mode, profile selection
- `scripts/common-functions.sh` - Shared utilities for YAML parsing, output formatting, string normalization
- `profiles/default/roles/implementers.yml` - Specialized implementation agent definitions
- `profiles/default/roles/verifiers.yml` - Verification agent definitions
- `profiles/default/standards/global/tech-stack.md` - Template for defining project tech stack
- `profiles/default/workflows/specification/write-spec.md` - Workflow for creating specifications

## Documentation

Full documentation available at: https://buildermethods.com/agent-os

Key sections:
- Installation and setup
- Workflows and usage
- Customization guide
- Version 2.0 changes and migration
