<#
.SYNOPSIS
Builds all assets in this repository.
.PARAMETER Configuration
The project configuration to build.
#>
[CmdletBinding(SupportsShouldProcess)]
Param(
    [Parameter()]
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration
)

$msbuildCommandLine = "msbuild `"$PSScriptRoot\src\Nerdbank.GitVersioning.sln`" /m /verbosity:minimal /nologo"

if (Test-Path "C:\Program Files\AppVeyor\BuildAgent\Appveyor.MSBuildLogger.dll") {
    $msbuildCommandLine += " /logger:`"C:\Program Files\AppVeyor\BuildAgent\Appveyor.MSBuildLogger.dll`""
}

if ($Configuration) {
    $msbuildCommandLine += " /p:Configuration=$Configuration"
}

Push-Location .
try {
    if ($PSCmdlet.ShouldProcess("$PSScriptRoot\src\Nerdbank.GitVersioning.sln", "msbuild")) {
        Invoke-Expression $msbuildCommandLine
        if ($LASTEXITCODE -ne 0) {
            throw "MSBuild failed"
        }
    }

    if ($PSCmdlet.ShouldProcess("$PSScriptRoot\src\nerdbank-gitversioning.npm", "gulp")) {
        cd "$PSScriptRoot\src\nerdbank-gitversioning.npm"
        .\node_modules\.bin\gulp.cmd
        if ($LASTEXITCODE -ne 0) {
            throw "Node build failed"
        }
    }
} catch {
    Write-Error "Build failure"
    # we have the try so that PS fails when we get failure exit codes from build steps.
    throw;
} finally {
    Pop-Location
}
