# Aug 26 Changelog

Summary of recent updates, feature additions, and UI/UX improvements implemented for AgentCraft.

---

## 1. Repository Synchronization & Comments Column
* **Change Detection in Sync Script ([scripts/get-updates.sh](file:///Users/chrys/Projects/AgentCraft/scripts/get-updates.sh))**:
  - Enhanced Git pull/clone inspection using `git rev-list --count $OLD_REV..$NEW_REV` to calculate the exact number of new changes found per active repository during sync.
  - Persists last synced timestamp and number of changes found in `sync-state.txt` (e.g. `2026-08-24 07:56:17 | 0 changes found`).
* **Comments Column Replacement**:
  - Replaced the `Last Synced` table column with a `Comments` column in the Active Repositories table across [public/index.html](file:///Users/chrys/Projects/AgentCraft/public/index.html), [server.js](file:///Users/chrys/Projects/AgentCraft/server.js), and [README.md](file:///Users/chrys/Projects/AgentCraft/README.md).
  - Displays last synced timestamp (`⏱️`) and number of changes found (`📊`) with styled typography and spacing in [public/style.css](file:///Users/chrys/Projects/AgentCraft/public/style.css).
* **Live Refresh & Console Feedback**:
  - Configured HTMX to automatically re-fetch `/api/sources` to update the Active Repositories table immediately upon sync completion.
  - Updated `/api/sync` endpoint in [server.js](file:///Users/chrys/Projects/AgentCraft/server.js) to summarize total changes found across active repositories in the execution console.

---

## 2. Tool-Specific Command & Workflow Provisioning
* **Strict Tool Target Scoping ([scripts/createagents.sh](file:///Users/chrys/Projects/AgentCraft/scripts/createagents.sh))**:
  - Fixed provisioning so that `.opencode/commands/` is only targeted when the selected tool is **OpenCode**.
  - For **Antigravity IDE**, workflows are provisioned exclusively to `.agents/workflows/` (`spec-task.md`, `plan-task.md`, `build-task.md`, `review-task.md`).
* **Adaptive Bundle UI ([server.js](file:///Users/chrys/Projects/AgentCraft/server.js))**:
  - Updated the Production-grade engineering bundle card to dynamically display the appropriate target directory (`.agents/workflows/` for Antigravity IDE, `.opencode/commands/` for OpenCode).

---

## 3. Workflows & Slash Commands Discovery in Existing Skills
* **Target Project Discovery ([server.js](file:///Users/chrys/Projects/AgentCraft/server.js))**:
  - Extended `renderSkillsCardHtml` to discover installed workflows in `.agents/workflows/` (Antigravity IDE) and slash commands in `.opencode/commands/` (OpenCode).
  - Added dedicated `Workflow` and `Command` badges and exact disk locations (`📍 ...`).
* **Management & Batch Actions**:
  - Grouped installed workflows and commands clearly under **Existing Skills**.
  - Supported single removal and bulk batch deletion (`POST /api/skills/delete-batch`) for workflows and commands.

---

## 4. Skill Review & Edit Modal with Integrated Split Diff View
* **Double-Click Modal Frame ([public/index.html](file:///Users/chrys/Projects/AgentCraft/public/index.html), [server.js](file:///Users/chrys/Projects/AgentCraft/server.js))**:
  - Double-clicking any skill or workflow card under **Existing Skills** or **Available Skills** opens an in-app review and editor modal frame.
* **Merged Split Diff View**:
  - When an installed skill has upstream differences:
    - **Left Side (`Repository Updates`)**: Displays line-by-line syntax-colored diffs (`+` additions in green, `-` deletions in red, `@@` headers in blue) against the upstream repository version, with an **`📥 Copy Upstream to Editor`** quick action button.
    - **Right Side (`Current Version (Editable)`)**: Displays the current local version in an editable code editor textarea for direct modification and saving.
  - When a skill has no upstream differences (or is a local/available skill), smoothly renders a full-width code editor.
* **Editor API & Keyboard Shortcuts ([server.js](file:///Users/chrys/Projects/AgentCraft/server.js), [public/index.html](file:///Users/chrys/Projects/AgentCraft/public/index.html))**:
  - Added `GET /api/skills/editor` (calculates live diff on-the-fly) and `POST /api/skills/editor` (saves edits directly to disk).
  - Added `Ctrl+S` / `Cmd+S` shortcut to save changes and `Esc` / outside click to close.
  - Removed the previous standalone `Skill Differences` card container.
