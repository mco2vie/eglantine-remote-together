# Eglantine Remote Together

Static GitHub Pages guide for trying the private, source-built Steam Remote Play Together patch for compatible [Eglantine](https://github.com/Eglantine-Community/Eglantine) versions and public GitHub forks.

The deployed site lives in [`site/`](site/). It includes:

- English and French setup instructions;
- a download for the shareable Patch & Build wizard;
- the source patch and SHA-256 checksums;
- explicit requirements, privacy, licensing, and troubleshooting guidance.

## What this repository may contain

This repository intentionally contains only:

- static documentation;
- the source patch;
- the Patch & Build wizard, which contains no Steamworks SDK material or Valve runtime DLL.

It must **not** contain a generated patched Eglantine build, `steam_api64.dll`, the Steamworks SDK, keys, game files, or game dumps.

Each user obtains Steamworks through access authorized by Valve, supplies an App ID they own or are explicitly authorized to use, and builds their own private output locally. The builder checks the source patch and prepares an isolated local build workspace. A compatible build exposes Steam Remote Play Together in Eglantine's Multiplayer menu, including friend invites, guest links, controller handling, and App ID selection.

The `STEAMWORKS_SDK_URL` value must be a real Valve Steamworks SDK archive, usually a direct download from the Steamworks partner portal such as `https://partner.steamgames.com/downloads/steamworks_sdk_*.zip`. There is no generic public SDK URL for a normal app; a random ZIP or a different Steam download is rejected by the builder.

## Private SDK hosting for GitHub Actions

The recommended GitHub-hosted pattern is to keep the SDK out of git and upload the official `steamworks_sdk_*.zip` to a private location that the runner can fetch directly.

The easiest version is a private GitHub Release asset:

1. Upload the official Valve Steamworks SDK ZIP as a release asset in a private repository or a private release in the same repository.
2. Set one of the following:
   - `STEAMWORKS_SDK_URL` to the direct asset URL; or
   - `STEAMWORKS_SDK_RELEASE_TAG` + `STEAMWORKS_SDK_ASSET_NAME` + `STEAMWORKS_SDK_REPO` if you want the workflow to resolve the private asset via the GitHub API.
3. Trigger the build; the workflow will download the private SDK at runtime and then validate it before patching.

This keeps the SDK out of the source tree while still letting a hosted runner fetch it without user login. A local filesystem path, a Steamworks.NET package, or an arbitrary non-Valve ZIP is not accepted by the builder.


<!-- ci-trigger 2026-11-10 18:00:33 -->

