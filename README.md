# vm2.Templates

<!-- TOC tocDepth:2..3 chapterDepth:2..6 -->

- [vm2.Templates](#vm2templates)
  - [Install a template](#install-a-template)
    - [To install a template locally from the source code in the current directory](#to-install-a-template-locally-from-the-source-code-in-the-current-directory)
    - [To install a template globally from a NuGet feed](#to-install-a-template-globally-from-a-nuget-feed)
  - [vm2 Add New NuGet Package Solution (**`vm2pkg`**)](#vm2-add-new-nuget-package-solution-vm2pkg)
    - [Prerequisites](#prerequisites)
    - [Create a package scaffolding](#create-a-package-scaffolding)
    - [Template parameters (key ones)](#template-parameters-key-ones)
    - [What gets generated](#what-gets-generated)
    - [After adding a package project use `setup-repo.sh`](#after-adding-a-package-project-use-setup-reposh)
    - [This Repo Layout](#this-repo-layout)
    - [Development Notes](#development-notes)

<!-- /TOC -->

This repo contains templates for creating new .NET projects for packages that can be installed with `dotnet add package <PACKAGE>` from a NuGet feed.

## Install a template

### To install a template locally from the source code in the current directory

```bash
dotnet new install .
```

or, if there were any changes to an already installed template:

```bash
dotnet new install . --force
```

### To install a template globally from a NuGet feed

```bash
dotnet new install vm2.Templates --add-source "https://nuget.pkg.github.com/vmelamed/index.json" --interactive
```

`vm2.Templates` (and `vm2.TestUtilities`) can be found on the NuGet feed GitHub packages, which requires authentication. From the [GitHub documentation](https://github.com/copilot/c/f6ece879-48e3-4574-8da3-b0fc4185293a):

> [sic] *... add the GitHub Packages feed to NuGet first, then install from it. In practice that usually means configuring the GitHub Packages NuGet source with your GitHub username and a token that has package read access, then running dotnet new install against that source. The dotnet new docs also note it resolves packages from configured NuGet sources for the current directory, plus any source passed on the command line. (learn.microsoft.com)*:

E.g.:

> ```bash
> dotnet nuget add source "https://nuget.pkg.github.com/vmelamed/index.json" \
>  --name github.vm2 \
>  --username vmelamed \
>  --store-password-in-clear-text \
>  --password <GITHUB_TOKEN>
> ```

Then you can install the templates with:

```bash
dotnet new install vm2.Templates --nuget-source github.vm2
```

In subsequent installs, if you have a local or a previous version of a global installation of the template, then you may see a message similar to:

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
> You may want to first uninstall the previous version of the template and then install the new one with:
>
> ```bash
> dotnet new uninstall vm2.Templates  &&  dotnet new install vm2.Templates --nuget-source github.vm2
> ```

Now you are ready to use the templates with `dotnet new vm2pkg <package-project-name>`.

## vm2 Add New NuGet Package Solution (**`vm2pkg`**)

The first template is **vm2 Add New NuGet Package Solution (short name `vm2pkg`)**, which scaffolds a new .NET package
repository with conventional structure, GitHub Actions workflows, and optional components.

### Prerequisites

- .NET SDK 10.0.x
- `gh` CLI (used by the generated bootstrap script)

### Create a package scaffolding

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

Then run the generated `scripts/setup-repo.sh` to create and push the GitHub repo (uses `gh repo create`, default visibility
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
  │   ├── CONVENTIONS.md *      # Claude conventions for contributing to the repo
  │   ├── PULL_REQUEST_TEMPLATE.md *
  │   ├── copilot-instructions.md
  │   ├── dependabot.yml *      # dependabot configuration (see note below)
  │   └── workflows/            # GitHub Actions workflows
  │       ├── AutoMerge.yaml *
  │       ├── CI.yaml **
  │       ├── ClearCache.yaml *
  │       ├── Prerelease.yaml **
  │       ├── RebuildBenchHistory.yaml *
  │       ├── RefreshLockFiles.yaml *
  │       └── Release.yaml **
  ├── benchmarks/               # Benchmark projects (recommended)
  │   └── <name>.Benchmarks/
  │       ├── <name>.Benchmarks.csproj
  │       ├── usings.cs
  │       ├── EchoBenchmarks.cs
  │       └── Program.cs
  ├── changelog/                # git-cliff toml files for updating the Changelog from commit messages
  │   ├── cliff.prerelease.toml *
  │   └── cliff.release.toml *
  ├── docs/                     # Extra package documentation - in addition to the README.md in the repo root (optional)
  │   └── README.md
  ├── examples/                 # Example program(s) (one file program(s) or project(s) - optional)
  │   └── Program.cs
  ├── src/                      # Source code
  │   └── <name>/
  │       ├── <name>.csproj
  │       ├── <name>Api.cs
  |       └── usings.cs
  ├── tests/                    # Test projects (highly recommended)
  │   └── <name>.Tests/
  │       ├── <name>.Tests.csproj
  │       ├── <name>ApiTests.cs
  |       └── usings.cs
  ├── .editorconfig *
  ├── .gitattributes *
  ├── .gitignore *
  ├── .gitmessage *
  ├── CHANGELOG.md
  ├── CLAUDE.md
  ├── Directory.Build.props **
  ├── Directory.Packages.props **
  ├── LICENSE *
  ├── NuGet.config *
  ├── README.md
  ├── codecov.yaml *
  ├── coverage.settings.xml *
  ├── global.json *
  ├── testconfig.json *
  └── vm2.<name>.slnx
  ```

---
> [!NOTE]
> The files marked with asterisk(s) **\*** or **\*\*** are the "source-of-truth" files (SoT) that contain shared content between all repos
> in the `vm2` workspace. To propagate and or update the shared content from this folder to one or more repos in this workspace, use
> the `diff-shared.sh` script - a configurable tool that is used to diff, and copy or merge content from the source SoT files \
> in the `vm2.Templates` project to one or more target repos, like the newly created `vm2.<name>` repo. The files marked with
> - **\*** indicates files that by default are copied from the template content folder without modification, e.g.
>      `.editorconfig`, `codecov.yaml`, `global.json`, etc.
> - **\*\*** indicate files that are diff-ed and then copied to (if missing) or merged with the existing file in the target
> repo, e.g.
      `Directory.Build.props` and `Directory.Packages.props`, which contain a lot of shared content but also have repo-specific content (e.g. package references, project references, etc.) that needs to be preserved.
>
> For more details on how to use the `diff-shared.sh` script, see the [tool's documentation](../vm2.DevOps/docs/diff-shared.md)

---

> [!WARNING]
> Note that GitHub only recognizes the **`dependabot.yml`** filename, not `dependabot.yAml`

---

- tests under `tests/<name>.Tests/`: xUnit + FluentAssertions + MTP + coverage + MTP v2
- optional benchmarks project under `benchmarks/<name>.Benchmarks/` using BenchmarkDotNet
- optional console example single file program: `examples/Program.cs/`

### After adding a package project use `setup-repo.sh`

Create GitHub repository using the generated bootstrap script: `$VM2_REPOS/vm2.DevOps/scripts/bash/setup-repo.sh`. It will:
- Update README, CHANGELOG, and package metadata.
- Use the repository setup script `scripts/setup-repo.sh` to initialize the repository as follows:
  - create a local Git  repository and make the initial commit
  - set local Git configuration settings:
    - core.hooksPath                       = `$VM2_REPOS/vm2.DevOps/scripts/githooks`
    - commit.template                      = `.gitmessage`
    - merge.ff                             = `only`
    - **pull.rebase                          = `true`**
    - fetch.prune                          = `true`
    - push.autoSetupRemote                 = `true`
    - rerere.enabled                       = `true`
    - rerere.autoUpdate                    = `true`
    - rebase.autoStash                     = `true`
    - merge.conflictstyle                  = `zdiff3`
    - push.useForceIfIncludes              = `true`
    - tag.sort                             = `version:refname`
    - merge.nugetlock.name                 = `NuGet lockfile - take the incoming side and regenerate`
    - merge.nugetlock.driver               = `cp -f %B %A && echo "vm2: %P auto-resolved (took the incoming side) - regenerate with: dotnet restore --force-evaluate" >&2`
  - create a remote repository on GitHub and link it to the local repository
  - push the initial commit to the remote repository on GitHub
  - set repository settings:
    - **Default branch                       = `main`**
    - Has wiki                             = `false`
    - Has issues                           = `true`
    - Has projects                         = `false`
    - **Has pull requests                    = `true`**
    - Pull request creation policy         = `all`
    - Allow merge commit                   = `false`
    - Allow squash merge                   = `false`
    - **Allow rebase merge                   = `true`**
    - Allow auto merge                     = `true`
    - Delete branch on merge               = `true`
    - Visibility                           = `public`
    - Actions permissions:
      - Can approve pull request reviews   = true
      - Default workflow permissions       = read
  - protect the `main` branch by enabling required checks and requiring pull requests:
    - Enforcement                          = `active`
    - Repository admin bypass              = present
    - Deletion                             = present
    - Required linear history              = present
    - Pull request                         = present
    - Required approving review count      = present
    - Dismiss stale reviews on push        = present
    - Require code owner review            = present
    - Require last push approval           = present
    - Required review thread resolution    = present
    - Required reviewers                   = present
    - Allowed merge methods                = present
    - Required status checks               = present
    - Do not enforce on create             = present
    - Strict required status checks policy = present
    - Non fast forward                     = present
    - Required status checks list:
      - **Postrun-CI                           = present** (combines the results from build, test, benchmark, test package)
  - **interactively** set required variables for workflows:
    - CONFIGURATION                        = `Release`
    - DOTNET_VERSION                       = `10.0.x`
    - MAX_GEN1_COLLECTS                    = `2`
    - MAX_GEN2_COLLECTS                    = `1`
    - MAX_REGRESSION_PCT                   = `20`
    - MIN_COVERAGE_PCT                     = `80`
    - MINVERDEFAULTPRERELEASEIDENTIFIERS   = `preview.0`
    - MINVERTAGPREFIX                      = `v`
    - NUGET_SERVER                         = `github` (can be also `nuget`)
    - RESET_BENCHMARK_THRESHOLDS           = `false`
    - SAVE_PACKAGE_ARTIFACTS               = `false`
    - VERBOSE                              = `false` (use for workflow debugging)
    - ACTIONS_RUNNER_DEBUG                 = `false`
    - ACTIONS_STEP_DEBUG                   = `false`
  - **interactively** set required secrets for workflows (prepare the secrets in advance):
    - BENCH_DISPATCH_PAT                   = [secret]
    - BENCHER_API_TOKEN                    = [secret]
    - CODECOV_TOKEN                        = [secret]
    - NUGET_API_KEY                        = [secret]
    - RELEASE_PAT                          = [secret]
    - REPORTGENERATOR_LICENSE              = [secret]
    - Dependabot Secrets:
      - GH_PACKAGES_TOKEN                    = [secret]
- Changelog: prerelease workflow appends a prerelease section; release workflow adds a stable header with "See prereleases below." (prerelease sections stay intact).

> [!NOTE]
> The above settings and configurations **may change** over time and should be reviewed periodically to ensure they align with the desired workflow and security practices. The source of truth is the up-to-date script `setup-repo.sh`. It is idempotent and can be run multiple times without causing unintended side effects. Also, can be run with option `--audit` to review the current settings and configurations against the defaults without making any changes.

### This Repo Layout

- templates/AddNewPackage/.template.config: template definition
- templates/AddNewPackage/content: payload files used by `dotnet new`

### Development Notes

- Keep template content minimal and rely on shared props/central package management.
- Optional folders are conditionally excluded based on include flags.
