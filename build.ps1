param(
    [Alias('v')][string]$version = ""
)

if (!(Test-Path -Path .\bin)) {
    New-Item -ItemType Directory -Path .\bin
}

$filename = "smz3-ap-tracker.zip"

if ($version -ne "") {
    $filename = "smz3-ap-tracker-$version.zip"
}

if (Test-Path .\bin\$filename){
    Remove-Item .\bin\$filename -Force
}  

Compress-Archive -Path .\src -DestinationPath .\bin\$filename -Force

$sha256 = Get-FileHash -Path .\bin\$filename -Algorithm SHA256

Write-Host "Build complete. Output: .\bin\$filename"
Write-Host "SHA256: $($sha256.Hash)"


