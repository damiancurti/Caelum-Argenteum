param([string]$Engine, [string]$Iwad)
$ErrorActionPreference = 'Stop'

function Resolve-PlaytestFile([string]$Provided, [string]$Filename, [string]$Prompt) {
    if ([string]::IsNullOrWhiteSpace($Provided)) {
        $LocalFile = Join-Path $PSScriptRoot $Filename
        if (Test-Path -LiteralPath $LocalFile -PathType Leaf) {
            return (Resolve-Path -LiteralPath $LocalFile).ProviderPath
        }
        $Provided = Read-Host $Prompt
    }
    $Candidate = $Provided.Trim().Trim('"').Trim()
    if ([string]::IsNullOrWhiteSpace($Candidate)) {
        throw "No path supplied for $Filename. Put it beside launch_playtest.bat or enter its full path."
    }
    if (-not [IO.Path]::IsPathRooted($Candidate)) {
        $Candidate = Join-Path $PSScriptRoot $Candidate
    }
    if (Test-Path -LiteralPath $Candidate -PathType Container) {
        $Candidate = Join-Path $Candidate $Filename
    }
    if (-not (Test-Path -LiteralPath $Candidate -PathType Leaf)) {
        throw "Could not find $Filename at '$Candidate'. Put it beside launch_playtest.bat or enter its full path."
    }
    return (Resolve-Path -LiteralPath $Candidate).ProviderPath
}

try {
    $Package = Join-Path $PSScriptRoot 'caelum_argenteum_dev.pk3'
    if (-not (Test-Path -LiteralPath $Package -PathType Leaf)) { throw 'Extract the complete playtest ZIP before launching.' }
    $Engine = Resolve-PlaytestFile $Engine 'gzdoom.exe' 'Full path to GZDoom 4.14.2 gzdoom.exe (or its folder)'
    $Iwad = Resolve-PlaytestFile $Iwad 'DOOM2.WAD' 'Full path to your Doom II DOOM2.WAD (or its folder)'
    $UserDirectory = Join-Path $PSScriptRoot 'user'
    $SaveDirectory = Join-Path $UserDirectory 'saves'
    [IO.Directory]::CreateDirectory($SaveDirectory) | Out-Null
    $Configuration = Join-Path $UserDirectory 'gzdoom.ini'
    $EngineArguments = @('-iwad', $Iwad, '-file', $Package, '-config', $Configuration, '-savedir', $SaveDirectory, '-noautoload')
    # Initialize the portable profile once; later launches preserve player edits.
    if (-not (Test-Path -LiteralPath $Configuration -PathType Leaf)) {
        $Defaults = Join-Path $PSScriptRoot 'default_controls.cfg'
        if (-not (Test-Path -LiteralPath $Defaults -PathType Leaf)) {
            throw 'First-start controls are missing. Extract the complete playtest ZIP.'
        }
        $EngineArguments += @('+exec', $Defaults)
    }
    Push-Location -LiteralPath $PSScriptRoot
    try {
        & $Engine @EngineArguments
        $EngineExitCode = $LASTEXITCODE
    } finally {
        Pop-Location
    }
    exit $EngineExitCode
} catch {
    Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
