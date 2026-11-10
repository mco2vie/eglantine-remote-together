# Packages the shareable builder release. It does not package Steamworks SDK files or generated
# Eglantine builds.
[CmdletBinding()]
param(
    [string]$IsccPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $IsccPath) {
    # winget installs Inno Setup per user; the classic installer uses Program Files.
    $IsccPath = @(
        "${env:ProgramFiles(x86)}\Inno Setup 7\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 7\ISCC.exe",
        "$env:LOCALAPPDATA\Programs\Inno Setup 7\ISCC.exe"
    ) | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    if (-not $IsccPath) { $IsccPath = "${env:ProgramFiles(x86)}\Inno Setup 7\ISCC.exe" }
}

$builderRoot = $PSScriptRoot
$installerSource = Join-Path $builderRoot 'eglantine-steam-builder.iss'
$releaseReadme = Join-Path $builderRoot 'release\Eglantine-Steam-Remote-Play-Builder-README.txt'
$outputDir = Join-Path $builderRoot 'release\output'
$installer = Join-Path $builderRoot 'output\Eglantine-Steam-Remote-Play-Builder.exe'
$archive = Join-Path $outputDir 'Eglantine-Steam-Remote-Play-Builder.zip'

if (-not (Test-Path -LiteralPath $IsccPath -PathType Leaf)) {
    throw "Inno Setup compiler not found: $IsccPath"
}
if (-not (Test-Path -LiteralPath $installerSource -PathType Leaf)) {
    throw "Missing installer source: $installerSource"
}
if (-not (Test-Path -LiteralPath $releaseReadme -PathType Leaf)) {
    throw "Missing release README: $releaseReadme"
}

# The builder refuses a patch whose SHA-256 differs from the one in Build-SteamRemotePlay.ps1, so
# never package one that would fail (for example after Git converted its line endings).
$patchPath = Join-Path $builderRoot 'payload\steam-remote-play-together.patch'
$buildScript = Get-Content -LiteralPath (Join-Path $builderRoot 'payload\Build-SteamRemotePlay.ps1') -Raw
if ($buildScript -notmatch "\`$ExpectedPatchSha256 = '([0-9a-f]{64})'") {
    throw 'Could not read the expected patch SHA-256 from Build-SteamRemotePlay.ps1.'
}
$expectedPatch = $Matches[1]
$actualPatch = (Get-FileHash -LiteralPath $patchPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualPatch -ne $expectedPatch) {
    throw "The patch SHA-256 is $actualPatch but the builder expects $expectedPatch. If only line endings changed, delete the patch and run: git checkout -- builder/payload/steam-remote-play-together.patch"
}

& $IsccPath '/Qp' $installerSource
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $installer -PathType Leaf)) {
    throw 'Inno Setup did not produce the builder installer.'
}

New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
$stage = Join-Path ([System.IO.Path]::GetTempPath()) ('eglantine-builder-release-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stage | Out-Null
try {
    Copy-Item -LiteralPath $installer -Destination (Join-Path $stage 'Eglantine-Steam-Remote-Play-Builder.exe')
    Copy-Item -LiteralPath $releaseReadme -Destination (Join-Path $stage 'Eglantine-Steam-Remote-Play-Builder-README.txt')
    Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $archive -CompressionLevel Optimal -Force
} finally {
    Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
}
$hashes = @()
$hashes += (Get-FileHash -LiteralPath $installer -Algorithm SHA256).Hash.ToLowerInvariant() +
    '  Eglantine-Steam-Remote-Play-Builder.exe'
$hashes += (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant() +
    '  Eglantine-Steam-Remote-Play-Builder.zip'
$hashes += (Get-FileHash -LiteralPath (Join-Path $builderRoot 'payload\steam-remote-play-together.patch') -Algorithm SHA256).Hash.ToLowerInvariant() +
    '  steam-remote-play-together.patch'
Set-Content -LiteralPath (Join-Path $outputDir 'SHA256SUMS.txt') -Value $hashes -Encoding UTF8

Write-Host "Builder installer: $installer"
Write-Host "Release archive:   $archive"
Write-Host "Checksums:         $(Join-Path $outputDir 'SHA256SUMS.txt')"
