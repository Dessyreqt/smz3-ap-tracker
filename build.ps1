param(
    [Alias('v')][string]$version = "",
    [Alias('c')][string]$changelog = "",
    [switch]$skipcompression = $false
)

function Remove-JsonCComments {
    param (
        [string]$filePath
    )
    $content = Get-Content -Path $filePath -Raw
    # Remove comments (// and /* */) and trailing commas
    $content = $content -replace '(?m)//.*?$|/\*.*?\*/', '' -replace ',\s*([}\]])', '$1'
    Set-Content -Path $filePath -Value $content -Force
}

function Minify-Json {
    param (
        [string]$filePath
    )
    $content = Get-Content -Path $filePath -Raw
    # Remove whitespace and newlines
    $content = $content -replace '\s+', ' ' -replace '^\s+|\s+$', ''
    Set-Content -Path $filePath -Value $content -Force
}

if (-not $skipcompression) {
    Write-Host "Compressing images..."
    & ".\compressimages.ps1"
} else {
    Write-Host "Skipping image compression."
}

# Create the bin directory if it doesn't exist
if (!(Test-Path -Path .\bin)) {
    New-Item -ItemType Directory -Path .\bin
}

$filename = "smz3-ap-tracker.zip"

if ($version -ne "") {
    $filename = "smz3-ap-tracker-$version.zip"

    # update the version in the manifest file
    $manifestPath = ".\src\manifest.json"
    $manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
    $manifest.package_version = $version
    $manifest | ConvertTo-Json -Depth 10 | Set-Content -Path $manifestPath -Force
}

# build the package
Write-Host "Building poptracker pack..."

if (Test-Path .\bin\build) {
    Remove-Item -Path .\bin\build -Recurse -Force
}

Copy-Item -Path .\src -Destination .\bin\build -Recurse -Force

foreach ($file in Get-ChildItem -Path .\bin\build -Recurse -Filter *.jsonc) {
    Remove-JsonCComments -filePath $file.FullName
    Minify-Json -filePath $file.FullName
    Rename-Item -Path $file.FullName -NewName ($file.BaseName + ".json") -Force
}

# update filenames in init.lua
$initLuaPath = ".\bin\build\scripts\init.lua"
if (Test-Path -Path $initLuaPath) {
    $content = Get-Content -Path $initLuaPath -Raw
    $content = $content -replace 'jsonc', 'json'
    Set-Content -Path $initLuaPath -Value $content -Force
}

if (Test-Path .\bin\$filename){
    Remove-Item .\bin\$filename -Force
}  

Compress-Archive -Path .\bin\build\* -DestinationPath .\bin\$filename -Force
Write-Host "Build complete. Output: .\bin\$filename"

if ($version -ne "") {
    $sha256 = Get-FileHash -Path .\bin\$filename -Algorithm SHA256
    Write-Host "SHA256: $($sha256.Hash)"

    # add the new version to the versions.json file
    $versionsPath = ".\versions.json"
    $versions = Get-Content -Path $versionsPath -Raw | ConvertFrom-Json
  
    $newVersion = [PSCustomObject]@{
        package_version = $version
        download_url = "https://github.com/dessyreqt/smz3-ap-tracker/releases/download/$version/smz3-ap-tracker-$version.zip"
        sha256  = $sha256.Hash
        changelog = [array]@($changelog)
    }
    $versions.versions = @($newVersion) + $versions.versions
    $versions | ConvertTo-Json -Depth 10 | Set-Content -Path $versionsPath -Force

    Write-Host "Versioning complete! Next items to do to release this version:

- Commit and push all files except .\versions.json
- Create release in GitHub and attach $filename to it
- Commit and push .\versions.json"
}
