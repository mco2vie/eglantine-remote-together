# Packages the shareable builder release. It does not package Steamworks SDK files or generated
# Eglantine builds.
[CmdletBinding()]
param(
    [string]$IsccPath = "${env:ProgramFiles(x86)}\Inno Setup 7\ISCC.exe"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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
