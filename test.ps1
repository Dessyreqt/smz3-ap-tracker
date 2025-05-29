# This script assumes a portable copy of poptracker at .\test\poptracker.exe

Import-Module ".\buildfunctions.psm1" 

# close running poptracker first
if (Get-Process -Name "poptracker" -ErrorAction SilentlyContinue) {
    Stop-Process -Name "poptracker"
}

# wait for poptracker to close
while (Get-Process -Name "poptracker" -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 1
}

Write-Host "Building poptracker pack..."

Build-PackContent

if (Test-Path .\test\packs\smz3-ap-tracker.zip){
    Remove-Item .\test\packs\smz3-ap-tracker.zip -Force
}  

Compress-Archive -Path .\bin\build\* -DestinationPath .\test\packs\smz3-ap-tracker.zip -Force

# run poptracker
Start-Process .\test\poptracker.exe
