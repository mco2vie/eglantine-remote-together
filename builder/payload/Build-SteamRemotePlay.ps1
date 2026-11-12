# Eglantine Steam Remote Play Builder
# Creates a private Windows build from a user-selected, trusted GitHub Eglantine repository.
# It never edits an existing emulator install or deletes user source files.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConfigPath,
    # When the wizard runs the build, it shows progress from this small status file.
    [string]$StatusPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$BuilderVersion = '2.0.0'
# Kept in step with payload/steam-remote-play-together.patch when a compatible feature update ships.
# The patch adds Eglantine's extension system (damienjacinto/Eglantine, branch "extensions",
# commit 357ba63) and the Steam Remote Play Together extension
# (damienjacinto/eglantine-remote-play-together, tag v0.0.3) in extensions/remote_play_together.
# The extension loads Steam's runtime library at runtime, so no Steamworks SDK is needed.
$ExpectedPatchSha256 = '28cbdfdac7ff064194c0701514f5b85291d3aefb1771b8acb6b8c9a288ecf20b'
# The app ID must be one you own or are explicitly authorized to use, and configured for
# Remote Play Together. This builder does not grant permission to use another game's App ID.
# The App ID can be changed later from Eglantine's Multiplayer menu.
$MinimumFreeSpace = 15GB
# Steam's runtime library, bundled next to the extension. It comes from the Steamworks.NET
# release for Steamworks SDK 1.65, whose copies are byte-identical to Valve's
# redistributable_bin; both the archive and the DLL are checked against pinned hashes (the same
# ones the extension's own release workflow uses).
$SteamRuntime = @{
    Version = '1.65'
    Url = 'https://github.com/rlabrecque/Steamworks.NET/releases/download/2025.165.0/Steamworks.NET-Standalone_2025.165.0.zip'
    Sha256 = '9b86dda48b257013a350c8fea87edf3ab3f6f8fd6a812563fddec73fb1189fee'
    Entry = 'Windows-x64\steam_api64.dll'
    EntrySha256 = 'e6d9bafb9a41e42fba7b21553db49f8719027af3f0deb23ff86cfc44d60e776d'
}
$ExtensionId = 'dev.eglantine.remote-play-together'
$MinimumCmake = [Version]'3.31.0'

# Tools the builder downloads into <workspace>\cache\tools when the user did not pick their own.
# Every download is pinned and checked against its SHA-256. These match Eglantine's own Windows CI
# (Qt 6.8.3 with Qt Charts from aqtinstall). Keep the versions in step with Check-Requirements.ps1.
$QtVersion = '6.8.3'
$QtArch = 'win64_msvc2022_64'
$AqtTool = @{
    Version = '3.3.0'
    Url = 'https://github.com/miurahr/aqtinstall/releases/download/v3.3.0/aqt.exe'
    Sha256 = '4f74d4c95c464d238d7e17ec2d9b7f22a7c333f0f5270a62584e2b47fc765150'
}
$GlslangTool = @{
    Version = '16.6.0'
    Url = 'https://github.com/KhronosGroup/glslang/releases/download/16.6.0/glslang-16.6.0-windows-x86_64-release.zip'
    Sha256 = '82bf434e69b9bb4829de7e2b4bc2c5e7a7861e53d66cf75e5cc70f5f694a8d9b'
}
$MinGitTool = @{
    Version = '2.56.0.2'
    Url = 'https://github.com/git-for-windows/git/releases/download/v2.56.0.windows.2/MinGit-2.56.0.2-64-bit.zip'
    Sha256 = 'da35e72aa21c005a5a0d298cfbae110bc1609a815730ea0dde84b01a1b3cd3be'
}
# Eglantine's CMake patches some libraries with GNU patch, which on Windows ships only with the
# full Git for Windows (usr\bin\patch.exe), not with MinGit or Visual Studio's Git. Only usr\bin of
# this archive is extracted, and only when no patch.exe is found.
$GitForWindowsTool = @{
    Version = '2.56.0.2'
    Url = 'https://github.com/git-for-windows/git/releases/download/v2.56.0.windows.2/Git-2.56.0.2-64-bit.tar.bz2'
    Sha256 = '16ca394bdb94b372267d79e1e10b68763674f73e03e0648202a7971a8a730a84'
}
# Compiler cache, the same version Eglantine's Windows CI uses with MSVC.
$SccacheTool = @{
    Version = '0.19.0'
    Url = 'https://github.com/mozilla/sccache/releases/download/v0.19.0/sccache-v0.19.0-x86_64-pc-windows-msvc.zip'
    Sha256 = '28be8c61f6b2c89b9eb2869f6af7f78e6f992e78a8abae0ce855fcc129cbeac1'
    CacheSize = '10G'
}
# Bump when the layout of the reusable build folder changes, so old folders are rebuilt cleanly.
# 2: Steam support moved from a Steamworks SDK link to the extension.
$BuildCacheVersion = 2
# Microsoft's Build Tools bootstrapper changes with every update, so it is checked by its
# Microsoft Authenticode signature instead of a fixed hash.
$VisualStudioBootstrapperUrl = 'https://aka.ms/vs/17/release/vs_BuildTools.exe'
$VisualStudioComponents = @(
    'Microsoft.VisualStudio.Workload.VCTools',
    'Microsoft.VisualStudio.Component.VC.Tools.x86.x64',
    'Microsoft.VisualStudio.Component.VC.CMake.Project'
)

$script:Language = 'en'
$script:TotalSteps = 6
$script:LogPath = $null
$script:RunRoot = $null
$script:BuildLock = $null
$script:Workspace = $null
$script:RunId = $null

$script:Status = @{ State = 'running'; Step = 0; Title = ''; Hint = ''; Result = '' }
$script:StatusTail = New-Object 'System.Collections.Generic.Queue[string]'
$script:StatusWatch = [System.Diagnostics.Stopwatch]::StartNew()

# Rewrites the wizard's status file: key=value lines, "---", then the last log lines. It is
# throttled because compiler output can be thousands of lines; -Force writes immediately.
function Write-Status {
    param([switch]$Force)

    if (-not $StatusPath) { return }
    if (-not $Force -and $script:StatusWatch.ElapsedMilliseconds -lt 700) { return }
    $script:StatusWatch.Restart()
    $clean = { param($value) ([string]$value) -replace '[\r\n]+', ' ' }
    # Each item is parenthesized: in PowerShell the comma binds tighter than +.
    $lines = @(
        ('STATE=' + $script:Status.State),
        ('PID=' + $PID),
        ('STEP=' + $script:Status.Step),
        ('TOTAL=' + $script:TotalSteps),
        ('TITLE=' + (& $clean $script:Status.Title)),
        ('HINT=' + (& $clean $script:Status.Hint)),
        ('RESULT=' + (& $clean $script:Status.Result)),
        ('LOG=' + (& $clean $script:LogPath)),
        '---'
    ) + $script:StatusTail.ToArray()
    $temporary = $StatusPath + '.tmp'
    try {
        [System.IO.File]::WriteAllLines($temporary, [string[]]$lines, (New-Object System.Text.UTF8Encoding($true)))
        [System.IO.File]::Copy($temporary, $StatusPath, $true)
    } catch {
        # The wizard may be reading the file at this moment; the next update catches up.
    }
}

function Add-StatusLine {
    param([string]$Text, [switch]$Force)

    if (-not $StatusPath) { return }
    $script:StatusTail.Enqueue($Text)
    while ($script:StatusTail.Count -gt 60) { [void]$script:StatusTail.Dequeue() }
    Write-Status -Force:$Force
}

function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR')][string]$Level = 'INFO'
    )

    $line = '[{0}] [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    if ($Level -eq 'ERROR') {
        Write-Host $line -ForegroundColor Red
    } elseif ($Level -eq 'WARN') {
        Write-Host $line -ForegroundColor Yellow
    } else {
        Write-Host $line
    }
    if ($script:LogPath) {
        Add-Content -LiteralPath $script:LogPath -Value $line -Encoding UTF8
    }
    Add-StatusLine $line -Force
}

