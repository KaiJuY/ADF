# Stage H: runs gate 1 (unit tests), gate 2 (CRAP and changed-line coverage), gate 3 (mutation).
# Development: main framework only, changed code only.  -Release: every release framework, full mutation run.
param(
    [Parameter(Mandatory = $true)][string]$Repo,
    [string]$Base,
    [switch]$Release,
    [string]$OutDir
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AdfCommon.psm1') -Force

$Repo = (Resolve-Path $Repo).Path
$adfProfile = Get-AdfProfile $Repo
if (-not $Base) { $Base = $adfProfile.baseBranch }
$Base = Resolve-AdfBase $Repo $Base
if (-not $OutDir) { $OutDir = Join-Path $Repo ".adf\out\gate-$(Get-Date -Format 'yyyyMMdd-HHmmss')" }

$frameworks = @($adfProfile.mainFramework)
if ($Release) { $frameworks = @($adfProfile.releaseFrameworks) }

$summary = @()
foreach ($framework in $frameworks) {
    & (Join-Path $PSScriptRoot 'run-tests.ps1') -Repo $Repo -Framework $framework -OutDir $OutDir
    $gate1 = $LASTEXITCODE
    $summary += [pscustomobject]@{ Framework = $framework; Gate = '1 unit tests'; Passed = ($gate1 -eq 0) }
    if ($gate1 -ne 0) { break }

    & (Join-Path $PSScriptRoot 'crap.ps1') -Repo $Repo -CoverageDir (Join-Path $OutDir $framework) -Base $Base -ReportJson (Join-Path $OutDir "crap-$framework.json")
    $gate2 = $LASTEXITCODE

    $typeCheck = $true
    $baselinePath = Join-Path $Repo '.adf\baseline\crap.json'
    if ($gate2 -eq 0 -and (Test-Path $baselinePath)) {
        $baseline = Get-Content $baselinePath -Raw -Encoding UTF8 | ConvertFrom-Json
        $now = Get-Content (Join-Path $OutDir "crap-$framework.json") -Raw -Encoding UTF8 | ConvertFrom-Json
        $changed = Get-ChangedLines $Repo $Base
        $limit = [int]$adfProfile.limits.complexity
        $heavyTypes = @($baseline.Methods | Where-Object { $_.Complexity -gt $limit -and $changed.ContainsKey($_.File) } | ForEach-Object { "$($_.File)|$($_.Type)" } | Sort-Object -Unique)
        foreach ($key in $heavyTypes) {
            $before = @($baseline.Types | Where-Object { "$($_.File)|$($_.Type)" -eq $key })[0].Complexity
            $afterRow = @($now.Types | Where-Object { "$($_.File)|$($_.Type)" -eq $key })
            if ($afterRow.Count -eq 0) { continue }
            $after = $afterRow[0].Complexity
            Write-Host "Type complexity $key : baseline $before, now $after"
            if ($after -ge $before) {
                Write-Host "GATE 2 FAILED: $key had a method over complexity $limit and its total complexity did not go down. Splitting a method does not remove branches."
                $typeCheck = $false
            }
        }
    }
    $summary += [pscustomobject]@{ Framework = $framework; Gate = '2 CRAP'; Passed = ($gate2 -eq 0 -and $typeCheck) }
    if ($gate2 -ne 0 -or -not $typeCheck) { break }

    if ($Release) {
        & (Join-Path $PSScriptRoot 'mutation.ps1') -Repo $Repo -Framework $framework -OutDir $OutDir
    }
    else {
        & (Join-Path $PSScriptRoot 'mutation.ps1') -Repo $Repo -Framework $framework -OutDir $OutDir -Base $Base
    }
    $gate3 = $LASTEXITCODE
    $summary += [pscustomobject]@{ Framework = $framework; Gate = '3 mutation'; Passed = ($gate3 -eq 0) }
    if ($gate3 -ne 0) { break }
}

Write-Host ''
Write-Host "Output: $OutDir"
$summary | Format-Table -AutoSize | Out-Host
# Gate 3 detail comes from gate3.json. A missing or unreadable file counts as failed.
$gate3Failed = $false
foreach ($row in @($summary | Where-Object { $_.Gate -eq '3 mutation' })) {
    $gate3Path = Join-Path (Join-Path $OutDir "mutation-$($row.Framework)") 'gate3.json'
    $gate3Json = $null
    if (Test-Path $gate3Path) { try { $gate3Json = Get-Content $gate3Path -Raw -Encoding UTF8 | ConvertFrom-Json } catch { $gate3Json = $null } }
    if (-not $gate3Json) {
        Write-Host "Gate 3 ($($row.Framework)): gate3.json missing or unreadable: $gate3Path"
        $gate3Failed = $true
        continue
    }
    $onChangedCount = @($gate3Json.OnChangedLines).Count
    Write-Host "Gate 3 ($($row.Framework), $($gate3Json.Mode)): Passed=$($gate3Json.Passed), $onChangedCount on changed lines, $($gate3Json.Counted) counted, $($gate3Json.Static) static"
    if (-not $gate3Json.Passed) { $gate3Failed = $true }
}
$expectedRows = 3 * $frameworks.Count
if ($gate3Failed -or @($summary | Where-Object { -not $_.Passed }).Count -gt 0 -or $summary.Count -lt $expectedRows) {
    Write-Host 'ADF GATE FAILED'
    exit 1
}
Write-Host 'ADF GATE PASSED'
exit 0
