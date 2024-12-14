# Stop on errors
$ErrorActionPreference = "Stop"

# Load environment variables
Get-Content .\.env | ForEach-Object {
    if ($_ -match '(.+)=(.+)') {
        Set-Item -Path "Env:$($Matches[1])" -Value $Matches[2]
    }
}

# Install requirements
pip install python-dotenv

# Create output directory structure
$THEME_DIR = "SplashOS-Icon-Theme"
New-Item -ItemType Directory -Path $THEME_DIR -Force | Out-Null

# Create array for enabled sizes
$SIZES = @()
if ($env:sit_global_render_32 -eq "true") { $SIZES += 32 }
if ($env:sit_global_render_64 -eq "true") { $SIZES += 64 }
if ($env:sit_global_render_128 -eq "true") { $SIZES += 128 }
if ($env:sit_global_render_256 -eq "true") { $SIZES += 256 }
if ($env:sit_global_render_512 -eq "true") { $SIZES += 512 }

# Create directories string for index.theme
$dirString = ($SIZES | ForEach-Object { "applications/$_" }) -join ","

# Create index.theme content
$indexContent = @"
[Icon Theme]
Name=SplashOS Theme
Comment=The official icon theme for SplashOS
Inherits=MoreWaita,Adwaita
Directories=$dirString

$($SIZES | ForEach-Object {
@"
[applications/$_]
Size=$_
Context=Applications
Type=Fixed

"@
})
"@

# Write index.theme file
$indexContent | Out-File -FilePath "$THEME_DIR/index.theme" -Encoding UTF8

# Process all blend files
Get-ChildItem -Path "src/blend/applications" -Filter "*.blend" -Recurse | ForEach-Object {
    Write-Host "Processing $($_.FullName)..."
    # Convert paths to use forward slashes
    $blendPath = $_.FullName -replace '\\','/'
    $renderPath = (Join-Path $PSScriptRoot "src/render.py") -replace '\\','/'
    $outputPath = (Join-Path $THEME_DIR "applications") -replace '\\','/'

    blender -b "$blendPath" -P "$renderPath" -- "$outputPath"
}

Write-Host "Icon theme build complete!"
