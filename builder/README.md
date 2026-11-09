# Builder source

This directory contains the complete source for the public **Eglantine Steam Remote Play Builder** Windows wizard.

The builder creates a private local Eglantine build from a user-selected public GitHub repository or fork. It does not contain the Steamworks SDK, `steam_api64.dll`, any generated Eglantine build, keys, or game files.

## What each file does

- [`eglantine-steam-builder.iss`](eglantine-steam-builder.iss) creates the Windows wizard with Inno Setup.
- [`payload/Build-SteamRemotePlay.ps1`](payload/Build-SteamRemotePlay.ps1) validates the user-selected GitHub source, local tools, and Steamworks SDK; creates an isolated worktree; applies the source patch; and builds a local output folder.
- [`payload/Run-Build.cmd`](payload/Run-Build.cmd) opens the PowerShell builder and leaves its result visible.
- [`payload/steam-remote-play-together.patch`](payload/steam-remote-play-together.patch) is the source patch applied by the builder.
- [`payload/README-en.txt`](payload/README-en.txt) and [`payload/README-fr.txt`](payload/README-fr.txt) are installed by the wizard.
- [`release/Eglantine-Steam-Remote-Play-Builder-README.txt`](release/Eglantine-Steam-Remote-Play-Builder-README.txt) is the text included in the published ZIP.
- [`package-release.ps1`](package-release.ps1) compiles the installer and builds the release ZIP plus checksums.

## Build and package the builder

1. Install [Inno Setup 7.1.1 or newer](https://jrsoftware.org/isdl.php).
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

The published v1.1.0 installer SHA-256 is listed in [`../site/downloads/SHA256SUMS.txt`](../site/downloads/SHA256SUMS.txt). The builder source is UTF-8 and contains the same patch checksum hard-coded in `Build-SteamRemotePlay.ps1`; it refuses a modified patch at build time. Installer files can differ byte-for-byte across machines or build times, so verify the published hash for the downloaded release rather than expecting a local rebuild to have the same hash.

## Security and licensing boundaries

- The wizard only accepts public HTTPS GitHub repository URLs and validates branches/tags before calling Git.
- It makes new directories inside a workspace selected by the user. It does not run `git clean`, reset existing user source, or overwrite an Eglantine installation.
- It asks the user to confirm that they trust the selected repository, that their Steamworks SDK is their own authorized copy, and that they have permission to use the selected App ID.
- It requires an App ID that the user owns or is explicitly authorized to use and that is configured for Remote Play Together. It does not grant rights to use any third party's App ID.
- The generated output may contain `steam_api64.dll` from the user's own SDK. That local output must not be committed, released, uploaded, or shared through this repository.

The output is deliberately unsigned because this project has no code-signing certificate. Verify the published checksum and inspect this source before running it.

## AI disclosure

This builder and source patch were created with AI assistance. Anyone considering an upstream contribution must independently review, understand, test, and revise the code as needed, then follow the upstream project's licensing and AI disclosure policies.
