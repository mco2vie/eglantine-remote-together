Eglantine Steam Remote Play Builder
===================================

This builder makes a PRIVATE Windows Eglantine build with Steam Remote Play
Together. It works from the source code of a GitHub Eglantine repository or
fork that you choose.

It does not alter an existing Eglantine installation. In the build folder you
selected in the wizard, it keeps one source and build folder per repository
(work\...), plus a log, an output folder and build-manifest.json for each build.

What you prepare yourself
-------------------------

1. The Steamworks SDK zip, version 1.62 or newer, downloaded with your
   Steamworks account. You do not need to unzip it.
   https://partner.steamgames.com/downloads/list

2. A Steam App ID that you own or are explicitly authorized to use, and that
   is configured for Remote Play Together.

What the builder gets for you when it is missing
------------------------------------------------

The wizard's "Checking your PC" page shows what is ready. During the build,
the wizard gets anything missing:

- The Microsoft C++ compiler (Visual Studio Build Tools, free, about 8 GB),
  only if you ticked "Install the Microsoft C++ compiler for me". It uses
  Microsoft's installer, checks Microsoft's signature, and Windows asks you
  for administrator approval once.
- Git, Qt 6.8.3 with Qt Charts, and the glslang shader compiler. They are
  downloaded into <build folder>\cache\tools only, checked against fixed
  SHA-256 values, and reused by later builds.

Advanced users can tick "Use my own Qt or Vulkan SDK folders" in the wizard.

The build
---------

The wizard's "Building Eglantine" page shows six numbered steps, a progress
bar and the live log. The first build can take one to two hours, mostly
downloads and compiling. When it succeeds, a button opens the folder with the
new eglantine.exe. If it fails, the red message says what
to fix; run the builder again afterwards and it keeps what was already
downloaded.

The builder validates the GitHub URL and the branch or tag, makes a private
Git mirror and worktree, checks and applies the source patch, and stops if it
cannot apply the patch cleanly.

Only build a repository you trust. Building source code runs the repository's
CMake build instructions on your PC.

The wizard runs the bundled build script in a hidden PowerShell process with a
temporary execution-policy setting. To build again without the wizard, run
Run-Build.cmd in this folder. It does not change your Windows
PowerShell settings.

The output contains steam_api64.dll from Valve's SDK. Do not share or publish
that build. The builder itself does not contain Steamworks SDK files.

Start the builder again to make another version or fork. Later builds reuse
the previous work: only files that changed are compiled again, and a compiler
cache (sccache) keeps results across branches. If a tool or folder changed, the
builder starts a clean build by itself. Logs of every build are kept.
