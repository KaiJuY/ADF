# Installs the pinned ADF tools into <ADF>/.tools. Safe to run again.
$ErrorActionPreference = 'Stop'

$toolPath = Join-Path (Split-Path $PSScriptRoot -Parent) '.tools'
$tools = @(
    @{ Id = 'dotnet-reportgenerator-globaltool'; Version = '5.5.12'; Exe = 'reportgenerator.exe' },
    # 5.0.0 ships only a net10.0 build. Move to it after the .NET 10 SDK is installed.
    @{ Id = 'dotnet-stryker'; Version = '4.16.0'; Exe = 'dotnet-stryker.exe' }
)

foreach ($tool in $tools) {
    $exe = Join-Path $toolPath $tool.Exe
    if (Test-Path $exe) {
        $installed = & dotnet tool list --tool-path $toolPath | Select-String -Pattern ("^" + [regex]::Escape($tool.Id) + "\s+(\S+)")
        if ($installed -and $installed.Matches[0].Groups[1].Value -eq $tool.Version) { continue }
        & dotnet tool uninstall $tool.Id --tool-path $toolPath | Out-Null
    }
    & dotnet tool install $tool.Id --version $tool.Version --tool-path $toolPath
    if ($LASTEXITCODE -ne 0) { throw "Install failed: $($tool.Id) $($tool.Version)" }
}

& dotnet tool list --tool-path $toolPath
