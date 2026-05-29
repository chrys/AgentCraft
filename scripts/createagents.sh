#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Default values
TARGET_PATH=""
TOOL_TYPE=""
SKILLS_ARG=""

# Helper function to print usage
print_usage() {
  echo "Usage: $0 [path] --tool <github-copilot|opencode> [--skills <indices-or-slugs>]" >&2
  echo "" >&2
  echo "Options:" >&2
  echo "  -p, --path PATH      Target project directory" >&2
  echo "  -t, --tool TOOL      Target tool style ('github-copilot' or 'opencode')" >&2
  echo "  -s, --skills SKILLS  Space/comma separated list of skill numbers or slugs" >&2
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

if [[ "$TOOL_TYPE" != "github-copilot" && "$TOOL_TYPE" != "opencode" ]]; then
  echo "Error: Invalid tool type '$TOOL_TYPE'. Must be 'github-copilot' or 'opencode'." >&2
  exit 1
fi

# Locate agent-skills directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$PROJECT_ROOT/agent-skills/skills"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "Error: Skills source directory '$SKILLS_DIR' not found." >&2
  exit 1
fi

# Load and sort available skill slugs alphabetically
ALL_SKILLS=()
# Standard alphabetical globbing
for skill_path in "$SKILLS_DIR"/*; do
  if [ -d "$skill_path" ]; then
    skill_slug=$(basename "$skill_path")
    if [ -f "$skill_path/SKILL.md" ]; then
      ALL_SKILLS+=("$skill_slug")
    fi
  fi
done

TOTAL_SKILLS=${#ALL_SKILLS[@]}
if [ $TOTAL_SKILLS -eq 0 ]; then
  echo "Error: No skills found under '$SKILLS_DIR'." >&2
  exit 1
fi

# Parse skills to copy
SELECTED_SLUGS=()

if [ -z "$SKILLS_ARG" ]; then
  # No skills specified, copy all of them
  SELECTED_SLUGS=("${ALL_SKILLS[@]}")
else
  # Replace commas with spaces to support comma-separated lists, then split
  SKILLS_ARG_CLEANED=$(echo "$SKILLS_ARG" | tr ',' ' ')
  
  for token in $SKILLS_ARG_CLEANED; do
    # Check if the token is an index number (1-based)
    if [[ "$token" =~ ^[0-9]+$ ]]; then
      index=$((token - 1)) # 0-indexed internally
      if [[ $index -ge 0 && $index -lt $TOTAL_SKILLS ]]; then
        SELECTED_SLUGS+=("${ALL_SKILLS[$index]}")
      else
        echo "Error: Invalid skill index '$token'. Must be between 1 and $TOTAL_SKILLS." >&2
        exit 1
      fi
    else
      # Check if the token matches a slug/folder name
      found=0
      for s in "${ALL_SKILLS[@]}"; do
        if [[ "$s" == "$token" ]]; then
          SELECTED_SLUGS+=("$s")
          found=1
          break
        fi
      done
      if [ $found -eq 0 ]; then
        echo "Error: Invalid skill slug '$token'. Refer to README.md for a list of valid slugs." >&2
        exit 1
      fi
    fi
  done
fi

# Create target path directory if it doesn't exist
mkdir -p "$TARGET_PATH"

echo "=== Provisioning Skills to Target Path: $TARGET_PATH ===" >&2
copied_count=0

for slug in "${SELECTED_SLUGS[@]}"; do
  source_file="$SKILLS_DIR/$slug/SKILL.md"
  
  if [ ! -f "$source_file" ]; then
    echo "Warning: Source file for skill '$slug' not found at '$source_file'. Skipping." >&2
    continue
  fi
  
  # Determine target destination directory based on tool selection
  if [[ "$TOOL_TYPE" == "github-copilot" ]]; then
    dest_dir="$TARGET_PATH/.github/skills/$slug"
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
