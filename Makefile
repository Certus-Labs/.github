.PHONY: help ruler-sync-all configs-sync-all sync-all

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

ruler-sync-all: ## Sync AI rules to all repos in workspace
	./scripts/sync-ruler.sh --all --force

configs-sync-all: ## Sync config files to all repos in workspace
	./scripts/sync-configs.sh --all --force

sync-all: configs-sync-all ruler-sync-all ## Sync everything (configs + AI rules) to all repos
	@echo "All repos synced!"
