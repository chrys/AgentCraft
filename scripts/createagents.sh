#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Default values
TARGET_PATH=""
TOOL_TYPE=""
SKILLS_ARG=""

# Helper function to print usage
print_usage() {
  echo "Usage: $0 [path] --tool <github-copilot|opencode|antigravity-ide> [--skills <indices-or-slugs>]" >&2
  echo "" >&2
  echo "Options:" >&2
  echo "  -p, --path PATH      Target project directory" >&2
  echo "  -t, --tool TOOL      Target tool style ('github-copilot', 'opencode', or 'antigravity-ide')" >&2
  echo "  -s, --skills SKILLS  Space/comma separated list of skill numbers, slugs, or repo:slug namespaces" >&2
  echo "  -h, --help           Show this help message" >&2
}

# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--path)
      TARGET_PATH="$2"
      shift 2
      ;;
    -t|--tool)
      TOOL_TYPE="$2"
      shift 2
      ;;
    -s|--skills)
      # Consume all subsequent arguments that do not start with "-" (handles space separated values)
      SKILLS_ARG=""
      while [[ $# -gt 1 && ! "$2" =~ ^- ]]; do
        if [ -z "$SKILLS_ARG" ]; then
          SKILLS_ARG="$2"
        else
          SKILLS_ARG="$SKILLS_ARG $2"
        fi
        shift
      done
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    -*)
      echo "Error: Unknown option $1" >&2
      print_usage
      exit 1
      ;;
    *)
      if [ -z "$TARGET_PATH" ]; then
        TARGET_PATH="$1"
        shift
      else
        echo "Error: Unexpected positional argument $1" >&2
        print_usage
        exit 1
      fi
      ;;
  esac
done

# Validate target path
if [ -z "$TARGET_PATH" ]; then
  echo "Error: Target path is required." >&2
  print_usage
  exit 1
fi

# Validate tool type
if [ -z "$TOOL_TYPE" ]; then
  echo "Error: Tool type is required (--tool github-copilot or --tool opencode)." >&2
  print_usage
  exit 1
fi

if [[ "$TOOL_TYPE" != "github-copilot" && "$TOOL_TYPE" != "opencode" && "$TOOL_TYPE" != "antigravity-ide" ]]; then
  echo "Error: Invalid tool type '$TOOL_TYPE'. Must be 'github-copilot', 'opencode', or 'antigravity-ide'." >&2
  exit 1
fi

# Get the directory of this script (scripts/) and navigate to the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 1. Parse sources.txt
SOURCES_FILE="$PROJECT_ROOT/sources.txt"
if [ ! -f "$SOURCES_FILE" ]; then
  echo "Error: '$SOURCES_FILE' not found in the project root." >&2
  exit 1
fi

declare -a SOURCE_NAMES
declare -a SOURCE_PATHS
declare -a SOURCE_REL_PATHS

