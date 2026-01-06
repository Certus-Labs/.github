# Certus Labs Organization Configuration

This repository contains shared configurations and community health files for all Certus Labs repositories.

## 📁 Structure

```tree
.github/
├── configs/              # Shared configuration files
│   ├── .cursorrules     # Cursor IDE rules for AI assistance
│   └── .markdownlint.json  # Markdown linting rules
├── scripts/
│   └── sync-configs.sh  # Script to sync configs to repositories
├── CONTRIBUTING.md      # (Optional) Auto-applied to all repos
├── CODE_OF_CONDUCT.md   # (Optional) Auto-applied to all repos
└── profile/
    └── README.md        # (Optional) Shows on organization page
```

## 🎯 Purpose

### Automatic Distribution (GitHub Native)

Files at the root like `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, etc. are automatically shown in all organization repositories that don't have their own version.

**Supported files**: [See GitHub Docs](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file)

### Manual Sync (Custom Configs)

Custom configuration files in `configs/` need to be manually synced to each repository using the provided script.

## 🚀 Usage

### Adding Configs to a New Repository

1. Navigate to your repository:

   ```bash
   cd /path/to/your/repo
   ```

2. Run the sync script from anywhere:

   ```bash
   /path/to/.github/scripts/sync-configs.sh .
   ```

   Or if you're in the workspace:

   ```bash
   ../.github/scripts/sync-configs.sh .
   ```

3. Review and commit:

   ```bash
   git status
   git add .cursorrules .markdownlint.json
   git commit -m "Add shared config files"
   git push
   ```

### Adding a New Config File

1. Add your config file to `configs/`:

   ```bash
   cd .github/configs
   cp /path/to/new/.prettierrc .
   git add .prettierrc
   git commit -m "Add Prettier configuration"
   git push
   ```

2. Sync to existing repositories:

   ```bash
   cd .github/scripts
   ./sync-configs.sh ../../repo-name
   ```

### Updating Existing Configs

1. Update the file in `configs/`:

   ```bash
   cd .github/configs
   # Edit the file
   git add .
   git commit -m "Update config: description of change"
   git push
   ```

2. Sync to repositories (the script will skip existing files):

   ```bash
   # To overwrite, delete the old file first in the target repo
   rm /path/to/repo/.cursorrules
   ./sync-configs.sh /path/to/repo
   ```

## 📝 Available Configurations

### `.cursorrules`

Rules and guidelines for Cursor AI assistant when working in Certus Labs repositories.

### `.markdownlint.json`

Markdown linting configuration for consistent documentation formatting.

## 🔄 Workflow

```txt
1. Add/update config in .github/configs/
2. Commit and push to .github repo
3. Run sync script for each repository that needs it
4. Commit synced files in target repository
```

## 📚 Resources

- [GitHub Default Community Health Files](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file)
- [Cursor Rules Documentation](https://docs.cursor.com/)
- [Markdownlint Rules](https://github.com/DavidAnson/markdownlint)

## 🤝 Contributing

To propose changes to shared configurations:

1. Create a branch in this repository
2. Make your changes to files in `configs/`
3. Open a pull request with a clear description
4. After merge, sync to repositories as needed

---

**Maintained by**: Certus Labs Team  
**Last Updated**: January 2026
