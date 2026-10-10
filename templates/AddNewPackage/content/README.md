# vm2.MyPackage

A starter vm2 package scaffold. Customize the code, tests, benchmarks, docs, and workflows as needed.

## Getting started

- Build:

  ```bash
  dotnet restore
  dotnet build
  ```

- Test:
  - from **CLI**, if it is not built yet (builds on MTP v2):

    ```bash
    dotnet run --project tests/MyPackage.Tests/MyPackage.Tests.csproj
    ```

  - from **CLI**, if it is already built in **CLI** or **VSCode** (MTP v2):
    - any OS or shell:

      ```bash
      dotnet test tests/MyPackage.Tests/bin/Debug/net10.0/MyPackage.Tests.dll
      ```

    - on Windows **CLI** (already built in **CLI** or **VSCode** - on MTP v2):

      ```batch
      tests/MyPackage.Tests/bin/Debug/net10.0/MyPackage.Tests.exe
      ```

    - on Linux or MacOS **CLI** (already built in **CLI** or **VSCode** - on MTP v2):

      ```bash
      tests/MyPackage.Tests/bin/Debug/net10.0/MyPackage.Tests
      ```

  - from Visual Studio:
    - use the Test Explorer to build and run tests (builds on MTP v1)
    - if it is already built in **Visual Studio** (MTP v1), from the **CLI** you can run:

      ```bash
      dotnet test
      ```

- Benchmarks (if included):

  ```bash
  dotnet run --project benchmarks/MyPackage.Benchmarks/MyPackage.Benchmarks.csproj --configuration Release
  ```

  > [!TIP]
  > In a personal development environment, you can run benchmarks with defined `SHORT_RUN` preprocessor directive. The
  run will be faster, although less accurate, but still suitable for quick iterations.

## Package metadata

- Package ID: `vm2.MyPackage`
- Version: {{initialVersion}}
- License: {{license}}
- Repository: <https://github.com/{{repositoryOrg}}/vm2.MyPackage>

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
  │       ├── <name>.Benchmarks.csproj
  │       ├── Program.cs
  │       └── usings.cs
  ├── changelog/                # git-cliff toml files for updating the Changelog from commit messages
  │   ├── cliff.prerelease.toml *
  │   └── cliff.release.toml *
  ├── docs/                     # Extra documentation - in addition to the README.md in the repo root (optional)
  │   └── README.md
  ├── examples/                 # Example program(s) (one file program(s) or project(s) - optional)
  │   └── Program.cs
  ├── src/                      # Source code
  │   └── <name>/
  │       ├── <name>.csproj
  │       ├── <name>.Api.cs
  │       └── usings.cs
  ├── tests/                    # Test projects (highly recommended)
  │   └── <name>.Tests/
  │       ├── <name>.Tests.csproj
  │       ├── <name>ApiTests.cs
  │       └── usings.cs
  ├── .editorconfig *
  ├── .gitattributes *
  ├── .gitmessage *
  ├── .gitignore *
  ├── CLAUDE.md
  ├── codecov.yaml *
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

- .github/workflows: CI, prerelease, release, clear-cache.
- src/MyPackage: the library source code
- tests/MyPackage.Tests: xUnit + MTP tests, includes testconfig.json
- benchmarks/MyPackage.Benchmarks: BenchmarkDotNet suite (optional)
- examples/MyPackage.Example: minimal console sample (optional)
- docs/: documentation starter (optional)
- scripts/: bootstrap helpers
- changelog/: git-cliff configs for prerelease/release changelog updates

## Next steps

Build the project using the following command:

```bash
dotnet build
```
