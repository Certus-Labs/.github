#!/bin/bash
# Sync shared AI rules (.ruler/) to a repository
# Usage: ./sync-ruler.sh <repo-path> [--force]
#        ./sync-ruler.sh --all [--force]
# Example: ./sync-ruler.sh ../showcase-a-batch
#          ./sync-ruler.sh --all
#          ./sync-ruler.sh --all --force  # Overwrite existing shared files
#
# Note: Only syncs shared files (10-*.md, 11-*.md, etc.)
#       Never touches project-specific files (00-*.md to 09-*.md)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULER_DIR="$(cd "$SCRIPT_DIR/../.ruler" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATES_DIR="$RULER_DIR/templates"

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

# Function to sync ruler files to a single repo
sync_ruler_to_repo() {
    local REPO_PATH="$1"
    local FORCE_FLAG="$2"
    local repo_name="$(basename "$REPO_PATH")"
    
    # Create .ruler directory if it doesn't exist
    if [ ! -d "$REPO_PATH/.ruler" ]; then
        mkdir -p "$REPO_PATH/.ruler"
        echo -e "${GREEN}✓ Created: .ruler/${NC}"
    fi
    
    local COPIED=0
    local SKIPPED=0
    local PROTECTED=0
    
    # Enable nullglob
    shopt -s nullglob
    
    # Sync shared files (10-*.md and above)
    for SOURCE in "$RULER_DIR"/[1-9][0-9]-*.md; do
        [ -f "$SOURCE" ] || continue
        
        file="$(basename "$SOURCE")"
        TARGET="$REPO_PATH/.ruler/$file"
        
        if [ -f "$TARGET" ]; then
            if [ "$FORCE_FLAG" = true ]; then
                cp "$SOURCE" "$TARGET"
                echo -e "${GREEN}✓ Overwritten: $file${NC}"
                COPIED=$((COPIED + 1))
            else
                # Check if files are different
                if ! cmp -s "$SOURCE" "$TARGET"; then
                    echo -e "${YELLOW}⚠ Modified: $file (keeping existing, use --force to overwrite)${NC}"
                    SKIPPED=$((SKIPPED + 1))
                else
                    echo -e "${GREEN}✓ Up to date: $file${NC}"
                fi
            fi
        else
            cp "$SOURCE" "$TARGET"
            echo -e "${GREEN}✓ Copied: $file${NC}"
            COPIED=$((COPIED + 1))
        fi
    done
    
    # Check for project-specific files (00-09) - never touch them
    for EXISTING in "$REPO_PATH/.ruler"/0[0-9]-*.md; do
        [ -f "$EXISTING" ] || continue
        file="$(basename "$EXISTING")"
        echo -e "${BLUE}● Protected: $file (project-specific)${NC}"
        PROTECTED=$((PROTECTED + 1))
    done
    
    # Copy ruler.toml template if it doesn't exist
    if [ ! -f "$REPO_PATH/.ruler/ruler.toml" ]; then
        if [ -f "$TEMPLATES_DIR/ruler.toml.template" ]; then
            cp "$TEMPLATES_DIR/ruler.toml.template" "$REPO_PATH/.ruler/ruler.toml"
            echo -e "${GREEN}✓ Created: ruler.toml (from template)${NC}"
            COPIED=$((COPIED + 1))
        fi
    else
        echo -e "${BLUE}● Exists: ruler.toml${NC}"
    fi
    
    # Create 00-project.md from template if it doesn't exist
    if [ ! -f "$REPO_PATH/.ruler/00-project.md" ]; then
        if [ -f "$TEMPLATES_DIR/00-project.md.template" ]; then
            cp "$TEMPLATES_DIR/00-project.md.template" "$REPO_PATH/.ruler/00-project.md"
            echo -e "${GREEN}✓ Created: 00-project.md (from template - please customize!)${NC}"
            COPIED=$((COPIED + 1))
        fi
    fi
    
    # Inject Makefile commons snippet
    "$SCRIPT_DIR/inject-makefile-commons.sh" "$REPO_PATH"
    
    echo "---"
    echo -e "${GREEN}Done! Copied: $COPIED, Skipped: $SKIPPED, Protected: $PROTECTED${NC}"
}

# Check if --all flag is provided
if [ "$ALL" = true ]; then
    echo -e "${GREEN}Syncing .ruler/ to all repositories in workspace...${NC}"
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
        
        if sync_ruler_to_repo "$repo_dir" "$FORCE"; then
            TOTAL_SYNCED=$((TOTAL_SYNCED + 1))
        else
            TOTAL_FAILED=$((TOTAL_FAILED + 1))
        fi
        echo ""
    done
    
    echo "================================"
    echo -e "${GREEN}Summary: $TOTAL_SYNCED repo(s) synced${NC}"
    if [ $TOTAL_FAILED -gt 0 ]; then
        echo -e "${RED}Failed: $TOTAL_FAILED repo(s)${NC}"
    fi
    echo ""
    echo "Next steps:"
    echo "  1. Review and customize 00-project.md in each repo"
    echo "  2. Run 'make ruler' in each repo to generate AGENTS.md"
    echo "  3. Generated files are auto-gitignored by Ruler"
    
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
    echo ""
    echo "Examples:"
    echo "  $0 ../showcase-a-batch"
    echo "  $0 --all --force"
    echo ""
    echo "Note: Only syncs shared files (10-*.md and above)"
    echo "      Never touches project-specific files (00-09)"
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

echo -e "${GREEN}Syncing .ruler/ to: $REPO_PATH${NC}"
echo "---"

sync_ruler_to_repo "$REPO_PATH" "$FORCE"

echo ""
echo "Next steps:"
echo "  cd $REPO_PATH"
echo "  # Customize .ruler/00-project.md with project-specific context"
echo "  make ruler                      # Generate AGENTS.md"
echo "  git status                      # Review changes"
echo "  git add .ruler/                 # Stage ruler files"
echo "  git commit -m 'Add/update AI rules'"
