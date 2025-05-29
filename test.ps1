# This script assumes a portable copy of poptracker at .\test\poptracker.exe

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

# close running poptracker first
if (Get-Process -Name "poptracker" -ErrorAction SilentlyContinue) {
    Stop-Process -Name "poptracker"
}

# wait for poptracker to close
while (Get-Process -Name "poptracker" -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 1
}

if (Test-Path .\bin\build) {
    Remove-Item -Path .\bin\build -Recurse -Force
}

Write-Host "Building poptracker pack..."

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

if (Test-Path .\test\packs\smz3-ap-tracker.zip){
    Remove-Item .\test\packs\smz3-ap-tracker.zip -Force
}  

Compress-Archive -Path .\bin\build\* -DestinationPath .\test\packs\smz3-ap-tracker.zip -Force

# run poptracker
Start-Process .\test\poptracker.exe
