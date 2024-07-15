#!/usr/bin/env bash

# Function to print error message and exit
function abort {
	echo "$1"
	exit 1
}

# Check if there are uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
	abort "Uncommitted changes found. Please commit your changes before updating."
fi

# Update flake inputs
echo "Updating flake inputs..."
sudo nix flake update || abort "Failed to update flake inputs."

# Run flake check
echo "Running flake check..."
flake_check_output=$(nix flake check 2>&1)

# Print any warnings from the check
if echo "$flake_check_output" | grep -i "warning"; then
	echo "Warnings found during flake check:"
	echo "$flake_check_output"
	abort "Please address the warnings before committing."
fi

# Stage the changes
git add flake.lock

# Commit the changes
git commit -m "task: flake update" || abort "Failed to commit changes."

# Push the changes
git push || abort "Failed to push changes."

echo "Flake update completed successfully."
