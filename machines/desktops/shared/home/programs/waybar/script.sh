#!/usr/bin/env bash

# Function to convert JSON to Nix format
json_to_nix() {
    jq -r '
        # Convert JSON to a string with some Nix-like formatting
        tostring

        # Replace colons and commas with equal signs and semicolons
        | gsub(":"; "=")
        | gsub(","; ";")
				| gsub("};"; ";};")

        # Handle arrays (this part might need refinement based on your specific use cases)
        | gsub("\\{\n\\s+\"\\*\": "; "{\n\"*\"= ")

        # Replace double quotes around keys
        | gsub("\"([a-zA-Z0-9_-]+)\": "; "\\1= ")

        # Handle special comment case
        | gsub("//"; "#")
    ' <<< "$1"
}

# Function to remove comments from JSON
remove_comments() {
    # Remove lines with optional leading whitespace followed by //
    sed -E '/^[[:space:]]*\/\//d' <<< "$1"
}

# Read JSON from a file
input_json=$(cat "$1")

# Remove comments
clean_json=$(remove_comments "$input_json")

# Convert and print the result
converted_nix=$(json_to_nix "$clean_json")
echo "$converted_nix"
