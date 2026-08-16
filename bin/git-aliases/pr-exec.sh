#!/usr/bin/env bash
set -eo pipefail

# Find repo root from current working directory, not script location
REPO_ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$REPO_ROOT_DIR" ]; then
    ERROR "Not in a git repository. Please run this script from within the repository."
    exit 1
fi

function INFO() {
    echo -e "\033[0;32mINFO:\033[0m $1"
}

function WARN() {
    echo -e "\033[0;33mWARN:\033[0m $1"
}

function ERROR() {
    echo -e "\033[0;31mERROR:\033[0m $1"
}

# Check if command is provided
if [ $# -eq 0 ]; then
    ERROR "Usage: $0 <command> [args...]"
    ERROR "Example: $0 bazel build :lib"
    ERROR "Example: $0 rushx test"
    exit 1
fi

# Get changed files from PR
INFO "Getting changed files from PR..."
CHANGED_FILES=$(gh pr diff --name-only 2>/dev/null || {
    ERROR "Failed to get PR diff. Make sure you're in a PR branch and 'gh' CLI is installed."
    exit 1
})

if [ -z "$CHANGED_FILES" ]; then
    WARN "No changed files found in PR."
    exit 0
fi

# Function to find the Bazel package directory for a file
# Walks up the directory tree to find the nearest BUILD.bazel file
find_package_dir() {
    local file_path="$1"
    local file_dir=$(dirname "$file_path")
    
    # Handle root-level files
    if [ "$file_dir" = "." ]; then
        file_dir=""
    fi
    
    local current_dir="$REPO_ROOT_DIR"
    if [ -n "$file_dir" ]; then
        current_dir="$REPO_ROOT_DIR/$file_dir"
    fi
    
    # Walk up the directory tree, including repo root
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/BUILD.bazel" ] || [ -f "$current_dir/BUILD" ]; then
            # Return relative path from repo root
            if [ "$current_dir" = "$REPO_ROOT_DIR" ]; then
                echo "."
            else
                echo "${current_dir#$REPO_ROOT_DIR/}"
            fi
            return 0
        fi
        
        # Stop if we've reached the repo root
        if [ "$current_dir" = "$REPO_ROOT_DIR" ]; then
            break
        fi
        
        current_dir=$(dirname "$current_dir")
    done
    
    return 1
}

# Collect unique package directories (without associative arrays for bash 3 compatibility)
PACKAGE_DIRS=()
PACKAGE_COUNT=0

# Function to check if a package directory is already in the array
package_exists() {
    local pkg="$1"
    local existing
    for existing in "${PACKAGE_DIRS[@]}"; do
        if [ "$existing" = "$pkg" ]; then
            return 0
        fi
    done
    return 1
}

INFO "Mapping changed files to Bazel packages..."
while IFS= read -r file; do
    # Skip empty lines
    [ -z "$file" ] && continue
    
    # Skip deleted files (they won't have a BUILD.bazel to find)
    if [ ! -f "$REPO_ROOT_DIR/$file" ]; then
        continue
    fi
    
    package_dir=$(find_package_dir "$file")
    if [ $? -eq 0 ] && [ -n "$package_dir" ]; then
        if ! package_exists "$package_dir"; then
            PACKAGE_DIRS+=("$package_dir")
            PACKAGE_COUNT=$((PACKAGE_COUNT + 1))
        fi
    fi
done <<< "$CHANGED_FILES"

if [ $PACKAGE_COUNT -eq 0 ]; then
    WARN "No Bazel packages found for changed files."
    exit 0
fi

INFO "Found $PACKAGE_COUNT unique package(s):"
for pkg_dir in "${PACKAGE_DIRS[@]}"; do
    echo "  - $pkg_dir"
done

# Run command in each package sequentially
COMMAND="$*"
FAILED_PACKAGES=()
SUCCESS_COUNT=0

INFO "Running command in each package..."
for pkg_dir in "${PACKAGE_DIRS[@]}"; do
    INFO "Processing package: $pkg_dir"
    
    # Run command in subshell with error handling disabled to allow continuation
    set +e
    (
        cd "$REPO_ROOT_DIR/$pkg_dir" || exit 1
        eval "$COMMAND"
    )
    CMD_EXIT_CODE=$?
    set -e
    
    if [ $CMD_EXIT_CODE -eq 0 ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        INFO "✓ Successfully ran command in $pkg_dir"
    else
        FAILED_PACKAGES+=("$pkg_dir")
        WARN "✗ Command failed in $pkg_dir (exit code: $CMD_EXIT_CODE) - continuing..."
    fi
done

# Summary
echo ""
if [ ${#FAILED_PACKAGES[@]} -eq 0 ]; then
    INFO "All commands completed successfully in $SUCCESS_COUNT package(s)."
    exit 0
else
    ERROR "Command failed in ${#FAILED_PACKAGES[@]} package(s):"
    for pkg in "${FAILED_PACKAGES[@]}"; do
        echo "  - $pkg"
    done
    exit 1
fi

