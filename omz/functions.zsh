## Actvo functions
function ashow() {
    # Default to 1 if no argument provided
    local migration_number=${1:-1}

    # Validate that the argument is a positive integer
    if [[ ! $migration_number =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Argument must be a positive integer"
        return 1
    fi

    # Get the migration history and extract the specific line - filter out INFO logs
    local migration_line=$(alembic history --indicate-current | head -n $migration_number | tail -n 1)

    # Check if we found a migration
    if [[ -z "$migration_line" ]]; then
        echo "Error: No migration found at position $migration_number"
        return 1
    fi

    # Parse the down and up revision hashes
    local down_rev=$(echo $migration_line | awk -F ' -> ' '{print $1}')
    local up_rev=$(echo $migration_line | awk -F ' -> ' '{print $2}' | awk '{print $1}' | sed 's/(head)//' | sed 's/(current)//' | sed 's/,//')

    # Show the migration being displayed
    echo "Showing SQL for migration: $migration_line"
    echo "Command: alembic upgrade $down_rev:$up_rev --sql"
    echo "---------------------------------------------------"

    # Run the alembic command to show the SQL - filter out INFO logs
    alembic upgrade $down_rev:$up_rev --sql
}


## Git functions
function get_default_branch() {
    local default_branch=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')
    if [[ -z $default_branch ]]; then
        echo "Error: Could not determine default branch name" >&2
        echo "Tip: Ensure you have a remote named 'origin' configured" >&2
        return 1
    fi
    echo "$default_branch"
}


function get_current_branch() {
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo "Error: You have uncommitted changes. Please commit or stash them first."
        return 1
    fi

    echo "$(git branch --show-current)"
}

function gsm() {
    # Get the default branch name
    local default_branch=$(get_default_branch) || return 1
    local current_branch=$(get_current_branch) || return 1

    # Check if we're already on the default branch
    if [[ "$current_branch" == "$default_branch" ]]; then
        echo "Already on default branch '$default_branch'"
        return 0
    fi

    echo "Switching to default branch '$default_branch'..."
    if git switch "$default_branch"; then
        echo "✨ Successfully switched to '$default_branch'"
    else
        echo "Error: Failed to switch to '$default_branch'"
        return 1
    fi
}


function gitup() {
    # Get the default branch name
    local default_branch=$(get_default_branch) || return 1
    local current_branch=$(get_current_branch) || return 1

    # Check if we're already on the default branch
    if [[ "$current_branch" == "$default_branch" ]]; then
        echo "Already on default branch '$default_branch'"
        return 0
    fi

    echo "📦 Updating $default_branch branch and rebasing $current_branch..."

    # Switch to main and update it
    git rebase "$default_branch" || return 1
    git pull --rebase || return 1

    # Switch back to feature branch and rebase
    git switch "$current_branch" || return 1
    git rebase "$default_branch" || return 1

    echo "✨ Done! Branch '$current_branch' is now up to date with $default_branch"
}
