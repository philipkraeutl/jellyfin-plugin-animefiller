# Anime Filler Marker for Jellyfin

Anime Filler Marker adds visible prefixes to anime episode titles using data from
[animefillerlist.com](https://www.animefillerlist.com):

- pure filler episodes receive `[F]`;
- mixed canon/filler episodes optionally receive `[C/F]`;
- disabling both options removes previously added markers on the next run.

This repository is a maintained fork of
[Staubgeborener/jellyfin-plugin-animefiller](https://github.com/Staubgeborener/jellyfin-plugin-animefiller).
It keeps the original plugin identity so existing installations can be moved to this
repository feed. Do not configure both repository feeds at the same time.

Unlike badge-only solutions, the marker is part of the episode title and is therefore
also visible in Jellyfin clients that do not display custom badges.

## Compatibility

| Jellyfin Server | Runtime | Package |
|---|---|---|
| 12.x | .NET 10 | `animefiller-jellyfin12_<version>.zip` |
| 10.11.x | .NET 9 | `animefiller_<version>.zip` |

Both variants are built from the same source. Jellyfin selects the correct download
from the repository manifest using `targetAbi`.

## Installation

Add this repository URL under **Dashboard → Plugins → Repositories**:

```text
https://raw.githubusercontent.com/philipkraeutl/jellyfin-plugin-animefiller/main/manifest.json
```

Open the plugin catalog, install **Anime Filler Marker**, and restart Jellyfin.

For a manual installation, download the ZIP matching your Jellyfin version from the
GitHub release and extract both DLL files into an `Anime Filler Marker` directory
inside Jellyfin's plugin directory. Restart Jellyfin afterwards.

Common plugin directories:

- Windows service: `C:\ProgramData\Jellyfin\Server\plugins`
- Windows user installation: `%LOCALAPPDATA%\jellyfin\plugins`
- Linux packages: `/var/lib/jellyfin/plugins`
- Docker: `/config/plugins`

## Settings and use

Open **Dashboard → Plugins → Anime Filler Marker → Settings**.

| Setting | Default | Description |
|---|---:|---|
| Mark filler episodes | on | Prepends `[F]` to pure filler episodes |
| Mark mixed episodes | on | Prepends `[C/F]` to mixed canon/filler episodes |

The scheduled task runs daily at 03:00. It can also be started manually under
**Dashboard → Scheduled Tasks → Anime Filler Marker**.

The task changes episode titles in Jellyfin metadata. Before installing a third-party
plugin, back up the Jellyfin data directory. Disable both settings and run the task
once if you want to remove its markers before uninstalling.

## Building

Jellyfin 12 requires the .NET 10 SDK:

```powershell
dotnet restore Jellyfin.Plugin.AnimeFiller/Jellyfin.Plugin.AnimeFiller.csproj
dotnet build Jellyfin.Plugin.AnimeFiller/Jellyfin.Plugin.AnimeFiller.csproj -c Release
./scripts/package.ps1 -Version 1.1.0.0 -Framework net10.0 -JellyfinVersion 12.0.0 -PackageSuffix -jellyfin12
```

To build the Jellyfin 10.11 variant, use .NET 9 and run:

```powershell
./scripts/package.ps1 -Version 1.1.0.0 -Framework net9.0 -JellyfinVersion 10.11.0
```

Packages and SHA-256 checksum files are written to `artifacts/`.

## Automated releases

The build workflow verifies Jellyfin 10.11/.NET 9 and Jellyfin 12/.NET 10 on every
push and pull request.

A release can be started in either way:

1. Push a four-part version tag such as `v1.1.0.0`.
2. Open **Actions → Release plugin → Run workflow** and enter `1.1.0.0`.

The release workflow:

1. builds separate packages for Jellyfin 10.11 and 12;
2. creates SHA-256 checksum files;
3. creates the GitHub release and uploads both variants;
4. updates `manifest.json`, `build.yaml`, and the project version;
5. commits the updated release metadata to the default branch.

The workflow uses the repository's automatically supplied `GITHUB_TOKEN`; no personal
access token is required. The repository must allow GitHub Actions to write repository
contents under **Settings → Actions → General → Workflow permissions**.

## How matching works

The task downloads and caches the show index and episode classifications from
animefillerlist.com for 24 hours. It first matches a Jellyfin series by normalized
name. Episode numbers are converted to absolute numbers across regular seasons;
episode-title matching is used as a fallback for incomplete libraries. Specials in
season 0 are excluded from absolute numbering.

## License

This fork follows the licensing terms of the upstream project and its dependencies.
