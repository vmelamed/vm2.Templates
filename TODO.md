# TODO: Branch Protection & Bootstrap Script Improvements

## Issues to Address in `bootstrap-new-package.sh`

### 1. Check Name Mismatch

`detect_required_checks()` uses short names (`"build"`, `"test"`, `"benchmarks"`) that don't match
the actual nested reusable workflow check names (e.g.,
`"Run CI: Build, Test, Benchmark, Pack / Build the source code / build (ubuntu-latest, ./vm2.Glob.slnx)"`).

### 2. Classic Branch Protection API vs Rulesets

The script uses the classic API (`repos/{owner}/{repo}/branches/{branch}/protection`), but vm2.Glob
uses the newer GitHub Rulesets. Standardize on one approach.

### 3. `required_approving_review_count: 1` Blocks Solo Maintainers

Can't self-approve PRs. Combined with `enforce_admins: true`, merging is permanently blocked
without removing the protection rule. Make review count configurable or default to 0.

### 4. Missing `"pack"` Check Detection

`detect_required_checks()` doesn't look for package projects. Add detection and include `"pack"`
in `required_checks` when found.

### 5. `enforce_admins: true` Too Strict for Solo Workflows

Even admins can't bypass required reviews. Set to `false` or make configurable.

## Plan

1. Merge vm2.Glob PR #3 (using bypass checkbox)
2. Capture actual CI check names from the workflow run on `main`
3. Update `bootstrap-new-package.sh` with correct check names and chosen protection model
4. Apply the same protection configuration to vm2.Glob and vm2.Ulid
