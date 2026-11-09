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

## Publish the Pages site

The workflow at [`.github/workflows/deploy-pages.yml`](.github/workflows/deploy-pages.yml) publishes the static `site/` folder after a push to `main` or a manual workflow run. See [`PUBLISH-PAGES.md`](PUBLISH-PAGES.md) for the no-command GitHub Desktop steps.

In GitHub:

1. Open **Settings → Pages** for this repository.
2. Under **Build and deployment**, choose **GitHub Actions** as the source.
3. Commit and push these files to `main`.
4. Open **Actions → Deploy GitHub Pages** and wait for the deployment to finish.

The URL will normally be:

```text
https://mco2vie.github.io/eglantine-remote-together-/
```

## Updating the builder download

1. Replace `site/downloads/Eglantine-Steam-Remote-Play-Builder.zip`.
2. Recalculate `site/downloads/SHA256SUMS.txt`.
3. Update the expected builder hash in `site/index.html`.
4. Test the site locally, then commit and push the three changes together.

The builder runs locally. It downloads the public GitHub repository selected by the user and can download source build dependencies. The builder itself does not upload keys, game files, Steamworks SDK files, or generated builds, but a selected source repository can run build commands and make network requests. Use only trusted sources and do not put private files in the workspace.

## License and notices

Unless a file states otherwise, the documentation, static site, source patch, and builder source are offered under GPL-3.0-or-later. Read [`LICENSE`](LICENSE) and [`NOTICE.md`](NOTICE.md) for the Eglantine upstream attribution, distribution boundaries, and third-party-name notice.

## AI disclosure and upstream contributions

This project contains AI-assisted work. It is unofficial and is not affiliated with Eglantine, Eden, Valve, Steam, or any application whose App ID a user enters.

Before proposing the source patch upstream, review every line, test it independently, and follow the upstream project’s AI and contribution policies. Do not copy Steamworks SDK files into this repository.
