# Lists the branches and tags of a public GitHub repository for the builder wizard.
# It reads the Git smart-HTTP ref advertisement, so it needs neither Git nor the GitHub API.
# Output, one per line: "default <branch>", then "branch <name>" lines, then "tag <name>" lines.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RepositoryUrl
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-SafeGitRef {
    param([Parameter(Mandatory = $true)][string]$Ref)

    if ($Ref.Length -eq 0 -or $Ref.Length -gt 128) { return $false }
    if ($Ref -notmatch '^[A-Za-z0-9][A-Za-z0-9._/@-]*$') { return $false }
    if ($Ref.Contains('..') -or $Ref.Contains('//') -or $Ref.Contains('@{')) { return $false }
    if ($Ref.EndsWith('/') -or $Ref.EndsWith('.') -or $Ref.EndsWith('.lock')) { return $false }
    return $true
}

function Get-VersionSortKey {
    param([Parameter(Mandatory = $true)][string]$Name)
    # Pads every number so v0.10.0 sorts after v0.9.0.
    return [regex]::Replace($Name, '\d+', { param($m) $m.Value.PadLeft(10, '0') })
}

try {
    $uri = [System.Uri]$RepositoryUrl.Trim()
    $parts = $uri.AbsolutePath.Trim('/').Split('/')
    if ($uri.Scheme -ne 'https' -or $uri.Host -ne 'github.com' -or $uri.Port -ne 443 -or
        -not [string]::IsNullOrEmpty($uri.UserInfo) -or -not [string]::IsNullOrEmpty($uri.Query) -or
        -not [string]::IsNullOrEmpty($uri.Fragment) -or $parts.Count -ne 2 -or
        $parts[0] -notmatch '^[A-Za-z0-9_.-]+$' -or $parts[1] -notmatch '^[A-Za-z0-9_.-]+(?:\.git)?$') {
        throw 'Not a GitHub repository URL.'
    }
    $cloneUrl = 'https://github.com/{0}/{1}.git' -f $parts[0], ($parts[1] -replace '\.git$', '')

    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    $request = [System.Net.HttpWebRequest]::Create($cloneUrl + '/info/refs?service=git-upload-pack')
    $request.UserAgent = 'git/2.0 (Eglantine Steam Remote Play Builder)'
    $request.Timeout = 20000
    $request.ReadWriteTimeout = 20000
    $response = $request.GetResponse()
    try {
        $stream = $response.GetResponseStream()
        $buffer = New-Object System.IO.MemoryStream
        $stream.CopyTo($buffer)
        $bytes = $buffer.ToArray()
    } finally {
        $response.Close()
    }

    # Parse pkt-lines: 4 hex digits of length (including themselves), then the payload.
    $branches = New-Object System.Collections.Generic.List[string]
    $tags = New-Object System.Collections.Generic.List[string]
    $defaultBranch = ''
    $ascii = [System.Text.Encoding]::ASCII
    $offset = 0
    while ($offset + 4 -le $bytes.Length) {
        $length = [Convert]::ToInt32($ascii.GetString($bytes, $offset, 4), 16)
        if ($length -eq 0) { $offset += 4; continue }
        if ($length -lt 4 -or $offset + $length -gt $bytes.Length) { break }
        $line = $ascii.GetString($bytes, $offset + 4, $length - 4).TrimEnd("`n")
        $offset += $length

        $capabilities = ''
        $nul = $line.IndexOf([char]0)
        if ($nul -ge 0) {
            $capabilities = $line.Substring($nul + 1)
            $line = $line.Substring(0, $nul)
        }
        if ($capabilities -match '(?:^| )symref=HEAD:refs/heads/(\S+)') {
            $defaultBranch = $Matches[1]
        }
        if ($line -notmatch '^[0-9a-f]{40} (refs/(heads|tags)/(.+))$') { continue }
        $name = $Matches[3]
        if ($name.EndsWith('^{}') -or -not (Test-SafeGitRef $name)) { continue }
        if ($Matches[2] -eq 'heads') { $branches.Add($name) } else { $tags.Add($name) }
    }

    if ($branches.Count -eq 0 -and $tags.Count -eq 0) {
        throw 'The repository has no branches or tags.'
    }
    if ($defaultBranch -and (Test-SafeGitRef $defaultBranch)) {
        Write-Output "default $defaultBranch"
    }
    $branches | Sort-Object | ForEach-Object { Write-Output "branch $_" }
    $tags | Sort-Object -Property @{ Expression = { Get-VersionSortKey $_ } } -Descending |
        ForEach-Object { Write-Output "tag $_" }
    exit 0
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