function Write-JsonFile {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $Value | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Get-FileHashString {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-StringHash {
    param([Parameter(Mandatory = $true)][string]$Text)

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        return (($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') }) -join '')
    } finally {
        $sha.Dispose()
    }
}

function Require-File {
    param([string]$Path, [string]$Description)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing ${Description}: $Path"
    }
    return [System.IO.Path]::GetFullPath($Path)
}

function Require-Directory {
    param([string]$Path, [string]$Description)
    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "$Description was not selected."
    }
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Missing ${Description}: $Path"
    }
    return [System.IO.Path]::GetFullPath($Path)
}

function Invoke-Tool {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [string]$WorkingDirectory = '',
        [string]$Name = ''
    )

    if ([string]::IsNullOrWhiteSpace($Name)) {
        $Name = [System.IO.Path]::GetFileName($FilePath)
    }
    $shownArguments = ($Arguments | ForEach-Object {
        if ($_ -match '[\s"]') { '"' + ($_ -replace '"', '\"') + '"' } else { $_ }
    }) -join ' '
    Write-Log ('Running: {0} {1}' -f $Name, $shownArguments)

    $previous = $null
    if ($WorkingDirectory) {
        $previous = Get-Location
        Set-Location -LiteralPath $WorkingDirectory
    }
    # Windows PowerShell 5.1 turns every stderr line of a native tool into an error record, and
    # with ErrorActionPreference=Stop the first one (git progress, a Python warning...) would end
    # the build even though the tool succeeds. Only the exit code decides success.
    $ErrorActionPreference = 'Continue'
    try {
        & $FilePath @Arguments 2>&1 | ForEach-Object {
            if ($_ -is [System.Management.Automation.ErrorRecord]) {
                $text = $_.Exception.Message
            } else {
                $text = $_.ToString()
            }
            Write-Host $text
            if ($script:LogPath) {
                Add-Content -LiteralPath $script:LogPath -Value $text -Encoding UTF8
            }
            Add-StatusLine $text
        }
        $exitCode = $LASTEXITCODE
        Write-Status -Force
    } finally {
        if ($previous) {
            Set-Location -LiteralPath $previous.Path
        }
    }
    if ($exitCode -ne 0) {
        throw "$Name failed with exit code $exitCode."
    }
}

function Get-CommandPath {
    param([Parameter(Mandatory = $true)][string]$Name)

    $command = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if (-not $command) {
        throw "$Name was not found."
    }
    return $command.Path
}

function Resolve-Tool {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string[]]$Candidates
    )

    foreach ($candidate in $Candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }
    return Get-CommandPath $Name
}

function Test-SafeGitRef {
    param([Parameter(Mandatory = $true)][string]$Ref)

    if ($Ref.Length -eq 0 -or $Ref.Length -gt 128) { return $false }
    if ($Ref -notmatch '^[A-Za-z0-9][A-Za-z0-9._/@-]*$') { return $false }
    if ($Ref.Contains('..') -or $Ref.Contains('//') -or $Ref.Contains('@{')) { return $false }
    if ($Ref.EndsWith('/') -or $Ref.EndsWith('.') -or $Ref.EndsWith('.lock')) { return $false }
    return $true
}

function Get-RepositoryIdentity {
    param([Parameter(Mandatory = $true)][string]$RepositoryUrl)

    try {
        $uri = [System.Uri]$RepositoryUrl
    } catch {
        throw "Repository URL is not valid: $RepositoryUrl"
    }
    if ($uri.Scheme -ne 'https' -or $uri.Host -ne 'github.com' -or
        -not [string]::IsNullOrEmpty($uri.UserInfo) -or $uri.Port -ne 443 -or
        -not [string]::IsNullOrEmpty($uri.Query) -or -not [string]::IsNullOrEmpty($uri.Fragment)) {
        throw 'Use a normal GitHub HTTPS repository URL, for example https://github.com/owner/Eglantine.git'
    }

    $parts = $uri.AbsolutePath.Trim('/').Split('/')
    if ($parts.Count -ne 2 -or $parts[0] -notmatch '^[A-Za-z0-9_.-]+$' -or
        $parts[1] -notmatch '^[A-Za-z0-9_.-]+(?:\.git)?$') {
        throw 'Repository URL must name one GitHub repository, for example https://github.com/owner/Eglantine.git'
    }
    $owner = $parts[0]
    $repository = $parts[1] -replace '\.git$', ''
    return [PSCustomObject]@{
        Owner = $owner
        Repository = $repository
        CloneUrl = 'https://github.com/{0}/{1}.git' -f $owner, $repository
        DisplayName = '{0}/{1}' -f $owner, $repository
    }
}

# Finds a Visual Studio or Build Tools instance with the x64 C++ tools and a recent enough
# CMake. Returns an object whose Ready is false and Problem explains why when none is usable.
function Find-VisualStudio {
    # Native tools may write to stderr; only their exit codes and output decide (see Invoke-Tool).
    $ErrorActionPreference = 'Continue'
    $candidates = @()
    if (${env:ProgramFiles(x86)}) {
        $candidates += (Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe')
    }
    if ($env:ProgramFiles) {
        $candidates += (Join-Path $env:ProgramFiles 'Microsoft Visual Studio\Installer\vswhere.exe')
    }
    $vswhere = $candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
        Select-Object -First 1
    if (-not $vswhere) {
        return [PSCustomObject]@{ Ready = $false; Problem = 'The Microsoft C++ Build Tools (Visual Studio) are not installed.' }
    }

    $vswhereArgs = @(
        '-all', '-sort', '-products', '*', '-requires',
        'Microsoft.VisualStudio.Component.VC.Tools.x86.x64', '-property', 'installationPath'
    )
    $installPaths = @(& $vswhere @vswhereArgs 2>$null | ForEach-Object { ([string]$_).Trim() } | Where-Object { $_ })
    if ($installPaths.Count -eq 0) {
        return [PSCustomObject]@{ Ready = $false; Problem = 'Visual Studio is installed, but its x64 C++ tools are missing.' }
    }

    $problem = 'Visual Studio is too old: Eglantine needs CMake {0} or newer.' -f $MinimumCmake
    # -sort lists the newest first, so a freshly installed Build Tools wins over an older Visual Studio.
    foreach ($installPath in $installPaths) {
        $vcvars = Join-Path $installPath 'VC\Auxiliary\Build\vcvars64.bat'
        $cmakeBin = Join-Path $installPath 'Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin'
        $cmakeExe = Join-Path $cmakeBin 'cmake.exe'
        if (-not (Test-Path -LiteralPath $vcvars -PathType Leaf) -or
            -not (Test-Path -LiteralPath $cmakeExe -PathType Leaf)) {
            continue
        }
        try {
            if ((Get-CmakeVersion $cmakeExe) -lt $MinimumCmake) { continue }
        } catch {
            continue
        }
        return [PSCustomObject]@{
            Ready = $true
            Problem = ''
            InstallPath = $installPath
            VcVars = $vcvars
            CMakeBin = $cmakeBin
            NinjaBin = Join-Path $installPath 'Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja'
            GitBin = Join-Path $installPath 'Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\cmd'
        }
    }
    return [PSCustomObject]@{ Ready = $false; Problem = $problem }
}

function Get-Text {
    param([Parameter(Mandatory = $true)][string]$English, [Parameter(Mandatory = $true)][string]$French)
    if ($script:Language -eq 'fr') { return $French }
    return $English
}

# Shows a clear, numbered step for people who are not reading the technical log.
function Write-Step {
    param(
        [Parameter(Mandatory = $true)][int]$Number,
        [Parameter(Mandatory = $true)][string]$Title,
        [string]$Hint = ''
    )

    $heading = (Get-Text 'Step {0} of {1}: {2}' 'Étape {0} sur {1} : {2}') -f $Number, $script:TotalSteps, $Title
    Write-Host ''
    Write-Host ('=' * 72) -ForegroundColor Cyan
    Write-Host ('  ' + $heading) -ForegroundColor Cyan
    if ($Hint) {
        Write-Host ('  ' + $Hint) -ForegroundColor Gray
    }
    Write-Host ('=' * 72) -ForegroundColor Cyan
    try { $Host.UI.RawUI.WindowTitle = 'Eglantine Steam Builder - ' + $heading } catch { }
    if ($script:LogPath) {
        Add-Content -LiteralPath $script:LogPath -Value ('### ' + $heading) -Encoding UTF8
    }
    $script:Status.Step = $Number
    $script:Status.Title = $Title
    $script:Status.Hint = $Hint
    Add-StatusLine ('### ' + $heading) -Force
}

# Downloads a file once into the tool cache and refuses it unless its SHA-256 matches.
function Save-VerifiedDownload {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$Destination,
        [string]$Sha256 = '',
        [Parameter(Mandatory = $true)][string]$Description
    )

    if ((Test-Path -LiteralPath $Destination -PathType Leaf) -and $Sha256 -and
        (Get-FileHashString $Destination) -eq $Sha256) {
        Write-Log "$Description is already downloaded."
        return $Destination
    }
    New-Item -ItemType Directory -Path (Split-Path $Destination -Parent) -Force | Out-Null
    $partial = $Destination + '.part'
    Remove-Item -LiteralPath $partial -Force -ErrorAction SilentlyContinue
    Write-Log "Downloading $Description from $Url"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    $client = New-Object System.Net.WebClient
    $client.Headers.Add('User-Agent', "Eglantine-Steam-Remote-Play-Builder/$BuilderVersion")
    try {
        $client.DownloadFile($Url, $partial)
    } catch {
        Remove-Item -LiteralPath $partial -Force -ErrorAction SilentlyContinue
        throw "Could not download $Description. Check your internet connection, then run the builder again. ($($_.Exception.Message))"
    } finally {
        $client.Dispose()
    }
    if ($Sha256) {
        $actual = Get-FileHashString $partial
        if ($actual -ne $Sha256) {
            Remove-Item -LiteralPath $partial -Force -ErrorAction SilentlyContinue
            throw "The downloaded $Description failed its integrity check (expected $Sha256, got $actual). It was deleted."
        }
    }
    Move-Item -LiteralPath $partial -Destination $Destination -Force
    return $Destination
}

