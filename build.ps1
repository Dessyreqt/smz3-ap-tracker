param(
    [Alias('v')][string]$version = "",
    [Alias('c')][string]$changelog = ""
)

# Create the bin directory if it doesn't exist
if (!(Test-Path -Path .\bin)) {
    New-Item -ItemType Directory -Path .\bin
}

$filename = "smz3-ap-tracker.zip"

if ($version -ne "") {
    $filename = "smz3-ap-tracker-$version.zip"
}

# build the package
if (Test-Path .\bin\$filename){
    Remove-Item .\bin\$filename -Force
}  

Compress-Archive -Path .\src -DestinationPath .\bin\$filename -Force
Write-Host "Build complete. Output: .\bin\$filename"

if ($version -ne "") {
    $sha256 = Get-FileHash -Path .\bin\$filename -Algorithm SHA256
    Write-Host "SHA256: $($sha256.Hash)"

    # update the version in the manifest file
    $manifestPath = ".\src\manifest.json"
    $manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
    $manifest.package_version = $version
    $manifest | ConvertTo-Json -Depth 10 | Set-Content -Path $manifestPath -Force

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




