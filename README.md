# Certus Labs Organization Configuration

This repository contains shared configurations and community health files for all Certus Labs repositories.

## 📁 Structure

```tree
.github/
├── .ruler/               # Shared AI assistant rules
│   ├── 10-principles.md  # Core working principles
│   ├── 11-verification.md
│   ├── 12-epistemic.md
│   ├── 13-code-quality.md
│   ├── 14-debugging.md
│   ├── 15-output-format.md
│   ├── 16-python.md      # Python stack rules
│   └── templates/
│       ├── 00-project.md.template
│       └── ruler.toml.template
├── .repoconfig/          # Shared configuration files
│   └── .markdownlint.json
├── scripts/
│   ├── sync-ruler.sh     # Sync AI rules to repositories
│   └── sync-configs.sh   # Sync config files to repositories
├── CONTRIBUTING.md       # Auto-applied to all repos (GitHub native)
└── profile/
    └── README.md         # Shows on organization page
```

## 🎯 Purpose

### AI Rules (`.ruler/`)

Shared AI assistant instructions using the [Ruler framework](https://github.com/intellectronica/ruler).

**Numbering Convention:**

- `00-09`: Project-specific (never synced, protected)
- `10+`: Shared rules (synced from `.github/.ruler/`)

### Configuration Files (`.repoconfig/`)

Non-AI configuration files like linters, formatters, etc.

### Community Health Files (GitHub Native)

Files like `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md` are automatically shown in all organization repositories that don't have their own version.

**Supported files**: [See GitHub Docs](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file)

## 🚀 Usage

### Sync AI Rules to All Repositories

```bash
cd .github/scripts
./sync-ruler.sh --all
```

Force overwrite existing shared files:

```bash
./sync-ruler.sh --all --force
```

### Sync AI Rules to a Single Repository

```bash
./sync-ruler.sh ../showcase-a-batch
```

### Sync Config Files

```bash
./sync-configs.sh --all           # All repos
./sync-configs.sh ../my-repo      # Single repo
./sync-configs.sh --all --force   # Force overwrite
```

### After Syncing AI Rules

In each repository:

```bash
cd your-repo

# 1. Customize project-specific rules
vim .ruler/00-project.md

# 2. Generate AGENTS.md (requires Ruler via npx)
ruler apply

# 3. Stage and commit
git add .ruler/
git commit -m "Add/update AI rules"
```

## 📝 AI Rules Structure

### Shared Rules (synced)

| File | Description |
|------|-------------|
| `10-principles.md` | Core working principles (correctness, planning) |
| `11-verification.md` | Verification & source citation |
| `12-epistemic.md` | Facts vs assumptions vs unknowns |
| `13-code-quality.md` | Code quality standards |
| `14-debugging.md` | Debugging methodology |
| `15-output-format.md` | Response format requirements |
| `16-python.md` | Python stack (UV, Ruff, pytest) |

### Project-Specific Rules (protected)

| File | Description |
|------|-------------|
| `00-project.md` | Project context, domain, architecture |
| `01-09` | Reserved for project-specific overrides |

## 🔄 Workflow

### Updating Shared AI Rules

```bash
# 1. Edit shared rules in .github
cd .github/.ruler
vim 10-principles.md

# 2. Commit changes
git add .
git commit -m "Update: AI working principles"
git push

# 3. Sync to all repos
cd ../scripts
./sync-ruler.sh --all --force

# 4. In each repo: regenerate and commit
cd ../../my-repo
ruler apply
git add .ruler/
git commit -m "Update: sync shared AI rules"
```

### Updating Config Files

```bash
# 1. Edit config in .github
cd .github/.repoconfig
vim .markdownlint.json

# 2. Commit and sync
git add .
git commit -m "Update: markdownlint config"
cd ../scripts
./sync-configs.sh --all --force
```

## 📚 Resources

- [Ruler Framework](https://github.com/intellectronica/ruler) - AI rules management
- [GitHub Default Community Health Files](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file)
- [Markdownlint Rules](https://github.com/DavidAnson/markdownlint)

## 🤝 Contributing

To propose changes to shared configurations:

1. Create a branch in this repository
2. Make your changes to files in `.ruler/` or `.repoconfig/`
3. Open a pull request with a clear description
4. After merge, sync to repositories as needed

---

**Maintained by**: Certus Labs Team  
**Last Updated**: January 2026
