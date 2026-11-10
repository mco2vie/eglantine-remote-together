# Eglantine Remote Together

This repository contains the source, documentation, builder logic, and GitHub Actions automation for a private Eglantine Steam Remote Play Together patch flow.

It is not a public binary distribution. The repo intentionally does not include generated builds, `steam_api64.dll`, Valve runtime material, Steamworks SDK content, keys, game files, or game dumps.

## Repository layout

- `builder/` — Windows build wizard and PowerShell patch logic
- `site/` — static GitHub Pages site for the project docs and downloads
- `.github/workflows/build-eglantine.yml` — automated build workflow for PRs, main pushes, and manual runs
- `LICENSE`, `NOTICE.md`, `LICENSE-NOTICE.md` — licensing and attribution

## What this project is

This project is meant to help an authorized user build a private patched Eglantine build with Steam Remote Play Together support.

The build expects:

- a public Eglantine repo or fork URL
- a branch or tag to build
- a Steam App ID the user owns or is explicitly authorized to use
- a real Valve Steamworks SDK archive (`steamworks_sdk_*.zip`) provided through a private direct URL or private release asset

The workflow validates the SDK before patching/building. Random ZIP files, partial archives, or wrapper packages such as Steamworks.NET standalone zips are rejected.

## What this project is not

- a generic, public Eglantine release repo
- a place to store the Steamworks SDK or built binaries
- a mirror for Valve runtime DLLs or SDK headers

## Private SDK handling

GitHub-hosted runners cannot log in to the Steamworks partner portal, so the workflow expects the SDK to be available through a private, direct HTTP(S) URL or a private GitHub Release asset.

The direct URL input is intended for manual `workflow_dispatch` runs. Automated push/PR builds should use the release asset configuration, not a local machine path.

## Build rules and boundaries

- The repo remains source-only: no generated output is committed.
- The builder validates the official Valve SDK layout before continuing.
- The build only works for authorized Steam App IDs and valid private SDK access.
- Users must review the patch, source, and upstream licensing before using or redistributing anything generated from this project.


