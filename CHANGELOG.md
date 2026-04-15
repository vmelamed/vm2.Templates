# Changelog






## v1.2.1-preview.4 - 2026-04-15


### Internal

- promote to stable v1.2.1 [skip ci]
- update changelog for v1.2.1 [skip ci]
- add workflow to refresh NuGet lock files







## v1.2.1 - 2026-04-14

See prereleases below.





## v1.2.1-preview.3 - 2026-04-14


### Internal

- sync round-3 changelog templates and bump TestUtilities to 1.4.4


## v1.2.1-preview.2 - 2026-04-14

### Internal

- update changelog template formatting for consistency - addressed GH copilot review messages


## v1.2.1-preview.1 - 2026-04-14

### Fixed

- prevent prerelease pointer duplication


## v1.2.0 - 2026-04-14

### Internal

- promote to stable v1.2.0 [skip ci]
- update changelog for v1.2.0 [skip ci]

## v1.2.0 - 2026-04-14

See prereleases below.

## v1.2.0-preview.3 - 2026-04-13

### Internal

- bump vm2.TestUtilities to 1.4.2 and harden docs parser regex
- remove duplicate version sections

## v1.2.0-preview.2 - 2026-04-13

### Internal

- clean-up the changelog

## v1.2.0-preview.1 - 2026-04-13

### Added

- add prerelease reminder and normalize cliff parser rules

## v1.1.0 - 2026-04-12

### Internal

- promote to stable v1.1.0 [skip ci]
- update changelog for v1.1.0 [skip ci]

## v1.1.0-preview.1 - 2026-04-12

### Added

- this is now the source of truth for diff-shared.sh. Added PULL_REQUEST_TEMPLATE.md and .gitmessage - commit message template
- add support for .slnx files in .gitattributes

## v1.0.0 - 2026-04-11

### Internal

- promote to stable v1.0.0 [skip ci]
- update changelog for v1.0.0 [skip ci]

## v1.0.0-preview.2 - 2026-04-11

### Added

- add example program to the template

### Fixed

- details in the template
- in CI build the solution, not the project
- update copyright year to 2025-2026 in license files and .editorconfig
- remove unnecessary attributes from EchoBenchmarks class
- update workflow configurations to use pull_request_target and set default for SAVE_PACKAGE_ARTIFACTS
- add missing attributes for JSON and Markdown export in EchoBenchmarks class
- update CI and workflow configurations to set default values for environment variables and improve logging
- update DisableTestingPlatformServerCapability condition for Visual Studio builds
- update git-cliff template for v2.x compatibility
- add blank line for improved readability in changelog template
- update vm2.TestUtilities package version to 1.4.0
- update MyPackageApiTests class constructor to include ITestOutputHelper dependency
- update changelog format, remove obsolete configuration files, and adjust project namespace

### Internal

- diff-shared

## v1.0.0-preview.1 - 2026-03-26

### Internal

DevOps changes only.

## Usage Notes

> [!TIP] Be disciplined with your commit messages and let git-cliff do the work of updating this file.
>
> **Added:**
>
> - add new features here
> - commit prefix for git-cliff: `feat:`
>
> **Changed:**
>
> - add behavior changes/refactors here
> - commit prefix for git-cliff: `refactor:`
>
> **Fixed:**
>
> - add bug fixes here
> - commit prefix for git-cliff: `fix:`
>
> **Performance**
>
> - add performance improvements here
> - commit prefix for git-cliff: `perf:`
>
> **Removed**
>
> - add removed/obsolete items
> - commit prefix for git-cliff: `revert:` or `remove:`
>
> **Security**
>
> - add security-related changes
> - commit prefix for git-cliff: `security:`
>
> **Internal**
>
> - add internal changes here
> - commit prefix for git-cliff: `refactor:`, `doc:`, `docs:`, `style:`, `test:`, `chore:`, `ci:`, `build:`
>
> **Skipped by git-cliff**
>
> - commit prefix: `ci:`, `devops:`, `build:`
>

## References

This format follows:

- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
- [Semantic Versioning](https://semver.org/)
- Version numbers are produced by [MinVer](./ReleaseProcess.md) from Git tags.
