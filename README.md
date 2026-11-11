Eglantine Remote Together — Builder Fork Guide

This repository contains a GitHub Actions workflow that builds a patched version of Eglantine (a Steam Remote Play tool) on a Windows runner. It does not contain the Eglantine source code itself — it fetches it, patches it, and produces a build artifact or GitHub Release.

This guide explains how to fork this repo and get a working build.
What this repo does

The workflow at .github/workflows/build-eglantine.yml:

    Clones a public Eglantine repository (or fork) at a specified branch/tag.

    Downloads the Steamworks SDK (which cannot be fetched automatically — see below).

    Patches and compiles Eglantine with your Steam App ID baked in.

    Produces a .zip build archive, uploaded either as a workflow artifact or a GitHub Release.

Runs on windows-2022, with a 240-minute timeout.
Prerequisites

Before forking, make sure you have:

    A GitHub account with Actions enabled.

    A Steam App ID that belongs to you (e.g. your own game) or that you are explicitly authorized to use. Do not use an App ID you don't own — this is both a legal and a ToS issue.

    Access to the Steamworks SDK zip. GitHub-hosted runners cannot log into the Steamworks partner portal, so you must provide the SDK some other way (see next section).

Getting the Steamworks SDK into the build

You have two options. Pick one.
Option A — Private GitHub Release asset (recommended)

Upload the Steamworks SDK zip as an asset on a release in a repository you control (public or private). The workflow downloads it using the runner's GITHUB_TOKEN.

Then set these repository variables (Settings → Secrets and variables → Actions → Variables):
Variable	Example	Purpose
STEAMWORKS_SDK_RELEASE_TAG	steamworks-sdk-165	Tag of the release holding the zip
STEAMWORKS_SDK_ASSET_NAME	steamworks_sdk_165.zip	Exact asset filename
STEAMWORKS_SDK_REPO	yourname/your-private-repo	Repo containing the release (defaults to the current repo)

    ⚠️ If the release is in a different private repo, the default GITHUB_TOKEN won't have access to it. Either put the release in the same repo, or create a PAT and adjust the workflow.

Option B — Direct HTTPS URL (manual runs only)

Provide a direct download URL to a .zip in the manual dispatch form (steamworks_sdk_url). The URL must:

    Be plain https://…something.zip (no redirects to a login page),

    Be reachable without authentication (a signed S3/Azure/blob URL works, or a self-hosted runner file).

This option is disabled for push and pull_request runs on purpose — you cannot use it for automated builds.
Forking and configuring

    Fork this repo on GitHub.

    Go to Settings → Actions → General and ensure workflows are enabled ("Allow all actions and reusable workflows").

    (Recommended) Go to Settings → Secrets and variables → Actions → Variables and add:
    Variable	Example	Used as
    EGLANTINE_BUILD_REPO_URL	https://github.com/Eglantine-Community/Eglantine.git	Source repo to build
    EGLANTINE_BUILD_REF	main	Branch/tag to build
    STEAM_APP_ID	1118310	Your App ID
    STEAMWORKS_SDK_RELEASE_TAG	steamworks-sdk-165	See above
    STEAMWORKS_SDK_ASSET_NAME	steamworks_sdk_165.zip	See above
    STEAMWORKS_SDK_REPO	yourname/your-private-repo	See above
    
    Make sure the repo has write permissions for Actions (Settings → Actions → General → Workflow permissions → Read and write permissions). The workflow needs contents: write to publish releases.

Running a build
Automatically

    Push to main → builds and publishes a GitHub Release (tag main-<run_number>).

    Open/update a PR → builds and uploads an artifact (retained 1 day) with a download link in the PR summary.

Manually (recommended for first-time tests)

Go to Actions → Build patched Eglantine → Run workflow and fill in:

    repository_url — the Eglantine repo/fork to build

    git_ref — branch or tag

    steam_app_id — your App ID

    steamworks_sdk_url — (optional) direct zip URL, or leave blank

    steamworks_sdk_release_tag / steamworks_sdk_asset_name / steamworks_sdk_repo — (optional) if you didn't set repo variables

    create_release — true (default) to publish a Release, false for artifact-only

    release_name — (optional) custom title

Manual runs default to publishing a Release with tag manual-<run_number>.
Troubleshooting
Error	Fix
Steamworks SDK is missing	Set the release-asset variables or pass steamworks_sdk_url in a manual run.
STEAMWORKS_SDK_URL is manual-only	You have a repo variable/secret named STEAMWORKS_SDK_URL; delete it and use the release-asset variables.
No GitHub Release asset named '…' was found	Check the tag, asset filename, and that the release is in the repo named in STEAMWORKS_SDK_REPO.
Resource not accessible by integration	Enable Read and write permissions for Actions in Settings → Actions → General.
Build times out	240 min is generous; if it still fails, check the Eglantine repo's own build requirements.

Full logs are under Actions → the run → build-eglantine → steps. The build script also writes a status file at %RUNNER_TEMP%\eglantine-build-status.txt.
⚠️ Legal & policy notes

    App ID: You must own the Steam App ID you bake in, or have explicit written permission to use it. Using someone else's App ID can get your Steam account and/or the build into trouble.

    Steamworks SDK: Distributed by Valve under the Steamworks SDK License. Do not redistribute the SDK publicly, and follow Valve's terms for its use.

    Eglantine / Steam ToS: Patching Steam Remote Play-related software may violate the Steam Subscriber Agreement or the terms of the game you're playing. This repo only provides a build pipeline — you are responsible for how you use the resulting binary.

    No warranty: This workflow is provided as-is. Nothing here is endorsed by Valve, Steam, or the Eglantine project.

What's next

Once a build succeeds you'll get a .zip artifact. The contents depend on Eglantine's own build script (builder/payload/Build-SteamRemotePlay.ps1 in this repo). Consult that script and the Eglantine project for how to install/run the result.

If you only want the build for personal experimentation, use a manual run with create_release: false so nothing is published to your repo's Releases.
