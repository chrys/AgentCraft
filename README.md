# Specs Kit - Agent Skills Provisioner

Specs Kit is a centralized toolkit designed to manage, update, and provision senior engineering **Agent Skills** across various software projects. By leveraging the standardized agent skills from the [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) project, Specs Kit enables developer tools (like **GitHub Copilot** and **OpenCode**) to follow robust, proven software development processes.

---

## 🚀 Key Features

- **Automated Skill Updates**: `scripts/get-updates.sh` keeps the underlying `agent-skills` repository synchronized and updates this README file dynamically with the latest skill descriptions and Git commit logs.
- **Multi-Tool Support**: Easily provision agent skills tailored for either **GitHub Copilot** or **OpenCode** conventions.
- **Granular Provisioning**: Choose to copy all skills, or selectively copy specific skills using either their numerical indexes or folder slugs.
- **Zero Configuration**: Fast and lightweight execution with pure bash script implementation.

---

## 🛠️ Getting Started

### Prerequisites

Ensure you have Git installed and that the `agent-skills` submodule or directory is present in the project root:
```bash
git clone https://github.com/addyosmani/agent-skills.git
```

---

## 📖 Usage Guide

### 1. Synchronizing Skills (`get-updates.sh`)
To fetch the latest skills and update the documentation catalog dynamically:
```bash
bash scripts/get-updates.sh
```
This script will:
1. Navigate to the `agent-skills` directory.
2. Pull the latest updates via `git pull origin main`.
3. Alphabetically list and parse all available skills in `agent-skills/skills/`.
4. Query the latest Git commits for each skill folder.
5. Dynamically regenerate the **Available Skills** section in this `README.md` file between the markers.

---

### 2. Provisioning Agent Skills to a Project (`createagents.sh`)
To copy the necessary skill definition (`SKILL.md`) files to a target project, use the provisioner script.

#### Syntax:
```bash
bash scripts/createagents.sh <target-path> --tool <github-copilot | opencode> [--skills <indices-or-slugs>]
```
Or use explicit options:
```bash
bash scripts/createagents.sh --path <target-path> --tool <github-copilot | opencode> [--skills <indices-or-slugs>]
```

