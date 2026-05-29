#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Synchronizing Agent Skills & Updating Documentation ===" >&2

# Get the directory of this script (scripts/) and navigate to the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# 1. Validate agent-skills directory exists
if [ ! -d "agent-skills" ]; then
  echo "Error: 'agent-skills' directory not found in the project root." >&2
  echo "Please clone the repository first: git clone https://github.com/addyosmani/agent-skills.git" >&2
  exit 1
fi

# 2. Pull latest updates in agent-skills
echo "Fetching latest updates for agent-skills..." >&2
cd agent-skills

if [ -d ".git" ]; then
  # Fetch and pull main branch, suppressing standard outputs but keeping errors
  git fetch origin main >/dev/null 2>&1 || echo "Warning: git fetch failed. Proceeding with local version." >&2
  git pull origin main >/dev/null 2>&1 || echo "Warning: git pull failed. Proceeding with local version." >&2
else
  echo "Notice: agent-skills is not a Git repository. Skipping git pull." >&2
fi

cd "$PROJECT_ROOT"

# 3. Read and parse skills alphabetically
SKILLS_DIR="agent-skills/skills"
if [ ! -d "$SKILLS_DIR" ]; then
  echo "Error: 'agent-skills/skills' directory does not exist." >&2
  exit 1
fi

echo "Parsing skills from $SKILLS_DIR..." >&2

# Build the markdown table header
table_content="| # | Skill Slug | Description | Latest Update |"$'\n'
table_content+="|---|------------|-------------|---------------|"

index=1

# Get sorted list of skill directories
# We loop through directories under agent-skills/skills/
cd "$PROJECT_ROOT"
# Alphabetical sort using standard globbing
for skill_path in "$SKILLS_DIR"/*; do
  if [ -d "$skill_path" ]; then
    skill_slug=$(basename "$skill_path")
    skill_file="$skill_path/SKILL.md"
    
    if [ -f "$skill_file" ]; then
      # Extract name and description from the SKILL.md file
      # Use grep/sed to handle single-line frontmatter fields robustly
      skill_name=$(grep -E "^name:" "$skill_file" | head -n 1 | sed -E 's/^name:[[:space:]]*//' | tr -d '\r' || true)
      skill_desc=$(grep -E "^description:" "$skill_file" | head -n 1 | sed -E 's/^description:[[:space:]]*//' | tr -d '\r' || true)
      
      # Fallback to slug if name is not found in frontmatter
      if [ -z "$skill_name" ]; then
        skill_name="$skill_slug"
      fi
      
      # Fallback message for description
      if [ -z "$skill_desc" ]; then
        skill_desc="*No description available in SKILL.md*"
      fi
      
      # Query the latest Git commit inside agent-skills for this specific skill directory
      commit_info=""
      if [ -d "agent-skills/.git" ]; then
        # Check if the folder has any commits in the log
        cd agent-skills
        commit_info=$(git log -n 1 --format="%ad | %s" --date=format:"%Y-%m-%d" -- "skills/$skill_slug" 2>/dev/null || true)
        cd "$PROJECT_ROOT"
      fi
      
      if [ -z "$commit_info" ]; then
        commit_info="N/A | Direct copy / no git history"
      fi
      
      # Escape pipe characters to avoid breaking the markdown table
      escaped_desc=$(echo "$skill_desc" | sed 's/|/\\|/g')
      escaped_commit=$(echo "$commit_info" | sed 's/|/\\|/g')
      
      # Add a row to the table
      table_content+=$'\n'"| $index | \`$skill_slug\` | $escaped_desc | $escaped_commit |"
      
      index=$((index + 1))
    fi
  fi
done

# 4. Update the root README.md dynamically
README_PATH="README.md"
if [ ! -f "$README_PATH" ]; then
  echo "Error: README.md not found in the project root." >&2
  exit 1
fi

echo "Updating root README.md with the available skills catalog..." >&2

new_readme=""
in_skills_section=0

# Read README.md and replace the block between markers
while IFS= read -r line || [ -n "$line" ]; do
  if [[ "$line" == *"<!-- SKILLS_START -->"* ]]; then
    new_readme+="$line"$'\n'
    new_readme+="$table_content"$'\n'
    in_skills_section=1
    continue
  fi
  if [[ "$line" == *"<!-- SKILLS_END -->"* ]]; then
    in_skills_section=0
  fi
  
  if (( in_skills_section == 0 )); then
    new_readme+="$line"$'\n'
  fi
done < "$README_PATH"

# Write back to README.md (ensuring no trailing extra newline if new_readme is constructed)
echo -n "$new_readme" > "$README_PATH"

echo "=== Successfully updated root README.md with $((index - 1)) skills! ===" >&2
