# Eglantine Steam Remote Play Builder
# Creates a private Windows build from a user-selected, trusted GitHub Eglantine repository.
# It never edits an existing emulator install or deletes user source files.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConfigPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$BuilderVersion = '1.1.0'
# Kept in step with payload/steam-remote-play-together.patch when a compatible feature update ships.
$ExpectedPatchSha256 = '58002335aa9a8a132eefb32134d93f910407d6111e3fc4ef13ec72f148000440'
# The app ID must be one you own or are explicitly authorized to use, and configured for
# Remote Play Together. This builder does not grant permission to use another game's App ID.
# The App ID can be changed later from Eglantine's Multiplayer menu.
$MinimumFreeSpace = 15GB
$script:LogPath = $null
$script:RunRoot = $null
$script:Workspace = $null
$script:RunId = $null

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
    try {
        & $FilePath @Arguments 2>&1 | ForEach-Object {
            $text = $_.ToString()
            Write-Host $text
            if ($script:LogPath) {
                Add-Content -LiteralPath $script:LogPath -Value $text -Encoding UTF8
            }
        }
        $exitCode = $LASTEXITCODE
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

function Get-VisualStudio {
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
        throw 'Visual Studio with Desktop development with C++ was not found. Install it, then run the builder again.'
    }

    $vswhereArgs = @(
        '-latest', '-products', '*', '-requires',
        'Microsoft.VisualStudio.Component.VC.Tools.x86.x64', '-property', 'installationPath'
    )
    $installResult = & $vswhere @vswhereArgs 2>$null | Select-Object -First 1
    $installPath = [string]$installResult
    $installPath = $installPath.Trim()
    if ([string]::IsNullOrWhiteSpace($installPath)) {
        throw 'Visual Studio is installed, but its x64 C++ tools are missing. Add Desktop development with C++.'
    }
    $vcvars = Join-Path $installPath 'VC\Auxiliary\Build\vcvars64.bat'
    Require-File $vcvars 'Visual Studio x64 environment script' | Out-Null
    return [PSCustomObject]@{
        InstallPath = $installPath
        VcVars = $vcvars
        CMakeBin = Join-Path $installPath 'Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin'
        NinjaBin = Join-Path $installPath 'Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja'
        GitBin = Join-Path $installPath 'Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\cmd'
    }
}

function Import-VcVars {
    param([Parameter(Mandatory = $true)][string]$VcVars)

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

    $line = (& $Cmake '--version' 2>&1 | Select-Object -First 1).ToString()
    if ($LASTEXITCODE -ne 0 -or $line -notmatch '(\d+\.\d+\.\d+)') {
        throw 'Could not read the CMake version.'
    }
    return [Version]$Matches[1]
}

