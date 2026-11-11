# Builder source

This directory contains the complete source for the public **Eglantine Steam Remote Play Builder** Windows wizard.

The builder creates a private local Eglantine build from a user-selected public GitHub repository or fork. It does not contain the Steamworks SDK, `steam_api64.dll`, any generated Eglantine build, keys, or game files.

## What each file does

- [`eglantine-steam-builder.iss`](eglantine-steam-builder.iss) creates the Windows wizard with Inno Setup.
- [`payload/Build-SteamRemotePlay.ps1`](payload/Build-SteamRemotePlay.ps1) validates the user-selected GitHub source and Steamworks SDK (zip or folder); installs or downloads missing tools when allowed; creates an isolated worktree; applies the source patch; and builds a local output folder. It shows six numbered steps in English or French.
- [`payload/Check-Requirements.ps1`](payload/Check-Requirements.ps1) is used only by the wizard. It checks the PC (Windows, Microsoft C++ tools, Git, cached Qt/glslang, free space) and inspects or finds the Steamworks SDK zip. It is read-only.
- [`payload/List-GitRefs.ps1`](payload/List-GitRefs.ps1) is used only by the wizard. It lists the branches and tags of the selected GitHub repository for the version drop-down. It reads GitHub's public Git ref list, so it needs neither Git nor the GitHub API.
- [`payload/Run-Build.cmd`](payload/Run-Build.cmd) opens the PowerShell builder and leaves its result visible.
- [`payload/steam-remote-play-together.patch`](payload/steam-remote-play-together.patch) is the source patch applied by the builder.
- [`payload/README-en.txt`](payload/README-en.txt) and [`payload/README-fr.txt`](payload/README-fr.txt) are installed by the wizard.
- [`release/Eglantine-Steam-Remote-Play-Builder-README.txt`](release/Eglantine-Steam-Remote-Play-Builder-README.txt) is the text included in the published ZIP.
- [`package-release.ps1`](package-release.ps1) compiles the installer and builds the release ZIP plus checksums.

## Build and package the builder

