Create `agent-os/product/tech-stack.md` with a list of all tech stack choices that cover all aspects of this product's codebase.

### Creating the Tech Stack document

#### Step 1: Note User's Input Regarding Tech Stack

IF the user has provided specific information in the current conversation in regards to tech stack choices, these notes ALWAYS take precidence.  These must be reflected in your final `tech-stack.md` document that you will create.

#### Step 2: Gather User's Default Tech Stack Information

Reconcile and fill in the remaining gaps in the tech stack list by finding, reading and analyzing information regarding the tech stack.  Find this information in the following sources, in this order:

1. If user has provided their default tech stack under "User Standards & Preferences Compliance", READ and analyze this document.
2. If the current project has any of these files, read them to find information regarding tech stack choices for this codebase:
  - `claude.md`
  - `agents.md`

#### Step 3: Create the Tech Stack Document

Create `agent-os/product/tech-stack.md` and populate it with the final list of all technical stack choices, reconciled between the information the user has provided to you and the information found in provided sources.

#### Step 4: Offer Profile Creation

After documenting the tech stack, check if a matching Agent OS profile exists:

1. Parse the frameworks from `agent-os/product/tech-stack.md` (look for major frameworks like Next.js, Rails, Django, Laravel, etc.)

2. Check the current Agent OS profile:
   - If `agent-os/config.yml` exists, read the `profile:` field to see the current profile
   - Check if the current profile name matches any of the documented frameworks

3. If no matching profile exists or current profile is "default", offer to create a custom profile:

   **Prompt user:**

   ```
   I've documented your tech stack in agent-os/product/tech-stack.md.

   Would you like to create a custom Agent OS profile optimized for your tech stack?

   This will:
   - Generate framework-specific coding standards
   - Create tailored workflows for your frameworks
   - Ensure AI agents follow best practices for your stack

   Create custom profile? (y/N)
   ```

4. If user agrees:
   - Extract the main frameworks from tech-stack.md
   - Suggest a profile name based on the frameworks (e.g., "nextjs-react" or "rails-postgresql")
   - Create the profile directory structure at `~/.agent-os/profiles/[profile-name]/`
   - Create standard directory structure: `standards/{global,backend,frontend,testing}`, `workflows/`, `agents/`, `roles/`, `commands/`, `automations/`
   - Create `profile-config.yml` with detected frameworks:
     ```yaml
     inherits_from: default
     frameworks:
       - [framework1]
       - [framework2]
     ```
   - Offer to generate standards: "Generate standards now using specialized agents with WebSearch? (y/N)"
   - If yes, inform them: "To generate standards, ask Claude: 'Generate framework standards for the [profile-name] profile'"
   - If no, inform them standards will inherit from default and can be customized later
   - Update `agent-os/config.yml` to use the new profile
