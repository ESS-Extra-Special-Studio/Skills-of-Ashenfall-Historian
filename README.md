# Skills of Ashenfall: Historian

Historian is a RuneScape: Dragonwilds skill mod from Extra Special Studio. It is the first Skills of Ashenfall mod. This repository is that mod, not a disposable test project.

Design and research live on the Desktop, not in this repo:

`<user>\<studio>\DRAGONWILDS_MASTER.md`

## Current build

The mod logs one line when UE4SS loads it:

`[Skills of Ashenfall: Historian] Loaded`

XP, levels, and the journal are not in this build. They wait on the native skill research notes.

## Requirements

- RuneScape: Dragonwilds, Steam
- UE4SS for this game. The build this machine is aiming at is 3.0.1 Git SHA `f6d5f942` (Nexus file "UE4SS Steam (latest)"). See the Desktop environment note for the build that is actually installed.

## Install

CurseForge installs Dragonwilds mods into the Steam game:

`RSDragonwilds\RSDragonwilds\Content\Paks\~mods`

Copy the `SkillsOfAshenfallHistorian` folder into that `~mods` directory. Leave any other mod folders there alone. The UE4SS loader has to be installed separately under `RSDragonwilds\Binaries\Win64`, and its settings need `+ModsFolderPaths` pointed at `~mods` so this folder is loaded. That is recorded in the Desktop environment note.

Launch the game and look in `Binaries\Win64\ue4ss\UE4SS.log` for the load line.

## Licence

See [LICENSE](LICENSE).
