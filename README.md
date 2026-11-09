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
