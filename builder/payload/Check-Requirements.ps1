# Read-only checks for the builder wizard. Nothing is installed or changed.
#
#   -Mode System -Workspace <folder>
#       One line per requirement: key|status|detail
#
# No Steamworks SDK is needed: the builder downloads Steam's runtime library itself.
#
# Keep the tool versions and cache paths in step with Build-SteamRemotePlay.ps1.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('System')]
    [string]$Mode,
    [string]$Workspace = ''
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
    }
    exit 0
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
