Eglantine Steam Remote Play Builder v1.1.0
===========================================

1. Extract this zip anywhere, then double-click:
   Eglantine-Steam-Remote-Play-Builder.exe

2. The wizard asks for:
   - a public GitHub Eglantine repository or fork and its branch/tag;
   - your Steamworks SDK "sdk" folder;
   - your Qt MSVC 2022 folder;
   - your Vulkan SDK folder;
   - an App ID that you own or are explicitly authorized to use, configured for
     Remote Play Together;
   - a private build workspace with at least 15 GB free.

3. Before the first build, install Visual Studio C++ tools, Qt with Qt Charts,
the Vulkan SDK, and obtain Steamworks access authorized by Valve. You need an
App ID you own or are explicitly authorized to use, configured for Remote Play
Together. The wizard includes French/English instructions and checks each
folder before building.

4. Click Finish. A PowerShell window builds a private, fully deployed output
folder and zip inside your selected workspace. It shows the log if something
fails. It never modifies your existing Eglantine installation.

Important: The BUILDER contains no Valve files and may be shared. The BUILD it
creates contains Valve's steam_api64.dll from your own SDK, so keep the output
private and do not share or publish it.

The builder source is published in this GitHub repository so users can inspect
or reproduce it before running it. Use only source repositories you trust.
Compiling source runs that repository's build instructions on your PC.
