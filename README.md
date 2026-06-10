# vm2.Templates

<!-- TOC tocDepth:2..3 chapterDepth:2..6 -->

- [vm2.Templates](#vm2templates)
  - [Install a template](#install-a-template)
    - [To install a template locally](#to-install-a-template-locally)
    - [To install a template globally](#to-install-a-template-globally)
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

## Install a template

### To install a template locally

```bash
dotnet new install .
```

or, if there were any changes to an already installed template:

```bash
dotnet new install . --force
```

### To install a template globally

```bash
dotnet new install vm2.Templates --add-source "https://nuget.pkg.github.com/vmelamed/index.json" --interactive
```

> From the [GitHub documentation](https://github.com/copilot/c/f6ece879-48e3-4574-8da3-b0fc4185293a):
>
> *If authentication is required, add the GitHub Packages feed to NuGet first, then install from it. In practice that usually means configuring the GitHub Packages NuGet source with your GitHub username and a token that has package read access, then running dotnet new install against that source. The dotnet new docs also note it resolves packages from configured NuGet sources for the current directory, plus any source passed on the command line. (learn.microsoft.com)*:
>
> ```bash
> dotnet nuget add source "https://nuget.pkg.github.com/vmelamed/index.json" \
>  --name github \
>  --username vmelamed \
>  --password <GITHUB_TOKEN> \
>  --store-password-in-clear-text
> ```

Then you can install the templates with:

```bash
dotnet new install vm2.Templates --nuget-source github
```

If you see a message similar to:

```text
The following template packages will be installed:
   /home/valo/repos/vm2/vm2.Templates

Warning:
The following templates use the same identity 'vm2.Templates.AddNewPackage':
  * 'vm2 NuGet Package Solution with GitHub Repository, Actions' from 'vm2.templates@X.Y.Z'
  * 'vm2 NuGet Package Solution with GitHub Repository, Actions' from '/home/valo/repos/vm2/vm2.Templates'
The template from 'vm2 NuGet Package Solution with GitHub Repository, Actions' will be used. To resolve this conflict, uninstall the conflicting template packages.
Success: /home/valo/repos/vm2/vm2.Templates installed the following templates:
Template Name                                               Short Name  Language  Tags
----------------------------------------------------------  ----------  --------  --------------------------------------------------
vm2 NuGet Package Solution with GitHub Repository, Actions  vm2pkg      [C#]      vm2/NuGet/Package/Repository/GitHub/GitHub Actions
```

> [!IMPORTANT]
> You may first uninstall the previously installed template and then install the new one with:
>
> ```bash
> dotnet new uninstall vm2.Templates  &&  dotnet new install vm2.Templates --nuget-source github
> ```

Now you are ready to use the templates with `dotnet new <template-name>`.

## vm2 Add New NuGet Package Solution (**`vm2pkg`**)

The first template is **vm2 Add New NuGet Package Solution (short name `vm2pkg`)**, which scaffolds a new .NET package
repository with conventional structure, GitHub Actions workflows, and optional components.

### Prerequisites

- .NET SDK 10.0.x
- `gh` CLI (used by the generated bootstrap script)

### Create a package scaffold

```bash
dotnet new vm2pkg \
  --name <PACKAGE> \
  --output $VM2_REPOS/vm2.<PACKAGE> \
  --initialVersion 0.0.0 \
  --repositoryOrg vmelamed \
  --includeTests true \
  --includeBenchmarks true \
  --includeExamples true \
  --includeDocs true \
  --license MIT
```

Then run the generated `scripts/repo-setup.sh` to create and push the GitHub repo (uses `gh repo create`, default visibility
public, requires authentication).

### Template parameters (key ones)

| Parameter             | Default    | Description                                                                |
| :-------------------- | :--------- | :------------------------------------------------------------------------- |
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
  │   ├── dependabot.yml *      # dependabot configuration (see note below)
  │   ├── CONVENTIONS.md *      # Claude conventions for contributing to the repo
  │   ├── copilot-instructions.md
  │   ├── PULL_REQUEST_TEMPLATE.md *
  │   └── workflows/            # GitHub Actions workflows
  │       ├── AutoMerge.yaml *
  │       ├── ClearCache.yaml *
  │       ├── CI.yaml **
  │       ├── Prerelease.yaml **
  │       └── Release.yaml **
  ├── benchmarks/               # Benchmark projects (recommended)
  │   └── vm2.<name>.Benchmarks/
  │       ├── EchoBenchmarks.cs
  │       ├── vm2.<name>.Benchmarks.cs
  │       ├── Program.cs
  │       └── usings.cs
  ├── changelog/                # git-cliff toml files for updating the Changelog from commit messages
  │   ├── cliff-prerelease.toml *
  │   └── cliff-release.toml *
  ├── docs/                     # Extra documentation - in addition to the README.md in the repo root (optional)
  │   └── README.md
  ├── examples/                 # Example program(s) (one file program(s) or project(s) - optional)
  │   └── Program.cs
  ├── src/                      # Source code
  │   └── vm2.<name>/
  │       ├── MyPackage.csproj
  │       ├── MyPackage.Api.cs
  |       └── usings.cs
  ├── tests/                    # Test projects (highly recommended)
  │   └── vm2.<name>.Tests/
  │       ├── MyPackage.Tests.csproj
  │       ├── MyPackageApiTests.cs
  |       └── usings.cs
  ├── .editorconfig *
  ├── .gitattributes *
  ├── .gitmessage *
  ├── .gitignore *
  ├── CHANGELOG.md
  ├── CLAUDE.md
  ├── codecov.yml *
  ├── coverage.settings.xml *
  ├── Directory.Build.props **
  ├── Directory.Packages.props **
  ├── global.json *
  ├── LICENSE *
  ├── NuGet.config *
  ├── README.md
  ├── testconfig.json *
  ├── vm2.MyPackage.slnx
  └── CHANGELOG.md
  ```

---
> [!NOTE]
> The files marked with asterisk(s) **\*** or **\*\*** are the "source-of-truth" files (SoT) that contain shared content between all repos
> in this workspace. To propagate and or update the shared content from this folder to one or more repos in this workspace, use
> the `diff-shared.sh` script - a configurable tool that is used to diff, and copy or merge content from the source SoT files \
> in this project to one or more target repos, with token replacement. The files marked with
>
> - **\*** indicates files that by default are copied from the template content folder without modification, e.g.
>      `.editorconfig`, `codecov.yml`, `global.json`, etc.
> - **\*\*** indicate files that are diff-ed and then copied to (if missing) or merged with the existing file in the target
> repo, e.g.
      `Directory.Build.props` and `Directory.Packages.props`, which contain shared content but also have repo-specific content (e.g. package references, project references, etc.) that needs to be preserved.
>
> For more details on how to use the `diff-shared.sh` script, see the [tool's documentation](../vm2.DevOps/docs/diff-shared.md)

---

> [!WARNING]
> Note that GitHub only recognizes the `dependabot.yml` filename, not `dependabot.yAml`

---

- tests under `tests/<name>.Tests/` (xUnit + FluentAssertions + MTP + coverage)
  - MTP v1 when built and run inside Visual Studio Test Explorer
  - MTP v2 when run via `dotnet run` CLI, or run the test executable, or in Visual Studio Code Test Explorer
- optional benchmarks project under `benchmarks/<name>.Benchmarks/` using BenchmarkDotNet
- optional console example single file program: `examples/Program.cs/`

### Bootstrap script (generated)

`scripts/repo-setup.sh` (SPDX uses selected license) will:

- Require `gh` and authentication
- Create repo `vm2.<name>` under `--org` (default `vmelamed`) with `--visibility` (default `private`)
- Init git if needed, commit scaffold, set origin, push `main`.

### After generation

1. Set required secrets in the new GitHub repo:
   - `BENCHER_API_TOKEN`
   - `CODECOV_TOKEN` - **one for each repo!**
   - `NUGET_API_KEY` - must be issued by the selected `NUGET_SERVER`: NuGet or GitHub Packages
   - `RELEASE_PAT`
   - `REPORTGENERATOR_LICENSE` - license key
   - `GH_PACKAGES_TOKEN` - GitHub token with `read:packages` and `write:packages` scopes

1. Variables
   1. Set required variables:
      - `CONFIGURATION`: `Release`: the build configuration to use (e.g., Release or Debug)
      - `DOTNET_VERSION`: `10.0.x`: the .NET SDK version to use
      - `MAX_REGRESSION_PCT`: `20`%: Maximum allowed regression percentage
      - `MINVERTAGPREFIX`: `v`: Prefix for git tags to be recognized by MinVer
      - `MIN_COVERAGE_PCT`: `80`%: Minimum code coverage percentage required
      - `NUGET_SERVER`: `github`: the NuGet server to publish to (supported values: 'github', 'nuget', or custom URI)
      - `SAVE_PACKAGE_ARTIFACTS`: `false`: Whether to save package artifacts after build/publish
      - `MINVERDEFAULTPRERELEASEIDENTIFIERS`: `preview.0`: Prefix for the prerelease tag, e.g. 'preview.0', 'alpha', 'beta', 'rc',
        etc.
      - `RESET_BENCHMARK_THRESHOLDS`: `false`: Whether to reset Bencher thresholds
   1. Set debug flags (variables):
      - `ACTIONS_RUNNER_DEBUG`: `false`: Whether to enable GitHub Actions runner debug logging
      - `ACTIONS_STEP_DEBUG`: `false`: Whether to enable GitHub Actions step debug logging

1. Protect `main` with required checks and require PRs. Suggested check names:
   - `build` (job id from CI workflow "CI: Build, Test, Benchmark")
   - `test` (job id from CI workflow "CI: Build, Test, Benchmark")
   - `benchmark` (job id from CI workflow "CI: Build, Test, Benchmark")
1. Update README/CHANGELOG content and package metadata as needed.

### Repo layout

- templates/AddNewPackage/.template.config: template definition
- templates/AddNewPackage/content: payload files used by `dotnet new`
- scripts/: shared helper scripts (copied into generated repos)

### Development notes

- Keep template content minimal and rely on shared props/central package management.
- Optional folders are conditionally excluded based on include flags.
- Bootstrap script follows the style of vm2.DevOps `_common.sh`/`github.sh` helpers for consistency.
