param(
    [string]$Source,
    [string]$ModName,
    [string]$MCVersion,
    [string]$Loader,
    [string]$OutputDir
)

if ($Source -ne "modrinth") {
    Write-Output "Error: Only Modrinth supported"
    exit
}

try {
    # Search for mod
    $searchUrl = "https://api.modrinth.com/v2/search?query=$([uri]::EscapeDataString($ModName))"
    $search = Invoke-RestMethod -Uri $searchUrl -Method Get

    if ($search.hits.Count -eq 0) {
        Write-Output "Error: Mod not found"
        exit
    }

    $projectId = $search.hits[0].project_id

    # Get versions
    $versionsUrl = "https://api.modrinth.com/v2/project/$projectId/version"
    $versions = Invoke-RestMethod -Uri $versionsUrl -Method Get

    # Filter by MC version
    $compatible = $versions | Where-Object { $_.game_versions -contains $MCVersion }

    if ($compatible.Count -eq 0) {
        Write-Output "Error: No versions match Minecraft $MCVersion"
        exit
    }

    # If loader not chosen yet, return loader list
    if (-not $Loader) {
        $loaderList = ($compatible.loaders | Select-Object -Unique)
        Write-Output ($loaderList -join ",")
        exit
    }

    # Filter by loader
    $loaderMatch = $compatible | Where-Object { $_.loaders -contains $Loader }

    if ($loaderMatch.Count -eq 0) {
        Write-Output "Error: No versions available for loader $Loader"
        exit
    }

    # Select newest version
    $newest = $loaderMatch[0]
    $file = $newest.files[0]

    # Download file
    $downloadUrl = $file.url
    $filename = $file.filename
    $outputPath = Join-Path $OutputDir $filename

    Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath -UseBasicParsing

    Write-Output "$ModName saved"

} catch {
    Write-Output "Error: $($_.Exception.Message)"
}