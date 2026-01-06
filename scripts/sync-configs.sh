#!/bin/bash
# Sync shared configuration files to a repository
# Usage: ./sync-configs.sh <repo-path>
# Example: ./sync-configs.sh ../certus-docs

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "$SCRIPT_DIR/../configs" && pwd)"

# Check if repo path is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Repository path required${NC}"
    echo "Usage: $0 <repo-path>"
    echo "Example: $0 ../certus-docs"
    exit 1
fi

REPO_PATH="$1"

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
for SOURCE in "$CONFIG_DIR"/{.*,*}; do
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
        echo -e "${YELLOW}⚠ Exists: $file (keeping existing)${NC}"
        echo "  To overwrite, delete it first: rm $TARGET"
        ((SKIPPED++))
        continue
    fi
    
    cp "$SOURCE" "$TARGET"
    echo -e "${GREEN}✓ Copied: $file${NC}"
    ((COPIED++))
done

echo "---"
echo -e "${GREEN}Done! Copied: $COPIED, Skipped: $SKIPPED${NC}"
echo ""
echo "Next steps:"
echo "  cd $REPO_PATH"
echo "  git status        # Review changes"
echo "  git add .         # Stage new files"
echo "  git commit -m 'Add shared config files'"

