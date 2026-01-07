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

# Ensure git initialized
if [[ ! -d .git ]]; then
    git init
    git checkout -b main
fi

git add .
if ! git diff --cached --quiet; then
    git commit -m "chore: initial scaffold" || true
fi

if gh repo view "$full_repo" >/dev/null 2>&1; then
    echo "Repo $full_repo already exists; skipping creation." >&2
else
    gh repo create "$full_repo" "--$visibility" --source . --remote origin --push --branch main
fi

git remote set-url origin "git@github.com:${full_repo}.git"
git push -u origin main

echo "Repository ready: https://github.com/${full_repo}"
