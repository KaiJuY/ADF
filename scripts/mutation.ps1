# Gate 3: mutation testing with Stryker.NET.
# Development (-Base): mutate changed files; zero surviving mutants on changed lines.
# Release (no -Base): mutate everything; survivors per file must not exceed .adf/baseline/mutation.json.
# -WriteBaseline: store the per-file survivor counts as the new baseline (used by scan).
#
# Mutants in static initializers can change between Killed and Survived from run to run, because the
# initializer runs once per test process. Stryker marks them "static": the release count leaves them
# out. A failure is also confirmed by a second run on the failing files; only findings in both runs count.
param(
    [Parameter(Mandatory = $true)][string]$Repo,
    [Parameter(Mandatory = $true)][string]$Framework,
    [Parameter(Mandatory = $true)][string]$OutDir,
    [string]$Base,
    [switch]$WriteBaseline
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AdfCommon.psm1') -Force

$adfProfile = Get-AdfProfile $Repo
$stryker = Get-AdfToolPath 'dotnet-stryker.exe'
$runDir = Join-Path $OutDir "mutation-$Framework"
if (Test-Path $runDir) { Remove-Item -Recurse -Force $runDir }

# Returns an MSBuild.exe that can build SDK-style projects, or $null to let Stryker pick one.
# Stryker picks the newest Visual Studio, which can be a Build Tools install without the .NET SDK component.
function Get-MsBuildPath {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path $vswhere)) { return $null }
    $found = Invoke-AdfNative $vswhere @('-latest', '-products', '*', '-requires', 'Microsoft.NetCore.Component.SDK', '-find', 'MSBuild\**\Bin\MSBuild.exe')
    return @($found | Where-Object { $_ -and (Test-Path $_) })[0]
}

# Used only for .NET Framework targets: Stryker builds those with MSBuild.exe instead of dotnet build.
$msBuild = Get-MsBuildPath

