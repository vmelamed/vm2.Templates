#!/bin/bash
# Syncs _common*.sh files from vm2.DevOps (source of truth) to vm2.Templates
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SOURCE_DIR="$TEMPLATES_ROOT/../vm2.DevOps/.github/actions/scripts"
TARGET_DIR="$TEMPLATES_ROOT/templates/AddNewPackage/content/scripts"

# Check if source directory exists
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "❌  ERROR: Source directory not found: $SOURCE_DIR" >&2
    echo "   Make sure vm2.DevOps and vm2.Templates are in the same parent directory" >&2
    exit 1
fi

# Check if target directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "❌  ERROR: Target directory not found: $TARGET_DIR" >&2
    exit 1
fi

# Check if any _common*.sh files exist in source
if ! compgen -G "$SOURCE_DIR/_common*.sh" > /dev/null; then
    echo "❌  ERROR: No _common*.sh files found in: $SOURCE_DIR" >&2
    exit 1
fi

echo "Syncing _common*.sh files from vm2.DevOps to vm2.Templates..."
cp -v "$SOURCE_DIR/_common"*.sh "$TARGET_DIR/"

echo ""
echo "✅ Sync complete"
echo ""
echo "⚠️  Don't forget to commit the changes:"
echo "  git add templates/AddNewPackage/content/scripts/_common*.sh"
echo "  git commit -m 'chore: sync _common*.sh files from vm2.DevOps'"
