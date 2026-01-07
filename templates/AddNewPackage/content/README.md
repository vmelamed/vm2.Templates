# vm2.MyPackage

A starter vm2 package scaffold. Customize the code, tests, benchmarks, docs, and workflows as needed.

## Getting started

```bash
dotnet restore
dotnet build
dotnet test
```

To run benchmarks (if included):

```bash
dotnet run --project benchmarks/MyPackage.Benchmarks/MyPackage.Benchmarks.csproj -c Release
```

## Package metadata

- Package ID: `vm2.MyPackage`
- Version: {{packageVersion}}
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

## Next steps

- Update README, CHANGELOG, and package metadata.
- Set secrets/variables for workflows (CODECOV_TOKEN, NUGET keys, etc.).
- Adjust branch protections to require build/tests/benchmarks/prerelease checks.
