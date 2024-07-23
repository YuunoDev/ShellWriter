#!/bin/bash
filename=$1

# Extract the base name
base="${filename%.*}"

# Extract the extension
ext="${filename##*.}"

# Create a temporary file
temp_file=$(mktemp tmp/$base.XXXXXX)

# Check if the file was created successfully
if [[ ! -z "$temp_file" ]]; then
  echo "Temporary file created: $temp_file"
else
  echo "Failed to create temporary file"
  exit 1
fi

# Use the temporary file for your operations
# For example, write some data to it
cat "$1" > "$temp_file"

# Display the contents of the temporary file
cat "$temp_file"

# Clean up by removing the temporary file
sleep 10
rm "$temp_file"
echo "Temporary file removed."