function Get-ResolvedCommit {
    param(
        [Parameter(Mandatory = $true)][string]$Git,
        [Parameter(Mandatory = $true)][string]$Mirror,
        [Parameter(Mandatory = $true)][string]$Ref
    )

    $candidates = @(
        ('refs/tags/{0}^{{commit}}' -f $Ref),
        ('refs/heads/{0}^{{commit}}' -f $Ref),
        ('refs/remotes/origin/{0}^{{commit}}' -f $Ref),
        ('{0}^{{commit}}' -f $Ref)
    )
    foreach ($candidate in $candidates) {
        $value = (& $Git ("--git-dir=$Mirror") 'rev-parse' '--verify' '--quiet' $candidate 2>$null |
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

Start Steam, then start eglantine.exe directly. Use Multiplayer > Invite Friends to
Remote Play Together or Multiplayer > Copy Remote Play Guest Link.

The app starts as Steam App ID $AppId by default. Inside Eglantine, Multiplayer > Change
Steam App ID... lets you choose another App ID for the next start.

IMPORTANT: This folder contains Valve's steam_api64.dll from the Steamworks SDK. Keep this
build for yourself. Do not share or publish it.

If a controller does nothing, press Shift+Tab, open Controller Settings, and choose a
Gamepad template for each controller.

Build log: $script:LogPath
Build manifest: build-manifest.json
"@ | Set-Content -LiteralPath $Path -Encoding UTF8
}

$exitCode = 1
try {
    $ConfigPath = Require-File $ConfigPath 'builder configuration file'
    $config = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($property in @('RepositoryUrl', 'GitRef', 'SteamworksSdk', 'QtDir', 'VulkanSdk',
                             'Workspace', 'SteamAppId')) {
        if (-not $config.PSObject.Properties.Name.Contains($property)) {
            throw "Builder configuration is missing '$property'. Run the wizard again."
        }
    }

    $repository = Get-RepositoryIdentity ([string]$config.RepositoryUrl)
    $gitRef = ([string]$config.GitRef).Trim()
    if (-not (Test-SafeGitRef $gitRef)) {
        throw "'$gitRef' is not a supported branch or tag name."
    }

    $appId = 0
    if (-not [UInt32]::TryParse(([string]$config.SteamAppId), [ref]$appId) -or $appId -eq 0) {
        throw 'Steam App ID must be a positive whole number.'
    }

    $steamSdk = Require-Directory ([string]$config.SteamworksSdk) 'Steamworks SDK sdk folder'
    $qtDir = Require-Directory ([string]$config.QtDir) 'Qt MSVC folder'
    $vulkanSdk = Require-Directory ([string]$config.VulkanSdk) 'Vulkan SDK folder'

    Require-File (Join-Path $steamSdk 'public\steam\steam_api.h') 'Steamworks SDK header' | Out-Null
    $remotePlayHeader = Join-Path $steamSdk 'public\steam\isteamremoteplay.h'
    Require-File $remotePlayHeader 'Steamworks Remote Play header' | Out-Null
    Require-File (Join-Path $steamSdk 'redistributable_bin\win64\steam_api64.lib') 'Steamworks x64 import library' | Out-Null
    Require-File (Join-Path $steamSdk 'redistributable_bin\win64\steam_api64.dll') 'Steamworks x64 runtime library' | Out-Null
    $hasRemotePlayInput = Select-String -LiteralPath $remotePlayHeader -SimpleMatch 'BEnableRemotePlayTogetherDirectInput' -Quiet
    if (-not $hasRemotePlayInput) {
        throw 'The Steamworks SDK is too old. Install SDK 1.62 or newer.'
    }
    Require-File (Join-Path $qtDir 'lib\cmake\Qt6\Qt6Config.cmake') 'Qt 6 CMake files' | Out-Null
    Require-File (Join-Path $qtDir 'lib\cmake\Qt6Charts\Qt6ChartsConfig.cmake') 'Qt Charts CMake files' | Out-Null
    $windeployqt = Require-File (Join-Path $qtDir 'bin\windeployqt.exe') 'Qt deployment tool'
    $glslang = Require-File (Join-Path $vulkanSdk 'Bin\glslangValidator.exe') 'Vulkan SDK shader tool'

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
    $script:RunRoot = Join-Path $workspace ('runs\' + $script:RunId)
    $logsDir = Join-Path $workspace 'logs'
    New-Item -ItemType Directory -Path $script:RunRoot, $logsDir -Force | Out-Null
    $script:LogPath = Join-Path $logsDir ($script:RunId + '.log')
    New-Item -ItemType File -Path $script:LogPath -Force | Out-Null

    Write-Log "Eglantine Steam Remote Play Builder $BuilderVersion"
    Write-Log "Repository: $($repository.CloneUrl)"
    Write-Log "Reference: $gitRef"
    Write-Log "Workspace: $workspace"
    Write-Log 'Only build source you trust. CMake and the chosen repository can run build commands on this PC.' 'WARN'

    $patch = Require-File (Join-Path $PSScriptRoot 'steam-remote-play-together.patch') 'Steam Remote Play source patch'
    $patchHash = Get-FileHashString $patch
    if ($patchHash -ne $ExpectedPatchSha256) {
        throw "The bundled patch failed its integrity check. Expected $ExpectedPatchSha256, got $patchHash. Re-download the builder."
    }
    Write-Log "Patch SHA-256: $patchHash"

    $visualStudio = Get-VisualStudio
    Write-Log "Visual Studio: $($visualStudio.InstallPath)"
    $toolPaths = @($visualStudio.CMakeBin, $visualStudio.NinjaBin, $visualStudio.GitBin, (Join-Path $qtDir 'bin')) |
        Where-Object { Test-Path -LiteralPath $_ -PathType Container }
    $pathSeparator = [System.IO.Path]::PathSeparator
    $env:Path = (($toolPaths -join $pathSeparator) + $pathSeparator + $env:Path)
    Import-VcVars $visualStudio.VcVars
    $env:Path = (($toolPaths -join $pathSeparator) + $pathSeparator + $env:Path)

    $git = Resolve-Tool 'git.exe' @(
        (Join-Path $visualStudio.GitBin 'git.exe')
    )
    $cmake = Resolve-Tool 'cmake.exe' @(
        (Join-Path $visualStudio.CMakeBin 'cmake.exe')
    )
    $ninja = Resolve-Tool 'ninja.exe' @(
        (Join-Path $visualStudio.NinjaBin 'ninja.exe')
    )
    $cmakeVersion = Get-CmakeVersion $cmake
    if ($cmakeVersion -lt [Version]'3.31.0') {
        throw "CMake $cmakeVersion is too old. Eglantine needs CMake 3.31 or newer."
    }
    Write-Log "Git: $((& $git '--version' | Select-Object -First 1).ToString())"
    Write-Log "CMake: $cmakeVersion"
    Write-Log "Ninja: $((& $ninja '--version' | Select-Object -First 1).ToString())"

    $cacheRoot = Join-Path $workspace 'cache'
    $mirror = Join-Path $cacheRoot ('repositories\' + $repoKey + '.git')
    $cpmCache = Join-Path $cacheRoot 'cpm'
    New-Item -ItemType Directory -Path (Split-Path $mirror -Parent), $cpmCache -Force | Out-Null
    if (Test-Path -LiteralPath $mirror -PathType Container) {
        $bare = (& $git ("--git-dir=$mirror") 'rev-parse' '--is-bare-repository' 2>$null | Select-Object -First 1)
        if ($LASTEXITCODE -ne 0 -or $bare -ne 'true') {
            throw "Builder cache path exists but is not its expected Git mirror: $mirror"
        }
        Invoke-Tool $git @("--git-dir=$mirror", 'fetch', '--prune', '--tags', 'origin') '' 'git fetch'
    } else {
        Invoke-Tool $git @('clone', '--mirror', $repository.CloneUrl, $mirror) '' 'git clone'
    }

    $commit = Get-ResolvedCommit $git $mirror $gitRef
    $shortCommit = $commit.Substring(0, 12)
    Write-Log "Resolved $gitRef to $commit"

    $sourceDir = Join-Path $script:RunRoot 'source'
    $buildDir = Join-Path $script:RunRoot 'build'
    Invoke-Tool $git @('clone', '--shared', '--no-checkout', $mirror, $sourceDir) '' 'git clone worktree'
    Invoke-Tool $git @('-C', $sourceDir, 'checkout', '--detach', $commit) '' 'git checkout'

    $directPatch = $true
    try {
        Invoke-Tool $git @('-C', $sourceDir, 'apply', '--check', '--whitespace=nowarn', $patch) '' 'git apply check'
    } catch {
        $directPatch = $false
        Write-Log 'The patch needs Git three-way merge help for this version.' 'WARN'
    }
    try {
        Invoke-Tool $git @('-C', $sourceDir, 'apply', '--3way', '--whitespace=nowarn', $patch) '' 'git apply'
    } catch {
        $conflicts = (& $git -C $sourceDir 'diff' '--name-only' '--diff-filter=U' 2>$null) -join ', '
        if ($conflicts) {
            throw "The patch conflicts with this source version in: $conflicts. This fork/version needs an updated patch."
        }
        throw 'The patch did not apply to this source version. This fork/version needs an updated patch.'
    }
    foreach ($requiredPath in @(
        'CMakeModules\find\FindSteamworks.cmake',
        'src\input_common\drivers\remote_play_keyboard.cpp',
        'src\yuzu\steam_remote_play.cpp',
        'src\yuzu\steam_remote_play.h')) {
        Require-File (Join-Path $sourceDir $requiredPath) "patched source file $requiredPath" | Out-Null
    }
    Write-Log ('Patch applied ({0}).' -f $(if ($directPatch) { 'directly' } else { 'with Git three-way merge' }))

    $cmakeCachePath = $cpmCache.Replace('\', '/')
    $qtCmakePath = $qtDir.Replace('\', '/')
    $steamCmakePath = $steamSdk.Replace('\', '/')
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
        '-DENABLE_STEAM_REMOTE_PLAY=ON',
        "-DSTEAMWORKS_SDK_DIR=$steamCmakePath",
        "-DSTEAM_REMOTE_PLAY_APPID=$appId",
        "-DGLSLANGVALIDATOR=$glslangCmakePath"
    )
    Invoke-Tool $cmake $cmakeArgs '' 'cmake configure'
    Invoke-Tool $cmake @('--build', $buildDir, '--target', 'yuzu', '--parallel') '' 'cmake build'

    $builtExe = Require-File (Join-Path $buildDir 'bin\eglantine.exe') 'built eglantine.exe'
    $builtSteam = Require-File (Join-Path $buildDir 'bin\steam_api64.dll') 'built steam_api64.dll'
    $builtSwitches = Join-Path $buildDir 'bin\nx2_switches.txt'

    $bundleName = '{0}-{1}-{2}-steam-remote-play' -f $repository.Repository, $shortCommit, $timestamp
    $bundleDir = Join-Path $workspace ('output\' + $bundleName)
    New-Item -ItemType Directory -Path $bundleDir -Force | Out-Null
    Copy-VerifiedFile $builtExe (Join-Path $bundleDir 'eglantine.exe')
    Copy-VerifiedFile $builtSteam (Join-Path $bundleDir 'steam_api64.dll')
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
            visualStudio = $visualStudio.InstallPath
            cmakeVersion = $cmakeVersion.ToString()
        }
        artifacts = @(
            [ordered]@{ file = 'eglantine.exe'; sha256 = Get-FileHashString (Join-Path $bundleDir 'eglantine.exe') },
            [ordered]@{ file = 'steam_api64.dll'; sha256 = Get-FileHashString (Join-Path $bundleDir 'steam_api64.dll') }
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
    Write-Log 'Do not share or publish this build: it contains Valve''s steam_api64.dll.' 'WARN'
    $exitCode = 0
} catch {
    $message = $_.Exception.Message
    if ($script:LogPath) {
        Write-Log $message 'ERROR'
    } else {
        Write-Host ('[ERROR] ' + $message) -ForegroundColor Red
    }
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
    Write-Host 'BUILD FAILED. Read the last messages above.' -ForegroundColor Red
    if ($script:LogPath) {
        Write-Host ('Log: ' + $script:LogPath)
    }
}

exit $exitCode
