# Jul1 Changelog

Summary of recent updates and feature additions implemented for AgentCraft.

---

## 1. OpenCode Skill Path Alignment
* **Standardized Path**: Changed the target destination path for **OpenCode** tool style from `skills/` to `.opencode/skills/`.
* **Script Provisioning ([createagents.sh](file:///Users/chrys/Projects/AgentCraft/scripts/createagents.sh))**: Updated destination directory logic when running `--tool opencode` to target `$TARGET_PATH/.opencode/skills/$slug/SKILL.md`.
* **Server Logic ([server.js](file:///Users/chrys/Projects/AgentCraft/server.js))**: Updated destination path resolution in skill status checks, diff generation, and deletion endpoints.
* **UI & Documentation ([public/index.html](file:///Users/chrys/Projects/AgentCraft/public/index.html), [README.md](file:///Users/chrys/Projects/AgentCraft/README.md))**: Updated tool badges and documentation text to reflect `.opencode/skills/`.

---

## 2. Target Project Pre-existing Skills Discovery
* **Local Skill Scanning**: Enhanced `renderSkillsCardHtml` in [server.js](file:///Users/chrys/Projects/AgentCraft/server.js) to scan the target project's skills folder (`.opencode/skills/`, `.github/skills/`, `.agents/skills/`, or `skills/`) for pre-existing local skills not present in source repositories.
* **UI Classification**: Automatically displays installed local skills under the **Existing Skills** sub-tab grouped under `Source: Target Project`.

---

## 3. Batch Skill Selection & Removal
* **Context-Aware Select All**: Updated `selectAllSkills(select)` in [public/index.html](file:///Users/chrys/Projects/AgentCraft/public/index.html) to select/clear checkboxes within the active sub-tab (`Existing Skills` or `Available Skills`).
* **Batch Delete Endpoint**: Added `POST /api/skills/delete-batch` in [server.js](file:///Users/chrys/Projects/AgentCraft/server.js) to process bulk skill deletions from target project directories.
* **Batch Delete Action UI**: Added a **"🗑️ Remove Selected Skills"** button in the skills card footer and connected it to `removeSelectedSkills()` helper with a confirmation prompt.
