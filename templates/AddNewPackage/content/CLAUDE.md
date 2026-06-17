# vm2.MyPackage — Claude Context

@~/.claude/CLAUDE.md
@~/repos/vm2/CLAUDE.md
@.github/CONVENTIONS.md

## Package Identity

- Repo: <https://github.com/{{repositoryOrg}}/vm2.MyPackage>
- NuGet: <https://www.nuget.org/packages/vm2.MyPackage/>
- Status: *TODO* — in design / Unpublished / Published, stable
- Target: .NET 10.0+

## What This Package Does

*TODO* One-paragraph description of the package's purpose and the problem it solves.

Key design decisions:

- *TODO*

## Common Local Commands

```bash
# Build
dotnet build vm2.MyPackage.slnx

# Run tests (xUnit v3, MTP v2 — each project is a compiled executable)
dotnet test --project tests/MyPackage.Tests/MyPackage.Tests.csproj

# Run test executables (xUnit v3, MTP v2 — each project is a compiled to an executable) on Linux:
tests/MyPackage/bin/Debug/net10.0/MyPackage.Tests # or
tests/MyPackage/bin/Debug/net10.0/MyPackage.Tests.exe #  on Windows

# Run a single test by method name (xUnit v3, MTP v2 filter syntax)
dotnet test --project tests/MyPackage.Tests/MyPackage.Tests.csproj --filter "MethodName_WhenCondition_ShouldOutcome"

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
