#!/usr/bin/env bash
# scan.sh — Best-effort data-collection accelerator for the read-repo skill
# Usage: bash scan.sh [repo-path]
# Output goes to stdout for the agent to read.
# This script is NOT authoritative — the agent's Phase 2 deep read is.

set -euo pipefail

REPO="${1:-.}"
REPO="$(cd "$REPO" && pwd)"

HR="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Single unified exclusion list used by both tree and find
EXCLUDE_DIRS="node_modules|.git|__pycache__|.pytest_cache|dist|build|.next|.nuxt|target|*.pyc|*.class|.DS_Store|vendor|venv|.venv|coverage|.nyc_output"
# find-compatible prune expression (derived from same list)
find_prune() {
  echo \( \
    -name "node_modules" -o -name ".git" -o -name "__pycache__" \
    -o -name ".pytest_cache" -o -name "dist" -o -name "build" \
    -o -name ".next" -o -name ".nuxt" -o -name "target" \
    -o -name "vendor" -o -name "venv" -o -name ".venv" \
    -o -name "coverage" -o -name ".nyc_output" -o -name ".DS_Store" \
  \)
}

echo "$HR"
echo "REPO SCAN: $REPO"
echo "Scanned at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Note: best-effort scan — Phase 2 deep read is authoritative"
echo "$HR"

# ── 1. Directory tree ──────────────────────────────────────────────────────────
echo ""
echo "## DIRECTORY TREE (depth 3)"
echo ""
if command -v tree &>/dev/null; then
  tree "$REPO" -L 3 --dirsfirst -I "$EXCLUDE_DIRS" 2>/dev/null || true
else
  find "$REPO" -maxdepth 3 $(find_prune) -prune \
    -o -print | sed "s|$REPO||" | sort
fi

# ── 2. Language detection (by file count) ─────────────────────────────────────
echo ""
echo "## LANGUAGE BREAKDOWN (by file count, not line count)"
echo ""
find "$REPO" $(find_prune) -prune \
  -o -type f -name "*.*" -print \
  | grep -oE '\.[a-zA-Z0-9]+$' \
  | sort | uniq -c | sort -rn \
  | head -25

# ── 3. Monorepo signals ────────────────────────────────────────────────────────
echo ""
echo "## MONOREPO SIGNALS"
echo ""
for f in lerna.json pnpm-workspace.yaml nx.json rush.json turbo.json; do
  [ -f "$REPO/$f" ] && echo "  FOUND: $f"
done
for d in packages apps services; do
  if [ -d "$REPO/$d" ]; then
    count=$(find "$REPO/$d" -maxdepth 2 -name "package.json" -o -name "go.mod" -o -name "Cargo.toml" -o -name "pyproject.toml" 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 1 ] && echo "  FOUND: $d/ with $count package manifests"
  fi
done
if grep -q '"workspaces"' "$REPO/package.json" 2>/dev/null; then
  echo "  FOUND: workspaces field in root package.json"
fi

# ── 4. Manifest / dependency files ────────────────────────────────────────────
echo ""
echo "## MANIFEST & DEPENDENCY FILES"
echo ""

MANIFESTS=(
  "package.json" "package-lock.json" "yarn.lock" "pnpm-lock.yaml"
  "requirements.txt" "requirements-dev.txt" "Pipfile" "pyproject.toml" "setup.py" "setup.cfg"
  "go.mod" "go.sum"
  "Cargo.toml" "Cargo.lock"
  "pom.xml" "build.gradle" "build.gradle.kts" "settings.gradle"
  "CMakeLists.txt"
  "pubspec.yaml"
  "composer.json"
  "Gemfile" "Gemfile.lock"
  "mix.exs"
  "*.csproj" "*.sln" "nuget.config"
  "deno.json" "deno.lock"
  "bun.lockb"
)

for pattern in "${MANIFESTS[@]}"; do
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    rel="${f#$REPO/}"
    echo "### $rel"
    head -60 "$f" 2>/dev/null
    echo ""
  done < <(find "$REPO" -maxdepth 3 -name "$pattern" \
    ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/vendor/*" \
    2>/dev/null | sort)
done

# ── 5. Entry points ───────────────────────────────────────────────────────────
echo ""
echo "## ENTRY POINTS (candidates)"
echo ""
ENTRY_PATTERNS=(
  "main.go" "main.py" "main.rs" "main.js" "main.ts" "main.tsx"
  "index.js" "index.ts" "index.tsx"
  "app.py" "app.js" "app.ts" "app.tsx"
  "server.py" "server.js" "server.ts"
  "manage.py" "wsgi.py" "asgi.py"
  "Program.cs"
  "Application.java" "Main.java"
  "config.ru"
)

for pattern in "${ENTRY_PATTERNS[@]}"; do
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    rel="${f#$REPO/}"
    echo "### $rel"
    head -30 "$f" 2>/dev/null
    echo ""
  done < <(find "$REPO" -name "$pattern" \
    ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/vendor/*" \
    ! -path "*/dist/*" ! -path "*/build/*" ! -path "*/target/*" \
    -maxdepth 5 2>/dev/null | sort)
done

if [ -d "$REPO/cmd" ]; then
  echo "### cmd/ (Go entry points)"
  find "$REPO/cmd" -name "*.go" 2>/dev/null | head -5 | while read -r f; do
    echo "#### ${f#$REPO/}"
    head -20 "$f"
    echo ""
  done
fi

# ── 6. Config & infra files ───────────────────────────────────────────────────
echo ""
echo "## CONFIG & INFRASTRUCTURE FILES"
echo ""
CONFIG_PATTERNS=(
  "Dockerfile"
  "docker-compose.yml" "docker-compose.yaml"
  ".env.example" ".env.sample"
  ".gitlab-ci.yml"
  "Makefile"
  "nginx.conf"
  "serverless.yml" "serverless.yaml"
  "vercel.json" "netlify.toml"
)

for pattern in "${CONFIG_PATTERNS[@]}"; do
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    rel="${f#$REPO/}"
    echo "### $rel"
    head -40 "$f" 2>/dev/null
    echo ""
  done < <(find "$REPO" -maxdepth 5 -name "$pattern" \
    ! -path "*/.git/*" ! -path "*/node_modules/*" \
    2>/dev/null | sort | head -3)
done

# GitHub Actions
if [ -d "$REPO/.github/workflows" ]; then
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    rel="${f#$REPO/}"
    echo "### $rel"
    head -40 "$f" 2>/dev/null
    echo ""
  done < <(find "$REPO/.github/workflows" -maxdepth 1 \( -name "*.yml" -o -name "*.yaml" \) \
    2>/dev/null | sort | head -5)
fi

# ── 7. Test directories ───────────────────────────────────────────────────────
echo ""
echo "## TEST STRUCTURE"
echo ""
find "$REPO" -maxdepth 4 -type d \
  \( -name "test" -o -name "tests" -o -name "__tests__" \
     -o -name "spec" -o -name "specs" -o -name "e2e" -o -name "integration" \) \
  ! -path "*/node_modules/*" ! -path "*/.git/*" \
  2>/dev/null | sort | while read -r d; do
  echo "  ${d#$REPO/}/"
  ls "$d" 2>/dev/null | head -8 | sed 's/^/    /'
  echo ""
done

echo "$HR"
echo "END OF SCAN"
echo "$HR"

