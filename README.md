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
bash scripts/createagents.sh <target-path> --tool <github-copilot | opencode | antigravity-ide> [--skills <indices-or-slugs>]
```
Or use explicit options:
```bash
bash scripts/createagents.sh --path <target-path> --tool <github-copilot | opencode | antigravity-ide> [--skills <indices-or-slugs>]
```

#### Parameters:
- `-p`, `--path`: The absolute or relative path to the target project directory. If the first argument is a path (doesn't start with `-`), it is automatically parsed as the path.
- `-t`, `--tool`: The destination IDE/tool style:
  - `github-copilot`: Copies `SKILL.md` to `<target-path>/.github/skills/<skill-slug>/SKILL.md`
  - `opencode`: Copies `SKILL.md` to `<target-path>/skills/<skill-slug>/SKILL.md`
  - `antigravity-ide`: Copies `SKILL.md` to `<target-path>/.agents/skills/<skill-slug>/SKILL.md`, and generates corresponding workflow files in `<target-path>/.agents/workflows/` (`*-task.md`).
- `-s`, `--skills`: A space-separated list of skill identifiers to copy.
  - If omitted for `github-copilot` and `opencode`, **all** skills will be copied. For `antigravity-ide`, if omitted, only the 4 core skills needed for the workflows are copied (`incremental-implementation`, `planning-and-task-breakdown`, `code-review-and-quality`, and `spec-driven-development`).
  - If specifying other skills with `antigravity-ide`, the 4 core skills are automatically included alongside the selected ones.
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

# Provision core skills and workflows for Antigravity IDE in Project D
bash scripts/createagents.sh Projects/project-d --tool antigravity-ide
```

---

## 📚 Available Skills Catalog

The list below is dynamically synchronized and updated by `get-updates.sh`.

