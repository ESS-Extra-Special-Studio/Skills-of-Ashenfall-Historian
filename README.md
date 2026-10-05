# Skills of Ashenfall: Historian

Historian is a RuneScape: Dragonwilds skill mod from Extra Special Studio, and the first Skills of Ashenfall mod. It is a full skill on the game's own screens: the character select grid and total level, the skills menu tile, detail panel and perk list, and the game's level-up banner and XP popup, all with the Historian badge. Historian never unlocks, gates or changes a vanilla skill.

Design and research live on the Desktop, not in this repo:

`<user>\<studio>\DRAGONWILDS_MASTER.md`

## v1.0.0

Levels 1–25 (3,152 XP). Historian XP comes from the knowledge entries in the game's journal:

- The 20 starting-valley entries pay: 16 lore scraps, the Bramblemead Valley and Temple Woods place records, and two of Cathan's journals. Each has a fixed amount and pays once, when the game files it, in any order.
- Finishing a set, owning two entries that answer each other (a correlation), and owning the whole valley record (the reconstruction) pay on top. Owning everything always ends exactly on level 25: the reconstruction tops up to 3,152 XP, and the cap stops anything beyond it.
- Perks at every level from 2 to 25, in the game's perk list:
  - **Minor rows:** +0.5% Historian XP each, with the running total in the middle panel.
  - **Nose in a Book (3):** a card when new history reaches your journal.
  - **Dog-Eared Pages (6):** unread history counted on F7.
  - **Footnotes (10):** how much of a set is still missing.
  - **He Said, She Said (14):** which page disputes the one you just found.
  - **Primary Sources (19):** Cathan's journals pay 25% more.
  - **Peer Reviewed (25):** the Historian 25 requirement other Skills of Ashenfall mods check.
  - Perk names and wording are fan-written mod lore, not Jagex canon.
- Entries from later regions are remembered and pay when their band opens in a later version. Tutorials pay nothing.
- Characters and worlds made before the mod are credited for the entries they already have, quietly, the first time they load.
- Saves from an earlier test build are rebuilt once from the journal; old XP amounts are not carried over.

Progress is saved per character in `ESLDragonWilds/Saves/<Character>.Historian.txt`. The game's own character save is never modified.

The 1–99 plan, the lore-book gates and the level 75 combat gates are in `<studio>\docs\HISTORIAN_1-99.md`. What appears on each game screen, with screenshots, is in `docs\SKILL_SURFACE_CHECKLIST.md`.

## Keys

- **F7** shows Historian's level and XP; from level 6 it also counts your unread history.

With a `dev.txt` file next to the `Scripts` folder, developer keys and test content also load: F8 grants the next unpaid starting-valley entry, F9 selects Historian in the open skills menu, F11 plays every Historian notification, F6 writes widget dumps to the log, and Bed Rolls show a Historian 5 requirement.

## Requirements

- RuneScape: Dragonwilds, Steam
- UE4SS for this game
- [ESL:DragonWilds](../ESL-DragonWilds) 1.1.0 or later, installed next to this mod. On CurseForge it is a Required Dependency.

## Install

CurseForge installs Dragonwilds mods into:

`RSDragonwilds\RSDragonwilds\Content\Paks\~mods`

Put the `ESLDragonWilds` and `SkillsOfAshenfallHistorian` folders side by side in that `~mods` directory. Both ship with `enabled.txt`. If you list mods in `~mods\mods.txt` instead, enable both:

```
ESLDragonWilds : 1
SkillsOfAshenfallHistorian : 1
```

The `ESLDragonWilds` mod draws Historian on the game's screens, so it must be enabled too. Launch the game and look in `Binaries\Win64\ue4ss\UE4SS.log` for:

`[Skills of Ashenfall: Historian] Loaded`

`[ESL:DragonWilds] Showing Historian 1.0.0`

## Building on Historian

Other mods can make Historian a prerequisite for their own skills. Historian's skill id is `"Historian"` (`ESL.HISTORIAN` in ESL:DragonWilds), it is version 1.0.0, and it trains to level 25 in this version.

```lua
ESL.Depends(ESL.HISTORIAN, "1.0.0", "My Skill")             -- clear message if Historian is missing
local level = ESL.GetLevel(ESL.HISTORIAN)                     -- the loaded character's Historian level
requires = { { skill = ESL.HISTORIAN, level = 25 }, ... }     -- in your RegisterSkill definition
```

List Skills of Ashenfall: Historian as a Required Dependency on your CurseForge page. The full guide and an example mod are in ESL:DragonWilds: `docs/ESL_API.md` and `examples/ExampleSkill`.

## Licence

See [LICENSE](LICENSE).
