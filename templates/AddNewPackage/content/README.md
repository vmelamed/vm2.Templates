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

  - from **CLI**, if it is already built in **CLI** or **VSCode**  (MTP v2):
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

- .github/workflows: CI, prerelease, release, clear-cache
- src/MyPackage: library source
- test/MyPackage.Tests: xUnit + MTP tests, includes testconfig.json
- benchmarks/MyPackage.Benchmarks: BenchmarkDotNet suite (optional)
- examples/MyPackage.Example: minimal console sample (optional)
- docs/: documentation starter (optional)
- scripts/: bootstrap helpers
- changelog/: git-cliff configs for prerelease/release changelog updates

## Next steps

- Update README, CHANGELOG, and package metadata.
- Set secrets/variables for workflows (CODECOV_TOKEN, NUGET keys, etc.).
- Adjust branch protections to require build/tests/benchmarks/prerelease checks.
- Set `NUGET_SERVER` (github | nuget | custom URI). Workflows map it to `NUGET_API_GITHUB_KEY`, `NUGET_API_NUGET_KEY`, or `NUGET_API_KEY`.
- Changelog: prerelease workflow appends a prerelease section; release workflow adds a stable header with "See prereleases below." (prerelease sections stay intact).
