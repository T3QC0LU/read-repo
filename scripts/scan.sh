#!/usr/bin/env bash
# scan.sh — Mechanical repo scanner for the read-repo skill
# Usage: bash scan.sh [repo-path]
# Output goes to stdout for the agent to read

set -euo pipefail

REPO="${1:-.}"
REPO="$(cd "$REPO" && pwd)"

HR="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "$HR"
echo "REPO SCAN: $REPO"
echo "Scanned at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "$HR"

# ── 1. Directory tree ──────────────────────────────────────────────────────────
echo ""
echo "## DIRECTORY TREE (depth 3, excluding common noise)"
echo ""
if command -v tree &>/dev/null; then
  tree "$REPO" -L 3 \
    --dirsfirst \
    -I 'node_modules|.git|__pycache__|.pytest_cache|dist|build|.next|.nuxt|target|*.pyc|*.class|.DS_Store|vendor|venv|.venv|coverage|.nyc_output' \
    2>/dev/null || true
else
  find "$REPO" -maxdepth 3 \
    \( -name node_modules -o -name .git -o -name __pycache__ \
       -o -name dist -o -name build -o -name target -o -name vendor \
       -o -name venv -o -name .venv \) -prune \
    -o -print | sed "s|$REPO||" | sort
fi

# ── 2. Language detection ──────────────────────────────────────────────────────
echo ""
echo "## LANGUAGE BREAKDOWN (by file count)"
echo ""
find "$REPO" \
  \( -path "*/.git" -o -path "*/node_modules" -o -path "*/__pycache__" \
     -o -path "*/dist" -o -path "*/build" -o -path "*/target" \
     -o -path "*/vendor" -o -path "*/.venv" -o -path "*/venv" \) -prune \
  -o -type f -name "*.*" -print \
  | grep -oE '\.[a-zA-Z0-9]+$' \
  | sort | uniq -c | sort -rn \
  | head -25

# ── 3. Manifest / dependency files ────────────────────────────────────────────
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
  # Use find to handle glob patterns
  while IFS= read -r f; do
    rel="${f#$REPO/}"
    echo "### $rel"
    # Print first 60 lines, enough for deps section
    head -60 "$f" 2>/dev/null
    echo ""
  done < <(find "$REPO" -maxdepth 3 -name "$pattern" \
    ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/vendor/*" \
    2>/dev/null | sort)
done

# ── 4. Entry points ───────────────────────────────────────────────────────────
echo ""
echo "## ENTRY POINTS (candidates)"
echo ""
ENTRY_PATTERNS=(
  "main.go" "main.py" "main.rs" "main.js" "main.ts" "main.tsx"
  "index.js" "index.ts" "index.tsx"
  "app.py" "app.js" "app.ts" "app.tsx"
  "server.py" "server.js" "server.ts"
  "manage.py"
  "Program.cs"
  "Application.java" "Main.java"
)

for pattern in "${ENTRY_PATTERNS[@]}"; do
  while IFS= read -r f; do
    rel="${f#$REPO/}"
    echo "### $rel"
    head -30 "$f" 2>/dev/null
    echo ""
  done < <(find "$REPO" -name "$pattern" \
    ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/vendor/*" \
    ! -path "*/dist/*" ! -path "*/build/*" ! -path "*/target/*" \
    -maxdepth 5 2>/dev/null | sort)
done

# Also check cmd/ directory (Go pattern)
if [ -d "$REPO/cmd" ]; then
  echo "### cmd/ (Go entry points)"
  find "$REPO/cmd" -name "*.go" | head -5 | while read -r f; do
    echo "#### ${f#$REPO/}"
    head -20 "$f"
    echo ""
  done
fi

# ── 5. Config & infra files ───────────────────────────────────────────────────
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
    rel="${f#$REPO/}"
    # Skip if find returned the repo dir itself (pattern edge case)
    [ -f "$f" ] || continue
    echo "### $rel"
    head -40 "$f" 2>/dev/null
    echo ""
  done < <(find "$REPO" -maxdepth 5 -name "$(basename "$pattern")" \
    ! -path "*/.git/*" ! -path "*/node_modules/*" \
    2>/dev/null | sort | head -3)
done

# GitHub Actions (needs path filter, can't use simple -name)
while IFS= read -r f; do
  rel="${f#$REPO/}"
  echo "### $rel"
  head -40 "$f" 2>/dev/null
  echo ""
done < <(find "$REPO/.github/workflows" -maxdepth 1 -name "*.yml" -o -name "*.yaml" \
  2>/dev/null | sort | head -5)

# ── 6. Test directories ───────────────────────────────────────────────────────
echo ""
echo "## TEST STRUCTURE"
echo ""
find "$REPO" -maxdepth 4 -type d \
  \( -name "test" -o -name "tests" -o -name "__tests__" \
     -o -name "spec" -o -name "specs" -o -name "e2e" -o -name "integration" \) \
  ! -path "*/node_modules/*" ! -path "*/.git/*" \
  2>/dev/null | sort | while read -r d; do
  echo "  ${d#$REPO/}/"
  ls "$d" | head -8 | sed 's/^/    /'
  echo ""
done

echo "$HR"
echo "END OF SCAN"
echo "$HR"
