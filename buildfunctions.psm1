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

function Compress-Images {
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
}

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

function Build-PackContent {
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
}