# Eglantine Remote Together

A Windows builder that makes a private Eglantine build with **Steam Remote Play Together**. You choose a public Eglantine repository or fork and a branch or tag. The builder fetches that source, patches it, and compiles it on your PC or on a GitHub Actions runner.

**No Steamworks SDK is needed.** The patch adds Eglantine's [extension system](https://github.com/damienjacinto/Eglantine/tree/extensions) and the [Steam Remote Play Together extension](https://github.com/damienjacinto/eglantine-remote-play-together). The extension loads Steam's runtime library (`steam_api64.dll`) at runtime. The wizard installer ships that DLL, so users download nothing from Valve; the build places it next to the extension.

## What's in this repo

| Path | Purpose |
|---|---|
| [`builder/`](builder/) | The Inno Setup wizard, the PowerShell build script and the source patch. See [builder/README.md](builder/README.md). |
| [`.github/workflows/build-eglantine.yml`](.github/workflows/build-eglantine.yml) | Builds a patched Eglantine for pull requests and manual runs, and uploads the build as an artifact. |
| [`.github/workflows/tag-release-eglantine.yml`](.github/workflows/tag-release-eglantine.yml) | On a `v*` or `release-*` tag, packages the wizard installer and publishes it as a GitHub Release. |
| [`site/`](site/) | The project page, deployed to GitHub Pages. |

## Using the wizard

1. Download and run `Eglantine-Steam-Remote-Play-Builder.exe` from the Releases.
2. Pick the repository (default `https://github.com/Eglantine-Community/Eglantine.git`) and a branch or tag (default `nx2`).
3. Let the wizard check your PC. It can install the Microsoft C++ Build Tools and downloads Qt, glslang and Git (if needed) into the build folder.
4. Enter a Steam App ID that you own or are explicitly authorized to use. It becomes the extension's default and can be changed later in Eglantine.
5. Wait for the build. The output folder contains `eglantine.exe` and `extensions\dev.eglantine.remote-play-together\`.

The first time you start the build:

1. Start Steam, then start `eglantine.exe`.
2. Open **Extensions > Manage Extensions...**, tick **Steam Remote Play Together**, and restart Eglantine.
3. Use **Multiplayer > Remote Play Together: Invite Friends...** or **Copy Guest Link**.

## Running the workflow (CI)

The build workflow runs on pull requests, and manually from **Actions > Build patched Eglantine > Run workflow**. It needs no secrets. Optional inputs and repository variables:

| Input | Variable | Default |
|---|---|---|
| `repository_url` | `EGLANTINE_BUILD_REPO_URL` | `https://github.com/Eglantine-Community/Eglantine.git` |
| `git_ref` | `EGLANTINE_BUILD_REF` | `nx2` |
| `steam_app_id` | `STEAM_APP_ID` | `480` |
| `release_name` | `EGLANTINE_BUILD_RELEASE_NAME` | `Eglantine Remote Play <run number>` |

The build zip is uploaded as an artifact. It is kept 1 day for pull requests and 30 days for manual runs.

## Compatibility

The patch is made against upstream `nx2` at `6be10b5`. On other branches or forks, Git tries a three-way merge. If that fails too, the build stops and names the conflicting files; that version then needs an updated patch (see [builder/README.md](builder/README.md#what-the-patch-contains)).

## Legal and policy notes

- **App ID:** use only a Steam App ID you own or are explicitly authorized to use, configured for Remote Play Together. The Steam account must own it.
- **Steam runtime library:** `steam_api64.dll` is Valve's Steamworks redistributable. It is never committed here: `builder/package-release.ps1` fetches it from a pinned, SHA-256-checked archive when it packages the installer. CI runs, which use the script from a checkout, download it the same way. Keep the generated builds for yourself.
- **No warranty:** this is an unofficial project, not endorsed by Valve, Steam, or the Eglantine project.