# Extracts a zip into a new folder; the folder only appears once extraction succeeded.
function Expand-ZipToFolder {
    param(
        [Parameter(Mandatory = $true)][string]$Zip,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    $staging = $Destination + '.extracting'
    Remove-Item -LiteralPath $staging -Recurse -Force -ErrorAction SilentlyContinue
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    # ExtractToDirectory refuses entries that would land outside the destination folder.
    [System.IO.Compression.ZipFile]::ExtractToDirectory($Zip, $staging)
    if (Test-Path -LiteralPath $Destination) {
        Remove-Item -LiteralPath $Destination -Recurse -Force
    }
    Move-Item -LiteralPath $staging -Destination $Destination
}

function Get-AutoGlslang {
    param([Parameter(Mandatory = $true)][string]$ToolCache)

    $folder = Join-Path $ToolCache ('glslang-' + $GlslangTool.Version)
    $exe = Join-Path $folder 'bin\glslang.exe'
    if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
        $zip = Save-VerifiedDownload $GlslangTool.Url (Join-Path $ToolCache ('downloads\glslang-' + $GlslangTool.Version + '.zip')) `
            $GlslangTool.Sha256 ('glslang shader compiler ' + $GlslangTool.Version)
        Expand-ZipToFolder $zip $folder
    }
    return Require-File $exe 'glslang shader compiler'
}

function Get-AutoMinGit {
    param([Parameter(Mandatory = $true)][string]$ToolCache)

    $folder = Join-Path $ToolCache ('mingit-' + $MinGitTool.Version)
    $exe = Join-Path $folder 'cmd\git.exe'
    if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
        $zip = Save-VerifiedDownload $MinGitTool.Url (Join-Path $ToolCache ('downloads\MinGit-' + $MinGitTool.Version + '.zip')) `
            $MinGitTool.Sha256 ('portable Git ' + $MinGitTool.Version)
        Expand-ZipToFolder $zip $folder
    }
    return Require-File $exe 'portable Git'
}

function Get-AutoQt {
    param([Parameter(Mandatory = $true)][string]$ToolCache)

    $qtRoot = Join-Path $ToolCache 'qt'
    $qtDir = Join-Path $qtRoot ($QtVersion + '\msvc2022_64')
    $charts = Join-Path $qtDir 'lib\cmake\Qt6Charts\Qt6ChartsConfig.cmake'
    if (Test-Path -LiteralPath $charts -PathType Leaf) {
        Write-Log "Qt $QtVersion is already downloaded."
        return $qtDir
    }
    $aqt = Save-VerifiedDownload $AqtTool.Url (Join-Path $ToolCache ('aqtinstall-' + $AqtTool.Version + '\aqt.exe')) `
        $AqtTool.Sha256 ('Qt downloader (aqtinstall ' + $AqtTool.Version + ')')
    New-Item -ItemType Directory -Path $qtRoot -Force | Out-Null
    Write-Log "Downloading Qt $QtVersion with Qt Charts (about 1 GB). aqtinstall checks every Qt archive."
    Invoke-Tool $aqt @('install-qt', 'windows', 'desktop', $QtVersion, $QtArch, '-m', 'qtcharts',
                       '--outputdir', $qtRoot) $ToolCache 'aqt'
    Require-File $charts 'Qt Charts CMake files' | Out-Null
    return $qtDir
}

# Finds GNU patch the way Eglantine's CMake does (next to Git for Windows, then on PATH).
function Find-PatchProgram {
    param([Parameter(Mandatory = $true)][string]$Git)

    $gitDir = Split-Path -Parent $Git
    $candidates = @(
        (Join-Path (Split-Path -Parent $gitDir) 'usr\bin\patch.exe'),
        (Join-Path (Split-Path -Parent (Split-Path -Parent $gitDir)) 'usr\bin\patch.exe'),
        (Join-Path ${env:ProgramFiles} 'Git\usr\bin\patch.exe')
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }
    $onPath = Get-Command patch.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($onPath) { return $onPath.Path }
    return ''
}

function Get-AutoPatch {
    param([Parameter(Mandatory = $true)][string]$ToolCache)

    $folder = Join-Path $ToolCache ('git-for-windows-' + $GitForWindowsTool.Version)
    $exe = Join-Path $folder 'usr\bin\patch.exe'
    if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
        $archive = Save-VerifiedDownload $GitForWindowsTool.Url `
            (Join-Path $ToolCache ('downloads\Git-' + $GitForWindowsTool.Version + '-64-bit.tar.bz2')) `
            $GitForWindowsTool.Sha256 ('Git for Windows tools ' + $GitForWindowsTool.Version + ' (for patch.exe, about 120 MB)')
        $staging = $folder + '.extracting'
        Remove-Item -LiteralPath $staging -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory -Path $staging -Force | Out-Null
        $tar = Join-Path $env:SystemRoot 'System32\tar.exe'
        Require-File $tar 'Windows tar tool' | Out-Null
        Invoke-Tool $tar @('-xjf', $archive, '-C', $staging, 'usr/bin') '' 'tar'
        if (Test-Path -LiteralPath $folder) {
            Remove-Item -LiteralPath $folder -Recurse -Force
        }
        Move-Item -LiteralPath $staging -Destination $folder
    }
    return Require-File $exe 'GNU patch from Git for Windows'
}

function Get-AutoSccache {
    param([Parameter(Mandatory = $true)][string]$ToolCache)

    $folder = Join-Path $ToolCache ('sccache-' + $SccacheTool.Version)
    $exe = Get-ChildItem -LiteralPath $folder -Recurse -Filter 'sccache.exe' -File -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if (-not $exe) {
        $zip = Save-VerifiedDownload $SccacheTool.Url (Join-Path $ToolCache ('downloads\sccache-' + $SccacheTool.Version + '.zip')) `
            $SccacheTool.Sha256 ('sccache compiler cache ' + $SccacheTool.Version)
        Expand-ZipToFolder $zip $folder
        $exe = Get-ChildItem -LiteralPath $folder -Recurse -Filter 'sccache.exe' -File | Select-Object -First 1
    }
    if (-not $exe) {
        throw 'sccache.exe was not found in the downloaded archive.'
    }
    return $exe.FullName
}

