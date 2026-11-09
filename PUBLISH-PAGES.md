# Publish this GitHub Pages site

This repository is currently empty on GitHub. The Pages files have been prepared locally, but they have not been committed or pushed.

## Before publishing

Read these files:

- [`LICENSE-NOTICE.md`](LICENSE-NOTICE.md)
- [`NOTICE.md`](NOTICE.md)
- [`builder/README.md`](builder/README.md)

The repository must never contain a generated patched Eglantine build, `steam_api64.dll`, the Steamworks SDK, emulator keys, game files, or game dumps.

## Simple method: GitHub Desktop

1. Install [GitHub Desktop](https://desktop.github.com/) and sign in to your GitHub account.
2. Choose **File → Clone repository**, select `mco2vie/eglantine-remote-together-`, and choose a folder on your PC.
3. Copy the prepared repository files into that cloned folder, preserving these folders:

   ```text
   .github/
   builder/
   site/
   ```

4. In GitHub Desktop, review the changed files.
5. Write a commit message in your own words. The source patch and builder are AI-assisted, so disclose that fact in the commit message and repository description.
6. Click **Commit to main**, then **Push origin**.

## Enable GitHub Pages

1. Open [the repository Settings page](https://github.com/mco2vie/eglantine-remote-together-/settings/pages).
2. Under **Build and deployment**, choose **GitHub Actions**.
3. Open [Actions](https://github.com/mco2vie/eglantine-remote-together-/actions), select **Deploy GitHub Pages**, and wait for it to finish.
4. The site URL should be:

   ```text
   https://mco2vie.github.io/eglantine-remote-together-/
   ```

## Suggested repository description

```text
Unofficial documentation and private local builder for authorized Eglantine Steam Remote Play Together development.
```

The current description, “Play with your friends without needing to install anything,” is inaccurate because users must install their own tools and obtain authorized Steamworks access.
