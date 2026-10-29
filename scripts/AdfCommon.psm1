# Shared functions for the ADF gate scripts. Windows PowerShell 5.1 compatible.
Set-StrictMode -Version 2.0

function Get-AdfToolDirectory {
    if ($env:ADF_TOOLS) { return $env:ADF_TOOLS }
    return Join-Path $env:USERPROFILE '.adf\tools'
}

function Get-AdfToolPath([string]$exeName) {
    $exe = Join-Path (Get-AdfToolDirectory) $exeName
    if (-not (Test-Path $exe)) {
        throw "Tool not found: $exe. Run $PSScriptRoot\install-tools.ps1"
    }
    return $exe
}

function Get-AdfProfile([string]$repo) {
    $path = Join-Path $repo '.adf\profile.json'
    if (-not (Test-Path $path)) {
        throw "No ADF profile: $path. Run /adf:scan first."
    }
    return Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
}

# Returns the test projects as objects with Path and Frameworks ($null means every framework).
# A profile entry is a path string, or { "path": "...", "frameworks": ["..."] }.
function Get-AdfTestProjects($adfProfile) {
    foreach ($entry in $adfProfile.testProjects) {
        if ($entry -is [string]) {
            [pscustomobject]@{ Path = $entry; Frameworks = $null }
            continue
        }
        $frameworks = $null
        if ($entry.PSObject.Properties['frameworks']) { $frameworks = @($entry.frameworks) }
        [pscustomobject]@{ Path = $entry.path; Frameworks = $frameworks }
    }
}

function Test-SupportsFramework($testProject, [string]$framework) {
    return ($null -eq $testProject.Frameworks) -or ($testProject.Frameworks -contains $framework)
}

# Runs a native program and returns its stdout and stderr lines as strings; the caller checks $LASTEXITCODE.
# Windows PowerShell 5.1 turns a stderr line into a terminating error under $ErrorActionPreference = 'Stop'.
function Invoke-AdfNative([string]$exe, [string[]]$arguments) {
    $ErrorActionPreference = 'Continue'
    & $exe @arguments 2>&1 | ForEach-Object { "$_" }
}

