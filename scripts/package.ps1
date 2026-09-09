param(
    [Parameter(Mandatory = $true)][string]$Version,
    [Parameter(Mandatory = $true)][string]$Framework,
    [Parameter(Mandatory = $true)][string]$JellyfinVersion,
    [string]$PackageSuffix = "",
    [string]$DotnetCommand = "dotnet"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$project = Join-Path $root "Jellyfin.Plugin.AnimeFiller/Jellyfin.Plugin.AnimeFiller.csproj"
$publishDir = Join-Path $root "artifacts/publish-$Framework-$JellyfinVersion"
$artifactsDir = Join-Path $root "artifacts"
$packageName = "animefiller$PackageSuffix`_$Version.zip"
$archive = Join-Path $artifactsDir $packageName

New-Item -ItemType Directory -Force -Path $artifactsDir | Out-Null
& $DotnetCommand restore $project --configfile (Join-Path $root "nuget.config") `
    -p:JellyfinTargetFramework=$Framework `
    -p:JellyfinVersion=$JellyfinVersion
if ($LASTEXITCODE -ne 0) { throw "dotnet restore failed with exit code $LASTEXITCODE" }

& $DotnetCommand publish $project -c Release --no-restore -o $publishDir `
    -p:JellyfinTargetFramework=$Framework `
    -p:JellyfinVersion=$JellyfinVersion `
    -p:PluginVersion=$Version
if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed with exit code $LASTEXITCODE" }

$files = @(
    (Join-Path $publishDir "Jellyfin.Plugin.AnimeFiller.dll"),
    (Join-Path $publishDir "HtmlAgilityPack.dll")
)
foreach ($file in $files) {
    if (-not (Test-Path -LiteralPath $file)) { throw "Required artifact not found: $file" }
}

Compress-Archive -LiteralPath $files -DestinationPath $archive -Force
$sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $archive).Hash.ToLowerInvariant()
Set-Content -LiteralPath "$archive.sha256" -Value "$sha256  $packageName" -Encoding Ascii

Write-Host "Created: $archive"
Write-Host "Created: $archive.sha256"