# A source project referenced by several test projects is mutated once per test project.
# A mutant counts only if it survived every one of those runs: one test project that kills it is enough.
function Invoke-Mutation([string]$passDir, [string[]]$onlyFiles) {
    $survivors = @()
    foreach ($sourceProject in $adfProfile.sourceProjects) {
        $sourceName = Split-Path $sourceProject -Leaf
        $sourceDir = (Split-Path $sourceProject -Parent).Replace('\', '/').ToLowerInvariant() + '/'
        $targets = @()
        if ($onlyFiles) {
            $targets = @($onlyFiles | Where-Object { $_.StartsWith($sourceDir) })
            if ($targets.Count -eq 0) { continue }
        }

        $runs = @()
        foreach ($testProject in @(Get-AdfTestProjects $adfProfile)) {
            $projectFramework = Get-RunFramework $testProject $Framework $adfProfile.mainFramework
            if (-not $projectFramework) { continue }
            $testPath = Join-Path $Repo $testProject.Path
            $references = Get-Content $testPath -Raw
            if ($references -notmatch [regex]::Escape($sourceName)) { continue }

            $projectOut = Join-Path $passDir ([System.IO.Path]::GetFileNameWithoutExtension($testProject.Path) + '__' + [System.IO.Path]::GetFileNameWithoutExtension($sourceName))
            $arguments = @('-tp', $testPath, '-p', $sourceName, '--target-framework', $projectFramework,
                '-r', 'Json', '-r', 'Html', '-O', $projectOut, '--skip-version-check')
            if ($projectFramework -match '^net\d{2,3}$') {
                $arguments += @('-s', (Join-Path $Repo $adfProfile.solution))
                if ($msBuild) { $arguments += @('--msbuild-path', $msBuild) }
            }
            if ($Base) { $arguments += "--since:$Base" }
            foreach ($target in $targets) {
                $full = Join-Path $Repo $target
                $actualName = [System.IO.Directory]::GetFiles((Split-Path $full -Parent), (Split-Path $full -Leaf))[0]
                $arguments += @('-m', ('**/' + (Split-Path $actualName -Leaf)))
            }
            foreach ($pattern in $adfProfile.exclude) { $arguments += @('-m', "!$pattern") }

            New-Item -ItemType Directory -Force $projectOut | Out-Null
            $log = Join-Path $projectOut 'stryker.log'
            Push-Location (Split-Path $testPath -Parent)
            try { Invoke-AdfNative $stryker $arguments | Out-File $log -Encoding utf8 }
            finally { Pop-Location }
            if ($LASTEXITCODE -ne 0) { throw "Stryker failed for $($testProject.Path) -> $sourceName (exit $LASTEXITCODE). Log: $log" }
            Get-Content $log | Where-Object { $_ -match 'final mutation score|unable to calculate' } | ForEach-Object { Write-Host "  $sourceName $_" }

            $report = Find-AdfFiles $projectOut 'mutation-report.json' | Select-Object -First 1
            if (-not $report) { continue }
            $runs += , (Read-Survivors $report.FullName)
        }
        $survivors += Select-CommonSurvivors $runs
    }
    return , $survivors
}

function Read-Survivors([string]$reportPath) {
    $found = @()
    $json = Get-Content $reportPath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($fileProperty in $json.files.PSObject.Properties) {
        $repoPath = ConvertTo-RepoPath $Repo $fileProperty.Name
        foreach ($mutant in $fileProperty.Value.mutants) {
            if ($mutant.status -ne 'Survived' -and $mutant.status -ne 'NoCoverage') { continue }
            $isStatic = $false
            if ($mutant.PSObject.Properties['static']) { $isStatic = [bool]$mutant.static }
            $found += [pscustomobject]@{
                File = $repoPath; Line = [int]$mutant.location.start.line
                Mutator = $mutant.mutatorName; Status = $mutant.status; Replacement = $mutant.replacement
                Static = $isStatic
                Key = "$repoPath|$($mutant.location.start.line)|$($mutant.mutatorName)|$($mutant.replacement)"
            }
        }
    }
    return , $found
}

function Select-CommonSurvivors($runs) {
    if ($runs.Count -eq 0) { return , @() }
    $common = $runs[0]
    for ($i = 1; $i -lt $runs.Count; $i++) {
        $keys = @($runs[$i] | ForEach-Object { $_.Key })
        $common = @($common | Where-Object { $keys -contains $_.Key })
    }
    return , $common
}

# Counts non-static survivors only. Static mutants are unstable between runs (see the header).
function Get-PerFile($survivors) {
    $perFile = @{}
    foreach ($s in $survivors) {
        if ($s.Static) { continue }
        if (-not $perFile.ContainsKey($s.File)) { $perFile[$s.File] = 0 }
        $perFile[$s.File]++
    }
    return $perFile
}

function Get-Increased($perFile, $baseline) {
    $increased = @()
    foreach ($file in $perFile.Keys) {
        $before = 0
        $property = $baseline.PSObject.Properties[$file]
        if ($property) { $before = [int]$property.Value }
        if ($perFile[$file] -gt $before) { $increased += [pscustomobject]@{ File = $file; Baseline = $before; Now = $perFile[$file] } }
    }
    return , $increased
}

$survivors = Invoke-Mutation (Join-Path $runDir 'pass1') $null
$perFile = Get-PerFile $survivors
$staticCount = @($survivors | Where-Object { $_.Static }).Count
Write-AdfJson ([pscustomobject]@{ Framework = $Framework; Survivors = $survivors; PerFile = $perFile }) (Join-Path $runDir 'survivors.json')
Write-Host "Survivors: $($survivors.Count - $staticCount) counted, $staticCount in static initializers (listed in survivors.json, not counted)."

$baselinePath = Join-Path $Repo '.adf\baseline\mutation.json'
if ($WriteBaseline) {
    Write-AdfJson ([pscustomobject]@{ Framework = $Framework; Date = (Get-Date -Format 's'); PerFile = $perFile }) $baselinePath
    Write-Host "Baseline written: $baselinePath ($($survivors.Count - $staticCount) counted survivors in $($perFile.Count) files)"
    exit 0
}

if ($Base) {
    $changed = Get-ChangedLines $Repo $Base
    $onChanged = @($survivors | Where-Object { $changed.ContainsKey($_.File) -and $changed[$_.File].Contains($_.Line) })
    if ($onChanged.Count -gt 0) {
        Write-Host "Confirming $($onChanged.Count) survivor(s) with a second run..."
        $files = @($onChanged | ForEach-Object { $_.File } | Sort-Object -Unique)
        $second = Invoke-Mutation (Join-Path $runDir 'pass2') $files
        $secondKeys = @($second | ForEach-Object { $_.Key })
        $onChanged = @($onChanged | Where-Object { $secondKeys -contains $_.Key })
    }
    $onChanged | Format-Table File, Line, Mutator, Status, Replacement -AutoSize | Out-String -Width 250 | Out-Host
    if ($onChanged.Count -gt 0) {
        Write-Host "GATE 3 FAILED: $($onChanged.Count) surviving mutant(s) on changed lines. Kill them, or mark an equivalent mutant with a Stryker disable comment and a reason."
        exit 1
    }
    Write-Host "GATE 3 PASSED (development mode)"
    exit 0
}

if (-not (Test-Path $baselinePath)) { throw "No mutation baseline: $baselinePath. Run scan.ps1 -Mutation first." }
$baseline = (Get-Content $baselinePath -Raw -Encoding UTF8 | ConvertFrom-Json).PerFile
$increased = Get-Increased $perFile $baseline
if ($increased.Count -gt 0) {
    Write-Host "Confirming $($increased.Count) file(s) with a second run..."
    $second = Invoke-Mutation (Join-Path $runDir 'pass2') @($increased | ForEach-Object { $_.File })
    $secondIncreased = Get-Increased (Get-PerFile $second) $baseline
    $confirmed = @($secondIncreased | ForEach-Object { $_.File })
    $increased = @($increased | Where-Object { $confirmed -contains $_.File })
}
$increased | Format-Table -AutoSize | Out-String -Width 250 | Out-Host
if ($increased.Count -gt 0) {
    Write-Host "GATE 3 FAILED: surviving mutants went up in $($increased.Count) file(s), in both runs."
    exit 1
}
Write-Host "GATE 3 PASSED (release mode)"
exit 0