while IFS='|' read -r name rpath url branch rel_path || [ -n "$name" ]; do
  if [[ "$name" =~ ^[[:space:]]*# ]] || [[ -z "${name//[[:space:]]/}" ]]; then
    continue
  fi
  name=$(echo "$name" | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//')
  rpath=$(echo "$rpath" | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//')
  rel_path=$(echo "$rel_path" | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//')

  SOURCE_NAMES+=("$name")
  SOURCE_PATHS+=("$rpath")
  SOURCE_REL_PATHS+=("$rel_path")
done < "$SOURCES_FILE"

# 2. Collect and sort available skill slugs alphabetically
skills_raw=""

for i in "${!SOURCE_NAMES[@]}"; do
  name="${SOURCE_NAMES[$i]}"
  rpath="${SOURCE_PATHS[$i]}"
  rel_path="${SOURCE_REL_PATHS[$i]}"
  
  FULL_REPO_PATH="$PROJECT_ROOT/repos/$rpath"
  FULL_SKILLS_DIR="$FULL_REPO_PATH/$rel_path"
  
  if [ -d "$FULL_SKILLS_DIR" ]; then
    while IFS= read -r skill_file; do
      if [ -z "$skill_file" ]; then
        continue
      fi
      skill_path=$(dirname "$skill_file")
      skill_slug=$(basename "$skill_path")
      skills_raw+="${skill_slug}:::${name}:::${skill_path}"$'\n'
    done < <(find "$FULL_SKILLS_DIR" -type f -name "SKILL.md" 2>/dev/null)
  fi
done

# Sort alphabetically by skill slug
sorted_skills=""
if [ -n "$skills_raw" ]; then
  sorted_skills=$(echo -n "$skills_raw" | sort -f -t: -k1)
fi

ALL_SLUGS=()
ALL_REPOS=()
ALL_PATHS=()

if [ -n "$sorted_skills" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    if [ -z "$line" ]; then
      continue
    fi
    line_tabbed=$(echo "$line" | sed 's/:::/	/g')
    IFS=$'\t' read -r s_slug r_name s_path <<< "$line_tabbed"
    
    ALL_SLUGS+=("$s_slug")
    ALL_REPOS+=("$r_name")
    ALL_PATHS+=("$s_path")
  done <<< "$sorted_skills"
fi

TOTAL_SKILLS=${#ALL_SLUGS[@]}
if [ $TOTAL_SKILLS -eq 0 ]; then
  echo "Error: No skills found under the configured repository paths." >&2
  exit 1
fi

# Parse skills to copy
SELECTED_INDICES=()

if [ -z "$SKILLS_ARG" ]; then
  # No skills specified
  if [[ "$TOOL_TYPE" == "antigravity-ide" ]]; then
    # For antigravity-ide, only copy the 4 core skills
    for core_skill in "incremental-implementation" "planning-and-task-breakdown" "code-review-and-quality" "spec-driven-development"; do
      for idx in "${!ALL_SLUGS[@]}"; do
        if [[ "${ALL_SLUGS[$idx]}" == "$core_skill" ]]; then
          SELECTED_INDICES+=("$idx")
          break
        fi
      done
    done
  else
    # Copy all of them
    for idx in "${!ALL_SLUGS[@]}"; do
      SELECTED_INDICES+=("$idx")
    done
  fi
else
  # Replace commas with spaces to support comma-separated lists, then split
  SKILLS_ARG_CLEANED=$(echo "$SKILLS_ARG" | tr ',' ' ')
  
  for token in $SKILLS_ARG_CLEANED; do
    # Check if the token is an index number (1-based)
    if [[ "$token" =~ ^[0-9]+$ ]]; then
      index=$((token - 1)) # 0-indexed internally
      if [[ $index -ge 0 && $index -lt $TOTAL_SKILLS ]]; then
        SELECTED_INDICES+=("$index")
      else
        echo "Error: Invalid skill index '$token'. Must be between 1 and $TOTAL_SKILLS." >&2
        exit 1
      fi
    # Check if token is in namespaced format (repo:slug)
    elif [[ "$token" == *":"* ]]; then
      req_repo=$(echo "$token" | cut -d':' -f1)
      req_slug=$(echo "$token" | cut -d':' -f2)
      
      found=0
      for idx in "${!ALL_SLUGS[@]}"; do
        if [[ "${ALL_SLUGS[$idx]}" == "$req_slug" && "${ALL_REPOS[$idx]}" == "$req_repo" ]]; then
          SELECTED_INDICES+=("$idx")
          found=1
          break
        fi
      done
      if [ $found -eq 0 ]; then
        echo "Error: Skill '$req_slug' from repository '$req_repo' not found." >&2
        exit 1
      fi
    else
      # Check if token matches a slug (non-namespaced)
      # Check for ambiguity
      match_count=0
      matched_idx=-1
      for idx in "${!ALL_SLUGS[@]}"; do
        if [[ "${ALL_SLUGS[$idx]}" == "$token" ]]; then
          match_count=$((match_count + 1))
          matched_idx=$idx
        fi
      done
      
      if [ $match_count -eq 0 ]; then
        echo "Error: Invalid skill slug '$token'. Refer to README.md for a list of valid slugs." >&2
        exit 1
      elif [ $match_count -gt 1 ]; then
        echo "Error: Ambiguous skill slug '$token' matches multiple repositories." >&2
        echo "Please specify using the namespaced format (e.g., repo:slug)." >&2
        exit 1
      else
        SELECTED_INDICES+=("$matched_idx")
      fi
    fi
  done
  
  # For antigravity-ide, check if at least one of the 4 core skills is selected.
  # If so, ensure all 4 are included.
  if [[ "$TOOL_TYPE" == "antigravity-ide" ]]; then
    core_selected=0
    for core_skill in "incremental-implementation" "planning-and-task-breakdown" "code-review-and-quality" "spec-driven-development"; do
      for idx in "${SELECTED_INDICES[@]}"; do
        if [[ "${ALL_SLUGS[$idx]}" == "$core_skill" ]]; then
          core_selected=1
          break 2
        fi
      done
    done

    if [ $core_selected -eq 1 ]; then
      for core_skill in "incremental-implementation" "planning-and-task-breakdown" "code-review-and-quality" "spec-driven-development"; do
        # Find index in ALL_SLUGS
        core_idx=-1
        for idx in "${!ALL_SLUGS[@]}"; do
          if [[ "${ALL_SLUGS[$idx]}" == "$core_skill" ]]; then
            core_idx=$idx
            break
          fi
        done
        
        if [ $core_idx -ne -1 ]; then
          already_selected=0
          for idx in "${SELECTED_INDICES[@]}"; do
            if [ $idx -eq $core_idx ]; then
              already_selected=1
              break
            fi
          done
          if [ $already_selected -eq 0 ]; then
            SELECTED_INDICES+=("$core_idx")
          fi
        fi
      done
    fi
  fi
fi

# Create target path directory if it doesn't exist
mkdir -p "$TARGET_PATH"

echo "=== Provisioning Skills to Target Path: $TARGET_PATH ===" >&2
copied_count=0

# Deduplicate SELECTED_INDICES
DEDUPLICATED_INDICES=($(echo "${SELECTED_INDICES[@]}" | tr ' ' '\n' | sort -n -u | tr '\n' ' '))

for idx in "${DEDUPLICATED_INDICES[@]}"; do
  slug="${ALL_SLUGS[$idx]}"
  source_file="${ALL_PATHS[$idx]}/SKILL.md"
  
  if [ ! -f "$source_file" ]; then
    echo "Warning: Source file for skill '$slug' not found at '$source_file'. Skipping." >&2
    continue
  fi
  
  # Determine target destination directory based on tool selection
  if [[ "$TOOL_TYPE" == "github-copilot" ]]; then
    dest_dir="$TARGET_PATH/.github/skills/$slug"
  elif [[ "$TOOL_TYPE" == "antigravity-ide" ]]; then
    dest_dir="$TARGET_PATH/.agents/skills/$slug"
  else
    dest_dir="$TARGET_PATH/skills/$slug"
  fi
  
  # Create target directory
  mkdir -p "$dest_dir"
  
  # Copy SKILL.md
  cp "$source_file" "$dest_dir/SKILL.md"
  echo "Provisioned: '$slug' -> '$dest_dir/SKILL.md'" >&2
  copied_count=$((copied_count + 1))
done

echo "=== Successfully provisioned $copied_count skills to '$TARGET_PATH' ($TOOL_TYPE format)! ===" >&2

if [[ "$TOOL_TYPE" == "antigravity-ide" ]]; then
  echo "=== Provisioning Workflows to Target Path: $TARGET_PATH/.agents/workflows ===" >&2
  
  WORKFLOWS_DIR="$TARGET_PATH/.agents/workflows"
  mkdir -p "$WORKFLOWS_DIR"
  
  # Generate spec-task.md
  cat << 'EOF' > "$WORKFLOWS_DIR/spec-task.md"
---
name: spec-task
description: Start spec-driven development — write a structured specification before writing code
---

Invoke the spec-driven-development skill.

Begin by understanding what the user wants to build. Ask clarifying questions about:
1. The objective and target users
2. Core features and acceptance criteria
3. Tech stack preferences and constraints
4. Known boundaries (what to always do, ask first about, and never do)

Then generate a structured spec covering all six core areas: objective, commands, project structure, code style, testing strategy, and boundaries.

This workflow accepts the specs file path as an argument ($1). Load the specifications file from this path, update it with the requested changes, and save the updated specifications directly to the same file. If no path is specified as an argument, default to SPEC.md in the project root.
EOF
  echo "Provisioned Workflow: spec-task -> '$WORKFLOWS_DIR/spec-task.md'" >&2
  
  # Generate plan-task.md
  cat << 'EOF' > "$WORKFLOWS_DIR/plan-task.md"
---
name: plan-task
description: Break work into small verifiable tasks with acceptance criteria and dependency ordering
---

Invoke the planning-and-task-breakdown skill.

This workflow accepts the specs file path as an argument ($1). Read the specifications from the provided file. Then:

1. Enter plan mode — read only, no code changes
2. Identify the dependency graph between components
3. Slice work vertically (one complete path per task, not horizontal layers)
4. Write tasks with acceptance criteria and verification steps
5. Add checkpoints between phases
6. Present the plan for human review

Save the plan to plan.md and task list to todo.md in the same directory as the specifications file (e.g., in `dirname($1)/plan.md` and `dirname($1)/todo.md`).
EOF
  echo "Provisioned Workflow: plan-task -> '$WORKFLOWS_DIR/plan-task.md'" >&2
  
  # Generate build-task.md
  cat << 'EOF' > "$WORKFLOWS_DIR/build-task.md"
---
name: build-task
description: Implement tasks incrementally — build, test, verify, commit. Add "auto" to run the whole plan in one approved pass.
---

Invoke the incremental-implementation skill alongside test-driven-development.

## Modes

- `/build` — implement the next pending task, then stop (careful, one slice at a time).
- `/build auto` — generate the plan if needed, get a single approval, then implement every task without stopping between them.

The arguments select the mode. Treat `auto` (canonical) or `all` as autonomous mode; anything else (or empty) is the default single-task mode. Note: autonomous mode is not faster per task — it runs the same test-driven loop — it only removes the human stepping between tasks.

## Default: one task

Find the active todo file. Look for the very first line item containing an empty checkbox: `- [ ]`. Immediately modify that checkbox from `- [ ]` to `- [~]` to indicate that work has started, and save the file.

Then, for that task:
1. Read the task's acceptance criteria
2. Load relevant context (existing code, patterns, types)
3. Write a failing test for the expected behavior (RED)
4. Implement the minimum code to pass the test (GREEN)
5. Run the full test suite to check for regressions
6. Run the build to verify compilation
7. Commit with a descriptive message
8. Mark the task complete (change `- [~]` to `- [x]`) and stop

## Autonomous: the whole plan (`/build auto`)

Use this once a spec exists and you want to collapse plan + build into one run. It removes the manual stepping between tasks — not the verification. Every task still earns a passing test and its own commit.

1. Require a spec. Look only for a spec at a known path: SPEC.md at the repo root, docs/SPEC.md, or a file under spec/. A README or arbitrary doc does NOT count. If none exists, stop and tell the user to run /spec first — do not invent requirements.
2. Establish a clean baseline. Run `git status --porcelain`. If there are uncommitted changes outside the expected planning artifacts (SPEC.md, docs/SPEC.md, spec/*, tasks/plan.md, tasks/todo.md), stop and ask the user to commit, stash, or confirm how to handle them. Autonomous per-task commits must not absorb unrelated local work, or the clean-rollback guarantee breaks.
3. Plan if needed. If there is no tasks/plan.md, invoke the planning-and-task-breakdown skill to generate one.
4. Single checkpoint. Present the full plan and wait for an unambiguous affirmative (e.g. "approve", "go", "yes"). Treat hedged responses ("looks reasonable", "I guess") as NOT approved. This is the only human gate — after approval, run autonomously. If you generated tasks/plan.md, commit it as a single preparatory commit now so it doesn't bleed into the first task's commit.
5. Execute every task in dependency order. Use each task's declared dependencies; if they aren't explicit, execute in the order the plan lists them. For each task, run the full default loop above (modify `- [ ]` to `- [~]` -> RED → GREEN → regression → build → commit → mark complete `- [x]`). Stage only the files that task touched plus its task-status update — never `git add -A` blindly — and make one commit per task so any point is a clean rollback.
6. Stop and ask the user (do not push through) when:
   - a test can't be made to pass or the build breaks without an obvious fix → follow the debugging-and-error-recovery skill
   - the spec is ambiguous, or a task needs a decision the spec doesn't cover
   - a task is high-risk or irreversible — auth/permission changes, destructive data migrations, payments, deletions, deploys, anything touching secrets, or anything you can't undo with `git revert` → follow the doubt-driven-development skill and get explicit sign-off before continuing
   After the user resolves a blocker, they re-invoke /build auto — it resumes from the next pending task.
7. Summarize at the end: tasks completed, tests added, commits made, and anything skipped, flagged, or left for the user.

If any step fails, follow the debugging-and-error-recovery skill.

## 3. Error Handling and Logging
If a compilation error, syntax crash, or test runner failure happens while executing your build loop:
- Do not clear existing errors.
- Extract a concise summary of the traceback or regression.
- Locate the parent folder of the active todo file, and append the failure details to a file named `errlog.md` in that exact directory.
EOF
  echo "Provisioned Workflow: build-task -> '$WORKFLOWS_DIR/build-task.md'" >&2
  
  # Generate review-task.md
  cat << 'EOF' > "$WORKFLOWS_DIR/review-task.md"
---
name: review-task
description: Conduct a five-axis code review — correctness, readability, architecture, security, performance
---

Invoke the code-review-and-quality skill.

This workflow accepts the specs file path as an argument ($1). Review the current changes (staged or recent commits) across all five axes relative to the specification:

1. **Correctness** — Does it match the spec? Edge cases handled? Tests adequate?
2. **Readability** — Clear names? Straightforward logic? Well-organized?
3. **Architecture** — Follows existing patterns? Clean boundaries? Right abstraction level?
4. **Security** — Input validated? Secrets safe? Auth checked? (Use security-and-hardening skill)
5. **Performance** — No N+1 queries? No unbounded ops? (Use performance-optimization skill)

## Output Execution Rules
* Categorize findings clearly as **Critical**, **Important**, or **Suggestion**.
* Provide structured feedback including specific `file:line` references and actionable fix recommendations.
* Do not stream the final report to standard chat output. Write this structured report using the following file-system directive: `!write(!dirname($1)/findings.md)`. Overwrite the file if it already exists.
EOF
  echo "Provisioned Workflow: review-task -> '$WORKFLOWS_DIR/review-task.md'" >&2
  
  echo "=== Successfully provisioned workflows to '$WORKFLOWS_DIR'! ===" >&2
fi
