---
name: read-repo
description: Deep-analyze a local code repository and produce structured documentation: tech stack, languages, features, folder responsibilities, core architectural patterns, and generated markdown files (READREPO.md, ARCHITECTURE.md, etc.). Use when user wants to understand an unfamiliar codebase, document a project, analyze a repo, generate READREPO.md, or asks "what does this project do / how is it structured".
---

# Read Repo

Analyze a local repository end-to-end and produce structured documentation.

## Quick start

```
User: analyze this repo / read this codebase / generate READREPO.md
```

Run the scanner first, then reason over output:

```bash
bash ~/.agents/skills/read-repo/scripts/scan.sh [repo-path]
# defaults to current working directory if no path given
```

Then follow the **Full Workflow** below.

## Full Workflow

### Phase 1 — Mechanical scan (run script)

```bash
bash ~/.agents/skills/read-repo/scripts/scan.sh [repo-path]
```

The script outputs:
- Directory tree (depth 3)
- All detected languages + line counts
- Dependency/manifest files (package.json, requirements.txt, go.mod, Cargo.toml, pom.xml, build.gradle, CMakeLists.txt, pubspec.yaml, etc.)
- Entry-point candidates (main.*, index.*, app.*, server.*, cmd/)
- Config files (.env.example, docker-compose.yml, Dockerfile, CI yamls)
- Test directories

### Phase 2 — Deep read (targeted file reads)

Read in this order — stop when you have enough signal:

1. README.md / docs/ — stated purpose
2. Manifest files — declared dependencies → infer tech stack
3. Entry points — how the app boots
4. Core source directories — business logic
5. Config & infra files — deployment model
6. Test files — implicit contracts

### Phase 3 — Synthesize (fill every section below)

Reason carefully. Do NOT guess — if unsure, mark `⚠️ inferred`.

```
TECH STACK
  Runtime/Platform:
  Languages:
  Frameworks:
  Key Libraries:
  Databases/Storage:
  Infrastructure/DevOps:

FEATURES (user-facing or API capabilities)
  - ...

ARCHITECTURE
  Pattern: (MVC / hexagonal / microservices / monolith / event-driven / …)
  Data flow: [entry] → [processing] → [output]

FOLDER MAP
  /dir   → responsibility (2-line max per folder)

CORE POINTS (non-obvious insights)
  - ...

OPEN QUESTIONS / GAPS
  - ...
```

### Phase 4 — Generate documents

Always generate **READREPO.md**. Generate others based on project complexity.

| Document | Generate when |
|---|---|
| READREPO.md | Always |
| ARCHITECTURE.md | Project has non-trivial structure (>3 layers or microservices) |
| TECH-STACK.md | >5 significant dependencies or polyglot |
| FOLDER-GUIDE.md | >8 top-level source folders |
| ONBOARDING.md | Project has setup steps / env vars / local dev instructions |

Write files to the **repo root** unless user specifies otherwise.

See [REFERENCE.md](REFERENCE.md) for document templates.

## Output contract

After analysis, always respond with:

1. **Summary card** (inline, ≤15 lines) — stack, language(s), pattern, 3-line purpose
2. **Files written** — list with one-line description each
3. **Open questions** — things that need human confirmation

## Tips

- For monorepos: analyze each package separately, then write a top-level READREPO.md
- For unknown languages: use file extensions + syntax clues, mark as inferred
- Never fabricate API endpoints or DB schemas — only report what you see in code
