#!/bin/bash
# Sync shared configuration files to a repository
# Usage: ./sync-configs.sh <repo-path> [--force]
#        ./sync-configs.sh --all [--force]
# Example: ./sync-configs.sh ../certus-docs
#          ./sync-configs.sh --all
#          ./sync-configs.sh --all --force  # Overwrite existing files

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "$SCRIPT_DIR/../configs" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Parse flags
FORCE=false
ALL=false

for arg in "$@"; do
    case $arg in
        --all)
            ALL=true
            ;;
        --force)
            FORCE=true
            ;;
    esac
done

# Check if --all flag is provided
if [ "$ALL" = true ]; then
    echo -e "${GREEN}Syncing configs to all repositories in workspace...${NC}"
    echo ""
    
    TOTAL_SYNCED=0
    TOTAL_FAILED=0
    
    # Find all git repositories in workspace (excluding .github itself)
    for repo_dir in "$WORKSPACE_DIR"/*; do
        # Skip if not a directory
        [ -d "$repo_dir" ] || continue
        
        # Skip .github repo itself
        repo_name="$(basename "$repo_dir")"
        if [ "$repo_name" = ".github" ]; then
            continue
        fi
        
        # Skip if not a git repository
        if [ ! -d "$repo_dir/.git" ]; then
            echo -e "${YELLOW}⊘ Skipping: $repo_name (not a git repository)${NC}"
            continue
        fi
        
        echo -e "${GREEN}→ Syncing to: $repo_name${NC}"
        
        # Run sync for this repo (recursive call without --all)
        if [ "$FORCE" = true ]; then
            if "$0" "$repo_dir" --force; then
                TOTAL_SYNCED=$((TOTAL_SYNCED + 1))
            else
                TOTAL_FAILED=$((TOTAL_FAILED + 1))
            fi
        else
            if "$0" "$repo_dir"; then
                TOTAL_SYNCED=$((TOTAL_SYNCED + 1))
            else
                TOTAL_FAILED=$((TOTAL_FAILED + 1))
            fi
        fi
        echo ""
    done
    
    echo "================================"
    echo -e "${GREEN}Summary: $TOTAL_SYNCED repo(s) synced${NC}"
    if [ $TOTAL_FAILED -gt 0 ]; then
        echo -e "${RED}Failed: $TOTAL_FAILED repo(s)${NC}"
    fi
    
    # Also sync to .github repo root itself
    echo ""
    echo -e "${GREEN}→ Syncing to .github repo root${NC}"
    GITHUB_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    
    GITHUB_COPIED=0
    GITHUB_SKIPPED=0
    
    shopt -s nullglob dotglob
    for SOURCE in "$CONFIG_DIR"/*; do
        [ -f "$SOURCE" ] || continue
        file="$(basename "$SOURCE")"
        if [ "$file" = "." ] || [ "$file" = ".." ]; then
            continue
        fi
        
        TARGET="$GITHUB_ROOT/$file"
        
        if [ -f "$TARGET" ]; then
            if [ "$FORCE" = true ]; then
                cp "$SOURCE" "$TARGET"
                echo -e "${GREEN}✓ Overwritten: $file${NC}"
                GITHUB_COPIED=$((GITHUB_COPIED + 1))
            else
                # Check if files are different
                if ! cmp -s "$SOURCE" "$TARGET"; then
                    echo -e "${YELLOW}⚠ Modified: $file (keeping existing, use --force to overwrite)${NC}"
                    GITHUB_SKIPPED=$((GITHUB_SKIPPED + 1))
                else
                    echo -e "${GREEN}✓ Up to date: $file${NC}"
                fi
            fi
        else
            cp "$SOURCE" "$TARGET"
            echo -e "${GREEN}✓ Copied: $file${NC}"
            GITHUB_COPIED=$((GITHUB_COPIED + 1))
        fi
    done
    
    echo ""
    echo "================================"
    echo -e "${GREEN}Total repos synced: $TOTAL_SYNCED${NC}"
    echo -e "${GREEN}.github repo: $GITHUB_COPIED copied/updated, $GITHUB_SKIPPED skipped${NC}"
    if [ $TOTAL_FAILED -gt 0 ]; then
        echo -e "${RED}Failed: $TOTAL_FAILED repo(s)${NC}"
    fi
    
    exit 0
fi

# Get repo path (first non-flag argument)
REPO_PATH=""
for arg in "$@"; do
    if [[ ! "$arg" =~ ^-- ]]; then
        REPO_PATH="$arg"
        break
    fi
done

# Check if repo path is provided
if [ -z "$REPO_PATH" ]; then
    echo -e "${RED}Error: Repository path required${NC}"
    echo "Usage: $0 <repo-path> [--force]"
    echo "       $0 --all [--force]"
    echo "Example: $0 ../certus-docs"
    echo "         $0 --all --force"
    exit 1
fi

# Check if target directory exists
if [ ! -d "$REPO_PATH" ]; then
    echo -e "${RED}Error: Directory '$REPO_PATH' does not exist${NC}"
    exit 1
fi

# Check if target is a git repository
if [ ! -d "$REPO_PATH/.git" ]; then
    echo -e "${YELLOW}Warning: '$REPO_PATH' is not a git repository${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${GREEN}Syncing configs to: $REPO_PATH${NC}"
echo "---"

# Copy each config file (automatically finds all files in configs/)
COPIED=0
SKIPPED=0

# Loop through all files in the configs directory
# First, enable nullglob to handle cases where patterns don't match
shopt -s nullglob dotglob

for SOURCE in "$CONFIG_DIR"/*; do
    # Skip if it's a directory or doesn't exist
    [ -f "$SOURCE" ] || continue
    
    # Get just the filename
    file="$(basename "$SOURCE")"
    
    # Skip . and .. entries
    if [ "$file" = "." ] || [ "$file" = ".." ]; then
        continue
    fi
    
    TARGET="$REPO_PATH/$file"
    
    if [ -f "$TARGET" ]; then
        if [ "$FORCE" = true ]; then
            cp "$SOURCE" "$TARGET"
            echo -e "${GREEN}✓ Overwritten: $file${NC}"
            COPIED=$((COPIED + 1))
        else
            echo -e "${YELLOW}⚠ Exists: $file (keeping existing)${NC}"
            echo "  To overwrite, use --force or delete it first: rm $TARGET"
            SKIPPED=$((SKIPPED + 1))
        fi
        continue
    fi
    
    cp "$SOURCE" "$TARGET"
    echo -e "${GREEN}✓ Copied: $file${NC}"
    COPIED=$((COPIED + 1))
done

echo "---"
echo -e "${GREEN}Done! Copied: $COPIED, Skipped: $SKIPPED${NC}"
echo ""
echo "Next steps:"
echo "  cd $REPO_PATH"
echo "  git status        # Review changes"
echo "  git add .         # Stage new files"
echo "  git commit -m 'Add shared config files'"

