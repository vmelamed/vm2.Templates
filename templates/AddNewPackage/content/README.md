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
    dotnet run --project test/MyPackage.Tests/MyPackage.Tests.csproj`
    ```

  - from **CLI**, if it is already built in **CLI** or **VSCode** (MTP v2):
    - any OS or shell:

      ```bash
      dotnet test test/MyPackage.Tests/bin/Debug/net10.0/MyPackage.Tests.dll`
      ```

    - on Windows **CLI** (already built in **CLI** or **VSCode** - on MTP v2):

      ```batch
      test/MyPackage.Tests/bin/Debug/net10.0/MyPackage.Tests.exe`
      ```

    - on Linux or MacOS **CLI** (already built in **CLI** or **VSCode** - on MTP v2):

      ```bash
      test/MyPackage.Tests/bin/Debug/net10.0/MyPackage.Tests`
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

  > **Hint**: in a personal development environment, you can run benchmarks with defined `SHORT_RUN` preprocessor directive. The run will be faster, although less accurate, but still suitable for quick iterations.

## Package metadata

- Package ID: `vm2.MyPackage`
- Version: {{initialVersion}}
- License: {{license}}
- Repository: <https://github.com/{{repositoryOrg}}/vm2.MyPackage>

## Structure

- .github/workflows: CI, prerelease, release, clear-cache.
- src/MyPackage: the library source code
- test/MyPackage.Tests: xUnit + MTP tests, includes testconfig.json
- benchmarks/MyPackage.Benchmarks: BenchmarkDotNet suite (optional)
- examples/MyPackage.Example: minimal console sample (optional)
- docs/: documentation starter (optional)
- scripts/: bootstrap helpers
- changelog/: git-cliff configs for prerelease/release changelog updates

## Next steps

- create GitHub repository using the generated bootstrap script: `scripts/bootstrap-new-package.sh`
- Update README, CHANGELOG, and package metadata.
- Set secrets and variables for workflows:
  - Set required secrets in the new GitHub repo:
    - `CODECOV_TOKEN`
    - `BENCHER_API_TOKEN`
    - NuGet API keys - at least one of them must be defined and it must match the selected `NUGET_SERVER` (below)
      - `NUGET_API_GITHUB_KEY`
      - `NUGET_API_NUGET_KEY`
      - `NUGET_API_KEY` (if NUGET_SERVER is set to a custom server)
  - Set required variables:
    - `DOTNET_VERSION`: `10.0.x`: the .NET SDK version to use
    - `CONFIGURATION`: `Release`: the build configuration to use (e.g., Release or Debug)
    - `NUGET_SERVER`: `github`: the NuGet server to publish to (supported values: 'github', 'nuget', or custom URI)
    - `MINVERTAGPREFIX`: `v`: Prefix for git tags to be recognized by MinVer
    - `MINVERDEFAULTPRERELEASEIDENTIFIERS`: `.0`: Prefix for the prerelease tag, e.g. 'preview.0', 'alpha', 'beta', 'rc', etc.
    - `SAVE_PACKAGE_ARTIFACTS`: `false`: Whether to save package artifacts after build/publish
    - `MIN_COVERAGE_PCT`: `80`%: Minimum code coverage percentage required
    - `MAX_REGRESSION_PCT`: `20`%: Maximum allowed regression percentage
  - Set debug flags (variables):
    - `ACTIONS_RUNNER_DEBUG`: `false`: Whether to enable GitHub Actions runner debug logging
    - `ACTIONS_STEP_DEBUG`: `false`: Whether to enable GitHub Actions step debug logging

- Protect the `main` branch by enabling required checks and requiring pull requests. Suggested check names:
  - `build` (job id from CI workflow "CI: Build, Test, Benchmark")
  - `test` (job id from CI workflow "CI: Build, Test, Benchmark")
  - `benchmark` (job id from CI workflow "CI: Build, Test, Benchmark")
- Changelog: prerelease workflow appends a prerelease section; release workflow adds a stable header with "See prereleases below." (prerelease sections stay intact).
