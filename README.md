# AgentCraft - AI Agent Skills Provisioner & Dashboard

AgentCraft is a centralized manager and developer dashboard designed to synchronize, discover, and provision custom **AI Agent Skills** across your software projects. 

By pulling agent skill definitions from custom GitHub repositories (such as [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) or [mattpocock/skills](https://github.com/mattpocock/skills)), AgentCraft enables you to manage and package agent instructions for different tools and IDE extensions (like **Antigravity IDE**, **GitHub Copilot**, or **OpenCode**) so they are configured with robust, proven software development processes.

---

## 🚀 Key Features

* **Visual Web Dashboard**: An HTMX-powered dashboard to manage repositories, configure paths, and discover skills.
* **Smart Skills Classification**: Checks your target project and classifies skills into **Existing** (installed) vs **Available** (new) tabs.
* **Target-Specific Path Formatting**: Auto-packages skills for your specific environment:
  - **Antigravity IDE**: Copies to `.agents/skills/` and auto-generates custom workflows (`spec-task`, `plan-task`, etc.) in `.agents/workflows/`.
  - **GitHub Copilot**: Copies to `.github/skills/`.
  - **OpenCode**: Copies to `.opencode/skills/`.
* **Granular Control**: Selectively apply (install/update) or remove individual skills from your projects dynamically.
* **Clean Git Workspaces**: All cloned source repositories are stored in a dedicated `repos/` directory, which is ignored globally.

---

## 🛠️ Getting Started

### 1. Installation
Clone the repository and install the Node dependencies:
```bash
npm install
```

### 2. Start the Dashboard
Start the development server:
```bash
npm start
```
Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## 🖥️ Using the Dashboard

### Step 1: Manage Repositories (Configuration Tab)
* Configure the repositories from which you want to pull skills (e.g., name, clone URL, branch, and relative path to skills).
* Click **Sync Repositories** to clone/fetch updates. The dashboard will show you the exact "Comments" column containing the last synced timestamp and number of changes found for each repository.

### Step 2: Target Project & Tool Format (Skills Tab)
* Enter the **Target Project Path** (absolute folder path of your software project).
* Select your target **Tool / IDE Style** (GitHub Copilot, OpenCode, or Antigravity IDE).
* Click **Discover Skills**. The dashboard scans your project's directory and populates the skills.

### Step 3: Apply or Remove Skills
* **Existing Skills**: Displays skills already present in your project, along with their exact file path on your disk. You can remove any installed skill by clicking the red **Remove** button.
* **Available Skills**: Displays new skills available in your sources. Check the ones you want, and click **Apply Selected Skills** to copy them over.
* *Note (Antigravity Core)*: In Antigravity mode, if you apply any of the 4 core developer workflows, the other three core skills are automatically applied as dependencies to keep your custom workflows functional.

---

## 📟 CLI Script Usage

If you prefer using the command line, you can run the scripts directly:

### 1. Synchronizing Skills (`get-updates.sh`)
Fetches all configured repositories and dynamically updates this README file:
```bash
bash scripts/get-updates.sh
```

### 2. Provisioning Skills (`createagents.sh`)
Copies skill definitions to a project target:
```bash
bash scripts/createagents.sh <target-path> --tool <github-copilot | opencode | antigravity-ide> [--skills <indices-or-slugs>]
```
* Can specify specific indices (e.g., `1 5 12`) or slugs (e.g., `test-driven-development`).

---

## 📚 Available Skills Catalog

The list below is dynamically synchronized and updated by `get-updates.sh`.

<!-- SKILLS_START -->
| # | Repository | Skill Slug | Description | Latest Update |
|---|------------|------------|-------------|---------------|
| 1 | `agent-skills` | `api-and-interface-design` | Guides stable API and interface design. Use when designing APIs, module boundaries, or any public interface. Use when creating REST or GraphQL endpoints, defining type contracts between modules, or establishing boundaries between frontend and backend. | N/A \| Direct copy / no git history |
| 2 | `matt pocock skills` | `ask-matt` | Ask which skill or flow fits your situation. A router over the skills in this repo. | 2026-08-19 \| Remove all em-dashes from the repo |
| 3 | `agent-skills` | `browser-testing-with-devtools` | Tests in real browsers via Chrome DevTools MCP. Use when building or debugging anything that runs in a browser. Use when you need to inspect the DOM, capture console errors, analyze network requests, profile performance, or verify visual output with real runtime data. Requires the chrome-devtools MCP server to be configured. | N/A \| Direct copy / no git history |
| 4 | `agent-skills` | `ci-cd-and-automation` | Automates CI/CD pipeline setup. Use when setting up or modifying build and deployment pipelines. Use when you need to automate quality gates, configure test runners in CI, or establish deployment strategies. | N/A \| Direct copy / no git history |
| 5 | `matt pocock skills` | `claude-handoff` | Hand the current conversation off to a fresh background agent that picks up the work immediately. | 2026-08-19 \| Remove all em-dashes from the repo |
| 6 | `agent-skills` | `code-review-and-quality` | Conducts multi-axis code review. Use before merging any change. Use when reviewing code written by yourself, another agent, or a human. Use when you need to assess code quality across multiple dimensions before it enters the main branch. | N/A \| Direct copy / no git history |
| 7 | `matt pocock skills` | `code-review` | "Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes: Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match what the originating issue/spec asked for?). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \"review since X\"." | 2026-08-19 \| fix: quote SKILL.md descriptions with unquoted colons |
| 8 | `agent-skills` | `code-simplification` | Simplifies code for clarity. Use when refactoring code for clarity without changing behavior. Use when code works but is harder to read, maintain, or extend than it should be. Use when reviewing code that has accumulated unnecessary complexity. | N/A \| Direct copy / no git history |
| 9 | `matt pocock skills` | `codebase-design` | Shared vocabulary for designing deep modules. Use when the user wants to design or improve a module's interface, find deepening opportunities, decide where a seam goes, make code more testable or AI-navigable, or when another skill needs the deep-module vocabulary. | 2026-08-19 \| Remove all em-dashes from the repo |
| 10 | `agent-skills` | `context-engineering` | Optimizes agent context setup. Use when starting a new session, when agent output quality degrades, when switching between tasks, or when you need to configure rules files and context for a project. | N/A \| Direct copy / no git history |
| 11 | `agent-skills` | `debugging-and-error-recovery` | Guides systematic root-cause debugging. Use when tests fail, builds break, behavior doesn't match expectations, or you encounter any unexpected error. Use when you need a systematic approach to finding and fixing the root cause rather than guessing. | N/A \| Direct copy / no git history |
| 12 | `agent-skills` | `deprecation-and-migration` | Manages deprecation and migration. Use when removing old systems, APIs, or features. Use when migrating users from one implementation to another. Use when deciding whether to maintain or sunset existing code. | N/A \| Direct copy / no git history |
| 13 | `matt pocock skills` | `diagnosing-bugs` | Diagnosis loop for hard bugs and performance regressions. Use when the user says "diagnose"/"debug this", or reports something broken/throwing/failing/slow. | 2026-08-19 \| Remove all em-dashes from the repo |
| 14 | `agent-skills` | `documentation-and-adrs` | Records decisions and documentation. Use when making architectural decisions, changing public APIs, shipping features, or when you need to record context that future engineers and agents will need to understand the codebase. | N/A \| Direct copy / no git history |
| 15 | `matt pocock skills` | `domain-modeling` | Build and sharpen a project's domain model. Use when discussing codebase terminology, writing or editing a CONTEXT.md, or recording or editing an ADR. | 2026-08-19 \| Remove all em-dashes from the repo |
| 16 | `agent-skills` | `doubt-driven-development` | Subjects every non-trivial decision to a fresh-context adversarial review before it stands. Use when correctness matters more than speed, when working in unfamiliar code, when stakes are high (production, security-sensitive logic, irreversible operations), or any time a confident output would be cheaper to verify now than to debug later. | N/A \| Direct copy / no git history |
| 17 | `agent-skills` | `frontend-ui-engineering` | Builds production-quality, accessible, responsive user-facing UIs. Use when building or modifying interfaces and pages, creating components, implementing layouts, meeting WCAG accessibility requirements, managing state, or when the output needs to look and feel production-quality rather than AI-generated. | N/A \| Direct copy / no git history |
| 18 | `matt pocock skills` | `git-guardrails-claude-code` | Set up Claude Code hooks to block dangerous git commands (push, reset --hard, clean, branch -D, etc.) before they execute. Use when user wants to prevent destructive git operations, add git safety hooks, or block git push/reset in Claude Code. | 2026-08-19 \| Remove all em-dashes from the repo |
| 19 | `agent-skills` | `git-workflow-and-versioning` | Structures git workflow practices. Use when making any code change. Use when committing, branching, resolving conflicts, or when you need to organize work across multiple parallel streams. Use when cutting a release, choosing a semantic version bump, tagging, or writing a changelog. | N/A \| Direct copy / no git history |
| 20 | `matt pocock skills` | `grill-me` | A relentless interview to sharpen a plan or design. | 2026-08-15 \| Switch Skill tool phrasing to `with "name"`, revert grill-with-docs rewording |
| 21 | `matt pocock skills` | `grill-with-docs` | A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go. | 2026-08-15 \| Clarify multi-skill steps as multiple Skill tool calls, not one call with two names |
| 22 | `matt pocock skills` | `grilling` | Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases. | 2026-08-20 \| grilling: separate questions in a round with an HR |
| 23 | `matt pocock skills` | `handoff` | Compact the current conversation into a handoff document for another agent to pick up. | 2026-08-15 \| Standardize cross-skill invocation on explicit "call the Skill tool" phrasing |
| 24 | `agent-skills` | `idea-refine` | Refines raw ideas into sharp, actionable concepts through structured divergent and convergent thinking. Use when an idea is still vague, when you need to stress-test assumptions before committing to a plan, or when you want to expand options before converging on one. Triggers on "ideate", "refine this idea", or "stress-test my plan". | N/A \| Direct copy / no git history |
| 25 | `matt pocock skills` | `implement-spec` | "Implement a specification in code." | 2026-08-21 \| fix: clarify wording in implementation steps for code review process |
| 26 | `matt pocock skills` | `implement` | "Implement a piece of work based on a spec or set of tickets." | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 27 | `matt pocock skills` | `improve-codebase-architecture` | Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick. | 2026-08-19 \| Remove all em-dashes from the repo |
| 28 | `agent-skills` | `incremental-implementation` | Delivers changes incrementally. Use when implementing any feature or change that touches more than one file. Use when you're about to write a large amount of code at once, or when a task feels too big to land in one step. | N/A \| Direct copy / no git history |
| 29 | `agent-skills` | `interview-me` | Extracts what the user actually wants instead of what they think they should want. Achieves this through one-question-at-a-time interview until ~95% confidence about the underlying intent. Use when an ask is underspecified ("build me X" without "for whom" or "why now"), when the user explicitly invokes ("interview me", "grill me", "are we sure?", "stress-test my thinking"), or when you catch yourself silently filling in ambiguous requirements before any plan, spec, or code exists. | N/A \| Direct copy / no git history |
| 30 | `matt pocock skills` | `loop-me` | Grill me about specs for the workflows I want to build, within this workspace. | 2026-08-19 \| Remove all em-dashes from the repo |
| 31 | `matt pocock skills` | `migrate-to-shoehorn` | Migrate test files from `as` type assertions to @total-typescript/shoehorn. Use when user mentions shoehorn, wants to replace `as` in tests, or needs partial test data. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 32 | `agent-skills` | `observability-and-instrumentation` | Instruments code so production behavior is visible and diagnosable. Use when adding logging, metrics, tracing, or alerting. Use when shipping any feature that runs in production and you need evidence it works. Use when production issues are reported but you can't tell what happened from the available data. | N/A \| Direct copy / no git history |
| 33 | `agent-skills` | `performance-optimization` | Optimizes application performance across frontend, backend, queries, and databases. Use when performance requirements exist, when you suspect performance regressions, when Core Web Vitals or load times need improvement, when N+1 query patterns need fixing, or when profiling reveals bottlenecks. | N/A \| Direct copy / no git history |
| 34 | `agent-skills` | `planning-and-task-breakdown` | Breaks work into ordered tasks. Use when you have a spec or clear requirements and need to break work into implementable tasks. Use when a task feels too large to start, when you need to estimate scope, or when parallel work is possible. | N/A \| Direct copy / no git history |
| 35 | `matt pocock skills` | `prototype` | Build a throwaway prototype to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look like. | 2026-08-19 \| Remove all em-dashes from the repo |
| 36 | `matt pocock skills` | `research` | Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent. | 2026-08-19 \| Remove all em-dashes from the repo |
| 37 | `matt pocock skills` | `resolving-merge-conflicts` | "Use when you need to resolve an in-progress git merge/rebase conflict." | 2026-08-19 \| Remove all em-dashes from the repo |
| 38 | `matt pocock skills` | `scaffold-exercises` | Create exercise directory structures with sections, problems, solutions, and explainers that pass linting. Use when user wants to scaffold exercises, create exercise stubs, or set up a new course section. | 2026-07-13 \| feat: add Codex agents/openai.yaml metadata to every skill |
| 39 | `agent-skills` | `security-and-hardening` | Hardens code against vulnerabilities. Use when handling user input, authentication, data storage, or external integrations. Use when building any feature that accepts untrusted data, manages user sessions, or interacts with third-party services. | N/A \| Direct copy / no git history |
| 40 | `matt pocock skills` | `setup-matt-pocock-skills` | "Configure this repo for the engineering skills: set up its issue tracker, triage label vocabulary, and domain doc layout. Run once before first use of the other engineering skills." | 2026-08-19 \| fix: quote SKILL.md descriptions with unquoted colons |
| 41 | `matt pocock skills` | `setup-pre-commit` | Set up Husky pre-commit hooks with lint-staged (Prettier), type checking, and tests in the current repo. Use when user wants to add pre-commit hooks, set up Husky, configure lint-staged, or add commit-time formatting/typechecking/testing. | 2026-08-19 \| Remove all em-dashes from the repo |
| 42 | `matt pocock skills` | `setup-ts-deep-modules` | Wire dependency-cruiser into a TypeScript repo so each package is a deep module, with implementation hidden in subfolders and reachable only through its entry-point files. User-invoked. | 2026-08-19 \| Remove all em-dashes from the repo |
| 43 | `agent-skills` | `shipping-and-launch` | Prepares production launches. Use when preparing to deploy to production. Use when you need a pre-launch checklist, when setting up monitoring, when planning a staged rollout, or when you need a rollback strategy. | N/A \| Direct copy / no git history |
| 44 | `agent-skills` | `source-driven-development` | Grounds every implementation decision in official documentation. Use when you want authoritative, source-cited code free from outdated patterns. Use when building with any framework or library where correctness matters. | N/A \| Direct copy / no git history |
| 45 | `agent-skills` | `spec-driven-development` | Creates specs before coding. Use when starting a new project, feature, or significant change and no specification exists yet. Use when requirements are unclear, ambiguous, or only exist as a vague idea. | N/A \| Direct copy / no git history |
| 46 | `matt pocock skills` | `tdd` | Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions "red-green-refactor", or wants integration tests. | 2026-08-19 \| Remove all em-dashes from the repo |
| 47 | `matt pocock skills` | `teach` | Teach the user a new skill or concept, within this workspace. | 2026-08-19 \| Remove all em-dashes from the repo |
| 48 | `agent-skills` | `test-driven-development` | Drives development with tests. Use when implementing any logic, fixing any bug, or changing any behavior. Use when you need to prove that code works, when a bug report arrives, or when you're about to modify existing functionality. | N/A \| Direct copy / no git history |
| 49 | `matt pocock skills` | `to-questionnaire` | Turn a decision you can't fully answer into a questionnaire for someone else to fill in. | 2026-08-19 \| Remove all em-dashes from the repo |
| 50 | `matt pocock skills` | `to-spec` | "Turn the current conversation into a spec and publish it to the project issue tracker: no interview, just synthesis of what you've already discussed." | 2026-08-19 \| fix: quote SKILL.md descriptions with unquoted colons |
| 51 | `matt pocock skills` | `to-tickets` | Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker (edges as text in one file per ticket locally, or native blocking links on a real tracker). | 2026-08-19 \| Remove all em-dashes from the repo |
| 52 | `matt pocock skills` | `triage` | Move issues and external PRs through a state machine of triage roles, categorise, verify, grill if needed, and write agent-ready briefs. | 2026-08-19 \| Remove all em-dashes from the repo |
| 53 | `agent-skills` | `using-agent-skills` | Discovers and invokes agent skills. Use when starting a session or when you need to discover which skill applies to the current task. This is the meta-skill that governs how all other skills are discovered and invoked. | N/A \| Direct copy / no git history |
| 54 | `matt pocock skills` | `wait-what` | "Stop. That last message did not land: re-pitch it." | 2026-08-19 \| fix: quote SKILL.md descriptions with unquoted colons |
| 55 | `matt pocock skills` | `wayfinder` | Plan a huge chunk of work (more than one agent session can hold) as a shared map of decision tickets on your issue tracker, and resolve them one at a time until the way to the destination is clear. | 2026-08-19 \| Remove all em-dashes from the repo |
| 56 | `matt pocock skills` | `wizard` | Generate an interactive bash wizard that walks a human through steps only they can perform. Use when provisioning infrastructure, setting up credentials or CI secrets, walking an unfamiliar third-party dashboard, or running a one-off migration or cutover. Don't invoke this for steps the agent can perform itself. | 2026-08-19 \| Remove all em-dashes from the repo |
| 57 | `matt pocock skills` | `writing-beats` | Writing, exploit; assemble raw material into a journey of beats, grounding each term before a beat leans on it. | 2026-08-19 \| Remove all em-dashes from the repo |
| 58 | `matt pocock skills` | `writing-for-agents` | Writing documents for agents. Use when creating or editing skills, or modifying AGENTS.md or CLAUDE.md. | 2026-08-19 \| Remove all em-dashes from the repo |
| 59 | `matt pocock skills` | `writing-fragments` | "Writing, explore: mine raw fragments, no structure yet." | 2026-08-19 \| fix: quote SKILL.md descriptions with unquoted colons |
| 60 | `matt pocock skills` | `writing-shape` | "Writing, exploit: shape raw material into an article, paragraph by paragraph." | 2026-08-19 \| fix: quote SKILL.md descriptions with unquoted colons |
<!-- SKILLS_END -->

---

## 🔒 License
This toolkit is licensed under the MIT License.
