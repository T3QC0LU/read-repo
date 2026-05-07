# ADR-0001: Intent-driven mode system for document generation

## Status

Accepted

## Context

The read-repo skill generates documentation for three distinct audiences: developers taking over a codebase, learners wanting to understand a project, and open-source contributors wanting to fork or modify it.

An initial design considered generating a fixed document structure for all use cases (one READREPO.md with all sections). This was rejected because the three audiences have meaningfully different information priorities:

- Learners need data flow, reading path, concept explanations
- Takeover developers need module responsibilities, hidden decisions, known pitfalls
- Hackers/contributors need extension points, hardcoded locations, test coverage, dependency map

A fixed structure either over-stuffs all sections (long, unfocused) or under-serves each audience.

## Decision

The skill detects user intent before generating any document and operates in one of three modes:

| Mode | Trigger signals | READREPO.md emphasis |
|---|---|---|
| `learn` | "understand", "learn", "what does this do", "where to start" | Data flow, reading path, key concepts |
| `takeover` | "take over", "onboard", "new member", "inherit" | Module responsibilities, non-obvious decisions, pitfalls |
| `hack` | "fork", "extend", "contribute", "modify", "add feature" | Extension points, hardcoded locations, test coverage, dependency map |

Default mode when intent is ambiguous: `learn`.

## Consequences

- SKILL.md must include explicit intent detection logic before Phase 4
- REFERENCE.md must provide mode-specific READREPO.md templates (or a single template with mode-conditional sections clearly marked)
- The mode must be stated in the generated document header so the reader knows what lens was used
- If a user later changes their mind (e.g. starts with `learn`, then asks for `hack` focus), the agent re-generates with the new mode rather than merging
