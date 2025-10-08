#!/usr/bin/env bash

# Script to parse build logs and create issue templates for GitHub Action
# 
# This script processes JSONL build logs from nix flake check and creates
# markdown templates for each error (level 0) or warning (level 1) found.
# These templates are used by the create-an-issue GitHub Action.
# 
# Usage: create-issues-from-build-log.sh <build-log.jsonl> <output-dir>
#
# Features:
# - Filters build log for errors (level 0) and warnings (level 1)
# - Avoids duplicate issues in the same run using MD5 hashing
# - Creates individual markdown files for each issue
# - Issues are assigned to @copilot for automated fixing
#
# Requirements:
# - jq: for parsing JSONL build logs (provided via nix shell)

set -euo pipefail

BUILD_LOG="${1:-}"
OUTPUT_DIR="${2:-.github/ISSUE_TEMPLATES}"

# Check if build log file is provided
if [ -z "$BUILD_LOG" ]; then
	echo "Usage: $0 <build-log.jsonl> [output-dir]"
	exit 1
fi

if [ ! -f "$BUILD_LOG" ]; then
	echo "Error: Build log file '$BUILD_LOG' not found"
	exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
	echo "Error: jq is not installed. Run this script via: nix shell nixpkgs#jq -c bash $0 <build-log.jsonl>"
	exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Extract errors and warnings from build log
# level 0 = errors, level 1 = warnings
ISSUES=$(jq -r 'select(.level <= 1 and .action == "msg") | "\(.level)|\(.msg)"' "$BUILD_LOG")

if [ -z "$ISSUES" ]; then
	echo "No errors or warnings found in build log"
	exit 0
fi

# Track created issues to avoid duplicates in the same run
declare -A CREATED_ISSUES
ISSUE_COUNT=0

# Process each issue
while IFS='|' read -r level msg; do
	# Determine issue type and label
	if [ "$level" -eq 0 ]; then
		ISSUE_TYPE="error"
		LABEL="bug"
	else
		ISSUE_TYPE="warning"
		LABEL="warning"
	fi

	# Create a hash of the message to detect duplicates
	MSG_HASH=$(echo "$msg" | md5sum | cut -d' ' -f1)
	
	# Skip if we already added this issue
	if [ -n "${CREATED_ISSUES[$MSG_HASH]:-}" ]; then
		echo "Skipping duplicate issue: $msg"
		continue
	fi
	
	ISSUE_COUNT=$((ISSUE_COUNT + 1))
	CREATED_ISSUES[$MSG_HASH]="1"
	
	# Create issue template file for create-an-issue action
	ISSUE_FILE="$OUTPUT_DIR/build-issue-${MSG_HASH:0:8}.md"
	
	cat > "$ISSUE_FILE" << EOF
---
title: "[$ISSUE_TYPE] $msg"
labels: $LABEL, automated
assignees: copilot
---

## Build $ISSUE_TYPE

This issue was automatically created from a flake check build log.

**Type**: $ISSUE_TYPE (level $level)

**Message**:
\`\`\`
$msg
\`\`\`

## Instructions for @copilot

Please analyze and fix this $ISSUE_TYPE. 

**Important**: Make all code changes to the base branch of the flake.lock update PR, not directly to any automated PR. Ensure changes are committed to the correct branch that the dependency update PR is based on.

---
*Auto-generated from flake-check workflow*
EOF

	echo "Created issue template: $ISSUE_FILE"
	
done <<< "$ISSUES"

echo "Created $ISSUE_COUNT issue template(s) in $OUTPUT_DIR"