# Runs Git and returns its standard output lines; throws when Git fails.
function Get-GitOutput {
    param(
        [Parameter(Mandatory = $true)][string]$Git,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $ErrorActionPreference = 'Continue'
    $output = @(& $Git @Arguments 2>$null)
    if ($LASTEXITCODE -ne 0) {
        throw ('git {0} failed with exit code {1}.' -f ($Arguments -join ' '), $LASTEXITCODE)
    }
    return $output
}

# Keeps one build folder from being used by two builds at the same time. The lock is released
# when this process ends, even after a crash.
function Enter-BuildLock {
    param([Parameter(Mandatory = $true)][string]$Folder)

    $path = Join-Path $Folder 'builder.lock'
    try {
        $script:BuildLock = [System.IO.File]::Open($path, [System.IO.FileMode]::OpenOrCreate,
            [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
    } catch {
        throw 'Another build is already using this build folder. Wait for it to finish, then try again.'
    }
}

# Brings the reusable source folder to <commit> + the Steam patch. The patched version is first
# assembled inside Git (temporary index, no files written), then checked out: Git only rewrites
# files whose content changed, so Ninja keeps every object file that is still valid.
# Returns $true when the patch applied directly, $false when it needed a three-way merge.
function Update-PatchedSource {
    param(
        [Parameter(Mandatory = $true)][string]$Git,
        [Parameter(Mandatory = $true)][string]$Mirror,
        [Parameter(Mandatory = $true)][string]$SourceDir,
        [Parameter(Mandatory = $true)][string]$Commit,
        [Parameter(Mandatory = $true)][string]$Patch
    )

    $normalize = { param($value) ([string]$value).Replace('/', '\').TrimEnd('\').ToLowerInvariant() }
    $usable = $false
    if (Test-Path -LiteralPath (Join-Path $SourceDir '.git') -PathType Container) {
        try {
            $origin = (Get-GitOutput $Git @('-C', $SourceDir, 'config', '--get', 'remote.origin.url')) | Select-Object -First 1
            $usable = (& $normalize $origin) -eq (& $normalize $Mirror)
        } catch {
            $usable = $false
        }
    }
    if (-not $usable) {
        if (Test-Path -LiteralPath $SourceDir) {
            Write-Log 'The reusable source folder is not usable; creating it again.' 'WARN'
            Remove-Item -LiteralPath $SourceDir -Recurse -Force
        }
        Invoke-Tool $Git @('clone', '--shared', '--no-checkout', $Mirror, $SourceDir) '' 'git clone worktree'
    }

    $index = Join-Path $SourceDir '.git\builder-patch.index'
    Remove-Item -LiteralPath $index -Force -ErrorAction SilentlyContinue
    $direct = $true
    $env:GIT_INDEX_FILE = $index
    try {
        Invoke-Tool $Git @('-C', $SourceDir, 'read-tree', $Commit) '' 'git read-tree'
        try {
            Invoke-Tool $Git @('-C', $SourceDir, 'apply', '--cached', '--check', '--whitespace=nowarn', $Patch) '' 'git apply check'
        } catch {
            $direct = $false
            Write-Log 'The patch needs Git three-way merge help for this version.' 'WARN'
        }
        $applyArguments = @('-C', $SourceDir, 'apply', '--cached', '--whitespace=nowarn')
        if (-not $direct) { $applyArguments += '--3way' }
        try {
            Invoke-Tool $Git ($applyArguments + $Patch) '' 'git apply'
        } catch {
            $conflicts = @()
            try {
                $conflicts = @(Get-GitOutput $Git @('-C', $SourceDir, 'diff', '--cached', '--name-only', '--diff-filter=U'))
            } catch { }
            if ($conflicts.Count -gt 0) {
                throw "The patch conflicts with this source version in: $($conflicts -join ', '). This fork/version needs an updated patch."
            }
            throw 'The patch did not apply to this source version. This fork/version needs an updated patch.'
        }
        $tree = (Get-GitOutput $Git @('-C', $SourceDir, 'write-tree')) | Select-Object -First 1
    } finally {
        Remove-Item Env:\GIT_INDEX_FILE -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $index -Force -ErrorAction SilentlyContinue
    }

    $patched = (Get-GitOutput $Git @('-C', $SourceDir,
        '-c', 'user.name=Eglantine Steam Builder', '-c', 'user.email=builder@localhost',
        'commit-tree', $tree, '-p', $Commit, '-m', 'Steam Remote Play Together patch (local build)')) |
        Select-Object -First 1
    Invoke-Tool $Git @('-C', $SourceDir, 'checkout', '--force', '--detach', $patched) '' 'git checkout'
    return $direct
}

function Install-VisualStudioBuildTools {
    param([Parameter(Mandatory = $true)][string]$ToolCache)

    $bootstrapper = Join-Path $ToolCache 'downloads\vs_BuildTools.exe'
    Remove-Item -LiteralPath $bootstrapper -Force -ErrorAction SilentlyContinue
    Save-VerifiedDownload $VisualStudioBootstrapperUrl $bootstrapper '' 'Microsoft C++ Build Tools installer' | Out-Null
    $signature = Get-AuthenticodeSignature -LiteralPath $bootstrapper
    if ($signature.Status -ne 'Valid' -or -not $signature.SignerCertificate -or
        $signature.SignerCertificate.Subject -notmatch 'O=Microsoft Corporation') {
        Remove-Item -LiteralPath $bootstrapper -Force -ErrorAction SilentlyContinue
        throw 'The downloaded Visual Studio installer is not signed by Microsoft. It was deleted.'
    }

    $arguments = @('--wait', '--passive', '--norestart', '--nocache')
    foreach ($component in $VisualStudioComponents) { $arguments += @('--add', $component) }
    $arguments += '--includeRecommended'

    Write-Log (Get-Text `
        'Installing the Microsoft C++ Build Tools (about 8 GB, 10-30 minutes). Windows will ask for administrator approval: choose Yes.' `
        'Installation des outils Microsoft C++ Build Tools (environ 8 Go, 10 à 30 minutes). Windows va demander une autorisation administrateur : choisissez Oui.') 'WARN'
    Write-Log ('Running: vs_BuildTools.exe ' + ($arguments -join ' '))
    try {
        $process = Start-Process -FilePath $bootstrapper -ArgumentList $arguments -Verb RunAs -Wait -PassThru
    } catch {
        throw 'The Microsoft C++ Build Tools were not installed because administrator approval was refused. Run the builder again and choose Yes.'
    }
    $code = $process.ExitCode
    if ($code -eq 3010 -or $code -eq 1641) {
        Write-Log 'The Build Tools were installed. Windows asks for a restart; the build continues now, but restart if it fails.' 'WARN'
    } elseif ($code -ne 0) {
        throw "The Microsoft C++ Build Tools installer stopped with code $code. Run the builder again, or install 'Desktop development with C++' from https://visualstudio.microsoft.com/downloads/"
    }
}

# Returns Steam's runtime library (steam_api64.dll). The wizard installs it next to this script;
# when it is missing (GitHub Actions, or the script run from a repository checkout) it is
# downloaded once into the tool cache. Nothing from the Steamworks SDK is needed to build: the
# extension loads this DLL from its own folder at runtime.
function Get-SteamRuntime {
    param([Parameter(Mandatory = $true)][string]$ToolCache)

    $bundled = Join-Path $PSScriptRoot 'steam_api64.dll'
    if (Test-Path -LiteralPath $bundled -PathType Leaf) {
        $actual = Get-FileHashString $bundled
        if ($actual -ne $SteamRuntime.EntrySha256) {
            throw "The bundled steam_api64.dll failed its integrity check (expected $($SteamRuntime.EntrySha256), got $actual). Re-download the builder."
        }
        Write-Log "Using the Steam runtime library $($SteamRuntime.Version) bundled with the builder."
        return [System.IO.Path]::GetFullPath($bundled)
    }

    $folder = Join-Path $ToolCache ('steam-runtime-' + $SteamRuntime.Version)
    $dll = Join-Path $folder 'steam_api64.dll'
    if ((Test-Path -LiteralPath $dll -PathType Leaf) -and (Get-FileHashString $dll) -eq $SteamRuntime.EntrySha256) {
        Write-Log "Steam runtime library $($SteamRuntime.Version) is already downloaded."
        return $dll
    }
    $zip = Save-VerifiedDownload $SteamRuntime.Url `
        (Join-Path $ToolCache ('downloads\Steamworks.NET-Standalone-' + $SteamRuntime.Version + '.zip')) `
        $SteamRuntime.Sha256 ('Steam runtime library ' + $SteamRuntime.Version + ' (Steamworks.NET archive)')
    $extracted = $folder + '.archive'
    Expand-ZipToFolder $zip $extracted
    try {
        $entry = Join-Path $extracted $SteamRuntime.Entry
        Require-File $entry 'steam_api64.dll in the Steamworks.NET archive' | Out-Null
        $actual = Get-FileHashString $entry
        if ($actual -ne $SteamRuntime.EntrySha256) {
            throw "steam_api64.dll failed its integrity check (expected $($SteamRuntime.EntrySha256), got $actual)."
        }
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Copy-VerifiedFile $entry $dll
    } finally {
        Remove-Item -LiteralPath $extracted -Recurse -Force -ErrorAction SilentlyContinue
    }
    return $dll
}

function Import-VcVars {
    param([Parameter(Mandatory = $true)][string]$VcVars)

    # Native tools may write to stderr; only their exit codes and output decide (see Invoke-Tool).
    $ErrorActionPreference = 'Continue'
    $commandLine = 'call "{0}" >nul && set' -f $VcVars
    $lines = & $env:ComSpec '/d' '/s' '/c' $commandLine 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw 'Visual Studio could not initialize its x64 compiler environment.'
    }
    $count = 0
    foreach ($line in $lines) {
        $match = [regex]::Match($line, '^([^=]+)=(.*)$')
        if ($match.Success -and -not $match.Groups[1].Value.StartsWith('=')) {
            [System.Environment]::SetEnvironmentVariable(
                $match.Groups[1].Value, $match.Groups[2].Value, 'Process')
            $count++
        }
    }
    if ($count -eq 0) {
        throw 'Visual Studio did not provide a compiler environment.'
    }
}

function Get-CmakeVersion {
    param([Parameter(Mandatory = $true)][string]$Cmake)

    # Native tools may write to stderr; only their exit codes and output decide (see Invoke-Tool).
    $ErrorActionPreference = 'Continue'
    $line = (@(& $Cmake '--version' 2>&1) | Select-Object -First 1).ToString()
    if ($LASTEXITCODE -ne 0 -or $line -notmatch '(\d+\.\d+\.\d+)') {
        throw 'Could not read the CMake version.'
    }
    return [Version]$Matches[1]
}

function Get-ResolvedCommit {
    param(
        [Parameter(Mandatory = $true)][string]$Git,
        [Parameter(Mandatory = $true)][string]$Mirror,
        [Parameter(Mandatory = $true)][string]$Ref,
        [string]$Kind = ''
    )
    # Native tools may write to stderr; only their exit codes and output decide (see Invoke-Tool).
    $ErrorActionPreference = 'Continue'

    # The wizard says whether the name is a branch or a tag, so a branch and a tag with the same
    # name cannot be confused. Older configurations without a kind keep the previous lookup.
    if ($Kind -eq 'branch') {
        $candidates = @(('refs/heads/{0}^{{commit}}' -f $Ref))
    } elseif ($Kind -eq 'tag') {
        $candidates = @(('refs/tags/{0}^{{commit}}' -f $Ref))
    } else {
        $candidates = @(
            ('refs/tags/{0}^{{commit}}' -f $Ref),
            ('refs/heads/{0}^{{commit}}' -f $Ref),
            ('refs/remotes/origin/{0}^{{commit}}' -f $Ref),
            ('{0}^{{commit}}' -f $Ref)
        )
    }
    foreach ($candidate in $candidates) {
        $value = (@(& $Git ("--git-dir=$Mirror") 'rev-parse' '--verify' '--quiet' $candidate 2>$null) |
            Select-Object -First 1)
        if ($LASTEXITCODE -eq 0 -and $value -match '^[0-9a-fA-F]{40}$') {
            return $value.ToLowerInvariant()
        }
    }
    throw "Git cannot find '$Ref' in the selected repository. Check the branch or tag name."
}

function Copy-VerifiedFile {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    if ((Get-FileHashString $Source) -ne (Get-FileHashString $Destination)) {
        throw "Copy verification failed for $Destination"
    }
}

function Get-DriveFreeSpace {
    param([Parameter(Mandatory = $true)][string]$Path)

    $root = [System.IO.Path]::GetPathRoot([System.IO.Path]::GetFullPath($Path))
    return [System.IO.DriveInfo]::new($root).AvailableFreeSpace
}

function Write-OutputReadme {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string]$Ref,
        [Parameter(Mandatory = $true)][string]$Commit,
        [Parameter(Mandatory = $true)][uint32]$AppId
    )

    @"
Eglantine + Steam Remote Play Together
=======================================

This is a private build made on this PC by Eglantine Steam Remote Play Builder.

Source: $Repository
Reference: $Ref
Commit: $Commit
Steam App ID at build time: $AppId

Steam Remote Play Together is an Eglantine extension, in
extensions\$ExtensionId\.

First start:
1. Start Steam and sign in, then start eglantine.exe from this folder.
2. Open Extensions > Manage Extensions..., tick "Steam Remote Play Together",
   then restart Eglantine (the extension starts Steam before the main window).
3. Use Multiplayer > Remote Play Together: Invite Friends... or Copy Guest Link.

The extension starts as Steam App ID $AppId until you choose another one with
Multiplayer > Remote Play Together: Steam App ID... (takes effect at the next start).
The Steam account must own that App ID.

extensions\$ExtensionId\steam_api64.dll is Valve's Steam runtime library
(Steamworks redistributable, SDK $($SteamRuntime.Version)). Keep this build for yourself.

If a controller does nothing, press Shift+Tab, open Controller Settings, and choose a
Gamepad template for each controller.

Build log: $script:LogPath
Build manifest: build-manifest.json
"@ | Set-Content -LiteralPath $Path -Encoding UTF8
}

$exitCode = 1
Write-Status -Force
try {
    $ConfigPath = Require-File $ConfigPath 'builder configuration file'
    $config = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
    # Configurations from builder 1.x also have SteamworksSdk, which is no longer used.
    foreach ($property in @('RepositoryUrl', 'GitRef', 'QtDir', 'VulkanSdk', 'Workspace', 'SteamAppId')) {
        if (-not $config.PSObject.Properties.Name.Contains($property)) {
            throw "Builder configuration is missing '$property'. Run the wizard again."
        }
    }

    $repository = Get-RepositoryIdentity ([string]$config.RepositoryUrl)
    $gitRef = ([string]$config.GitRef).Trim()
    if (-not (Test-SafeGitRef $gitRef)) {
        throw "'$gitRef' is not a supported branch or tag name."
    }
    $gitRefKind = ''
    if ($config.PSObject.Properties.Name.Contains('GitRefKind')) {
        $gitRefKind = ([string]$config.GitRefKind).Trim()
    }
    if ($gitRefKind -notin @('', 'branch', 'tag')) {
        throw "'$gitRefKind' is not a supported reference kind. Run the wizard again."
    }

    $appId = 0
    if (-not [UInt32]::TryParse(([string]$config.SteamAppId), [ref]$appId) -or $appId -eq 0) {
        throw 'Steam App ID must be a positive whole number.'
    }

    # Empty Qt / Vulkan folders mean "download what is needed"; InstallMissing allows installing the
    # Microsoft C++ Build Tools. Configurations from builder 1.1 always name both folders.
    $qtInput = ([string]$config.QtDir).Trim()
    $vulkanInput = ([string]$config.VulkanSdk).Trim()
    $installMissing = $false
    if ($config.PSObject.Properties.Name.Contains('InstallMissing')) {
        $installMissing = ([string]$config.InstallMissing) -eq 'True'
    }
    $useCompilerCache = $true
    if ($config.PSObject.Properties.Name.Contains('UseCompilerCache')) {
        $useCompilerCache = ([string]$config.UseCompilerCache).Trim().ToLowerInvariant() -ne 'false'
    }
    if ($config.PSObject.Properties.Name.Contains('Language') -and ([string]$config.Language) -eq 'fr') {
        $script:Language = 'fr'
    }

    $workspaceInput = ([string]$config.Workspace).Trim()
    if ([string]::IsNullOrWhiteSpace($workspaceInput)) {
        throw 'Build workspace folder was not selected.'
    }
    $workspace = [System.IO.Path]::GetFullPath($workspaceInput)
    $root = [System.IO.Path]::GetPathRoot($workspace)
    if ($workspace.TrimEnd('\') -eq $root.TrimEnd('\')) {
        throw 'Choose a build workspace folder, not the root of a drive.'
    }
    New-Item -ItemType Directory -Path $workspace -Force | Out-Null
    $script:Workspace = $workspace
    if ((Get-DriveFreeSpace $workspace) -lt $MinimumFreeSpace) {
        throw ('At least {0:N0} GB free space is needed in the build workspace.' -f ($MinimumFreeSpace / 1GB))
    }

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $safeRef = ($gitRef -replace '[^A-Za-z0-9._-]', '-').Trim('-')
    if ([string]::IsNullOrWhiteSpace($safeRef)) { $safeRef = 'ref' }
    $repoKey = ('{0}-{1}' -f $repository.Repository, (Get-StringHash $repository.CloneUrl).Substring(0, 12)).ToLowerInvariant()
    $script:RunId = '{0}-{1}-{2}' -f $repository.Repository, $safeRef, $timestamp
    # One reusable source + build folder per repository, so a later build only recompiles what
    # changed. The path stays short on purpose (no branch name): long paths pushed CMake's object
    # files past its 250-character limit. The log file keeps the descriptive run name.
    $script:RunRoot = Join-Path $workspace ('work\' + $repoKey)
    $logsDir = Join-Path $workspace 'logs'
    New-Item -ItemType Directory -Path $script:RunRoot, $logsDir -Force | Out-Null
    $script:LogPath = Join-Path $logsDir ($script:RunId + '.log')
    New-Item -ItemType File -Path $script:LogPath -Force | Out-Null
    Enter-BuildLock $script:RunRoot

    Write-Log "Eglantine Steam Remote Play Builder $BuilderVersion"
    Write-Log "Repository: $($repository.CloneUrl)"
    Write-Log ("Reference: $gitRef" + $(if ($gitRefKind) { " ($gitRefKind)" } else { "" }))
    Write-Log "Workspace: $workspace"
    Write-Log 'Only build source you trust. CMake and the chosen repository can run build commands on this PC.' 'WARN'
    $oldRuns = Join-Path $workspace 'runs'
    if (Test-Path -LiteralPath $oldRuns -PathType Container) {
        Write-Log "Builds from older builder versions in $oldRuns are no longer used. You can delete that folder to free space." 'WARN'
    }

    $patch = Require-File (Join-Path $PSScriptRoot 'steam-remote-play-together.patch') 'Steam Remote Play source patch'
    $patchHash = Get-FileHashString $patch
    if ($patchHash -ne $ExpectedPatchSha256) {
        throw "The bundled patch failed its integrity check. Expected $ExpectedPatchSha256, got $patchHash. Re-download the builder."
    }
    Write-Log "Patch SHA-256: $patchHash"

    Write-Step 1 (Get-Text 'Preparing the build tools' 'Préparation des outils de compilation') (Get-Text `
        'The first time, this downloads what is missing (up to 10 GB) and can take 30 minutes.' `
        'La première fois, les éléments manquants sont téléchargés (jusqu''à 10 Go) : cela peut prendre 30 minutes.')
    $cacheRoot = Join-Path $workspace 'cache'
    $toolCache = Join-Path $cacheRoot 'tools'
    New-Item -ItemType Directory -Path $toolCache -Force | Out-Null

    $visualStudio = Find-VisualStudio
    if (-not $visualStudio.Ready) {
        if (-not $installMissing) {
            throw ($visualStudio.Problem + ' Run the wizard again and let it install what is missing, or install "Desktop development with C++" from https://visualstudio.microsoft.com/downloads/')
        }
        Write-Log $visualStudio.Problem 'WARN'
        Install-VisualStudioBuildTools $toolCache
        $visualStudio = Find-VisualStudio
        if (-not $visualStudio.Ready) {
            throw ('The Microsoft C++ Build Tools were installed but are not usable yet: ' + $visualStudio.Problem + ' Restart Windows, then run the builder again.')
        }
    }
    Write-Log "Visual Studio: $($visualStudio.InstallPath)"

    $steamRuntimeDll = Get-SteamRuntime $toolCache
    Write-Log "Steam runtime library: $steamRuntimeDll"

    if ($qtInput) {
        $qtDir = Require-Directory $qtInput 'Qt MSVC folder'
    } else {
        $qtDir = Get-AutoQt $toolCache
    }
    Require-File (Join-Path $qtDir 'lib\cmake\Qt6\Qt6Config.cmake') 'Qt 6 CMake files' | Out-Null
    Require-File (Join-Path $qtDir 'lib\cmake\Qt6Charts\Qt6ChartsConfig.cmake') 'Qt Charts CMake files' | Out-Null
    $windeployqt = Require-File (Join-Path $qtDir 'bin\windeployqt.exe') 'Qt deployment tool'
    Write-Log "Qt: $qtDir"

    $vulkanSdk = ''
    if ($vulkanInput) {
        $vulkanSdk = Require-Directory $vulkanInput 'Vulkan SDK folder'
        $glslang = Require-File (Join-Path $vulkanSdk 'Bin\glslangValidator.exe') 'Vulkan SDK shader tool'
    } else {
        $glslang = Get-AutoGlslang $toolCache
    }
    Write-Log "Shader compiler: $glslang"

    # This project prefers a reusable workspace cache over an aggressive compiler cache. The build
    # continues without sccache when it is disabled or fails to prepare.
    $sccache = ''
    if ($useCompilerCache) {
        try {
            $sccache = Get-AutoSccache $toolCache
            Write-Log "Compiler cache: $sccache"
        } catch {
            Write-Log ('The compiler cache could not be prepared, so this build runs without it: ' + $_.Exception.Message) 'WARN'
        }
    } else {
        Write-Log 'Compiler cache disabled by configuration; using the reusable workspace cache instead.'
    }

    $toolPaths = @($visualStudio.CMakeBin, $visualStudio.NinjaBin, $visualStudio.GitBin, (Join-Path $qtDir 'bin')) |
        Where-Object { Test-Path -LiteralPath $_ -PathType Container }
    $pathSeparator = [System.IO.Path]::PathSeparator
    $env:Path = (($toolPaths -join $pathSeparator) + $pathSeparator + $env:Path)
    Import-VcVars $visualStudio.VcVars
    $env:Path = (($toolPaths -join $pathSeparator) + $pathSeparator + $env:Path)

    try {
        $git = Resolve-Tool 'git.exe' @(
            (Join-Path $visualStudio.GitBin 'git.exe')
        )
    } catch {
        $git = Get-AutoMinGit $toolCache
    }
    $cmake = Resolve-Tool 'cmake.exe' @(
        (Join-Path $visualStudio.CMakeBin 'cmake.exe')
    )
    $ninja = Resolve-Tool 'ninja.exe' @(
        (Join-Path $visualStudio.NinjaBin 'ninja.exe')
    )
    $cmakeVersion = Get-CmakeVersion $cmake
    if ($cmakeVersion -lt $MinimumCmake) {
        throw "CMake $cmakeVersion is too old. Eglantine needs CMake $MinimumCmake or newer."
    }
    $patchProgram = Find-PatchProgram $git
    if (-not $patchProgram) {
        Write-Log 'No GNU patch program was found (it comes with the full Git for Windows); downloading it.'
        $patchProgram = Get-AutoPatch $toolCache
    }
    Write-Log "Patch program: $patchProgram"
    Write-Log "Git: $((& $git '--version' | Select-Object -First 1).ToString())"
    Write-Log "CMake: $cmakeVersion"
    Write-Log "Ninja: $((& $ninja '--version' | Select-Object -First 1).ToString())"

    Write-Step 2 (Get-Text 'Downloading the Eglantine source code' 'Téléchargement du code source d''Eglantine') (Get-Text `
        'Only the first download is long; later builds reuse it.' `
        'Seul le premier téléchargement est long ; les compilations suivantes le réutilisent.')
    $mirror = Join-Path $cacheRoot ('repositories\' + $repoKey + '.git')
    $cpmCache = Join-Path $cacheRoot 'cpm'
    New-Item -ItemType Directory -Path (Split-Path $mirror -Parent), $cpmCache -Force | Out-Null
    if (Test-Path -LiteralPath $mirror -PathType Container) {
        $ErrorActionPreference = 'Continue'
        $bare = (@(& $git ("--git-dir=$mirror") 'rev-parse' '--is-bare-repository' 2>$null) | Select-Object -First 1)
        $bareExit = $LASTEXITCODE
        $ErrorActionPreference = 'Stop'
        if ($bareExit -ne 0 -or $bare -ne 'true') {
            throw "Builder cache path exists but is not its expected Git mirror: $mirror"
        }
        Invoke-Tool $git @("--git-dir=$mirror", 'fetch', '--prune', '--tags', 'origin') '' 'git fetch'
    } else {
        Invoke-Tool $git @('clone', '--mirror', $repository.CloneUrl, $mirror) '' 'git clone'
    }

    $commit = Get-ResolvedCommit $git $mirror $gitRef $gitRefKind
    $shortCommit = $commit.Substring(0, 12)
    Write-Log "Resolved $gitRef to $commit"

    $sourceDir = Join-Path $script:RunRoot 'source'
    $buildDir = Join-Path $script:RunRoot 'build'

    Write-Step 3 (Get-Text 'Adding Steam Remote Play Together' 'Ajout de Steam Remote Play Together')
    $directPatch = Update-PatchedSource $git $mirror $sourceDir $commit $patch
    foreach ($requiredPath in @(
        'src\extension_api\include\eglantine\extension.h',
        'src\yuzu\extensions\extension_manager.cpp',
        'extensions\CMakeLists.txt',
        'extensions\remote_play_together\extension.json',
        'extensions\remote_play_together\remote_play_together.cpp')) {
        Require-File (Join-Path $sourceDir $requiredPath) "patched source file $requiredPath" | Out-Null
    }
    Write-Log ('Patch applied ({0}).' -f $(if ($directPatch) { 'directly' } else { 'with Git three-way merge' }))

    $cmakeCachePath = $cpmCache.Replace('\', '/')
    $qtCmakePath = $qtDir.Replace('\', '/')
    $steamCmakePath = $steamRuntimeDll.Replace('\', '/')
    $glslangCmakePath = $glslang.Replace('\', '/')
    $cmakeArgs = @(
        '-S', $sourceDir,
        '-B', $buildDir,
        '-G', 'Ninja',
        '-DCMAKE_BUILD_TYPE=Release',
        '-DCMAKE_POLICY_VERSION_MINIMUM=3.5',
        "-DCPM_SOURCE_CACHE=$cmakeCachePath",
        "-DCMAKE_PREFIX_PATH=$qtCmakePath",
        '-DYUZU_USE_BUNDLED_QT=OFF',
        '-DYUZU_USE_BUNDLED_SDL3=ON',
        '-DENABLE_QT_TRANSLATION=ON',
        '-DENABLE_UPDATE_CHECKER=OFF',
        '-DUSE_DISCORD_PRESENCE=OFF',
        '-DBUILD_TESTING=OFF',
        '-DYUZU_TESTS=OFF',
        '-DYUZU_CMD=OFF',
        '-DYUZU_ROOM=OFF',
        '-DYUZU_ROOM_STANDALONE=OFF',
        '-DNIGHTLY_BUILD=OFF',
        '-DENABLE_WERROR=OFF',
        '-DENABLE_EXTENSIONS=ON',
        '-DEGLANTINE_BUILD_EXTENSIONS=ON',
        "-DSTEAM_API_LIBRARY=$steamCmakePath",
        "-DSTEAM_REMOTE_PLAY_APPID=$appId",
        "-DGLSLANGVALIDATOR=$glslangCmakePath",
        # Eglantine's CPMUtil skips its own search when PATCH_EXE is already set.
        ("-DPATCH_EXE=" + $patchProgram.Replace('\', '/'))
    )
    if ($sccache) {
        $sccacheCmakePath = $sccache.Replace('\', '/')
        $cmakeArgs += @("-DCMAKE_C_COMPILER_LAUNCHER=$sccacheCmakePath", "-DCMAKE_CXX_COMPILER_LAUNCHER=$sccacheCmakePath")
        $env:SCCACHE_DIR = Join-Path $cacheRoot 'sccache'
        $env:SCCACHE_CACHE_SIZE = $SccacheTool.CacheSize
    }

    Write-Step 4 (Get-Text 'Preparing the build' 'Préparation de la compilation') (Get-Text `
        'The first time, Eglantine downloads its libraries here.' `
        'La première fois, Eglantine télécharge ici ses bibliothèques.')
    # The previous build folder is reused unless a tool or folder it was configured with changed;
    # mixing those would give a broken build, so a change means a clean build folder.
    $fingerprint = (@(
        "cache-version=$BuildCacheVersion",
        'generator=Ninja',
        "visual-studio=$($visualStudio.InstallPath)",
        "msvc=$env:VCToolsVersion",
        "cmake=$cmakeVersion",
        "qt=$qtDir",
        "glslang=$glslang",
        "steam-runtime=$($SteamRuntime.EntrySha256)",
        "sccache=$sccache"
    ) -join "`n")
    $fingerprintPath = Join-Path $buildDir 'builder-fingerprint.txt'
    $reusedBuild = $false
    if (Test-Path -LiteralPath $buildDir -PathType Container) {
        $previousFingerprint = ''
        if (Test-Path -LiteralPath $fingerprintPath -PathType Leaf) {
            $previousFingerprint = ([string](Get-Content -LiteralPath $fingerprintPath -Raw)).Trim()
        }
        if ($previousFingerprint -eq $fingerprint.Trim()) {
            $reusedBuild = $true
            Write-Log 'Reusing the previous build: only files that changed are compiled again.'
        } else {
            Write-Log 'The build tools or folders changed since the last build, so this is a clean build.' 'WARN'
            Remove-Item -LiteralPath $buildDir -Recurse -Force
        }
    }
    try {
        Invoke-Tool $cmake $cmakeArgs '' 'cmake configure'
    } catch {
        if (-not $reusedBuild) { throw }
        Write-Log 'Preparing the reused build failed; trying once more with a clean build folder.' 'WARN'
        Remove-Item -LiteralPath $buildDir -Recurse -Force
        $reusedBuild = $false
        Invoke-Tool $cmake $cmakeArgs '' 'cmake configure'
    }
    # Written before compiling, so a build that stops halfway is continued next time.
    [System.IO.File]::WriteAllText($fingerprintPath, $fingerprint)

    $buildHint = if ($reusedBuild) {
        Get-Text 'Only files that changed since the last build are compiled.' `
            'Seuls les fichiers modifiés depuis la dernière compilation sont recompilés.'
    } else {
        Get-Text 'This is the longest step (often 20 to 60 minutes). Later builds reuse this work.' `
            'C''est l''étape la plus longue (souvent 20 à 60 minutes). Les compilations suivantes réutilisent ce travail.'
    }
    Write-Step 5 (Get-Text 'Building Eglantine' 'Compilation d''Eglantine') $buildHint
    try {
        # The extension is its own target: yuzu does not depend on it.
        Invoke-Tool $cmake @('--build', $buildDir, '--target', 'yuzu', 'remote-play-together', '--parallel') '' 'cmake build'
    } finally {
        if ($sccache) {
            try { Invoke-Tool $sccache @('--show-stats') '' 'sccache' } catch { }
            try { Invoke-Tool $sccache @('--stop-server') '' 'sccache' } catch { }
        }
    }
    Write-Step 6 (Get-Text 'Creating your private build folder' 'Création de votre dossier de compilation privé')

    $builtExe = Require-File (Join-Path $buildDir 'bin\eglantine.exe') 'built eglantine.exe'
    # The extension's CMake copies the library, its manifest and steam_api64.dll here.
    $builtExtension = Require-Directory (Join-Path $buildDir ('bin\extensions\' + $ExtensionId)) 'built Remote Play Together extension'
    $extensionFiles = @('remote_play_together.dll', 'extension.json', 'steam_api64.dll')
    foreach ($file in $extensionFiles) {
        Require-File (Join-Path $builtExtension $file) "built extension file $file" | Out-Null
    }
    $builtSwitches = Join-Path $buildDir 'bin\nx2_switches.txt'

    $bundleName = '{0}-{1}-{2}-steam-remote-play' -f $repository.Repository, $shortCommit, $timestamp
    $bundleDir = Join-Path $workspace ('output\' + $bundleName)
    $bundleExtension = Join-Path $bundleDir ('extensions\' + $ExtensionId)
    New-Item -ItemType Directory -Path $bundleDir, $bundleExtension -Force | Out-Null
    Copy-VerifiedFile $builtExe (Join-Path $bundleDir 'eglantine.exe')
    foreach ($file in $extensionFiles) {
        Copy-VerifiedFile (Join-Path $builtExtension $file) (Join-Path $bundleExtension $file)
    }
    if (Test-Path -LiteralPath $builtSwitches -PathType Leaf) {
        Copy-VerifiedFile $builtSwitches (Join-Path $bundleDir 'nx2_switches.txt')
    }

    Invoke-Tool $windeployqt @('--release', '--no-translations', '--dir', $bundleDir,
                               (Join-Path $bundleDir 'eglantine.exe')) '' 'windeployqt'
    foreach ($runtime in @('d3dcompiler_47.dll', 'dxcompiler.dll', 'dxil.dll', 'opengl32sw.dll')) {
        $sourceRuntime = Join-Path $qtDir ('bin\' + $runtime)
        $destinationRuntime = Join-Path $bundleDir $runtime
        if ((Test-Path -LiteralPath $sourceRuntime -PathType Leaf) -and
            -not (Test-Path -LiteralPath $destinationRuntime -PathType Leaf)) {
            Copy-VerifiedFile $sourceRuntime $destinationRuntime
        }
    }

    Write-OutputReadme (Join-Path $bundleDir 'README.txt') $repository.DisplayName $gitRef $commit $appId
    $manifest = [ordered]@{
        schemaVersion = 1
        status = 'success'
        builderVersion = $BuilderVersion
        createdUtc = (Get-Date).ToUniversalTime().ToString('o')
        repository = [ordered]@{
            url = $repository.CloneUrl
            reference = $gitRef
            commit = $commit
            directPatch = $directPatch
        }
        patchSha256 = $patchHash
        configuration = [ordered]@{
            appId = $appId
            qtDir = $qtDir
            vulkanSdk = $vulkanSdk
            shaderCompiler = $glslang
            steamRuntime = $steamRuntimeDll
            visualStudio = $visualStudio.InstallPath
            cmakeVersion = $cmakeVersion.ToString()
        }
        artifacts = @(
            [ordered]@{ file = 'eglantine.exe'; sha256 = Get-FileHashString (Join-Path $bundleDir 'eglantine.exe') },
            @($extensionFiles | ForEach-Object {
                $relative = 'extensions\{0}\{1}' -f $ExtensionId, $_
                [ordered]@{ file = $relative; sha256 = Get-FileHashString (Join-Path $bundleDir $relative) }
            })
        )
        log = $script:LogPath
    }
    Write-JsonFile $manifest (Join-Path $bundleDir 'build-manifest.json')
    $zipPath = $bundleDir + '.zip'
    Compress-Archive -Path (Join-Path $bundleDir '*') -DestinationPath $zipPath -CompressionLevel Optimal -Force
    if (-not (Test-Path -LiteralPath $zipPath -PathType Leaf)) {
        throw 'Could not create the private build zip.'
    }

    Write-Log 'BUILD SUCCEEDED'
    Write-Log "Private build folder: $bundleDir"
    Write-Log "Private build zip:    $zipPath"
    Write-Host ''
    Write-Host (Get-Text `
        'Done! Start Steam, then open eglantine.exe in the folder above. The first time, enable "Steam Remote Play Together" in Extensions > Manage Extensions... and restart Eglantine. The folder opens now.' `
        'Terminé ! Démarrez Steam, puis ouvrez eglantine.exe dans le dossier ci-dessus. La première fois, activez « Steam Remote Play Together » dans Extensions > Manage Extensions... et redémarrez Eglantine. Le dossier s''ouvre maintenant.') -ForegroundColor Green
    if (-not $StatusPath) {
        # The wizard shows an "Open the build folder" button instead.
        try { Start-Process -FilePath 'explorer.exe' -ArgumentList @($bundleDir) } catch { }
    }
    $script:Status.State = 'done'
    $script:Status.Result = $bundleDir
    Write-Status -Force
    $exitCode = 0
} catch {
    $message = $_.Exception.Message
    if ($script:LogPath) {
        Write-Log $message 'ERROR'
    } else {
        Write-Host ('[ERROR] ' + $message) -ForegroundColor Red
    }
    $script:Status.State = 'failed'
    $script:Status.Result = $message
    Write-Status -Force
    if ($script:Workspace) {
        try {
            $failure = [ordered]@{
                schemaVersion = 1
                status = 'failed'
                builderVersion = $BuilderVersion
                createdUtc = (Get-Date).ToUniversalTime().ToString('o')
                runId = $script:RunId
                error = $message
                log = $script:LogPath
                runDirectory = $script:RunRoot
            }
            Write-JsonFile $failure (Join-Path $script:Workspace 'last-build-failure.json')
        } catch {
            Write-Host ('[ERROR] Could not write failure report: ' + $_.Exception.Message) -ForegroundColor Red
        }
    }
    Write-Host ''
    Write-Host (Get-Text 'BUILD FAILED. The red message above says what to fix.' `
        'ÉCHEC DE LA COMPILATION. Le message en rouge ci-dessus indique quoi corriger.') -ForegroundColor Red
    Write-Host (Get-Text 'After fixing it, run the builder again: downloads already done are kept.' `
        'Après correction, relancez l''outil : les téléchargements déjà faits sont conservés.')
    if ($script:LogPath) {
        Write-Host ('Log: ' + $script:LogPath)
    }
}

exit $exitCode
