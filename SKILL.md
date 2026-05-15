---
name: read-repo
description: Deep-analyze a local code repository and produce structured documentation: tech stack, languages, features, folder responsibilities, core architectural patterns, and generated markdown files (READREPO.md, ARCHITECTURE.md, etc.). Use when user wants to understand an unfamiliar codebase, document a project, analyze a repo, generate READREPO.md, or asks "what does this project do / how is it structured / how do I contribute / how do I take over".
---

# Read Repo

Analyze a local repository end-to-end and produce mode-specific structured documentation.

## Quick start

```
User: analyze this repo / read this codebase / generate READREPO.md
```

---

## Phase 0 — Detect intent (mode)

Before doing anything else, determine the user's mode:

| Mode | Trigger signals |
|---|---|
| `learn` | "understand", "learn", "what does this do", "explain", "where to start reading" |
| `takeover` | "take over", "onboard", "new member", "inherit", "I'm new to this codebase" |
| `hack` | "fork", "extend", "contribute", "modify", "add feature", "how do I change" |

**Default: `learn`** when signals are absent or ambiguous.

State the mode before proceeding:
> "I'll analyze this in **learn** mode. Say 'analyze this for someone taking over' or 'analyze this for contributing' to switch."

---

## Phase 1 — Mechanical scan (run script)

scan.sh is a **best-effort data-collection accelerator** — output may be incomplete or imprecise. Phase 2 is authoritative.

```bash
bash ~/.agents/skills/read-repo/scripts/scan.sh [repo-path]
# defaults to current working directory
```

The script outputs: directory tree (depth 3), language breakdown (by file count), manifest files (first 60 lines each), entry-point candidates, config/infra files, test directories.

**Monorepo detection** — if any of the following exist at the repo root, treat as monorepo:
`lerna.json`, `pnpm-workspace.yaml`, `nx.json`, `rush.json`, `turbo.json`, `workspaces` field in root `package.json`, or `packages/` / `apps/` / `services/` containing multiple subdirectories each with their own manifest.

For monorepos: run scan.sh once at the root, then again per package. Analyze each package separately. Generate `READREPO.md` inside each package directory. Generate a top-level `READREPO.md` describing inter-package relationships.

---

## Phase 2 — Deep read (targeted file reads)

Read in this order — stop when you have enough signal:

1. README.md / docs/ — stated purpose
2. Manifest files — declared dependencies → infer tech stack
3. Entry points — how the app boots
4. Core source directories — business logic
5. Config & infra files — deployment model
6. Test files — implicit contracts

---

## Phase 3 — Synthesize

Fill every field. Mark uncertain values `⚠️ inferred` inline (e.g. `Pattern: Hexagonal ⚠️ inferred`). Never fabricate — only report what you see in code.

```
TECH STACK
  Runtime/Platform:
  Languages:          (file count from scan; verify with manifests)
  Frameworks:
  Key Libraries:
  Databases/Storage:
  Infrastructure/DevOps:

FEATURES (user-facing or API capabilities)
  - ...

ARCHITECTURE
  Pattern:            (MVC / hexagonal / microservices / monolith / event-driven / …)
  Data flow:          Use Mermaid — flowchart LR for data flows, graph TD for component hierarchies, graph LR for dependency maps

FOLDER MAP
  /dir   → responsibility (2 lines max per folder)

CORE INSIGHTS         (each must meet ≥1 condition below; mark confirmed | ⚠️ inferred)
  Conditions:
  1. Apparent bad practice with a deliberate reason
  2. Critical logic hidden in an unexpected location
  3. Naming that misrepresents actual behaviour
  4. Important performance or security constraint
  5. Non-standard extension pattern
  - ...

OPEN QUESTIONS / GAPS
  - ...
```

---

## Phase 4 — Generate documents

**First line of every generated READREPO.md:**
```
> 🔍 Generated in **{mode}** mode by [read-repo](https://github.com/T3QC0LU/read-repo). Re-run with "{example re-run prompt}" to switch modes.
```

**Generation matrix** — what to generate per mode and complexity:

| Document | learn | takeover | hack | Also when |
|---|---|---|---|---|
| READREPO.md | ✅ | ✅ | ✅ | Always |
| ARCHITECTURE.md | — | ✅ | ✅ | Or: >3 layers / microservices |
| TECH-STACK.md | — | — | ✅ | Or: >5 significant deps / polyglot |
| FOLDER-GUIDE.md | ✅ | ✅ | — | Or: >8 top-level source folders |
| ONBOARDING.md | — | ✅ | — | Or: setup steps / env vars detected |

Write files to the **repo root** (or package root for monorepos) unless user specifies otherwise. READREPO.md must link to all generated companion files.

See [REFERENCE.md](REFERENCE.md) for mode-specific templates.

---

## Output contract

After analysis, always respond with:

1. **Mode used** and the signal that triggered it (or "default")
2. **Summary card** (≤15 lines) — stack, language(s), pattern, 3-line purpose
3. **Files written** — list with one-line description each
4. **Open questions** — especially `⚠️ inferred` fields that need human confirmation

---

## Tips

- Never fabricate API endpoints, DB schemas, or specific code behaviour — only report what you see
- For unknown languages: use file extensions + syntax clues, mark as `⚠️ inferred`
- If user changes mode after generation, re-generate — do not merge two modes into one document
- For unknown frameworks: check import statements and config file conventions

## Diagram conventions

Always use Mermaid — never ASCII art. Use the right diagram type for the content:

| Content | Mermaid type | Example |
|---|---|---|
| Data flow (left → right) | `flowchart LR` | request → handler → DB |
| Component hierarchy (top → down) | `graph TD` | App → Services → Repos |
| Module dependency map | `graph LR` | moduleA → moduleB |
| Request / response sequence | `sequenceDiagram` | Client → Server: GET /api |

Use short node labels. Keep diagrams ≤10 nodes — split into sub-diagrams if larger.
GitHub and VS Code both render Mermaid natively inside ` ```mermaid ` blocks.
