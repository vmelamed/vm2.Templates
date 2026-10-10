# vm2.Templates

<!-- TOC tocDepth:2..3 chapterDepth:2..6 -->

- [Install a template](#install-a-template)
  - [To install a template locally from the source code in the current directory](#to-install-a-template-locally-from-the-source-code-in-the-current-directory)
  - [To install a template globally from a NuGet feed](#to-install-a-template-globally-from-a-nuget-feed)
- [vm2 Add New NuGet Package Solution (**`vm2pkg`**)](#vm2-add-new-nuget-package-solution-vm2pkg)
  - [Prerequisites](#prerequisites)
  - [Create a package scaffolding](#create-a-package-scaffolding)
  - [When the post-actions are skipped or fail](#when-the-post-actions-are-skipped-or-fail)
  - [Template parameters (key ones)](#template-parameters-key-ones)
  - [What gets generated](#what-gets-generated)
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

- Linux, or WSL on Windows: the vm2.DevOps tooling is bash-only. On Windows, install WSL and work inside it (clone the
  repositories into the WSL file system, not under `/mnt/c`, where git and `dotnet` are much slower).
- .NET SDK 10.0.x
- `gh` CLI (used by `setup-repo.sh`)
- vm2.DevOps and vm2.Templates cloned into `$VM2_REPOS`, both up to date with `origin/main`

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

After the files are generated, the template's post-actions offer to run vm2.DevOps's `setup-repo.sh` (creates and configures
the GitHub repository with `gh repo create`, default visibility public, requires authentication) and then `diff-shared.sh`
(syncs the shared files with the latest SoT). `dotnet new` asks before running each script (see `--allow-scripts`); if
you decline, or a step fails, it prints the command to run by hand. On a Windows host the scripts are never run: the
post-actions print the commands to run from WSL instead.

### When the post-actions are skipped or fail

The post-actions can legitimately stop short of finishing the setup. Nothing is lost: run the two scripts yourself,
in the same order, from a Linux or WSL terminal.

| What you see                                                                               | Why                                                                                                 | What to do                                                                                                  |
| :----------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------- |
| `Windows host detected: continue in WSL`                                                   | `dotnet new` ran on Windows; the scripts are bash-only, so they are skipped by design               | Run the commands below in WSL                                                                               |
| `Execution of 'Run script' post action is not allowed`                                     | You declined the prompt, or passed `--allow-scripts no`                                             | Run the commands below                                                                                      |
| A script step fails at once, without any prompt                                            | No terminal on stdin (e.g. stdin redirected, or `dotnet new` started by a tool rather than a shell) | Run the commands below in a terminal                                                                        |
| `No such file or directory` for a path starting with `/vm2.DevOps/`                        | `VM2_REPOS` is not set, or not exported, in the shell that ran `dotnet new`                         | `export VM2_REPOS=<the directory that contains all vm2 repositories>` (e.g. in `~/.bashrc`), then run below |
| `... of the repository 'vm2.DevOps' (or 'vm2.Templates') does not appear in a clean state` | That repository is not on `main`, has uncommitted changes, or is behind `origin/main`               | `git switch main && git pull` in it (commit or stash first); then run below                                 |
| `gh` authentication errors                                                                 | The GitHub CLI is not logged in                                                                     | `gh auth login`; then run below                                                                             |

```bash
# from a Linux or WSL terminal, with VM2_REPOS exported and pointing to the directory that contains all vm2 repositories
cd "$VM2_REPOS/vm2.<PACKAGE>"
"$VM2_REPOS/vm2.DevOps/scripts/bash/src/setup-repo.sh" --interactive-vars --interactive-secrets
"$VM2_REPOS/vm2.DevOps/scripts/bash/src/diff-shared.sh"
```

Both scripts are safe to run again: `setup-repo.sh` is idempotent (run it with `--audit` to compare the repository's
settings with the defaults without changing anything), and `diff-shared.sh` only compares and then copies or merges what
differs. The new repository must live directly under `$VM2_REPOS` (see `--output` above), where the scripts look for it.
For what `setup-repo.sh` configures, see its `--help` and
[vm2.DevOps/docs/CONFIGURATION.md](https://github.com/vmelamed/vm2.DevOps/blob/main/docs/CONFIGURATION.md).

> [!NOTE]
> When any post-action is declined or fails, `dotnet new` exits with code `104` even though the files were generated
> successfully. Scripts that call `dotnet new vm2pkg` should treat `104` as "files created, finish the setup by hand".

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

### This Repo Layout

- templates/AddNewPackage/.template.config: template definition
- templates/AddNewPackage/content: payload files used by `dotnet new`

### Development Notes

- Keep template content minimal and rely on shared props/central package management.
- Optional folders are conditionally excluded based on include flags.
