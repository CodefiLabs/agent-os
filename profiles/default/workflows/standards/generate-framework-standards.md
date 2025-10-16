# Generate Framework-Specific Standards Workflow

This workflow generates comprehensive coding standards for a profile based on detected or specified frameworks.

## Prerequisites

- A profile has been created at `~/.agent-os/profiles/[profile-name]/`
- The profile's `profile-config.yml` includes a `frameworks:` section with detected frameworks
- OR frameworks have been manually specified

## Workflow Steps

### Step 1: Identify Target Profile and Frameworks

1. Determine which profile needs standards:
   - If specified in the task, use that profile name
   - Otherwise, check `agent-os/config.yml` for the current profile
   - Verify the profile exists at `~/.agent-os/profiles/[profile-name]/`

2. Read frameworks from the profile configuration:
   - Read `~/.agent-os/profiles/[profile-name]/profile-config.yml`
   - Extract the list from the `frameworks:` section
   - If no frameworks are listed, check `agent-os/product/tech-stack.md` for framework information
   - If still no frameworks found, ask the user to specify them

3. Validate the framework list:
   - Ensure frameworks are recognized (Next.js, Rails, Django, Laravel, React, etc.)
   - Confirm with user if needed: "I will generate standards for: [frameworks]. Is this correct?"

### Step 2: Determine Standards Scope

Based on the frameworks, determine which standards files to create:

1. **Always create:**
   - `global/tech-stack.md` - Document the tech stack
   - `global/code-style.md` - General code style guidelines
   - `testing/testing.md` - Testing standards

2. **Backend frameworks** (Rails, Django, Laravel, Express, NestJS, FastAPI, Flask):
   - Create `backend/architecture.md`
   - May also need `backend/database.md` if ORM/database access patterns are relevant

3. **Frontend frameworks** (Next.js, React, Vue, Remix):
   - Create `frontend/architecture.md`
   - May also need `frontend/components.md` for component patterns

4. **Full-stack frameworks** (Next.js, Remix):
   - Create both `backend/architecture.md` AND `frontend/architecture.md`

### Step 3: Delegate to Specialized Standards Writers

Use specialized **standards-writer** agents to generate each standards file. Delegate to the appropriate agent based on the standards file type:

#### For Tech Stack Standards:
Use the **tech-stack-standards-writer** agent:
- Provide: Profile name, frameworks list
- Agent will: Research and document the tech stack, supporting libraries, and development tools

#### For Code Style Standards:
Use the **code-style-standards-writer** agent:
- Provide: Profile name, frameworks list
- Agent will: Research framework-specific style guides and create comprehensive code style documentation

#### For Backend Architecture Standards:
Use the **backend-architecture-standards-writer** agent (only if backend frameworks detected):
- Provide: Profile name, backend frameworks list
- Agent will: Research and document backend architectural patterns, directory structures, and conventions

#### For Frontend Architecture Standards:
Use the **frontend-architecture-standards-writer** agent (only if frontend frameworks detected):
- Provide: Profile name, frontend frameworks list
- Agent will: Research and document frontend architectural patterns, component organization, and state management

#### For Testing Standards:
Use the **testing-standards-writer** agent:
- Provide: Profile name, frameworks list
- Agent will: Research and document testing frameworks, patterns, and conventions for the detected frameworks

### Step 4: Coordinate Agent Execution

Execute the standards-writer agents in a logical sequence:

1. **First**: tech-stack-standards-writer
   - This establishes the foundation that other agents can reference

2. **In parallel** (or sequence if parallel not available):
   - code-style-standards-writer
   - backend-architecture-standards-writer (if applicable)
   - frontend-architecture-standards-writer (if applicable)
   - testing-standards-writer

3. **Wait for all agents to complete** before proceeding to validation

### Step 5: Validate Generated Standards

After all agents complete:

1. **Verify files exist:**
   ```bash
   profile_dir="$HOME/.agent-os/profiles/[profile-name]"

   # Check required files
   for file in "standards/global/tech-stack.md" "standards/global/code-style.md" "standards/testing/testing.md"; do
       if [ ! -f "$profile_dir/$file" ]; then
           echo "⚠️  Missing: $file"
       else
           echo "✅ Created: $file"
       fi
   done

   # Check framework-specific files
   if [ -f "$profile_dir/standards/backend/architecture.md" ]; then
       echo "✅ Created: standards/backend/architecture.md"
   fi

   if [ -f "$profile_dir/standards/frontend/architecture.md" ]; then
       echo "✅ Created: standards/frontend/architecture.md"
   fi
   ```

2. **Verify file content:**
   - Each file should have the auto-generated header
   - Each file should contain substantive content (not just templates)
   - Code examples should be present and properly formatted

3. **Report any issues** to the user if files are missing or incomplete

### Step 6: Final Report

Provide a comprehensive summary to the user:

```markdown
✅ Framework-specific standards generation complete!

**Profile:** [profile-name]
**Location:** ~/.agent-os/profiles/[profile-name]/

**Frameworks covered:** [list of frameworks]

**Generated standards files:**
- ✅ global/tech-stack.md - Tech stack documentation with frameworks, libraries, and tools
- ✅ global/code-style.md - Code style guidelines with naming conventions and formatting rules
- ✅ backend/architecture.md - Backend architectural patterns and directory structure
- ✅ frontend/architecture.md - Frontend component organization and state management
- ✅ testing/testing.md - Testing frameworks, patterns, and coverage expectations

**Next steps:**

1. **Review the generated standards:**
   - Open ~/.agent-os/profiles/[profile-name]/standards/
   - Review each file for accuracy and completeness

2. **Customize as needed:**
   - These standards are starting points based on framework best practices
   - Adjust them to match your team's specific preferences and conventions

3. **Apply to projects:**
   - Run `~/agent-os/scripts/project-install.sh --profile [profile-name]` in your project
   - Or update existing project: `~/agent-os/scripts/project-update.sh --profile [profile-name]`

4. **Keep standards updated:**
   - As frameworks evolve, you can re-run this workflow to update standards
   - Or manually edit the files as your conventions change

**Documentation:** https://buildermethods.com/agent-os/profiles
```

## Error Handling

If any standards-writer agent fails:

1. **Note which file failed** and inform the user
2. **Continue with other agents** to generate remaining standards
3. **Provide instructions** for manually creating the missing standards file
4. **Offer to retry** the failed agent if the user wants

Example error message:
```
⚠️  Failed to generate: backend/architecture.md

The backend-architecture-standards-writer agent encountered an issue.

Remaining standards were generated successfully. You can:
1. Manually create backend/architecture.md using the template
2. Retry: [command to retry]
3. Continue with other standards - you can add this later
```

## Usage Notes

- This workflow is typically triggered after profile creation
- Can be run standalone to update existing profile standards
- Can be re-run to regenerate standards as frameworks evolve
- Generated standards inherit from default profile if they don't exist
- User can always manually edit generated standards
