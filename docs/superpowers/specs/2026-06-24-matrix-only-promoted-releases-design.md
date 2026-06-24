# Matrix-Only Promoted Releases Design

## Goal

Use one matrix-based build entrypoint for both one-manager and multi-manager builds, then promote an already successful matrix run to one manually approved draft release without rebuilding it.

## Decisions

- Remove the single-build dispatch workflow. The matrix workflow remains the only public build workflow and accepts one or many manager selections.
- Remove release creation from the build workflow. Builds always produce separate manager artifacts and never write repository contents.
- Add one user-facing promotion workflow. Its only input is the successful matrix build run ID.
- Protect promotion with a `release-approval` GitHub Environment and a required reviewer. The repository is public, so this protection is available on GitHub Free.
- Create one draft release per promoted matrix run. Use the existing combined matrix summary style for release notes.
- Upload only clean flashable ZIPs as release assets. Checksums and metadata remain inside Actions artifacts and are used internally before release creation.
- Document support as official Xiaomi stock HyperOS only for Poco F5 (`marblein`) and Redmi Note 12 Turbo (`marble`). Do not claim support for MIUI, AOSP, custom ROMs, or HyperOS-based custom ROMs.

## Workflow Architecture

### Build

`build-matrix.yml` is renamed at the display level to `Build Marble Kernel`. It keeps checkbox manager selection, data-driven matrix generation, the reusable `build-core.yml` fan-out, separate `marble-flash-*` artifacts, and one combined job summary. Selecting one checkbox is the supported single-manager path.

The `make_release` input and release job are removed. `build-core.yml` stays read-only apart from artifact attestation permissions.

### Promotion

`promote-release.yml` is a manual `workflow_dispatch` workflow with a required numeric `build_run_id` input. Its release job references the `release-approval` environment and requests only `actions: read` plus `contents: write`.

After approval, it:

1. Queries the target run through the GitHub API.
2. Requires the same repository, `main` branch, successful conclusion, and the matrix build workflow.
3. Checks out the exact builder commit used by the target build.
4. Downloads that run's `marble-flash-*-r<original run number>` artifacts with the pinned `download-artifact` action and the workflow token.
5. Requires each artifact to contain exactly one ZIP plus its checksum and required metadata.
6. Verifies every SHA-256 checksum and rejects duplicate ZIP names or an empty artifact set.
7. Recreates the combined matrix summary using the target commit's summary generator.
8. Creates `marble-hyperos-r<original run number>` as a draft release targeted at the original builder commit.
9. Uploads only the flashable `*.zip` files as release assets.

An existing tag or release causes a clear failure rather than modifying or overwriting a previous release. Expired artifacts also fail without rebuilding.

## ZIP Naming

Manager builds use:

```text
AK3_Marble-HyperOS_<Manager>-<version>-code<code>_<SUSFS>_r<build-run>.zip
```

Examples:

```text
AK3_Marble-HyperOS_KSUNext-v3.2.0-code33203_SUSFS-v2.2.0_r9.zip
AK3_Marble-HyperOS_SukiSUUltra-v4.1.3-code40813_SUSFS-v2.2.0_r9.zip
AK3_Marble-HyperOS_ReSukiSU-v4.1.0-code34990_SUSFS-v2.2.0_r9.zip
AK3_Marble-HyperOS_NoRoot_NoSUSFS_r9.zip
```

Version selection prefers build-log version name or tag, then resolved manager tag, then the seven-character manager commit. Version code prefers build-log code, then the pre-build manager version code. Unsafe filename characters are removed, upstream suffixes after `@` are excluded from the filename, and absent codes are omitted rather than rendered as `unknown`.

The run suffix always comes from the original kernel build, never the later promotion workflow.

## Summary and Documentation

The current summary layout remains intact. Single-manager and multi-manager matrix summaries add an explicit compatibility row and prerequisite warning for official Xiaomi stock HyperOS only. README workflow, artifact, naming, compatibility, and release sections are rewritten around the matrix-only and promotion model.

AnyKernel continues enforcing device codenames. Documentation must not imply that the installer can reliably detect the installed ROM family.

## Security and Failure Handling

- Promotion input is validated as digits before using it in API paths.
- Target run metadata and downloaded artifacts are treated as untrusted input.
- Release permission exists only in the protected promotion job.
- The target run must be a successful main-branch matrix build.
- Checksums must match before `gh release create` runs.
- Shell globs are expanded into a validated ZIP array; metadata cannot become release assets.
- The release remains a draft until manually published from the Releases UI.

## Verification

- Regression tests cover filename formatting and fallbacks.
- Summary tests require the stock HyperOS compatibility language.
- Workflow-policy tests require matrix-only builds, the protected promotion environment, least privilege, cross-run artifact download, checksum verification, and ZIP-only release assets.
- Local bash syntax, shellcheck, actionlint, all tests, and whitespace checks must pass.
- Remote preflight and a real matrix build must pass.
- The successful build is promoted after environment approval; the resulting draft release must contain one combined summary and only the expected clean flashable ZIPs.
