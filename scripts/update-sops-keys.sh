#!/usr/bin/env bash

# Exit on error
set -euo pipefail

# Function to print in color
print_info() {
	echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_error() {
	echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

# Check if sops is installed
if ! command -v sops &>/dev/null; then
	print_error "sops is not installed. Please install it first."
	exit 1
fi

# Function to check if a file matches any pattern in .sops.yaml
matches_sops_pattern() {
	local file="$1"
	# Extract the pattern from .sops.yaml
	local pattern=$(grep "path_regex:" .sops.yaml | sed 's/.*path_regex: //' | tr -d '"' | tr -d "'")

	if [[ -z "$pattern" ]]; then
		print_error "No path_regex pattern found in .sops.yaml"
		exit 1
	fi

	if echo "$file" | grep -E "$pattern"; then
		return 0
	else
		return 1
	fi
}

# Find .sops.yaml
if [[ ! -f ".sops.yaml" ]]; then
	print_error "No .sops.yaml file found in the current directory"
	exit 1
fi

# Counter for processed files
processed=0
updated=0

# Find all potential SOPS files
while IFS= read -r -d '' file; do
	if matches_sops_pattern "$file"; then
		((processed++))
		print_info "Updating keys for: $file"
		if sops updatekeys "$file"; then
			((updated++))
			print_info "Successfully updated keys for: $file"
		else
			print_error "Failed to update keys for: $file"
		fi
	fi
done < <(find . -type f -print0)

print_info "Summary: Processed $processed files, successfully updated $updated files"