<!-- SKILLS_START -->
| # | Repository | Skill Slug | Description | Latest Update |
|---|------------|------------|-------------|---------------|
| 1 | `agent-skills` | `api-and-interface-design` | Guides stable API and interface design. Use when designing APIs, module boundaries, or any public interface. Use when creating REST or GraphQL endpoints, defining type contracts between modules, or establishing boundaries between frontend and backend. | 2026-03-31 \| Align skill descriptions with Anthropic best practices |
| 2 | `matt pocock skills` | `ask-matt` | Ask which skill or flow fits your situation. A router over the skills in this repo. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 3 | `matt pocock skills` | `batch-grill-me` | A relentless interview that asks every frontier question at once, round by round. | 2026-07-16 \| feat(batch-grill-me): granular fact-finding, don't block the round |
| 4 | `agent-skills` | `browser-testing-with-devtools` | Tests in real browsers via Chrome DevTools MCP. Use when building or debugging anything that runs in a browser. Use when you need to inspect the DOM, capture console errors, analyze network requests, profile performance, or verify visual output with real runtime data. Requires the chrome-devtools MCP server to be configured. | 2026-06-11 \| fix(browser-testing): default to isolated profile, demote autoConnect |
| 5 | `agent-skills` | `ci-cd-and-automation` | Automates CI/CD pipeline setup. Use when setting up or modifying build and deployment pipelines. Use when you need to automate quality gates, configure test runners in CI, or establish deployment strategies. | 2026-03-31 \| Align skill descriptions with Anthropic best practices |
| 6 | `matt pocock skills` | `claude-handoff` | Hand the current conversation off to a fresh background agent that picks up the work immediately. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 7 | `agent-skills` | `code-review-and-quality` | Conducts multi-axis code review. Use before merging any change. Use when reviewing code written by yourself, another agent, or a human. Use when you need to assess code quality across multiple dimensions before it enters the main branch. | 2026-06-27 \| docs(code-review): add dependency upgrade workflow to Dependency Discipline |
| 8 | `matt pocock skills` | `code-review` | Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes — Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match what the originating issue/PRD asked for?). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to "review since X". | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 9 | `agent-skills` | `code-simplification` | Simplifies code for clarity. Use when refactoring code for clarity without changing behavior. Use when code works but is harder to read, maintain, or extend than it should be. Use when reviewing code that has accumulated unnecessary complexity. | 2026-03-31 \| Align skill descriptions with Anthropic best practices |
| 10 | `matt pocock skills` | `codebase-design` | Shared vocabulary for designing deep modules. Use when the user wants to design or improve a module's interface, find deepening opportunities, decide where a seam goes, make code more testable or AI-navigable, or when another skill needs the deep-module vocabulary. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 11 | `agent-skills` | `context-engineering` | Optimizes agent context setup. Use when starting a new session, when agent output quality degrades, when switching between tasks, or when you need to configure rules files and context for a project. | 2026-03-31 \| Align skill descriptions with Anthropic best practices |
| 12 | `agent-skills` | `debugging-and-error-recovery` | Guides systematic root-cause debugging. Use when tests fail, builds break, behavior doesn't match expectations, or you encounter any unexpected error. Use when you need a systematic approach to finding and fixing the root cause rather than guessing. | 2026-06-16 \| docs: fix step range in debugging skill (Steps 4-10 → 4-6) |
| 13 | `agent-skills` | `deprecation-and-migration` | Manages deprecation and migration. Use when removing old systems, APIs, or features. Use when migrating users from one implementation to another. Use when deciding whether to maintain or sunset existing code. | 2026-06-27 \| docs(deprecation): add database schema migration patterns (expand/contract) |
| 14 | `matt pocock skills` | `design-an-interface` | Generate multiple radically different interface designs for a module using parallel sub-agents. Use when user wants to design an API, explore interface options, compare module shapes, or mentions "design it twice". | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 15 | `matt pocock skills` | `diagnosing-bugs` | Diagnosis loop for hard bugs and performance regressions. Use when the user says "diagnose"/"debug this", or reports something broken/throwing/failing/slow. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 16 | `agent-skills` | `documentation-and-adrs` | Records decisions and documentation. Use when making architectural decisions, changing public APIs, shipping features, or when you need to record context that future engineers and agents will need to understand the codebase. | 2026-07-16 \| docs(adr): keep convention detection repository-local and forge-agnostic |
| 17 | `matt pocock skills` | `domain-modeling` | Build and sharpen a project's domain model. Use when the user wants to pin down domain terminology or a ubiquitous language, record an architectural decision, or when another skill needs to maintain the domain model. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 18 | `agent-skills` | `doubt-driven-development` | Subjects every non-trivial decision to a fresh-context adversarial review before it stands. Use when correctness matters more than speed, when working in unfamiliar code, when stakes are high (production, security-sensitive logic, irreversible operations), or any time a confident output would be cheaper to verify now than to debug later. | 2026-05-07 \| Harden doubt-driven-development: cross-model + internal consistency |
| 19 | `matt pocock skills` | `edit-article` | Edit and improve articles by restructuring sections, improving clarity, and tightening prose. Use when user wants to edit, revise, or improve an article draft. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 20 | `agent-skills` | `frontend-ui-engineering` | Builds production-quality, accessible, responsive user-facing UIs. Use when building or modifying interfaces and pages, creating components, implementing layouts, meeting WCAG accessibility requirements, managing state, or when the output needs to look and feel production-quality rather than AI-generated. | 2026-07-07 \| fix(evals): cover description vocabulary gaps |
| 21 | `matt pocock skills` | `git-guardrails-claude-code` | Set up Claude Code hooks to block dangerous git commands (push, reset --hard, clean, branch -D, etc.) before they execute. Use when user wants to prevent destructive git operations, add git safety hooks, or block git push/reset in Claude Code. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 22 | `agent-skills` | `git-workflow-and-versioning` | Structures git workflow practices. Use when making any code change. Use when committing, branching, resolving conflicts, or when you need to organize work across multiple parallel streams. Use when cutting a release, choosing a semantic version bump, tagging, or writing a changelog. | 2026-06-27 \| docs(git-workflow): add release & versioning (semver, tags, changelog) |
| 23 | `matt pocock skills` | `grill-me` | A relentless interview to sharpen a plan or design. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 24 | `matt pocock skills` | `grill-with-docs` | A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 25 | `matt pocock skills` | `grilling` | Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 26 | `matt pocock skills` | `handoff` | Compact the current conversation into a handoff document for another agent to pick up. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 27 | `agent-skills` | `idea-refine` | Refines raw ideas into sharp, actionable concepts through structured divergent and convergent thinking. Use when an idea is still vague, when you need to stress-test assumptions before committing to a plan, or when you want to expand options before converging on one. Triggers on "ideate", "refine this idea", or "stress-test my plan". | 2026-06-25 \| Merge pull request #307 from creazyfrog/fix/issue-136 |
| 28 | `matt pocock skills` | `implement` | "Implement a piece of work based on a spec or set of tickets." | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 29 | `matt pocock skills` | `improve-codebase-architecture` | Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 30 | `agent-skills` | `incremental-implementation` | Delivers changes incrementally. Use when implementing any feature or change that touches more than one file. Use when you're about to write a large amount of code at once, or when a task feels too big to land in one step. | 2026-06-23 \| docs(dod): align prose with links and cross-link standing items to owning skills |
| 31 | `agent-skills` | `interview-me` | Extracts what the user actually wants instead of what they think they should want. Achieves this through one-question-at-a-time interview until ~95% confidence about the underlying intent. Use when an ask is underspecified ("build me X" without "for whom" or "why now"), when the user explicitly invokes ("interview me", "grill me", "are we sure?", "stress-test my thinking"), or when you catch yourself silently filling in ambiguous requirements before any plan, spec, or code exists. | 2026-05-20 \| feat(interview-me): add reason to low-confidence numbers |
| 32 | `matt pocock skills` | `loop-me` | Grill me about specs for the workflows I want to build, within this workspace. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 33 | `matt pocock skills` | `migrate-to-shoehorn` | Migrate test files from `as` type assertions to @total-typescript/shoehorn. Use when user mentions shoehorn, wants to replace `as` in tests, or needs partial test data. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 34 | `agent-skills` | `observability-and-instrumentation` | Instruments code so production behavior is visible and diagnosable. Use when adding logging, metrics, tracing, or alerting. Use when shipping any feature that runs in production and you need evidence it works. Use when production issues are reported but you can't tell what happened from the available data. | 2026-06-11 \| docs: add observability-checklist reference as companion to observability skill |
| 35 | `matt pocock skills` | `obsidian-vault` | Search, create, and manage notes in the Obsidian vault with wikilinks and index notes. Use when user wants to find, create, or organize notes in Obsidian. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 36 | `agent-skills` | `performance-optimization` | Optimizes application performance across frontend, backend, queries, and databases. Use when performance requirements exist, when you suspect performance regressions, when Core Web Vitals or load times need improvement, when N+1 query patterns need fixing, or when profiling reveals bottlenecks. | 2026-07-07 \| fix(evals): cover description vocabulary gaps |
| 37 | `agent-skills` | `planning-and-task-breakdown` | Breaks work into ordered tasks. Use when you have a spec or clear requirements and need to break work into implementable tasks. Use when a task feels too large to start, when you need to estimate scope, or when parallel work is possible. | 2026-06-30 \| fix: add tasks/plan.md and tasks/todo.md output paths to planning skills |
| 38 | `matt pocock skills` | `prototype` | Build a throwaway prototype to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look like. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 39 | `matt pocock skills` | `qa` | Interactive QA session where user reports bugs or issues conversationally, and the agent files GitHub issues. Explores the codebase in the background for context and domain language. Use when user wants to report bugs, do QA, file issues conversationally, or mentions "QA session". | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 40 | `matt pocock skills` | `request-refactor-plan` | Create a detailed refactor plan with tiny commits via user interview, then file it as a GitHub issue. Use when user wants to plan a refactor, create a refactoring RFC, or break a refactor into safe incremental steps. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 41 | `matt pocock skills` | `research` | Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 42 | `matt pocock skills` | `resolving-merge-conflicts` | "Use when you need to resolve an in-progress git merge/rebase conflict." | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 43 | `matt pocock skills` | `scaffold-exercises` | Create exercise directory structures with sections, problems, solutions, and explainers that pass linting. Use when user wants to scaffold exercises, create exercise stubs, or set up a new course section. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 44 | `agent-skills` | `security-and-hardening` | Hardens code against vulnerabilities. Use when handling user input, authentication, data storage, or external integrations. Use when building any feature that accepts untrusted data, manages user sessions, or interacts with third-party services. | 2026-07-11 \| docs(security): harden package-manager supply-chain guidance |
| 45 | `matt pocock skills` | `setup-matt-pocock-skills` | Configure this repo for the engineering skills — set up its issue tracker, triage label vocabulary, and domain doc layout. Run once before first use of the other engineering skills. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 46 | `matt pocock skills` | `setup-pre-commit` | Set up Husky pre-commit hooks with lint-staged (Prettier), type checking, and tests in the current repo. Use when user wants to add pre-commit hooks, set up Husky, configure lint-staged, or add commit-time formatting/typechecking/testing. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 47 | `matt pocock skills` | `setup-ts-deep-modules` | Wire dependency-cruiser into a TypeScript repo so each package is a deep module — implementation hidden in subfolders, reachable only through its entry-point files. User-invoked. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 48 | `agent-skills` | `shipping-and-launch` | Prepares production launches. Use when preparing to deploy to production. Use when you need a pre-launch checklist, when setting up monitoring, when planning a staged rollout, or when you need a rollback strategy. | 2026-06-23 \| docs: add Definition of Done reference checklist |
| 49 | `agent-skills` | `source-driven-development` | Grounds every implementation decision in official documentation. Use when you want authoritative, source-cited code free from outdated patterns. Use when building with any framework or library where correctness matters. | 2026-04-09 \| address review feedback |
| 50 | `agent-skills` | `spec-driven-development` | Creates specs before coding. Use when starting a new project, feature, or significant change and no specification exists yet. Use when requirements are unclear, ambiguous, or only exist as a vague idea. | 2026-06-30 \| fix: add tasks/plan.md and tasks/todo.md output paths to planning skills |
| 51 | `matt pocock skills` | `tdd` | Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions "red-green-refactor", or wants integration tests. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 52 | `matt pocock skills` | `teach` | Teach the user a new skill or concept, within this workspace. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 53 | `agent-skills` | `test-driven-development` | Drives development with tests. Use when implementing any logic, fixing any bug, or changing any behavior. Use when you need to prove that code works, when a bug report arrives, or when you're about to modify existing functionality. | 2026-05-06 \| docs: tighten redundant-verification wording for consistency |
| 54 | `matt pocock skills` | `to-questionnaire` | Turn a decision you can't fully answer into a questionnaire for someone else to fill in. | 2026-07-14 \| Cut no-op justification and template the questionnaire structure |
| 55 | `matt pocock skills` | `to-spec` | Turn the current conversation into a spec and publish it to the project issue tracker — no interview, just synthesis of what you've already discussed. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 56 | `matt pocock skills` | `to-tickets` | Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker — edges as text in one file per ticket locally, or native blocking links on a real tracker. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 57 | `matt pocock skills` | `triage` | Move issues and external PRs through a state machine of triage roles — categorise, verify, grill if needed, and write agent-ready briefs. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 58 | `matt pocock skills` | `ubiquitous-language` | Extract a DDD-style ubiquitous language glossary from the current conversation, flagging ambiguities and proposing canonical terms. Saves to UBIQUITOUS_LANGUAGE.md. Use when user wants to define domain terms, build a glossary, harden terminology, create a ubiquitous language, or mentions "domain model" or "DDD". | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 59 | `agent-skills` | `using-agent-skills` | Discovers and invokes agent skills. Use when starting a session or when you need to discover which skill applies to the current task. This is the meta-skill that governs how all other skills are discovered and invoked. | 2026-06-23 \| docs: add Definition of Done reference checklist |
| 60 | `matt pocock skills` | `wayfinder` | Plan a huge chunk of work — more than one agent session can hold — as a shared map of decision tickets on your issue tracker, and resolve them one at a time until the way to the destination is clear. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 61 | `matt pocock skills` | `wizard` | Generate an interactive bash wizard that walks a human through a manual procedure — third-party setup, a one-off migration, an A→B state transition — opening URLs, capturing values, confirming each step, and writing .env files and GitHub Actions secrets. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 62 | `matt pocock skills` | `writing-beats` | Writing, exploit — assemble raw material into a journey of beats, grounding each term before a beat leans on it. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 63 | `matt pocock skills` | `writing-fragments` | Writing, explore — mine raw fragments, no structure yet. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 64 | `matt pocock skills` | `writing-great-skills` | Reference for writing and editing skills well — the vocabulary and principles that make a skill predictable. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 65 | `matt pocock skills` | `writing-shape` | Writing, exploit — shape raw material into an article, paragraph by paragraph. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
<!-- SKILLS_END -->

---

## 🔒 License
This toolkit is licensed under the MIT License. See [LICENSE](file:///Users/chrys/Projects/Specs_kit/agent-skills/LICENSE) for details.
