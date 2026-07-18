#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Synchronizing Agent Skills & Updating Documentation ===" >&2

# Get the directory of this script (scripts/) and navigate to the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# 1. Parse sources.txt
SOURCES_FILE="sources.txt"
if [ ! -f "$SOURCES_FILE" ]; then
  echo "Error: '$SOURCES_FILE' not found in the project root." >&2
  exit 1
fi

declare -a SOURCE_NAMES
declare -a SOURCE_PATHS
declare -a SOURCE_URLS
declare -a SOURCE_BRANCHES
declare -a SOURCE_REL_PATHS

while IFS='|' read -r name rpath url branch rel_path || [ -n "$name" ]; do
  # Trim comments and empty lines
  if [[ "$name" =~ ^[[:space:]]*# ]] || [[ -z "${name//[[:space:]]/}" ]]; then
    continue
  fi
  
  # Trim whitespace using sed
  name=$(echo "$name" | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//')
  rpath=$(echo "$rpath" | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//')
  url=$(echo "$url" | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//')
  branch=$(echo "$branch" | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//')
  rel_path=$(echo "$rel_path" | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//')

  SOURCE_NAMES+=("$name")
  SOURCE_PATHS+=("$rpath")
  SOURCE_URLS+=("$url")
  SOURCE_BRANCHES+=("$branch")
  SOURCE_REL_PATHS+=("$rel_path")
done < "$SOURCES_FILE"

# 2. Sync all sources
for i in "${!SOURCE_NAMES[@]}"; do
  name="${SOURCE_NAMES[$i]}"
  rpath="${SOURCE_PATHS[$i]}"
  url="${SOURCE_URLS[$i]}"
  branch="${SOURCE_BRANCHES[$i]}"
  
  FULL_REPO_PATH="$PROJECT_ROOT/repos/$rpath"
  
  if [ ! -d "$FULL_REPO_PATH" ]; then
    echo "Cloning latest updates for $name into $rpath..." >&2
    mkdir -p "$(dirname "$FULL_REPO_PATH")"
    git clone -b "$branch" "$url" "$FULL_REPO_PATH" >/dev/null 2>&1 || echo "Warning: git clone failed for $name. Proceeding with existing local state." >&2
  else
    echo "Fetching latest updates for $name..." >&2
    cd "$FULL_REPO_PATH"
    if [ -e ".git" ]; then
      git fetch origin "$branch" >/dev/null 2>&1 || echo "Warning: git fetch failed for $name. Proceeding with local version." >&2
      git pull origin "$branch" >/dev/null 2>&1 || echo "Warning: git pull failed for $name. Proceeding with local version." >&2
    else
      echo "Notice: $rpath is not a Git repository. Skipping git pull." >&2
    fi
    cd "$PROJECT_ROOT"
  fi

  # Update sync-state.txt for this repo
  SYNC_STATE_FILE="$PROJECT_ROOT/sync-state.txt"
  touch "$SYNC_STATE_FILE"
  temp_state=$(mktemp)
  if [ -f "$SYNC_STATE_FILE" ]; then
    grep -v "^${name}:" "$SYNC_STATE_FILE" > "$temp_state" || true
  fi
  echo "${name}: $(date +"%Y-%m-%d %H:%M:%S")" >> "$temp_state"
  mv "$temp_state" "$SYNC_STATE_FILE"
done

# 3. Read and parse skills across all repositories
skills_data=""

for i in "${!SOURCE_NAMES[@]}"; do
  name="${SOURCE_NAMES[$i]}"
  rpath="${SOURCE_PATHS[$i]}"
  rel_path="${SOURCE_REL_PATHS[$i]}"
  
  FULL_REPO_PATH="$PROJECT_ROOT/repos/$rpath"
  FULL_SKILLS_DIR="$FULL_REPO_PATH/$rel_path"
  
  if [ -d "$FULL_SKILLS_DIR" ]; then
    echo "Parsing skills from $name ($FULL_SKILLS_DIR)..." >&2
    while IFS= read -r skill_file; do
      if [ -z "$skill_file" ]; then
        continue
      fi
      skill_path=$(dirname "$skill_file")
      skill_slug=$(basename "$skill_path")
      
      # Extract name and description from the SKILL.md file
      skill_name=$(grep -E "^name:" "$skill_file" | head -n 1 | sed -E 's/^name:[[:space:]]*//' | tr -d '\r' || true)
      skill_desc=$(grep -E "^description:" "$skill_file" | head -n 1 | sed -E 's/^description:[[:space:]]*//' | tr -d '\r' || true)
      
      if [ -z "$skill_name" ]; then
        skill_name="$skill_slug"
      fi
      if [ -z "$skill_desc" ]; then
        skill_desc="*No description available in SKILL.md*"
      fi
      
      # Query latest Git commit
      commit_info=""
      if [ -e "$FULL_REPO_PATH/.git" ]; then
        cd "$FULL_REPO_PATH"
        # Find relative path of the skill directory from the git repo root
        rel_skill_dir="${skill_path#$FULL_REPO_PATH/}"
        commit_info=$(git log -n 1 --format="%ad | %s" --date=format:"%Y-%m-%d" -- "$rel_skill_dir" 2>/dev/null || true)
        cd "$PROJECT_ROOT"
      fi
      
      if [ -z "$commit_info" ]; then
        commit_info="N/A | Direct copy / no git history"
      fi
      
      # Escape pipe characters to avoid breaking the markdown table
      escaped_desc=$(echo "$skill_desc" | sed 's/|/\\|/g')
      escaped_commit=$(echo "$commit_info" | sed 's/|/\\|/g')
      
      # Append to raw collection: slug ::: repo ::: name ::: desc ::: commit
      skills_data+="${skill_slug}:::${name}:::${skill_name}:::${escaped_desc}:::${escaped_commit}"$'\n'
    done < <(find "$FULL_SKILLS_DIR" -type f -name "SKILL.md" 2>/dev/null)
  fi
done

# Build the markdown table
table_content="| # | Repository | Skill Slug | Description | Latest Update |"$'\n'
table_content+="|---|------------|------------|-------------|---------------|"

index=1
if [ -n "$skills_data" ]; then
  # Sort alphabetically (case-insensitive) by skill slug
  sorted_skills=$(echo -n "$skills_data" | sort -f -t: -k1)
  
  while IFS= read -r line || [ -n "$line" ]; do
    if [ -z "$line" ]; then
      continue
    fi
    
    # Translate delimiter to tab for reading
    line_tabbed=$(echo "$line" | sed 's/:::/	/g')
    
    IFS=$'\t' read -r s_slug r_name s_name s_desc s_commit <<< "$line_tabbed"
    
    table_content+=$'\n'"| $index | \`$r_name\` | \`$s_slug\` | $s_desc | $s_commit |"
    index=$((index + 1))
  done <<< "$sorted_skills"
fi

# 4. Update the root README.md dynamically
README_PATH="README.md"
if [ ! -f "$README_PATH" ]; then
  echo "Error: README.md not found in the project root." >&2
  exit 1
fi

echo "Updating root README.md with the available skills catalog..." >&2

new_readme=""
in_skills_section=0

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

echo -n "$new_readme" > "$README_PATH"

echo "=== Successfully updated root README.md with $((index - 1)) skills! ===" >&2
