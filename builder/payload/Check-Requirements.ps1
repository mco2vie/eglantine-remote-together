# Read-only checks for the builder wizard. Nothing is installed or changed.
#
#   -Mode System -Workspace <folder>
#       One line per requirement: key|status|detail
#   -Mode Steamworks -Path <zip file or sdk folder>
#       ok|<version>|<path>   or   error|<code>|<detail>
#   -Mode FindSteamworks
#       found|<path>|<version>   or   none||
#
# Keep the tool versions and cache paths in step with Build-SteamRemotePlay.ps1.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('System', 'Steamworks', 'FindSteamworks')]
    [string]$Mode,
    [string]$Workspace = '',
    [string]$Path = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$QtVersion = '6.8.3'
$GlslangVersion = '16.6.0'
$MinGitVersion = '2.56.0.2'
$MinimumFreeSpaceGB = 15
$VisualStudioSpaceGB = 8
$MinimumCmake = [Version]'3.31.0'

function Write-Result {
    param([string]$Key, [string]$Status, [string]$Detail = '')
    Write-Output ('{0}|{1}|{2}' -f $Key, $Status, ($Detail -replace '[\r\n|]', ' '))
}

function Get-ToolCache {
    param([string]$Root)
    return Join-Path $Root 'cache\tools'
}