1. Install [Inno Setup 7.1.1 or newer](https://jrsoftware.org/isdl.php) (`winget install JRSoftware.InnoSetup.7`). The script finds it in Program Files or in your user profile.
2. Open PowerShell in this directory.
3. Run:

   ```powershell
   .\package-release.ps1
   ```

4. The script creates these local files:

   ```text
   output\Eglantine-Steam-Remote-Play-Builder.exe
   release\output\Eglantine-Steam-Remote-Play-Builder.zip
   release\output\SHA256SUMS.txt
   ```

5. Copy the zip and checksums into `site/downloads/` together when publishing an update.

## GitHub Actions: validation builds and tag releases

This repository includes two GitHub Actions workflows:

- [../.github/workflows/build-eglantine.yml](../.github/workflows/build-eglantine.yml) validates a patched Eglantine build for pull requests and manual runs. It does not trigger on merges to `main` and does not publish a release.
- [../.github/workflows/tag-release-eglantine.yml](../.github/workflows/tag-release-eglantine.yml) runs when a tag is pushed and publishes the generated build as a GitHub Release asset.

For PR validation and manual runs, set these repository variables in GitHub if you do not override them in the workflow form:

- `EGLANTINE_BUILD_REPO_URL` — public repo or fork, for example `https://github.com/Eglantine-Community/Eglantine.git`
- `EGLANTINE_BUILD_REF` — typically `main` or another branch/tag you want to test
- `STEAM_APP_ID` — the App ID you own or have explicit permission to use
- `STEAMWORKS_SDK_RELEASE_TAG` and `STEAMWORKS_SDK_ASSET_NAME` — the private Valve SDK release asset used by CI

Manual runs can override the defaults in the workflow form. PR builds upload a short-lived workflow artifact with a link in the job summary; tag-pushed releases publish the generated build to the matching Git tag.

The published installer SHA-256 is listed in [`../site/downloads/SHA256SUMS.txt`](../site/downloads/SHA256SUMS.txt). The builder source is UTF-8 and contains the same patch checksum hard-coded in `Build-SteamRemotePlay.ps1`; it refuses a modified patch at build time, and `package-release.ps1` refuses to package one. `.gitattributes` keeps Git from converting the patch's line endings, which would change its checksum. Installer files can differ byte-for-byte across machines or build times, so verify the published hash for the downloaded release rather than expecting a local rebuild to have the same hash.

## Tools the builder fetches

When the user leaves the Qt and Vulkan folders empty (the default), `Build-SteamRemotePlay.ps1` downloads pinned tools into `<workspace>\cache\tools` and checks each one against a fixed SHA-256:

| Tool | Version | Source |
| --- | --- | --- |
| Qt + Qt Charts (`win64_msvc2022_64`) | 6.8.3, same as Eglantine's Windows CI | [aqtinstall](https://github.com/miurahr/aqtinstall) 3.3.0 `aqt.exe`, which verifies Qt's own archive checksums |
| glslang shader compiler | 16.6.0 | [KhronosGroup/glslang](https://github.com/KhronosGroup/glslang/releases) |
| MinGit (only if no Git is installed) | 2.56.0.2 | [git-for-windows](https://github.com/git-for-windows/git/releases) |
| GNU `patch.exe` (`usr\bin` of Git for Windows; only if no full Git for Windows is installed — Eglantine's CPM patches some libraries with it) | 2.56.0.2 | [git-for-windows](https://github.com/git-for-windows/git/releases) `.tar.bz2`, unpacked with Windows' `tar.exe` |
| optional compiler cache (disabled in the GitHub Actions workflow; the repo prefers a reusable workspace cache instead) | 0.19.0, same as Eglantine's Windows CI | [mozilla/sccache](https://github.com/mozilla/sccache/releases) |

When the user ticks *Install the Microsoft C++ compiler for me*, it downloads Microsoft's `vs_BuildTools.exe` from `aka.ms`, refuses it unless its Authenticode signature is valid and from Microsoft Corporation, and installs the VCTools workload with CMake (one UAC prompt). Update the versions and hashes in both `Build-SteamRemotePlay.ps1` and `Check-Requirements.ps1` together.

## Faster rebuilds

Each repository gets one reusable folder, `<workspace>\work\<repo>-<hash>\` with `source\` and `build\`:

- The patched source is assembled inside Git first (temporary index, `git apply --cached`, `commit-tree`) and then checked out, so Git rewrites only files whose content changed and Ninja keeps every object file that is still valid.
- `build\builder-fingerprint.txt` records the Visual Studio, MSVC, CMake, Qt, glslang, Steamworks and toolchain paths/versions. Any difference means a clean build folder. If configuring a reused folder fails, the builder retries once with a clean folder.
- The GitHub Actions workflow uses an `actions/cache` entry for `<workspace>\cache` and `<workspace>\work` so repeated builds reuse the downloaded tools and previous source/build state without depending on sccache.

## Security and licensing boundaries

- The wizard only accepts public HTTPS GitHub repository URLs and validates branches/tags before calling Git.
- It works only inside the workspace selected by the user. It keeps one source and build folder per repository under `work\` and force-checks out only that builder-owned source folder; it never resets source it did not create or overwrites an Eglantine installation. A lock file stops two builds from using the same folder.
- It asks the user to confirm that they trust the selected repository, that their Steamworks SDK is their own authorized copy, and that they have permission to use the selected App ID.
- It requires an App ID that the user owns or is explicitly authorized to use and that is configured for Remote Play Together. It does not grant rights to use any third party's App ID.
- The generated output may contain `steam_api64.dll` from the user's own SDK. That local output must not be committed, released, uploaded, or shared through this repository.

The output is deliberately unsigned because this project has no code-signing certificate. Verify the published checksum and inspect this source before running it.

## AI disclosure

This builder and source patch were created with AI assistance. Anyone considering an upstream contribution must independently review, understand, test, and revise the code as needed, then follow the upstream project's licensing and AI disclosure policies.
