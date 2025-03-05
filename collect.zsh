#! /bin/zsh

# Define all copy operations as source:destination pairs
operations=(
    # Frontend files
    "../frontend/.cursorrules:frontend/.cursorrules"

    # Backend files
    "../backend/.cursorrules:backend/.cursorrules"

    # Oh-My-Zsh files
    "$HOME/.zshrc:omz/.zshrc"
    "$HOME/.oh-my-zsh/custom/aliases.zsh:omz/aliases.zsh"
    "$HOME/.oh-my-zsh/custom/functions.zsh:omz/functions.zsh"
)

# Process all operations in a single loop
for operation in "${operations[@]}"; do
    # Split the operation into source and destination
    source="${operation%%:*}"
    destination="${operation#*:}"

    # Extract the directory part of the destination
    dest_dir=$(dirname "$destination")

    # Create the destination directory if it doesn't exist
    if [ ! -d "$dest_dir" ]; then
        echo "Creating directory: $dest_dir"
        mkdir -p "$dest_dir"
    fi

    # Check if source file exists
    if [ -f "$source" ]; then
        echo "Copying $source to $destination"
        if cp "$source" "$destination"; then
            echo "✓ Successfully copied to $destination"
        else
            echo "✗ Failed to copy to $destination (error code: $?)"
        fi
    else
        echo "⚠️ Warning: Source file $source does not exist, skipping"
    fi
done

echo "✅ Collection complete!"
