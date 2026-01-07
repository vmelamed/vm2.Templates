#!/usr/bin/env bash

# SPDX-License-Identifier: {{license}}
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_common.sh
source "${SCRIPT_DIR}/_common.sh"

package_name="MyPackage"
org="{{repositoryOrg}}"
repo_name="vm2.${package_name}"
visibility="public"
branch="main"

# Required checks enforced by branch protection; the list is extended dynamically based on repo contents.
required_checks=("build")

usage() {
    cat <<'EOF'
Bootstrap a vm2 package repository using gh CLI.

Usage:
  bootstrap-new-package.sh [--name <PackageName>] [--org <github-org>] [--visibility public|private]

Defaults:
    name: MyPackage
  org:  {{repositoryOrg}}
    visibility: public

This script will:
  - ensure gh is installed and authenticated
  - create GitHub repo ${org}/${repo_name}
        - initialize git (if needed), commit, set origin, push main
        - configure required secrets, variables, repo settings, and branch protection for CI
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)
            package_name="$2"; shift 2;;
        --org)
            org="$2"; shift 2;;
        --visibility)
            visibility="$2"; shift 2;;
        -h|--help)
            usage; exit 0;;
        *)
            echo "Unknown argument: $1" >&2; usage; exit 2;;
    esac
done

if ! command -v gh >/dev/null 2>&1; then
    echo "gh CLI is required. Install from https://cli.github.com/" >&2
    exit 1
fi

gh auth status >/dev/null 2>&1 || { echo "gh is not authenticated" >&2; exit 1; }

repo_name="vm2.${package_name}"
full_repo="${org}/${repo_name}"

detect_required_checks() {
    # Always require build
    required_checks=("build")

    if find . -maxdepth 3 -type d \( -name "test" -o -name "tests" \) -print -quit 2>/dev/null \
        || find . -maxdepth 5 -name "*.Tests.csproj" -print -quit 2>/dev/null; then
        required_checks+=("test")
    fi

    if find . -maxdepth 3 -type d -iname "benchmarks" -print -quit 2>/dev/null \
        || find . -maxdepth 5 -iname "*.Benchmarks.csproj" -print -quit 2>/dev/null; then
        required_checks+=("benchmarks")
    fi
}

configure_repo_settings() {
    gh api -X PATCH "repos/${full_repo}" \
    -f delete_branch_on_merge=true \
    -f allow_squash_merge=true \
    -f allow_merge_commit=false \
    -f allow_rebase_merge=false \
    -f allow_auto_merge=true \
    -f has_wiki=false \
    -f has_projects=false \
    >/dev/null
}

configure_actions_permissions() {
    gh api -X PUT "repos/${full_repo}/actions/permissions/workflow" \
    -H "Accept: application/vnd.github+json" \
    -f default_workflow_permissions=read \
    -f can_approve_pull_request_reviews=false \
    >/dev/null
}

configure_branch_protection() {
    local contexts_json="[]"
    if [[ ${#required_checks[@]} -gt 0 ]]; then
        contexts_json=$(printf '"%s",' "${required_checks[@]}")
        contexts_json="[${contexts_json%,}]"
    fi

    gh api -X PUT "repos/${full_repo}/branches/${branch}/protection" \
    -H "Accept: application/vnd.github+json" \
        --input - >/dev/null <<JSON
{
    "required_status_checks": {
        "strict": true,
        "contexts": ${contexts_json}
    },
    "enforce_admins": true,
    "required_pull_request_reviews": {
        "dismiss_stale_reviews": true,
        "require_code_owner_reviews": false,
        "required_approving_review_count": 1,
        "require_last_push_approval": false,
        "bypass_pull_request_allowances": {
            "users": [],
            "teams": [],
            "apps": []
        }
    },
    "restrictions": null,
    "required_linear_history": true,
    "allow_force_pushes": false,
    "allow_deletions": false,
    "block_creations": false,
    "required_conversation_resolution": true,
    "lock_branch": false
}
JSON
}

# Ensure git initialized
if [[ ! -d .git ]]; then
    git init
    git checkout -b "${branch}"
fi

git add .
if ! git diff --cached --quiet; then
    git commit -m "chore: initial scaffold" || true
fi

if gh repo view "$full_repo" >/dev/null 2>&1; then
    echo "Repo $full_repo already exists; skipping creation." >&2
else
    gh repo create "$full_repo" "--$visibility" --source . --remote origin --push --branch "${branch}"
fi

git remote set-url origin "git@github.com:${full_repo}.git"
git push -u origin "${branch}"

detect_required_checks

# Configure required secrets and variables for Actions
secrets=(
    "CODECOV_TOKEN:secret"
    "NUGET_API_GITHUB_KEY:github-secret"
    "NUGET_API_NUGET_KEY:nuget-secret"
    "NUGET_API_KEY:custom-secret"
    "BENCHER_API_TOKEN:secret"
)

variables=(
    "DOTNET_VERSION:10.0.x"
    "CONFIGURATION:Release"
    "MAX_REGRESSION_PCT:20"
    "MIN_COVERAGE_PCT:80"
    "MINVERTAGPREFIX:v"
    "NUGET_SERVER:github"
    "ACTIONS_RUNNER_DEBUG:false"
    "ACTIONS_STEP_DEBUG:false"
)

for entry in "${secrets[@]}"; do
    name="${entry%%:*}"
    value="${entry#*:}"
    gh secret set "$name" --body "$value" -R "$full_repo" >/dev/null
done

for entry in "${variables[@]}"; do
    name="${entry%%:*}"
    value="${entry#*:}"
    gh variable set "$name" --body "$value" -R "$full_repo" >/dev/null
done

configure_repo_settings
configure_actions_permissions
configure_branch_protection

echo "Repository ready: https://github.com/${full_repo}"
