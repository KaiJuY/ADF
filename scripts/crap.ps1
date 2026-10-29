# Gate 2: CRAP and changed-line coverage, from the Cobertura files of run-tests.ps1.
# -Base <ref>: check changed methods only. Without -Base: report every method (used by scan).
param(
    [Parameter(Mandatory = $true)][string]$Repo,
    [Parameter(Mandatory = $true)][string]$CoverageDir,
    [string]$Base,
    [string]$ReportJson
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AdfCommon.psm1') -Force

$adfProfile = Get-AdfProfile $Repo
$limitCrap = [double]$adfProfile.limits.crap
$limitComplexity = [int]$adfProfile.limits.complexity
$limitCoverage = [double]$adfProfile.limits.changedLineCoverage

$files = @(Find-AdfFiles $CoverageDir 'coverage.cobertura.xml' | ForEach-Object { $_.FullName })
if ($files.Count -eq 0) { throw "No coverage.cobertura.xml under $CoverageDir. Does the test project reference coverlet.collector?" }

$methods = Read-CoberturaMethods $Repo $files $adfProfile.exclude
$scope = @($methods.Values)
$changed = $null
if ($Base) {
    $changed = Get-ChangedLines $Repo $Base
    $scope = @($scope | Where-Object { Test-MethodChanged $_ $changed })
}

$rows = @($scope | ForEach-Object {
    $action = 'ok'
    if ($_.Crap -gt $limitCrap) {
        $action = 'add-tests'
        if ($_.Complexity -gt $limitComplexity) { $action = 'remove-branches' }
    }
    [pscustomobject]@{
        File = $_.File; Type = $_.Type; Method = $_.Method; Line = $_.FirstLine
        Complexity = $_.Complexity; Coverage = [math]::Round($_.Coverage, 3); Crap = $_.Crap; Action = $action
    }
} | Sort-Object Crap -Descending)

$typeSums = @($methods.Values | Group-Object { "$($_.File)|$($_.Type)" } | ForEach-Object {
    $first = $_.Group[0]
    $sum = 0
    foreach ($m in $_.Group) { $sum += $m.Complexity }
    [pscustomobject]@{ File = $first.File; Type = $first.Type; Complexity = $sum }
})

$diffCoverage = $null
if ($Base) {
    $coveredLines = 0; $countedLines = 0
    $lineHits = @{}
    foreach ($m in $methods.Values) {
        foreach ($n in $m.Lines.Keys) {
            $k = "$($m.File)|$n"
            if (-not $lineHits.ContainsKey($k) -or $lineHits[$k] -lt $m.Lines[$n]) { $lineHits[$k] = $m.Lines[$n] }
        }
    }
    foreach ($file in $changed.Keys) {
        foreach ($n in $changed[$file]) {
            $k = "$file|$n"
            if (-not $lineHits.ContainsKey($k)) { continue }
            $countedLines++
            if ($lineHits[$k] -gt 0) { $coveredLines++ }
        }
    }
    $diffCoverage = [pscustomobject]@{ Covered = $coveredLines; Counted = $countedLines; Rate = 1.0 }
    if ($countedLines -gt 0) { $diffCoverage.Rate = [math]::Round($coveredLines / $countedLines, 3) }
}

if ($ReportJson) {
    Write-AdfJson ([pscustomobject]@{ Methods = $rows; Types = $typeSums; ChangedLineCoverage = $diffCoverage }) $ReportJson
}

$violations = @($rows | Where-Object { $_.Action -ne 'ok' })
$rows | Select-Object -First 25 | Format-Table Crap, Complexity, Coverage, Action, @{ n = 'Method'; e = { ($_.Type -replace '^.*\.', '') + '.' + $_.Method } }, @{ n = 'At'; e = { "$($_.File):$($_.Line)" } } -AutoSize | Out-String -Width 250 | Out-Host
if ($rows.Count -gt 25) { Write-Host "($($rows.Count - 25) more rows in the JSON report)" }

if (-not $Base) {
    Write-Host "Methods: $($rows.Count). Over CRAP $limitCrap : $($violations.Count)."
    exit 0
}

$failed = $false
if ($violations.Count -gt 0) {
    Write-Host "GATE 2 FAILED: $($violations.Count) changed method(s) over CRAP $limitCrap."
    $failed = $true
}
Write-Host ("Changed-line coverage: {0} of {1} lines ({2:P1}), limit {3:P0}" -f $diffCoverage.Covered, $diffCoverage.Counted, $diffCoverage.Rate, $limitCoverage)
if ($diffCoverage.Rate -lt $limitCoverage) {
    Write-Host "GATE 2 FAILED: changed-line coverage below the limit."
    $failed = $true
}
if ($failed) { exit 1 }
Write-Host "GATE 2 PASSED"
exit 0
