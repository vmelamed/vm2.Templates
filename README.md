# vm2.Templates

<!-- TOC tocDepth:2..3 chapterDepth:2..6 -->

- [To install a template locally](#to-install-a-template-locally)
- [vm2 Add New NuGet Package Solution (**`vm2pkg`**)](#vm2-add-new-nuget-package-solution-vm2pkg)
  - [Prerequisites](#prerequisites)
  - [Create a package scaffold](#create-a-package-scaffold)
  - [Template parameters (key ones)](#template-parameters-key-ones)
  - [What gets generated](#what-gets-generated)
  - [Bootstrap script (generated)](#bootstrap-script-generated)
  - [After generation](#after-generation)
  - [Repo layout](#repo-layout)
  - [Development notes](#development-notes)

<!-- /TOC -->

This repo contains templates for creating new `dotnet` projects, solutions, etc.

## To install a template locally

```bash
dotnet new install .
```

or, if there were any changes to an already installed template:

```bash
dotnet new install . --force
```

## vm2 Add New NuGet Package Solution (**`vm2pkg`**)

The first template is **vm2 Add New NuGet Package Solution (short name `vm2pkg`)**, which scaffolds a new .NET package repository with conventional structure, GitHub Actions workflows, and optional components.

### Prerequisites

- .NET SDK 10.0.101
- `gh` CLI (used by the generated bootstrap script)

### Create a package scaffold

```bash
dotnet new vm2pkg \
  --name MyPackage \
  --initialVersion 0.1.0 \
  --license MIT \
  --repositoryOrg vmelamed \
  --includeBenchmarks true \
  --includeExamples true \
  --includeDocs true
```

Then run the generated `scripts/bootstrap-new-package.sh` to create and push the GitHub repo (uses `gh repo create`, default visibility public, requires authentication).

### Template parameters (key ones)

| Parameter             | Default    | Description                                                                |
|:--------------------- |:-------    |:-------------------------------------------------------------------------- |
| `--name`              | (required) | Package/project name (PascalCase); repo becomes `vm2.<name>`               |
| `--initialVersion`    | `0.1.0`    | Initial version used in README/CHANGELOG; MinVer computes build versions   |
| `--license`           | `MIT`      | One of `MIT`, `Apache-2.0`, `BSD-3`; materializes LICENSE and SPDX headers |
| `--repositoryOrg`     | `vmelamed` | GitHub org/user for URLs and bootstrap defaults                            |
| `--includeBenchmarks` | `true`     | Include `benchmarks/<name>.Benchmarks`                                     |
| `--includeExamples`   | `true`     | Include `examples/<name>.Example`                                          |
| `--includeDocs`       | `true`     | Include `docs/` stub                                                       |

### What gets generated

- .NET solution skeleton with shared settings in:
  - [Directory.Build.props](Directory.Build.props)
  - [Directory.Packages.props](Directory.Packages.props)
  - [global.json](global.json)
  - [NuGet.config](templates/AddNewPackage/content/NuGet.config)
- Workflows from org templates: CI, Prerelease, Release, ClearCache under `.github/workflows/`
- Dependabot config in `.github/dependabot.yml`
- Library project `src/<name>/` with SPDX headers and XML docs enabled
- Standard file structure:

  ```text
  vm2.<name>/
  ├── .github/
  │   └── dependabot.yml
  │   └── workflows/
  │       ├── ClearCache.yaml
  │       ├── CI.yaml
  │       ├── Prerelease.yaml
  │       └── Release.yaml
  ├── benchmarks/               # Benchmark projects (recommended)
  │   └── vm2.<name>.Benchmarks/
  ├── src/                      # Source code
  │   └── vm2.<name>/
  ├── test/                     # Test projects (highly recommended)
  │   └── vm2.<name>.Tests/
  ├── .editorconfig
  ├── .gitattributes
  ├── .gitignore
  ├── codecov.yml
  ├── Directory.Build.props
  ├── Directory.Packages.props
  ├── global.json
  ├── test.runsettings
  ├── README.md
  ├── LICENSE
  └── CHANGELOG.md
  ```

- tests under `test/<name>.Tests/` (xUnit + FluentAssertions + MTP + coverage)
  - MTP v1 when built and run inside Visual Studio Test Explorer
  - MTP v2 when run via `dotnet run` CLI, or run the test executable, or in Visual Studio Code Test Explorer
- optional benchmarks under `benchmarks/<name>.Benchmarks/` using BenchmarkDotNet
- optional console example under `examples/<name>.Example/`
- scripts folder with bootstrap helper and `_common.sh` and `_common.github.sh` utilities
- Packaging metadata patterned after vm2.Ulid (packable, SourceLink, MinVer tag prefix `v`, README/CHANGELOG/LICENSE packing entries).

### Bootstrap script (generated)

`scripts/bootstrap-new-package.sh` (SPDX uses selected license) will:

- Require `gh` and authentication
- Create repo `vm2.<name>` under `--org` (default `vmelamed`) with `--visibility` (default `private`)
- Init git if needed, commit scaffold, set origin, push `main`.

### After generation

1. Set required secrets in the new GitHub repo:
   - `CODECOV_TOKEN`
   - `BENCHER_API_TOKEN`
   - NuGet API keys - at least one of them must be defined and it must match the selected `NUGET_SERVER` (below)
     - `NUGET_API_GITHUB_KEY`
     - `NUGET_API_NUGET_KEY`
     - `NUGET_API_KEY` (if NUGET_SERVER is set to a custom server)
1. Set debug flags (variables):
   - `ACTIONS_RUNNER_DEBUG`: `false`: Whether to enable GitHub Actions runner debug logging
   - `ACTIONS_STEP_DEBUG`: `false`: Whether to enable GitHub Actions step debug logging
1. Set required variables:
   - `CONFIGURATION`: `Release`: the build configuration to use (e.g., Release or Debug)
   - `DOTNET_VERSION`: `10.0.x`: the .NET SDK version to use
   - `MAX_REGRESSION_PCT`: `20`%: Maximum allowed regression percentage
   - `MINVERTAGPREFIX`: `v`: Prefix for git tags to be recognized by MinVer
   - `MIN_COVERAGE_PCT`: `80`%: Minimum code coverage percentage required
   - `NUGET_SERVER`: `github`: the NuGet server to publish to (supported values: 'github', 'nuget', or custom URI)
   - `SAVE_PACKAGE_ARTIFACTS`: `false`: Whether to save package artifacts after build/publish
   - `SEMVER_PRERELEASE_PREFIX`: `preview`: Prefix for the prerelease tag, e.g. 'preview', 'alpha', 'beta', 'rc', etc.
1. Protect `main` with required checks and require PRs. Suggested check names:
   - `build` (job id from CI workflow "CI: Build, Test, Benchmark")
   - `test` (job id from CI workflow "CI: Build, Test, Benchmark")
   - `benchmark` (job id from CI workflow "CI: Build, Test, Benchmark")

1) Update README/CHANGELOG content and package metadata as needed.

### Repo layout

- templates/AddNewPackage/.template.config: template definition
- templates/AddNewPackage/content: payload files used by `dotnet new`
- scripts/: shared helper scripts (copied into generated repos)

### Development notes

- Keep template content minimal and rely on shared props/central package management.
- Optional folders are conditionally excluded based on include flags.
- Bootstrap script follows the style of vm2.DevOps `_common.sh`/`_common.github.sh` helpers for consistency.
