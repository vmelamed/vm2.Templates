# Copilot Instructions for vm2.Templates

## Shared Conventions

Copilot MUST read and follow [CONVENTIONS.md](CONVENTIONS.md) before suggesting or making changes.

Do not duplicate shared rules here — shared instructions belong in [CONVENTIONS.md](CONVENTIONS.md) so all AI systems
use the same source of truth.

## Package-Specific Guidance

This package contains templates for creating new projects within the vm2 ecosystem. It provides a standardized structure and shared conventions to ensure consistency across all projects. Copilot SHOULD use these templates as a reference when suggesting new project structures or modifications.

For now the templates are primarily focused on setting up new package projects. Copilot SHOULD prioritize these templates when suggesting structures for new package projects and follow the conventions established within them.

Note that the content of the templates should be treated as canonical examples for setting up new package projects. Copilot SHOULD refer to these templates to ensure that any new package projects adhere to the established structure and conventions. Also, the content is the source of truth for the contents of the new and the existing package projects within the vm2 ecosystem. It is used by `$VM2_REPOS/scripts/bash/diff-shared.sh` to compare the shared template content against the existing package projects and copy or highlight any differences that need to be reconciled or merged.

## Package Identity

- Repo: <https://github.com/vmelamed/vm2.Templates>
- NuGet: <https://github.com/vmelamed/vm2.Templates/pkgs/nuget/vm2.Templates>
- Status: stable
- Target: .NET 10.0+

## What This Package Does

This repo contains a template for creating new .NET projects for NuGet packages with a command like `dotnet new vm2pkg --name newPackage --output $VM2_REPOS/vm2.newPackage`. It is installed from a NuGet feed (GitHub packages), e.g.:

```bash
dotnet new install vm2.Templates --nuget-source github
```

The only template currently provided is `vm2pkg`.

## Common Commands

### To install a template locally from the directory of the source code

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
>  --name github \
>  --username vmelamed \
>  --password <GITHUB_TOKEN> \
>  --store-password-in-clear-text
> ```

Then you can install the templates with the shorter form of the command:

```bash
dotnet new install vm2.Templates --nuget-source github
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
> You may first uninstall the previous version of the template and then install the new one with:
>
> ```bash
> dotnet new uninstall vm2.Templates  &&  dotnet new install vm2.Templates --nuget-source github
> ```

Now you are ready to use the templates with `dotnet new vm2pkg --name <package-project-name> --output $VM2_REPOS/vm2.<package-project-name>`.

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

## Known Trade-offs and Design Notes

Most of the infrastructure files (e.g., .editorconfig, .gitignore, Directory.*.props, CI/CD workflow yaml files in .github/workflows/) in the `templates/` directory are considered to be the canonical **source of truth** for all projects. These files may drift over time as the ecosystem evolves. The utility script `diff-shared.sh` is used to synchronize (copy or merge) the changes in the shared content from the template files to the actual project files, ensuring that updates and improvements in the templates are propagated to all projects consistently.

## Active Work / Known Issues

### Issue: Double Prefixing with vm2

The solution file and other artifacts have vm2. hardcoded as a prefix, e.g., `vm2.MyPackage.slnx`. When a user passes `--name vm2.test1`, MyPackage is replaced by `vm2.test1` everywhere, so `vm2.MyPackage` becomes `vm2.vm2.test1`. We get a double prefix because `sourceName` replaces `MyPackage` literally everywhere including inside the vm2. prefix that's hardcoded in filenames, so there's no way to strip it at the template level without restructuring the file tree. For now the solution is to enter

```bash
dotnet new vm2pkg --name newPackage --output $VM2_REPOS/vm2.newPackage
```

Ideally the template should be smart enough to detect and avoid double prefixing.
