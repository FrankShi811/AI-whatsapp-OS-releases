[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Version,
  [Parameter(Mandatory = $true)]
  [string]$CandidateDirectory,
  [Parameter(Mandatory = $true)]
  [string]$ExpectedRepository,
  [string]$ExpectedBuildRunId = ''
)

$ErrorActionPreference = 'Stop'
if ($Version -notmatch '^\d+\.\d+\.\d+$') { throw "Invalid candidate version: $Version" }
if ($ExpectedRepository -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') { throw 'Invalid repository identity.' }
$candidate = [IO.Path]::GetFullPath($CandidateDirectory)
if (-not (Test-Path -LiteralPath $candidate -PathType Container)) { throw "Candidate directory is missing: $candidate" }

$requiredNames = @(
  'AI.Sales.OS.Setup.exe',
  "AISalesOS-$Version-full.nupkg",
  'AISalesOS-win-Setup.exe',
  'AISalesOS-win-Portable.zip',
  'releases.win.json',
  'RELEASES',
  "AI-Sales-OS-WhatsApp-Bridge-$Version-source.zip",
  'LICENSE',
  'EULA.md',
  'PRIVACY.md',
  'THIRD_PARTY_NOTICES.md',
  'BRIDGE_GPL_COMPLIANCE.md',
  'license-revocations.json',
  'relvyn-release-manifest.json',
  'SHA256SUMS.txt'
)
$optionalNames = @("AISalesOS-$Version-delta.nupkg")
$actualNames = @(Get-ChildItem -LiteralPath $candidate -File | ForEach-Object Name | Sort-Object)
$missing = @($requiredNames | Where-Object { $_ -notin $actualNames })
$unexpected = @($actualNames | Where-Object { $_ -notin $requiredNames -and $_ -notin $optionalNames })
if ($missing.Count -gt 0) { throw "Required assets are missing: $($missing -join ', ')" }
if ($unexpected.Count -gt 0) { throw "Unexpected public assets: $($unexpected -join ', ')" }
if ($actualNames.Count -ne ($requiredNames.Count + @($optionalNames | Where-Object { $_ -in $actualNames }).Count)) {
  throw 'Candidate asset names are not unique.'
}

$checksumsPath = Join-Path $candidate 'SHA256SUMS.txt'
$checksumEntries = [ordered]@{}
foreach ($line in Get-Content -LiteralPath $checksumsPath -Encoding utf8) {
  if ($line -notmatch '^(?<Hash>[0-9a-f]{64}) [ *](?<Name>[^\\/]+)$') { throw "Invalid SHA256SUMS entry: $line" }
  if ($checksumEntries.Contains($Matches.Name)) { throw "Duplicate checksum entry: $($Matches.Name)" }
  $checksumEntries[$Matches.Name] = $Matches.Hash
}
$expectedChecksumNames = @($actualNames | Where-Object { $_ -ne 'SHA256SUMS.txt' } | Sort-Object)
if ((@($checksumEntries.Keys | Sort-Object) -join "`n") -ne ($expectedChecksumNames -join "`n")) {
  throw 'SHA256SUMS must cover every release asset except itself, with no extra subjects.'
}
foreach ($entry in $checksumEntries.GetEnumerator()) {
  $path = Join-Path $candidate $entry.Key
  $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($actual -ne $entry.Value) { throw "SHA-256 mismatch: $($entry.Key)" }
}

$manifestPath = Join-Path $candidate 'relvyn-release-manifest.json'
$manifest = Get-Content -Raw -Encoding utf8 -LiteralPath $manifestPath | ConvertFrom-Json
if ($manifest.schemaVersion -ne 1 -or $manifest.product -ne 'Relvyn' -or $manifest.version -ne $Version -or $manifest.channel -ne 'stable') {
  throw 'Release manifest product, schema, version or channel is invalid.'
}
if ($manifest.sourceCommit -notmatch '^[0-9a-f]{40}$' -or $manifest.buildRunId -notmatch '^\d+$') {
  throw 'Release manifest source/build identity is invalid.'
}
if ($ExpectedBuildRunId -and $manifest.buildRunId -ne $ExpectedBuildRunId) { throw 'Dispatch build run ID does not match the manifest.' }
if ($manifest.codeSigning -ne 'DISABLED_NO_CERTIFICATE') { throw 'Unsigned free-release mode must be stated accurately.' }
if ($manifest.provenance.provider -ne 'public-github-artifact-attestation' -or
    $manifest.provenance.attestationRepository -ne $ExpectedRepository -or
    $manifest.provenance.privateBuildProvenance -ne $false) {
  throw 'Manifest overstates or misidentifies the public attestation provenance.'
}
$manifestArtifacts = @($manifest.artifacts)
$expectedManifestNames = @($actualNames | Where-Object { $_ -notin @('relvyn-release-manifest.json', 'SHA256SUMS.txt') } | Sort-Object)
if ((@($manifestArtifacts.name | Sort-Object) -join "`n") -ne ($expectedManifestNames -join "`n")) {
  throw 'Manifest artifact allowlist does not match the candidate files.'
}
foreach ($artifact in $manifestArtifacts) {
  if ($artifact.name -notmatch '^[^\\/]+$' -or $artifact.sha256 -notmatch '^[0-9a-f]{64}$' -or
      [int64]$artifact.size -lt 1 -or $artifact.attest -isnot [bool]) {
    throw "Invalid artifact metadata: $($artifact.name)"
  }
  $file = Get-Item -LiteralPath (Join-Path $candidate $artifact.name)
  if ([int64]$artifact.size -ne $file.Length -or $artifact.sha256 -ne $checksumEntries[$artifact.name]) {
    throw "Manifest digest or size mismatch: $($artifact.name)"
  }
  $shouldAttest = $artifact.type -in @('installer', 'update-package', 'update-manifest')
  if ($artifact.attest -ne $shouldAttest) { throw "Artifact attestation classification mismatch: $($artifact.name)" }
}

$feed = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $candidate 'releases.win.json') | ConvertFrom-Json
$current = @($feed.Assets | Where-Object { $_.Version -eq $Version })
if (@($current | Where-Object { $_.Type -eq 'Full' -and $_.FileName -eq "AISalesOS-$Version-full.nupkg" }).Count -ne 1) {
  throw 'Velopack feed does not identify the exact current Full package.'
}
if (@($current | Where-Object { $_.Type -notin @('Full', 'Delta') }).Count -ne 0 -or
    @($feed.Assets | Where-Object { $_.FileName -match 'SHA256SUMS|manifest|attestation|spdx|cyclonedx' }).Count -ne 0) {
  throw 'Velopack feed can select a security metadata asset or unexpected package type.'
}
foreach ($asset in $current) {
  $package = Join-Path $candidate $asset.FileName
  if (-not (Test-Path -LiteralPath $package -PathType Leaf)) { throw "Feed package is missing: $($asset.FileName)" }
  $actual = (Get-FileHash -LiteralPath $package -Algorithm SHA256).Hash.ToUpperInvariant()
  if ($asset.SHA256 -ne $actual) { throw "Feed SHA-256 mismatch: $($asset.FileName)" }
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$secretPatterns = @(
  '-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
  '(?<![A-Za-z0-9_])github_pat_[A-Za-z0-9_]{20,}(?![A-Za-z0-9_])',
  '(?<![A-Za-z0-9_])gh[pousr]_[A-Za-z0-9]{30,}(?![A-Za-z0-9_])',
  '(?<![A-Z0-9])AKIA[0-9A-Z]{16}(?![A-Z0-9])'
)
function Assert-NoSecretInStream([IO.Stream]$Stream, [string]$DisplayName) {
  $buffer = [byte[]]::new(1048576)
  $carry = ''
  while (($read = $Stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
    $chunk = $carry + [Text.Encoding]::GetEncoding(28591).GetString($buffer, 0, $read)
    foreach ($pattern in $secretPatterns) {
      if ($chunk -match $pattern) { throw "Potential secret material found in public artifact: $DisplayName" }
    }
    $carry = if ($chunk.Length -gt 256) { $chunk.Substring($chunk.Length - 256) } else { $chunk }
  }
}

foreach ($file in Get-ChildItem -LiteralPath $candidate -File) {
  $stream = [IO.File]::OpenRead($file.FullName)
  try { Assert-NoSecretInStream $stream $file.Name }
  finally { $stream.Dispose() }
}

foreach ($archiveFile in @(Get-ChildItem -LiteralPath $candidate -File | Where-Object { $_.Extension -in @('.zip', '.nupkg') })) {
  $archive = [IO.Compression.ZipFile]::OpenRead($archiveFile.FullName)
  try {
    $archiveEntries = @($archive.Entries | Where-Object { $_.Name })
    $entryNames = @($archiveEntries | ForEach-Object { $_.FullName.Replace('\', '/') })
    $unsafeEntries = @($entryNames | Where-Object {
      $segments = @($_ -split '/' | Where-Object { $_ -ne '' -and $_ -ne '.' })
      $_.StartsWith('/') -or $_ -match '^[A-Za-z]:' -or $segments -contains '..'
    })
    if ($unsafeEntries.Count -gt 0) { throw "Unsafe archive path: $($archiveFile.Name)" }
    $isBridgeSource = $archiveFile.Name -eq "AI-Sales-OS-WhatsApp-Bridge-$Version-source.zip"
    if ($isBridgeSource) {
      foreach ($required in @('COPYING', 'LICENSE.md', 'package.json', 'pnpm-lock.yaml', 'SOURCE-MANIFEST.json', 'INSTALL.md')) {
        if (@($entryNames | Where-Object { $_.TrimStart('./') -eq $required }).Count -ne 1) { throw "Bridge corresponding source is missing $required." }
      }
      $privateSourceEntries = @($entryNames | Where-Object {
        $_ -match '\.(cs|xaml|csproj|sln|pdb)$' -or
        ($_.EndsWith('.ps1', [StringComparison]::OrdinalIgnoreCase) -and
         $_ -notmatch '^\.?/node_modules/(?:.+/)?\.bin/[^/]+\.ps1$')
      })
      if ($privateSourceEntries.Count -gt 0) {
        throw 'Bridge corresponding-source archive contains proprietary desktop/build source types.'
      }
    }
    elseif (@($entryNames | Where-Object { $_ -match '\.(cs|xaml|csproj|sln|ps1|pdb|map)$' -or $_ -match '(^|/)(tests?|prompts?|internal-docs?)(/|$)' }).Count -gt 0) {
      throw "Binary release archive contains source, debug or internal material: $($archiveFile.Name)"
    }
    foreach ($entry in $archiveEntries) {
      $entryStream = $entry.Open()
      try { Assert-NoSecretInStream $entryStream "$($archiveFile.Name)!/$($entry.FullName)" }
      finally { $entryStream.Dispose() }
    }
  }
  finally { $archive.Dispose() }
}

$report = [ordered]@{
  version = $Version
  repository = $ExpectedRepository
  assetCount = $actualNames.Count
  checksumSubjects = $checksumEntries.Count
  manifestDigest = (Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToLowerInvariant()
  result = 'PASS'
} | ConvertTo-Json
[IO.File]::WriteAllText((Join-Path $candidate 'public-release-audit.json'), $report, [Text.UTF8Encoding]::new($false))
Write-Host "PASS public artifact allowlist: $($actualNames.Count) assets"
Write-Host "PASS manifest, feed and SHA-256 consistency: $($checksumEntries.Count) attestation subjects"
Write-Host 'PASS source-leak and secret scan'
