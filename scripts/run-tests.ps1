# Gate 1: runs each test project for one framework, with coverage.
# Output: <OutDir>/<framework>/... (trx and coverage.cobertura.xml files) and summary.json.
param(
    [Parameter(Mandatory = $true)][string]$Repo,
    [Parameter(Mandatory = $true)][string]$Framework,
    [Parameter(Mandatory = $true)][string]$OutDir
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AdfCommon.psm1') -Force

$adfProfile = Get-AdfProfile $Repo
$runDir = Join-Path $OutDir $Framework
if (Test-Path $runDir) { Remove-Item -Recurse -Force $runDir }
New-Item -ItemType Directory -Force $runDir | Out-Null

$results = @()
foreach ($project in $adfProfile.testProjects) {
    $projectPath = Join-Path $Repo $project
    $name = [System.IO.Path]::GetFileNameWithoutExtension($project)
    $projectDir = Join-Path $runDir $name

    $expected = @(& dotnet test $projectPath -f $Framework --list-tests --nologo 2>$null | Where-Object { $_ -match '^    \S' }).Count

    & dotnet test $projectPath -f $Framework --nologo `
        --collect:"XPlat Code Coverage" `
        --results-directory $projectDir `
        --logger "trx;LogFileName=$name.trx" *> (Join-Path $runDir "$name.log")
    $exitCode = $LASTEXITCODE

    $trx = Get-ChildItem $projectDir -Recurse -Filter '*.trx' | Select-Object -First 1
    $total = 0; $passed = 0; $failed = 0; $failedNames = @()
    if ($trx) {
        [xml]$doc = Get-Content $trx.FullName -Raw -Encoding UTF8
        $counters = $doc.TestRun.ResultSummary.Counters
        $total = [int]$counters.total
        $passed = [int]$counters.passed
        $failed = [int]$counters.failed
        $failedNames = @($doc.TestRun.Results.UnitTestResult | Where-Object { $_.outcome -eq 'Failed' } | ForEach-Object { $_.testName })
    }

    $truncated = $total -lt $expected
    $results += [pscustomobject]@{
        Project = $project; Framework = $Framework
        Expected = $expected; Total = $total; Passed = $passed; Failed = $failed
        Truncated = $truncated; ExitCode = $exitCode; FailedTests = $failedNames
    }
}

Write-AdfJson $results (Join-Path $runDir 'summary.json')
$results | Format-Table Project, Framework, Expected, Total, Passed, Failed, Truncated -AutoSize | Out-String -Width 250 | Out-Host
Write-Host "Logs: $runDir\*.log"

$bad = @($results | Where-Object { $_.Failed -gt 0 -or $_.Truncated -or $_.Total -eq 0 })
if ($bad.Count -gt 0) {
    Write-Host "GATE 1 FAILED: failed tests, a cut-off run (total below discovery count), or no tests ran."
    foreach ($r in $bad) { foreach ($t in $r.FailedTests) { Write-Host "  FAILED $($r.Project): $t" } }
    exit 1
}
Write-Host "GATE 1 PASSED"
exit 0