function Find-VisualStudio {
    $vswhere = @(
        (Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'),
        (Join-Path $env:ProgramFiles 'Microsoft Visual Studio\Installer\vswhere.exe')
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } | Select-Object -First 1
    if (-not $vswhere) {
        return [PSCustomObject]@{ Status = 'missing'; Detail = '' }
    }
    $json = @(& $vswhere -latest -products '*' -requires 'Microsoft.VisualStudio.Component.VC.Tools.x86.x64' -format json 2>$null) -join "`n"
    $instances = @()
    if ($json.Trim()) { $instances = @($json | ConvertFrom-Json) }
    if ($instances.Count -eq 0) {
        return [PSCustomObject]@{ Status = 'missing'; Detail = 'nocpp' }
    }
    $instance = $instances[0]
    $name = '{0} {1}' -f $instance.displayName, $instance.catalog.productDisplayVersion
    $cmake = Join-Path $instance.installationPath 'Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'
    if (-not (Test-Path -LiteralPath $cmake -PathType Leaf)) {
        return [PSCustomObject]@{ Status = 'old'; Detail = $name }
    }
    $line = [string](@(& $cmake '--version' 2>$null) | Select-Object -First 1)
    if ($line -match '(\d+\.\d+\.\d+)' -and [Version]$Matches[1] -ge $MinimumCmake) {
        return [PSCustomObject]@{ Status = 'ok'; Detail = $name }
    }
    return [PSCustomObject]@{ Status = 'old'; Detail = $name }
}

function Get-FreeSpaceGB {
    param([string]$Folder)
    $full = [System.IO.Path]::GetFullPath($Folder)
    $root = [System.IO.Path]::GetPathRoot($full)
    return [int][Math]::Floor([System.IO.DriveInfo]::new($root).AvailableFreeSpace / 1GB)
}

function Get-SdkVersionFromText {
    param([string]$Text)
    $match = [regex]::Match($Text, '(?m)^\s*v(\d+)\.(\d+)\b')
    if ($match.Success) { return '{0}.{1}' -f $match.Groups[1].Value, $match.Groups[2].Value }
    return ''
}

# Checks a Steamworks SDK zip or folder. Returns Status ok/error, Code, Version, Path.
function Test-SteamworksSdk {
    param([string]$Candidate)

    $result = [PSCustomObject]@{ Status = 'error'; Code = 'notfound'; Version = ''; Path = $Candidate }
    if ([string]::IsNullOrWhiteSpace($Candidate)) { return $result }

    if (Test-Path -LiteralPath $Candidate -PathType Container) {
        $sdk = $Candidate
        # Accept the unzipped folder that contains "sdk" as well as "sdk" itself.
        if (-not (Test-Path -LiteralPath (Join-Path $sdk 'public\steam') -PathType Container) -and
            (Test-Path -LiteralPath (Join-Path $sdk 'sdk\public\steam') -PathType Container)) {
            $sdk = Join-Path $sdk 'sdk'
        }
        $result.Path = $sdk
        foreach ($file in @('public\steam\steam_api.h', 'public\steam\isteamremoteplay.h',
                            'redistributable_bin\win64\steam_api64.lib', 'redistributable_bin\win64\steam_api64.dll')) {
            if (-not (Test-Path -LiteralPath (Join-Path $sdk $file) -PathType Leaf)) {
                $result.Code = 'notsdk'
                return $result
            }
        }
        $header = Get-Content -LiteralPath (Join-Path $sdk 'public\steam\isteamremoteplay.h') -Raw
        $readme = Join-Path $sdk 'Readme.txt'
        if (Test-Path -LiteralPath $readme -PathType Leaf) {
            $result.Version = Get-SdkVersionFromText (Get-Content -LiteralPath $readme -Raw)
        }
    } elseif ((Test-Path -LiteralPath $Candidate -PathType Leaf) -and $Candidate -match '\.zip$') {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        try {
            $zip = [System.IO.Compression.ZipFile]::OpenRead($Candidate)
        } catch {
            $result.Code = 'badzip'
            return $result
        }
        try {
            $entries = @{}
            foreach ($entry in $zip.Entries) { $entries[$entry.FullName.Replace('\', '/')] = $entry }
            $headerName = $entries.Keys | Where-Object { $_ -match '(^|/)public/steam/isteamremoteplay\.h$' } |
                Sort-Object Length | Select-Object -First 1
            if (-not $headerName) {
                $result.Code = 'notsdk'
                return $result
            }
            $prefix = $headerName.Substring(0, $headerName.Length - 'public/steam/isteamremoteplay.h'.Length)
            foreach ($file in @('public/steam/steam_api.h', 'redistributable_bin/win64/steam_api64.lib',
                                'redistributable_bin/win64/steam_api64.dll')) {
                if (-not $entries.ContainsKey($prefix + $file)) {
                    $result.Code = 'notsdk'
                    return $result
                }
            }
            $reader = New-Object System.IO.StreamReader($entries[$headerName].Open())
            try { $header = $reader.ReadToEnd() } finally { $reader.Dispose() }
            if ($entries.ContainsKey($prefix + 'Readme.txt')) {
                $reader = New-Object System.IO.StreamReader($entries[$prefix + 'Readme.txt'].Open())
                try { $result.Version = Get-SdkVersionFromText $reader.ReadToEnd() } finally { $reader.Dispose() }
            }
        } finally {
            $zip.Dispose()
        }
    } else {
        return $result
    }

    if (-not $result.Version -and [System.IO.Path]::GetFileName($Candidate) -match 'steamworks_sdk_(\d)(\d+)') {
        $result.Version = '{0}.{1}' -f $Matches[1], $Matches[2]
    }
    # The Remote Play Together input API is what the patch needs; it arrived in SDK 1.62.
    if ($header -notmatch 'BEnableRemotePlayTogetherDirectInput') {
        $result.Code = 'tooold'
        return $result
    }
    $result.Status = 'ok'
    $result.Code = ''
    return $result
}

try {
    switch ($Mode) {
        'System' {
            $build = [int](Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentBuildNumber
            $windowsName = if ($build -ge 22000) { 'Windows 11' } else { 'Windows 10' }
            if ([Environment]::Is64BitOperatingSystem -and $build -ge 10240) {
                Write-Result 'windows' 'ok' "$windowsName 64-bit"
            } else {
                Write-Result 'windows' 'unsupported' $windowsName
            }

            $vs = Find-VisualStudio
            Write-Result 'vs' $vs.Status $vs.Detail

            $toolCache = ''
            if ($Workspace) { $toolCache = Get-ToolCache $Workspace }

            $git = Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($git) {
                Write-Result 'git' 'ok' $git.Path
            } elseif ($toolCache -and (Test-Path -LiteralPath (Join-Path $toolCache "mingit-$MinGitVersion\cmd\git.exe"))) {
                Write-Result 'git' 'ok' 'cache'
            } else {
                Write-Result 'git' 'download' $MinGitVersion
            }

            if ($toolCache -and (Test-Path -LiteralPath (Join-Path $toolCache "qt\$QtVersion\msvc2022_64\lib\cmake\Qt6Charts\Qt6ChartsConfig.cmake"))) {
                Write-Result 'qt' 'ok' $QtVersion
            } else {
                Write-Result 'qt' 'download' $QtVersion
            }

            if ($toolCache -and (Test-Path -LiteralPath (Join-Path $toolCache "glslang-$GlslangVersion\bin\glslang.exe"))) {
                Write-Result 'glslang' 'ok' $GlslangVersion
            } else {
                Write-Result 'glslang' 'download' $GlslangVersion
            }

            if ($Workspace) {
                $free = Get-FreeSpaceGB $Workspace
                $needed = $MinimumFreeSpaceGB
                $workspaceDrive = [System.IO.Path]::GetPathRoot([System.IO.Path]::GetFullPath($Workspace))
                $systemDrive = [System.IO.Path]::GetPathRoot($env:SystemRoot)
                if ($vs.Status -ne 'ok' -and $workspaceDrive -eq $systemDrive) { $needed += $VisualStudioSpaceGB }
                $status = if ($free -ge $needed) { 'ok' } else { 'low' }
                Write-Result 'space' $status ('{0}/{1}' -f $free, $needed)
            }
        }
        'Steamworks' {
            $check = Test-SteamworksSdk $Path
            if ($check.Status -eq 'ok') {
                Write-Output ('ok|{0}|{1}' -f $check.Version, $check.Path)
            } else {
                Write-Output ('error|{0}|{1}' -f $check.Code, $check.Version)
            }
        }
        'FindSteamworks' {
            $folders = @(
                (Join-Path $env:USERPROFILE 'Downloads'),
                [Environment]::GetFolderPath('Desktop'),
                [Environment]::GetFolderPath('MyDocuments'),
                'C:\Steamworks'
            ) | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Container) } | Select-Object -Unique
            $candidates = @()
            foreach ($folder in $folders) {
                $candidates += @(Get-ChildItem -LiteralPath $folder -Filter 'steamworks_sdk*.zip' -File -ErrorAction SilentlyContinue |
                    ForEach-Object { $_.FullName })
                $candidates += @(Get-ChildItem -LiteralPath $folder -Directory -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -like 'steamworks*' -or $_.Name -eq 'sdk' } | ForEach-Object { $_.FullName })
                if (Test-Path -LiteralPath (Join-Path $folder 'sdk\public\steam') -PathType Container) {
                    $candidates += (Join-Path $folder 'sdk')
                }
            }
            $best = $null
            foreach ($candidate in ($candidates | Select-Object -Unique)) {
                $check = Test-SteamworksSdk $candidate
                if ($check.Status -ne 'ok') { continue }
                $version = [Version]'0.0'
                if ($check.Version) { $version = [Version]$check.Version }
                if (-not $best -or $version -gt $best.SortVersion) {
                    $best = [PSCustomObject]@{ Path = $candidate; Version = $check.Version; SortVersion = $version }
                }
            }
            if ($best) {
                Write-Output ('found|{0}|{1}' -f $best.Path, $best.Version)
            } else {
                Write-Output 'none||'
            }
        }
    }
    exit 0
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
