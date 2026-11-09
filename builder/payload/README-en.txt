Eglantine Steam Remote Play Builder
===================================

This builder makes a PRIVATE Windows Eglantine build with Steam Remote Play
Together. It works from the source code of a GitHub Eglantine repository or
fork that you choose.

It does not alter an existing Eglantine installation. It creates a new source
worktree, build folder, output folder, log, and build-manifest.json in the
build workspace you selected in the wizard.

Before building, install these yourself:

1. Visual Studio 2022 or later with "Desktop development with C++".
   https://visualstudio.microsoft.com/vs/community/

2. Qt for MSVC 2022 64-bit, including Qt Charts. Version 6.8.3 was tested
   with this patch; if the fork asks for a different version, use that version.
   https://www.qt.io/download-qt-installer-oss

3. The Vulkan SDK, including glslangValidator.exe.
   https://vulkan.lunarg.com/sdk/home#windows

4. Steamworks SDK 1.62 or newer, obtained through access authorized by Valve. You also need
   an App ID that you own or are explicitly authorized to use and that is configured for
   Remote Play Together. Select the SDK's "sdk" folder in the wizard.
   https://partner.steamgames.com/downloads/list

The builder verifies these requirements, validates the GitHub URL and ref,
makes a private Git mirror/worktree, checks and applies the source patch, and
stops if it cannot apply the patch cleanly. It does not overwrite your normal
Eglantine files.

Only build a repository you trust. Building source code runs the repository's
CMake build instructions on your PC.

The builder starts its own PowerShell window with a temporary execution-policy
setting so it can run the bundled build script. It does not change your Windows
PowerShell settings or install any software automatically.

The output contains steam_api64.dll from Valve's SDK. Do not share or publish
that build. The builder itself does not contain Steamworks SDK files.

Start the builder again to make another version or fork. It retains earlier
worktrees and logs so a failed build can be inspected without losing data.

A successful build creates a fully deployed folder and a private zip in the
workspace's output folder. It also includes README.txt, build-manifest.json,
and a log path for troubleshooting. The App ID typed in the wizard must be one
you own or are explicitly authorized to use.
