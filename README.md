# read-repo

> A Copilot CLI skill that deep-analyzes a local code repository and generates structured documentation.

## What it does

Install this skill and your Copilot CLI agent can:

- 🔍 **Analyze** any local codebase — tech stack, languages, architecture, folder responsibilities, core patterns
- 📄 **Generate** ready-to-commit markdown docs: `READREPO.md`, `ARCHITECTURE.md`, `TECH-STACK.md`, `FOLDER-GUIDE.md`, `ONBOARDING.md`
- 🗺️ **Map** every folder to its responsibility
- 💡 **Surface** non-obvious architectural decisions and core insights

## Install

```bash
npx skills add T3QC0LU/read-repo
```

That's it. The skill is auto-discovered next time you start Copilot CLI.

## Usage

Just talk to your agent naturally:

```
analyze this repo
read this codebase and generate docs
what does this project do?
generate READREPO.md for this project
explain the architecture of ~/work/my-app
```

## Output

The skill always produces:

| Output | Description |
|---|---|
| **Summary card** | Inline ≤15-line overview: stack, pattern, purpose |
| **READREPO.md** | Always generated — full project README-style doc |
| **ARCHITECTURE.md** | Generated for non-trivial structures |
| **TECH-STACK.md** | Generated for polyglot or complex dependency trees |
| **FOLDER-GUIDE.md** | Generated for large source trees (8+ top-level folders) |
| **ONBOARDING.md** | Generated when setup steps / env vars are detected |

## Contents

```
read-repo/
├── SKILL.md        # Agent instructions
├── REFERENCE.md    # Document templates
└── scripts/
    └── scan.sh     # Mechanical repo scanner (bash)
```

## Requirements

- GitHub Copilot CLI
- `bash`, `find` (standard on macOS/Linux)
- `tree` (optional, improves directory output — `brew install tree`)

## License

MIT
