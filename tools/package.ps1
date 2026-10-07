# Builds the release zip for Skills of Ashenfall: Historian from an allowlist.
#
# Only files tracked by git AND matching $Allow are packed, so local files
# (config.txt, build-warned.txt, logs) can never ship; config.txt is
# written with defaults on first run. The zip holds one
# SkillsOfAshenfallHistorian folder, ready to drop into Content\Paks\~mods
# next to ESLDragonWilds. CurseForge only accepts .txt .lua .dll .pak .utoc
# .ucas in a Dragonwilds UE4SS mod: the docs ship as .txt copies and the
# badge ships cooked in SoAHistorian_P (the PNG stays in the repo as the
# source for DragonwildsAssets' cook).
#   powershell -File tools\package.ps1 -Version 1.0.0
param([Parameter(Mandatory = $true)][string]$Version)
$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo
$mod = 'SkillsOfAshenfallHistorian'

$Allow = @(
    "^$mod/enabled\.txt$",
    "^$mod/Scripts/[a-z_]+\.lua$",
    "^$mod/SoAHistorian_P\.(pak|utoc|ucas)$"
)
# Repo file -> name in the zip.
$Docs = [ordered]@{ 'README.md' = 'README.txt'; 'LICENSE' = 'LICENSE.txt'; 'CHANGELOG.md' = 'CHANGELOG.txt' }
$AllowedTypes = '\.(txt|lua|dll|pak|utoc|ucas)$'
$Never = '(^|/)(dev|debug|config|build-warned|progress)\.txt$|\.log$|\.tmp$'

$tracked = git ls-files
$files = $tracked | Where-Object { $f = $_; ($Allow | Where-Object { $f -match $_ }).Count -gt 0 }
$bad = $files | Where-Object { $_ -match $Never }
if ($bad) { throw "Refusing to pack: $($bad -join ', ')" }
foreach ($need in "$mod/enabled.txt", "$mod/Scripts/main.lua", "$mod/Scripts/sources.lua", "$mod/Scripts/historian_strings.lua",
    "$mod/SoAHistorian_P.pak", "$mod/SoAHistorian_P.utoc", "$mod/SoAHistorian_P.ucas") {
    if ($files -notcontains $need) { throw "Missing $need" }
}
$dirty = git status --porcelain -- $mod
if ($dirty) { Write-Warning "Uncommitted changes under $mod are packed as they are on disk:`n$dirty" }

$stage = Join-Path $repo "dist\stage-$Version"
if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
foreach ($f in $files) {
    $to = Join-Path $stage $f
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $to) | Out-Null
    Copy-Item -LiteralPath (Join-Path $repo $f) -Destination $to
}
foreach ($d in $Docs.Keys) { Copy-Item -LiteralPath (Join-Path $repo $d) -Destination (Join-Path $stage "$mod\$($Docs[$d])") }
$wrongType = Get-ChildItem -LiteralPath $stage -Recurse -File -Force | Where-Object { $_.Name -notmatch $AllowedTypes }
if ($wrongType) { throw "Refusing to pack file types CurseForge rejects: $(($wrongType | ForEach-Object Name) -join ', ')" }

$zip = Join-Path $repo "dist\$mod-$Version.zip"
if (Test-Path $zip) { Remove-Item -Force $zip }
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
$archive = [IO.Compression.ZipFile]::Open($zip, 'Create')
try {
    # Forward slashes in entry names, so every unzip tool keeps the folders.
    Get-ChildItem -LiteralPath $stage -Recurse -File -Force | ForEach-Object {
        $name = $_.FullName.Substring($stage.Length + 1).Replace('\', '/')
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $_.FullName, $name) | Out-Null
    }
} finally { $archive.Dispose() }
Remove-Item -Recurse -Force $stage
$check = [IO.Compression.ZipFile]::OpenRead($zip)
try { $bad = @($check.Entries | Where-Object { $_.Name -and $_.Name -notmatch $AllowedTypes } | ForEach-Object FullName) } finally { $check.Dispose() }
if ($bad) { Remove-Item -Force $zip; throw "Zip removed, it held file types CurseForge rejects: $($bad -join ', ')" }
Write-Output "Packed $($files.Count + $Docs.Count) files into $zip"
