Eglantine Steam Remote Play Builder
===================================

Eglantine-Steam-Remote-Play-Builder.exe installs a wizard that makes a PRIVATE
Windows build of Eglantine with Steam Remote Play Together, from a public
GitHub Eglantine repository or fork and the branch or tag you choose.

No Steamworks SDK is needed. The build adds Eglantine's extension system and
the Steam Remote Play Together extension
(https://github.com/damienjacinto/eglantine-remote-play-together). The wizard
includes Steam's runtime library (steam_api64.dll, Steamworks SDK 1.65,
Valve's redistributable), so nothing has to be downloaded from Valve.

You need:
- Windows 10 or 11, 64-bit, and about 15 GB of free space (more if the
  Microsoft C++ Build Tools must be installed).
- A Steam App ID that you own or are explicitly authorized to use, configured
  for Remote Play Together.

Before running it, compare the SHA-256 of the installer with SHA256SUMS.txt
published with this release, for example in PowerShell:

    Get-FileHash .\Eglantine-Steam-Remote-Play-Builder.exe -Algorithm SHA256

The installer is not code-signed. Source and release recipe:
https://github.com/mco2vie/eglantine-remote-together/tree/main/builder

After a successful build:
1. Start Steam, then start eglantine.exe from the output folder.
2. Open Extensions > Manage Extensions..., tick "Steam Remote Play Together",
   and restart Eglantine.
3. Use Multiplayer > Remote Play Together: Invite Friends... or Copy Guest
   Link.

Keep the generated build for yourself. Only build repositories you trust:
building source code runs that repository's build instructions on your PC.

Unofficial project, not affiliated with Eglantine, Eden, Valve or Steam.
