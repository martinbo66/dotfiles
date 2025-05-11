#!/usr/bin/env bash

# Exit on error, undefined variables, and prevent pipe errors from being masked
set -euo pipefail

# Files to ignore during installation
IGNORE_FILES=("install-dotfiles.sh" "README.md" "LICENSE" "dotfiles.sublime-project" "dotfiles.sublime-workspace")

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
GRAY='\033[1;30m'
NC='\033[0m' # No Color

# Logging function with colored output
# Usage: log "color" "message"
log() {
    local color=$1
    local message=$2
    local first_word=$(echo "$message" | cut -d' ' -f1)
    local rest_message=$(echo "$message" | cut -d' ' -f2-)
    printf "${!color}%-10s${NC} %s\n" "$first_word" "$rest_message"
}

# Ask user for confirmation
# Usage: ask "color" "question"
# Returns: 0 for yes/always, 1 for no/quit
ask() {
    local color=$1
    local question=$2
    
    printf "${!color}%-10s${NC} [yNaq]? " "$question"
    read -r answer
    
    case $answer in
        a) echo "always"; return 0 ;;
        y) echo "yes"; return 0 ;;
        q) exit 0 ;;
        *) echo "no"; return 1 ;;
    esac
}

# Check if git repository is up to date
check_git_status() {
    if git fetch origin >/dev/null 2>&1; then
        if ! git diff HEAD origin/main --quiet; then
            log "YELLOW" "warning Working copy is out of date; consider \`git pull\`"
        fi
    fi
}

# Install system packages using brew and defaults
install_packages() {
    check_git_status
    
    for installer in brew defaults; do
        log "BLUE" "executing bin/${installer}-install …"
        if [ -x "bin/${installer}-install" ]; then
            "bin/${installer}-install"
        else
            log "RED" "error bin/${installer}-install not found or not executable"
        fi
    done
}

# Process ERB templates
# Usage: process_erb_file "input_file" "output_file"
process_erb_file() {
    local input_file=$1
    local output_file=$2
    
    # Simple ERB-like template processing using envsubst
    # Note: This is a basic implementation. For complex ERB templates,
    # you might need to use Ruby or a more sophisticated template engine
    log "YELLOW" "generating $(basename "$output_file")"
    envsubst < "$input_file" > "$output_file"
}

# Create symbolic link for dotfile
# Usage: link_dotfile "source" "target" ["force"]
link_dotfile() {
    local source=$1
    local target=$2
    local force=${3:-false}
    
    # Create target directory if it doesn't exist
    local target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        log "BLUE" "mkdir $(basename "$target_dir")"
        mkdir -p "$target_dir"
    fi
    
    # Handle existing files/links
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ "$force" = true ]; then
            rm -rf "$target"
        else
            return 1
        fi
    fi
    
    log "BLUE" "linking $(basename "$source")"
    ln -s "$(realpath "$source")" "$target"
}

# Install dotfiles
install_dotfiles() {
    local always_replace=false
    
    # Process each file in the current directory
    find . -type f -not -path '*/\.*' | while read -r file; do
        # Skip ignored files
        filename=$(basename "$file")
        for ignore in "${IGNORE_FILES[@]}"; do
            [ "$filename" = "$ignore" ] && continue 2
        done
        
        # Remove leading ./
        file=${file#./}
        
        # Calculate target path
        target="$HOME/.${file}"
        if [[ $file == *.erb ]]; then
            target="$HOME/.${file%.erb}"
        fi
        
        # Check file status
        if [ -e "$target" ]; then
            if cmp -s "$file" "$target"; then
                log "GREEN" "identical $(basename "$target")"
                continue
            else
                if [ "$always_replace" = true ]; then
                    replace=true
                else
                    if ask "RED" "overwrite? $(basename "$target")"; then
                        [ "$REPLY" = "always" ] && always_replace=true
                        replace=true
                    else
                        log "GRAY" "skipping $(basename "$target")"
                        continue
                    fi
                fi
            fi
        fi
        
        # Process and link file
        if [[ $file == *.erb ]]; then
            process_erb_file "$file" "$target"
        else
            link_dotfile "$file" "$target" true
        fi
    done
}

# Main installation process
main() {
    check_git_status
    # install_packages
    install_dotfiles
}

# Run main function
main "$@"