# vm2.Templates

Templates for creating new vm2 package repositories. The first template is **vm2 Add New NuGet Package Solution** (short name `vm2pkg`).

## Prerequisites

- .NET SDK 10.0.101
- `gh` CLI (used by the generated bootstrap script)

## Install the template locally

```bash
dotnet new install .
```

## Create a package scaffold

```bash
dotnet new vm2pkg \
  --name MyPackage \
  --packageVersion 0.1.0 \
  --license MIT \
  --repositoryOrg vmelamed \
  --includeBenchmarks true \
  --includeExamples true \
  --includeDocs true
```

Then run the generated `scripts/bootstrap-new-package.sh` to create and push the GitHub repo (uses `gh repo create`, requires auth).

## Template parameters (key ones)

| Parameter | Default | Description |
| --- | --- | --- |
| `--name` | (required) | Package/project name (PascalCase); repo becomes `vm2.<name>`. |
| `--packageVersion` | `0.1.0` | Initial package version stamped into csproj/CHANGELOG. |
| `--license` | `MIT` | One of `MIT`, `Apache-2.0`, `BSD-3`; materializes LICENSE and SPDX headers. |
| `--repositoryOrg` | `vmelamed` | GitHub org/user for URLs and bootstrap defaults. |
| `--includeBenchmarks` | `true` | Include `benchmarks/<name>.Benchmarks`. |
| `--includeExamples` | `true` | Include `examples/<name>.Example`. |
| `--includeDocs` | `true` | Include `docs/` stub. |

## What gets generated

- .NET solution skeleton with shared settings: [Directory.Build.props](Directory.Build.props), [Directory.Packages.props](Directory.Packages.props), [global.json](global.json), [NuGet.config](templates/AddNewPackage/content/NuGet.config).
- Workflows from org templates: CI, Prerelease, Release, ClearCache under `.github/workflows/`; Dependabot config.
- Library project `src/<name>/` with SPDX headers and XML docs enabled; tests under `test/<name>.Tests/` (xUnit + MTP + coverage); optional benchmarks/examples/docs; scripts folder with bootstrap helper and `_common.sh` utilities.
- Packaging metadata patterned after vm2.Ulid (packable, SourceLink, MinVer tag prefix `v`, README/CHANGELOG/LICENSE packing entries).

## Bootstrap script (generated)

`scripts/bootstrap-new-package.sh` (SPDX uses selected license) will:

- Require `gh` and authentication.
- Create repo `vm2.<name>` under `--org` (default `vmelamed`) with `--visibility` (default private).
- Init git if needed, commit scaffold, set origin, push `main`.

## After generation

1) Set required secrets/variables in GitHub: `CODECOV_TOKEN`, `NUGET_API_GITHUB_KEY`, `NUGET_API_NUGET_KEY`, `BENCHER_API_TOKEN`; variables `DOTNET_VERSION`, `CONFIGURATION`, `MAX_REGRESSION_PCT`, `MIN_COVERAGE_PCT`, `MINVERTAGPREFIX`, debug flags.
2) Protect `main` with required checks and require PRs. Suggested check names:

- `get-params` (job id from CI workflow "CI: Build, Test, Benchmark")
- `call-ci` (job id from CI workflow "CI: Build, Test, Benchmark")

1) Update README/CHANGELOG content and package metadata as needed.

## Repo layout

- templates/AddNewPackage/.template.config: template definition
- templates/AddNewPackage/content: payload files used by `dotnet new`
- scripts/: shared helper scripts (copied into generated repos)

## Development notes

- Keep template content minimal and rely on shared props/central package management.
- Optional folders are conditionally excluded based on include flags.
- Bootstrap script follows the style of vm2.DevOps `_common.sh` helpers for consistency.
