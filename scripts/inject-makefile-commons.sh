#!/bin/bash
# Inject commons snippet into a project's Makefile
# Usage: ./inject-makefile-commons.sh <repo-path>
# Creates Makefile if it doesn't exist, or appends snippet if not already present

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SNIPPET_FILE="$SCRIPT_DIR/../templates/Makefile.commons.snippet"
REPO_PATH="$1"

if [ -z "$REPO_PATH" ]; then
    echo "Usage: $0 <repo-path>"
    exit 1
fi

if [ ! -f "$SNIPPET_FILE" ]; then
    echo "Error: Snippet file not found at $SNIPPET_FILE"
    exit 1
fi

MAKEFILE="$REPO_PATH/Makefile"
MARKER="# --- Commons from .github ---"

# Check if Makefile exists
if [ -f "$MAKEFILE" ]; then
    # Check if snippet already present
    if grep -q "$MARKER" "$MAKEFILE"; then
        echo -e "${YELLOW}● Makefile already has commons snippet${NC}"
    else
        # Append snippet to existing Makefile
        echo "" >> "$MAKEFILE"
        cat "$SNIPPET_FILE" >> "$MAKEFILE"
        echo -e "${GREEN}✓ Appended commons snippet to Makefile${NC}"
    fi
else
    # Create new Makefile with snippet
    cat > "$MAKEFILE" << 'HEADER'
.PHONY: help

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

HEADER
    cat "$SNIPPET_FILE" >> "$MAKEFILE"
    echo -e "${GREEN}✓ Created Makefile with commons snippet${NC}"
fi