function ConvertTo-RepoPath([string]$repo, [string]$path) {
    $full = [System.IO.Path]::GetFullPath($path)
    $root = [System.IO.Path]::GetFullPath($repo).TrimEnd('\') + '\'
    if ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        $full = $full.Substring($root.Length)
    }
    return $full.Replace('\', '/').ToLowerInvariant()
}

function Test-Excluded([string]$repoPath, $patterns) {
    foreach ($pattern in $patterns) {
        $regex = '^' + [regex]::Escape($pattern.ToLowerInvariant()).Replace('\*\*/', '(.*/)?').Replace('\*\*', '.*').Replace('\*', '[^/]*') + '$'
        if ($repoPath -match $regex) { return $true }
    }
    return $false
}

# Returns @{ '<repo path>' = HashSet[int] of changed line numbers in the working tree, relative to $base }.
function Get-ChangedLines([string]$repo, [string]$base) {
    $result = @{}
    $diff = & git -C $repo diff --unified=0 --no-color --no-ext-diff $base -- '*.cs'
    if ($LASTEXITCODE -ne 0) { throw "git diff failed for base '$base'" }
    $current = $null
    foreach ($line in $diff) {
        if ($line -match '^\+\+\+ (?:b/)?(.+)$') {
            $current = $null
            if ($Matches[1] -eq '/dev/null') { continue }
            $current = $Matches[1].ToLowerInvariant()
            $result[$current] = New-Object 'System.Collections.Generic.HashSet[int]'
            continue
        }
        if ($null -eq $current) { continue }
        if ($line -notmatch '^@@ -\S+ \+(\d+)(?:,(\d+))? @@') { continue }
        $start = [int]$Matches[1]
        $count = 1
        if ($Matches[2]) { $count = [int]$Matches[2] }
        for ($i = 0; $i -lt $count; $i++) { [void]$result[$current].Add($start + $i) }
    }

    $untracked = & git -C $repo ls-files --others --exclude-standard -- '*.cs'
    foreach ($file in $untracked) {
        $key = $file.ToLowerInvariant()
        $set = New-Object 'System.Collections.Generic.HashSet[int]'
        $lineCount = (Get-Content (Join-Path $repo $file) | Measure-Object -Line).Lines
        for ($i = 1; $i -le $lineCount; $i++) { [void]$set.Add($i) }
        $result[$key] = $set
    }
    return $result
}

# Compiler-generated names map back to the source method:
#   Ns.Type/<LoadAsync>d__3 :: MoveNext  ->  Ns.Type :: LoadAsync
#   Ns.Type/<>c :: <Run>b__2_0          ->  Ns.Type :: Run
function Get-SourceMethodKey([string]$className, [string]$methodName) {
    $type = $className
    $method = $methodName
    if ($className -match '^(.+?)/<([^>]+)>d__\d+') {
        $type = $Matches[1]
        $method = $Matches[2]
    }
    elseif ($className -match '^(.+?)/') {
        $type = $Matches[1]
    }
    if ($method -match '^<([^>]+)>') { $method = $Matches[1] }
    return @{ Type = $type; Method = $method }
}

# Reads Cobertura files and merges them into one record per source method.
function Read-CoberturaMethods([string]$repo, [string[]]$files, $exclude) {
    $methods = @{}
    foreach ($file in $files) {
        [xml]$doc = Get-Content $file -Raw -Encoding UTF8
        $sources = @($doc.coverage.sources.source | ForEach-Object { "$_" })
        foreach ($class in $doc.SelectNodes('//class')) {
            $fileName = $class.filename
            if (-not [System.IO.Path]::IsPathRooted($fileName)) {
                foreach ($source in $sources) {
                    $candidate = Join-Path $source $fileName
                    if (Test-Path $candidate) { $fileName = $candidate; break }
                }
            }
            $repoPath = ConvertTo-RepoPath $repo $fileName
            if ([System.IO.Path]::IsPathRooted($repoPath)) { continue }
            if (Test-Excluded $repoPath $exclude) { continue }

            foreach ($method in $class.SelectNodes('methods/method')) {
                $name = Get-SourceMethodKey $class.name $method.name
                $key = "$repoPath|$($name.Type)|$($name.Method)"
                if (-not $methods.ContainsKey($key)) {
                    $methods[$key] = @{
                        File = $repoPath; Type = $name.Type; Method = $name.Method
                        Complexity = 0; Lines = @{}
                    }
                }
                $record = $methods[$key]
                $complexity = [int]$method.complexity
                if ($complexity -gt $record.Complexity) { $record.Complexity = $complexity }
                foreach ($line in $method.SelectNodes('lines/line')) {
                    $number = [int]$line.number
                    $hits = [int]$line.hits
                    if (-not $record.Lines.ContainsKey($number) -or $record.Lines[$number] -lt $hits) {
                        $record.Lines[$number] = $hits
                    }
                }
            }
        }
    }

    foreach ($record in $methods.Values) {
        $total = $record.Lines.Count
        $covered = @($record.Lines.Values | Where-Object { $_ -gt 0 }).Count
        $coverage = 1.0
        if ($total -gt 0) { $coverage = $covered / $total }
        $c = $record.Complexity
        $record.Coverage = $coverage
        $record.Crap = [math]::Round($c * $c * [math]::Pow(1 - $coverage, 3) + $c, 2)
        $record.FirstLine = 0
        $record.LastLine = 0
        if ($total -gt 0) {
            $record.FirstLine = ($record.Lines.Keys | Measure-Object -Minimum).Minimum
            $record.LastLine = ($record.Lines.Keys | Measure-Object -Maximum).Maximum
        }
    }
    return $methods
}

function Test-MethodChanged($record, $changedLines) {
    if (-not $changedLines.ContainsKey($record.File)) { return $false }
    foreach ($line in $record.Lines.Keys) {
        if ($changedLines[$record.File].Contains([int]$line)) { return $true }
    }
    return $false
}

function Write-AdfJson($object, [string]$path) {
    $dir = Split-Path $path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
    $json = $object | ConvertTo-Json -Depth 8
    [System.IO.File]::WriteAllText($path, $json, (New-Object System.Text.UTF8Encoding $false))
}

Export-ModuleMember -Function Get-AdfToolDirectory, Get-AdfToolPath, Get-AdfProfile, Get-AdfTestProjects, Test-SupportsFramework, Invoke-AdfNative, ConvertTo-RepoPath, Test-Excluded, Get-ChangedLines, Read-CoberturaMethods, Test-MethodChanged, Write-AdfJson
