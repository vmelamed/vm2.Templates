#!/bin/bash
# Syncs _common.sh from vm2.DevOps (source of truth) to vm2.Templates
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SOURCE="$TEMPLATES_ROOT/../vm2.DevOps/.github/actions/scripts/_common.sh"
TARGET="$TEMPLATES_ROOT/templates/AddNewPackage/content/scripts/_common.sh"

if [[ ! -f "$SOURCE" ]]; then
    echo "❌ Source file not found: $SOURCE" >&2
    echo "   Make sure vm2.DevOps and vm2.Templates are in the same parent directory" >&2
    exit 1
fi

if [[ ! -f "$TARGET" ]]; then
    echo "❌ Target file not found: $TARGET" >&2
    exit 1
fi

if diff -q "$SOURCE" "$TARGET" >/dev/null 2>&1; then
    echo "✅ _common.sh is already in sync"
    exit 0
fi

echo "Syncing _common.sh from vm2.DevOps..."
cp "$SOURCE" "$TARGET"
echo "✅ _common.sh synced successfully"
echo ""
echo "Don't forget to commit the change:"
echo "  git add templates/AddNewPackage/content/scripts/_common.sh"
echo "  git commit -m 'chore: sync _common.sh from vm2.DevOps'"
