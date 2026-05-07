# Reference — Document Templates

## READREPO.md

```markdown
# {Project Name}

> {One-sentence description of what this project does and for whom.}

## Overview

{2–4 paragraphs covering: purpose, target users, key value proposition, current status (active / archived / alpha).}

## Tech Stack

| Layer | Technology |
|---|---|
| Language | … |
| Framework | … |
| Database | … |
| Infrastructure | … |
| CI/CD | … |

## Features

- **{Feature}**: {Short description}
- …

## Architecture

```
{ASCII diagram or description of data flow}
```

{Pattern name} — {one sentence justification}

## Folder Structure

```
/
├── {dir}/     # {responsibility}
├── {dir}/     # {responsibility}
└── …
```

## Getting Started

```bash
# 1. Clone
git clone {url}

# 2. Install dependencies
{install command}

# 3. Configure
cp .env.example .env
# edit .env …

# 4. Run
{run command}
```

## Key Concepts

- **{Concept}**: {Explanation}

## Contributing

{Contribution instructions or link.}
```

---

## ARCHITECTURE.md

```markdown
# Architecture

## Pattern

**{Pattern}** — {Why this pattern fits this project.}

## Component Map

```
{ASCII component diagram}
```

## Data Flow

1. {Step}: {description}
2. …

## Key Design Decisions

| Decision | Rationale | Trade-off |
|---|---|---|
| … | … | … |

## Layers

### {Layer Name}
- Location: `{path}`
- Responsibility: {description}
- Key files: `{file}` — {purpose}

## External Integrations

| Service | Protocol | Purpose |
|---|---|---|
| … | … | … |

## Scaling Considerations

{Notes on bottlenecks, stateless-ness, horizontal scalability.}
```

---

## TECH-STACK.md

```markdown
# Tech Stack

## Languages

| Language | Usage | % (approx) |
|---|---|---|
| … | … | … |

## Frameworks & Libraries

| Package | Version | Purpose | Why chosen |
|---|---|---|---|
| … | … | … | … |

## Infrastructure

| Tool | Purpose |
|---|---|
| … | … |

## Development Tools

| Tool | Purpose |
|---|---|
| … | … |

## Upgrade Notes

{Any pinned versions with known issues or upgrade blockers.}
```

---

## FOLDER-GUIDE.md

```markdown
# Folder Guide

> Quick reference for contributors: what lives where and why.

## Source Tree

```
{tree output}
```

## Folder Responsibilities

### `/{folder}`

**Purpose**: {one sentence}

**Key files**:
- `{file}` — {role}

**Owned by**: {team/domain if known}

---

{repeat per folder}

## Naming Conventions

- {convention}: {explanation}

## Where to add new…

| Thing | Where |
|---|---|
| New API endpoint | `{path}` |
| New UI component | `{path}` |
| New DB migration | `{path}` |
| New test | `{path}` |
```

---

## ONBOARDING.md

```markdown
# Onboarding Guide

## Prerequisites

- {tool} {version+}
- …

## Local Setup

```bash
# Step-by-step, copy-pasteable
```

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| … | ✅ | — | … |

## Running Tests

```bash
{test command}
```

## Common Issues

### {Issue title}
**Symptom**: …
**Fix**: …

## Useful Commands

| Command | What it does |
|---|---|
| … | … |

## Team Contacts / Channels

{Slack, email, on-call rotation, etc.}
```
