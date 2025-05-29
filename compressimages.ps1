function Save-ImageHashes {
    param (
        [hashtable]$imageHashes,
        [string]$outputPath
    )

    # Sort the keys of the hashtable and create an ordered hashtable
    $orderedImageHashes = [ordered]@{}
    foreach ($key in $imageHashes.Keys | Sort-Object) {
        $orderedImageHashes[$key] = $imageHashes[$key]
    }

    # Write the sorted hashtable to the JSON file
    $orderedImageHashes | ConvertTo-Json -Depth 10 | Set-Content -Path $outputPath -Force
}

$zopflipngLocation = ".\bin\zopflipng.exe"

if (!(Test-Path -Path $zopflipngLocation)) {
    Write-Host "ZopfliPNG not found at $zopflipngLocation. Please ensure it is built and available."
    exit 1
}

# Load image hashes from imagehash.json for comparison
$imageHashesPath = ".\imagehash.json"
if (Test-Path -Path $imageHashesPath) {
    $imageHashes = [hashtable]::new()
    $jsonContent = Get-Content -Path $imageHashesPath -Raw | ConvertFrom-Json
    foreach ($key in $jsonContent.PSObject.Properties.Name) {
        $imageHashes[$key] = $jsonContent.$key
    }
} else {
    $imageHashes = @{}
} 
foreach ($file in Get-ChildItem -Path .\src -Recurse -Filter *.png) {
    $hashKey = $file.FullName.Substring((Get-Item ".\src").FullName.Length + 1).Replace("\", "/")
    # Check if the file is already compressed by comparing hashes
    $currentHash = Get-FileHash -Path $file.FullName -Algorithm SHA256 | Select-Object -ExpandProperty Hash
    if ($imageHashes.ContainsKey($hashKey) -and $imageHashes[$hashKey] -eq $currentHash) {
        Write-Host "Skipping $($file.FullName), already compressed."
        continue
    }
    
    $outputFile = Join-Path -Path $file.DirectoryName -ChildPath ($file.BaseName + "-compressed.png")
    Write-Host "Compressing $($file.FullName) to $outputFile..."
    & $zopflipngLocation --iterations=15 --filters=01234mepb --lossy_8bit --lossy_transparent $file.FullName $outputFile
    Remove-Item -Path $file.FullName -Force
    Rename-Item -Path $outputFile -NewName $file.Name -Force
    # Calculate hash of the compressed image
    $hash = Get-FileHash -Path $file.FullName -Algorithm SHA256 | Select-Object -ExpandProperty Hash
    $imageHashes[$hashKey] = $hash   
    # write the hash back to the imagehash.json file
    Save-ImageHashes -imageHashes $imageHashes -outputPath $imageHashesPath
} 