#### Parameters:
- `-p`, `--path`: The absolute or relative path to the target project directory. If the first argument is a path (doesn't start with `-`), it is automatically parsed as the path.
- `-t`, `--tool`: The destination IDE/tool style:
  - `github-copilot`: Copies `SKILL.md` to `<target-path>/.github/skills/<skill-slug>/SKILL.md`
  - `opencode`: Copies `SKILL.md` to `<target-path>/skills/<skill-slug>/SKILL.md`
- `-s`, `--skills`: A space-separated list of skill identifiers to copy. If omitted, **all** skills will be copied.
  - Can specify **indexes** (e.g., `1 5 12`)
  - Can specify **slugs** (e.g., `test-driven-development spec-driven-development`)
  - Can mix both (e.g., `1 5 spec-driven-development`)

#### Examples:
```bash
# Provision ALL skills for GitHub Copilot in Project A
bash scripts/createagents.sh Projects/project-a --tool github-copilot

# Provision specific skills by index for OpenCode in Project B
bash scripts/createagents.sh Projects/project-b --tool opencode --skills "1 4 9"

# Provision specific skills by folder name for GitHub Copilot in Project C
bash scripts/createagents.sh Projects/project-c --tool github-copilot --skills "test-driven-development performance-optimization"
```

---

## 📚 Available Skills Catalog

The list below is dynamically synchronized and updated by `get-updates.sh`.

<!-- SKILLS_START -->
| # | Skill Slug | Description | Latest Update |
|---|------------|-------------|---------------|
| 1 | `api-and-interface-design` | Guides stable API and interface design. Use when designing APIs, module boundaries, or any public interface. Use when creating REST or GraphQL endpoints, defining type contracts between modules, or establishing boundaries between frontend and backend. | N/A \| Direct copy / no git history |
| 2 | `browser-testing-with-devtools` | Tests in real browsers. Use when building or debugging anything that runs in a browser. Use when you need to inspect the DOM, capture console errors, analyze network requests, profile performance, or verify visual output with real runtime data via Chrome DevTools MCP. | N/A \| Direct copy / no git history |
| 3 | `ci-cd-and-automation` | Automates CI/CD pipeline setup. Use when setting up or modifying build and deployment pipelines. Use when you need to automate quality gates, configure test runners in CI, or establish deployment strategies. | N/A \| Direct copy / no git history |
| 4 | `code-review-and-quality` | Conducts multi-axis code review. Use before merging any change. Use when reviewing code written by yourself, another agent, or a human. Use when you need to assess code quality across multiple dimensions before it enters the main branch. | N/A \| Direct copy / no git history |
| 5 | `code-simplification` | Simplifies code for clarity. Use when refactoring code for clarity without changing behavior. Use when code works but is harder to read, maintain, or extend than it should be. Use when reviewing code that has accumulated unnecessary complexity. | N/A \| Direct copy / no git history |
| 6 | `context-engineering` | Optimizes agent context setup. Use when starting a new session, when agent output quality degrades, when switching between tasks, or when you need to configure rules files and context for a project. | N/A \| Direct copy / no git history |
| 7 | `debugging-and-error-recovery` | Guides systematic root-cause debugging. Use when tests fail, builds break, behavior doesn't match expectations, or you encounter any unexpected error. Use when you need a systematic approach to finding and fixing the root cause rather than guessing. | N/A \| Direct copy / no git history |
| 8 | `deprecation-and-migration` | Manages deprecation and migration. Use when removing old systems, APIs, or features. Use when migrating users from one implementation to another. Use when deciding whether to maintain or sunset existing code. | N/A \| Direct copy / no git history |
| 9 | `documentation-and-adrs` | Records decisions and documentation. Use when making architectural decisions, changing public APIs, shipping features, or when you need to record context that future engineers and agents will need to understand the codebase. | N/A \| Direct copy / no git history |
| 10 | `frontend-ui-engineering` | Builds production-quality UIs. Use when building or modifying user-facing interfaces. Use when creating components, implementing layouts, managing state, or when the output needs to look and feel production-quality rather than AI-generated. | N/A \| Direct copy / no git history |
| 11 | `git-workflow-and-versioning` | Structures git workflow practices. Use when making any code change. Use when committing, branching, resolving conflicts, or when you need to organize work across multiple parallel streams. | N/A \| Direct copy / no git history |
| 12 | `idea-refine` | Refines ideas iteratively. Refine ideas through structured divergent and convergent thinking. Use "idea-refine" or "ideate" to trigger. | N/A \| Direct copy / no git history |
| 13 | `incremental-implementation` | Delivers changes incrementally. Use when implementing any feature or change that touches more than one file. Use when you're about to write a large amount of code at once, or when a task feels too big to land in one step. | N/A \| Direct copy / no git history |
| 14 | `performance-optimization` | Optimizes application performance. Use when performance requirements exist, when you suspect performance regressions, or when Core Web Vitals or load times need improvement. Use when profiling reveals bottlenecks that need fixing. | N/A \| Direct copy / no git history |
| 15 | `planning-and-task-breakdown` | Breaks work into ordered tasks. Use when you have a spec or clear requirements and need to break work into implementable tasks. Use when a task feels too large to start, when you need to estimate scope, or when parallel work is possible. | N/A \| Direct copy / no git history |
| 16 | `security-and-hardening` | Hardens code against vulnerabilities. Use when handling user input, authentication, data storage, or external integrations. Use when building any feature that accepts untrusted data, manages user sessions, or interacts with third-party services. | N/A \| Direct copy / no git history |
| 17 | `shipping-and-launch` | Prepares production launches. Use when preparing to deploy to production. Use when you need a pre-launch checklist, when setting up monitoring, when planning a staged rollout, or when you need a rollback strategy. | N/A \| Direct copy / no git history |
| 18 | `source-driven-development` | Grounds every implementation decision in official documentation. Use when you want authoritative, source-cited code free from outdated patterns. Use when building with any framework or library where correctness matters. | N/A \| Direct copy / no git history |
| 19 | `spec-driven-development` | Creates specs before coding. Use when starting a new project, feature, or significant change and no specification exists yet. Use when requirements are unclear, ambiguous, or only exist as a vague idea. | N/A \| Direct copy / no git history |
| 20 | `test-driven-development` | Drives development with tests. Use when implementing any logic, fixing any bug, or changing any behavior. Use when you need to prove that code works, when a bug report arrives, or when you're about to modify existing functionality. | N/A \| Direct copy / no git history |
| 21 | `using-agent-skills` | Discovers and invokes agent skills. Use when starting a session or when you need to discover which skill applies to the current task. This is the meta-skill that governs how all other skills are discovered and invoked. | N/A \| Direct copy / no git history |
<!-- SKILLS_END -->

---

## 🔒 License
This toolkit is licensed under the MIT License. See [LICENSE](file:///Users/chrys/Projects/Specs_kit/agent-skills/LICENSE) for details.
