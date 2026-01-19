param(
    [string]$ModName,
    [string]$MCVersion,
    [string]$Loader,
    [string]$OutputDir
)

function Get-ModrinthJson($url) {
    try {
        return Invoke-RestMethod -Uri $url -Method Get
    } catch {
        Write-Output "Error: Failed to fetch $url"
        exit
    }
}

# Search for mod
$searchUrl = "https://api.modrinth.com/v2/search?query=$([uri]::EscapeDataString($ModName))"
$search = Get-ModrinthJson $searchUrl

if ($search.hits.Count -eq 0) {
    Write-Output "Error: Mod '$ModName' not found"
    exit
}

$projectId = $search.hits[0].project_id

# Get versions
$versionsUrl = "https://api.modrinth.com/v2/project/$projectId/version"
$versions = Get-ModrinthJson $versionsUrl

# Filter by MC version + loader
$compatible = $versions | Where-Object {
    $_.game_versions -contains $MCVersion -and
    $_.loaders -contains $Loader
}

if ($compatible.Count -eq 0) {
    Write-Output "Error: No compatible versions found"
    exit
}

# Use newest version
$version = $compatible[0]

# Extract required dependencies
$required = @()

foreach ($dep in $version.dependencies) {
    if ($dep.dependency_type -eq "required") {
        $required += $dep.project_id
    }
}

if ($required.Count -eq 0) {
    Write-Output "No required dependencies found"
    exit
}

# Resolve dependency names and prompt user
foreach ($depId in $required) {

    $depUrl = "https://api.modrinth.com/v2/project/$depId"
    $depInfo = Get-ModrinthJson $depUrl

    $depName = $depInfo.title

    Write-Host ""
    Write-Host "This mod requires '$depName'. Install it? (y/n)"
    $choice = Read-Host

    if ($choice -eq "y") {
        Write-Host "Installing $depName..."
        powershell -ExecutionPolicy Bypass -File "$PSScriptRoot\api.ps1" modrinth "$depName" "$MCVersion" "$Loader" "$OutputDir"
    } else {
        Write-Host "Skipping $depName"
    }
}

Write-Output "Dependency check complete."