# Technical debt scan: records the project baseline in .adf/baseline/.
#   crap.json      every method: complexity, coverage, CRAP, action
#   mutation.json  surviving mutants per file (only with -Mutation; slow)
#   inventory.json test projects with and without coverlet.collector
param(
    [Parameter(Mandatory = $true)][string]$Repo,
    [switch]$Mutation
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AdfCommon.psm1') -Force

$Repo = (Resolve-Path $Repo).Path
$adfProfile = Get-AdfProfile $Repo
$outDir = Join-Path $Repo ".adf\out\scan-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$baselineDir = Join-Path $Repo '.adf\baseline'

$inventory = @($adfProfile.testProjects | ForEach-Object {
    $text = Get-Content (Join-Path $Repo $_) -Raw
    [pscustomobject]@{ Project = $_; HasCoverlet = ($text -match 'coverlet\.collector') }
})
Write-AdfJson $inventory (Join-Path $baselineDir 'inventory.json')
$missing = @($inventory | Where-Object { -not $_.HasCoverlet })
if ($missing.Count -gt 0) {
    $missing | Format-Table -AutoSize | Out-Host
    Write-Host 'Add coverlet.collector to the projects above, then run the scan again.'
    exit 1
}

$framework = $adfProfile.mainFramework
& (Join-Path $PSScriptRoot 'run-tests.ps1') -Repo $Repo -Framework $framework -OutDir $outDir
if ($LASTEXITCODE -ne 0) { Write-Host 'Scan continues with the coverage that was collected. Record the failing tests as debt.' }

& (Join-Path $PSScriptRoot 'crap.ps1') -Repo $Repo -CoverageDir (Join-Path $outDir $framework) -ReportJson (Join-Path $baselineDir 'crap.json')

$reportGenerator = Get-AdfToolPath 'reportgenerator.exe'
$limit = $adfProfile.limits.crap
& $reportGenerator "-reports:$outDir\$framework\**\coverage.cobertura.xml" "-targetdir:$outDir\report" '-reporttypes:Html;TextSummary' "-riskHotspotsAnalysisThresholds:metricThresholdForCrapScore=$limit" "-riskHotspotsAnalysisThresholds:metricThresholdForCyclomaticComplexity=$limit" | Out-Null
Write-Host "Coverage report: $outDir\report\index.html"

if ($Mutation) {
    & (Join-Path $PSScriptRoot 'mutation.ps1') -Repo $Repo -Framework $framework -OutDir $outDir -WriteBaseline
}
exit 0
