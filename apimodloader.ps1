param(
    [string]$Loader,
    [string]$MCVersion,
    [string]$MCDir
)

# Normalize directory
$MCDir = $MCDir.Trim('"')

if (-not (Test-Path $MCDir)) {
    Write-Host "Directory does not exist: $MCDir"
    exit 1
}

function Ensure-Folder {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

Ensure-Folder (Join-Path $MCDir "versions")

# ------------------------------
# PURE INSTALLERS (NO LAUNCHER EDITING)
# ------------------------------

function Install-Fabric {
    $meta = Invoke-RestMethod "https://meta.fabricmc.net/v2/versions/loader/$MCVersion"
    $entry = $meta[0]

    $loaderVer = $entry.loader.version
    $interVer  = $entry.intermediary.version

    $versionId = "fabric-loader-$MCVersion-$loaderVer"
    $versionDir = Join-Path $MCDir "versions\$versionId"
    Ensure-Folder $versionDir

    $jsonUrl = "https://meta.fabricmc.net/v2/versions/loader/$MCVersion/$loaderVer/profile/json"
    $jarUrl  = "https://meta.fabricmc.net/v2/versions/loader/$MCVersion/$loaderVer/$interVer/server/jar"

    Invoke-WebRequest $jsonUrl -OutFile (Join-Path $versionDir "$versionId.json")
    Invoke-WebRequest $jarUrl  -OutFile (Join-Path $versionDir "$versionId.jar")

    Write-Host "$versionId installed."
}

function Install-Quilt {
    $meta = Invoke-RestMethod "https://meta.quiltmc.org/v3/versions/loader/$MCVersion"
    $entry = $meta[0]

    $loaderVer = $entry.loader.version
    $interVer  = $entry.intermediary.version

    $versionId = "quilt-loader-$MCVersion-$loaderVer"
    $versionDir = Join-Path $MCDir "versions\$versionId"
    Ensure-Folder $versionDir

    # Quilt server JAR URL (correct format)
    $jsonUrl = "https://meta.quiltmc.org/v3/versions/loader/$MCVersion/$loaderVer/profile/json"
    $jarUrl  = "https://meta.quiltmc.org/v3/versions/loader/$MCVersion/$loaderVer/$interVer/server/jar"

    Invoke-WebRequest $jsonUrl -OutFile (Join-Path $versionDir "$versionId.json")
    Invoke-WebRequest $jarUrl  -OutFile (Join-Path $versionDir "$versionId.jar")

    Write-Host "$versionId installed."
}

function Install-NeoForge {
    $metaXml = Invoke-WebRequest "https://maven.neoforged.net/releases/net/neoforged/neoforge/maven-metadata.xml" -UseBasicParsing
    [xml]$xml = $metaXml.Content
    $latest = $xml.metadata.versioning.latest

    $versionId = "neoforge-$MCVersion-$latest"
    $versionDir = Join-Path $MCDir "versions\$versionId"
    Ensure-Folder $versionDir

    $base = "https://maven.neoforged.net/releases/net/neoforged/neoforge/$latest"
    $jsonUrl = "$base/neoforge-$latest.json"
    $jarUrl  = "$base/neoforge-$latest-client.jar"

    Invoke-WebRequest $jsonUrl -OutFile (Join-Path $versionDir "$versionId.json")
    Invoke-WebRequest $jarUrl  -OutFile (Join-Path $versionDir "$versionId.jar")

    Write-Host "$versionId installed."
}

function Install-Forge {
    $promo = Invoke-RestMethod "https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json"

    $keyLatest = "$MCVersion-latest"
    $keyRec    = "$MCVersion-recommended"

    $forgeVer = $promo.promos.$keyRec
    if (-not $forgeVer) { $forgeVer = $promo.promos.$keyLatest }

    $fullVer = "$MCVersion-$forgeVer"
    $versionId = "forge-$fullVer"
    $versionDir = Join-Path $MCDir "versions\$versionId"
    Ensure-Folder $versionDir

    $base = "https://maven.minecraftforge.net/net/minecraftforge/forge/$fullVer"
    $jsonUrl = "$base/forge-$fullVer.json"
    $jarUrl  = "$base/forge-$fullVer-client.jar"

    Invoke-WebRequest $jsonUrl -OutFile (Join-Path $versionDir "$versionId.json")
    Invoke-WebRequest $jarUrl  -OutFile (Join-Path $versionDir "$versionId.jar")

    Write-Host "$versionId installed."
}

# ------------------------------
# MAIN SWITCH
# ------------------------------
switch ($Loader.ToLower()) {
    "fabric"   { Install-Fabric }
    "quilt"    { Install-Quilt }
    "neoforge" { Install-NeoForge }
    "forge"    { Install-Forge }
    default    { Write-Host "Unknown loader: $Loader" }
}

Write-Host "Done."