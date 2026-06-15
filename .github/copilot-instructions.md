# Copilot Instructions for vm2.Templates

## Shared Conventions

Copilot MUST read and follow [CONVENTIONS.md](CONVENTIONS.md) before suggesting or making changes.

Do not duplicate shared rules here — shared instructions belong in [CONVENTIONS.md](CONVENTIONS.md) so all AI systems
use the same source of truth.

## Package-Specific Guidance

This package contains templates for creating new projects within the vm2 ecosystem. It provides a standardized structure and shared conventions to ensure consistency across all projects. Copilot SHOULD use these templates as a reference when suggesting new project structures or modifications.

For now the templates are primarily focused on setting up new package projects. Copilot SHOULD prioritize these templates when suggesting structures for new package projects and follow the conventions established within them.

Note that the content of the templates should be treated as canonical examples for setting up new package projects. Copilot SHOULD refer to these templates to ensure that any new package projects adhere to the established structure and conventions. Also, the content is the source of truth for the contents of the new and the existing package projects within the vm2 ecosystem. It is used by `$VM2_REPOS/scripts/bash/diff-shared.sh` to compare the shared template content against the existing package projects and copy or highlight any differences that need to be reconciled or merged.
