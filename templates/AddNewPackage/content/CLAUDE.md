# vm2.MyPackage — Claude Context

@~/.claude/CLAUDE.md
@~/repos/vm2/CLAUDE.md
@.github/CONVENTIONS.md

## Package Identity

- Repo: <https://github.com/{{repositoryOrg}}/vm2.MyPackage>
- NuGet: <https://www.nuget.org/packages/vm2.MyPackage/>
- Status: *TODO* — e.g., In design / Unpublished / Published, stable
- Target: .NET 10.0+

## What This Package Does

*TODO* One-paragraph description of the package's purpose and the problem it solves.

Key design decisions:

- *TODO*

## Repository Layout

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
  │       └── usings.cs
  ├── test/                     # Test projects (highly recommended)
  │   └── vm2.<name>.Tests/
  │       ├── MyPackage.Tests.csproj
  │       ├── MyPackageApiTests.cs
  │       └── usings.cs
  ├── .editorconfig *
  ├── .gitattributes *
  ├── .gitmessage *
  ├── .gitignore *
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

## Common Local Commands

```bash
# Build
dotnet build vm2.MyPackage.slnx

# Run all tests (MTP v2 — each project is a compiled executable)
dotnet test --project test/MyPackage.Tests/MyPackage.Tests.csproj

# Run a single test by name (MTP v2 filter syntax)
dotnet test --project test/MyPackage.Tests/MyPackage.Tests.csproj --filter "MethodName_WhenCondition_ShouldOutcome"

# Pack NuGet package
dotnet pack vm2.MyPackage.slnx --configuration Release

# Run benchmarks (Release only)
dotnet run --project benchmarks/MyPackage.Benchmarks --configuration Release -- --filter "*"
```

Tests use MTP v2 (Microsoft Testing Platform v2) with xUnit v3 — they compile to standalone executables.
Use `dotnet test --project <path>` per project; solution-wide `dotnet test` is not supported with MTP v2.

## Performance Characteristics

- *TODO* Hot paths, allocation behavior, benchmark numbers if known.

## Known Trade-offs and Design Notes

- *TODO*

## Active Work / Known Issues

- *TODO*

## Prompting Notes for This Package

- *TODO* Key invariants Claude must preserve, what to inject for testability, any non-obvious constraints.
