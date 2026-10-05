# Skills of Ashenfall: Historian

Historian is a RuneScape: Dragonwilds skill mod from Extra Special Studio, and the first Skills of Ashenfall mod. It is a full skill on the game's own screens: the character select grid and total level, the skills menu tile, detail panel and perk list, and the game's level-up banner and XP popup, all with the Historian badge. Historian never unlocks, gates or changes a vanilla skill.

## v1.0.0

Levels 1–25 (3,152 XP). Historian XP comes from the knowledge entries in the game's journal:

- The 20 starting-valley entries pay: 16 lore scraps, the Bramblemead Valley and Temple Woods place records, and two of Cathan's journals. Each has a fixed amount and pays once, when the game files it, in any order.
- Finishing a set and owning two entries that answer each other (a correlation) pay on top, and a correlation files a short note on what the two pages share. The reconstruction, the fall of Bramblemead, needs any 18 of the 20 entries and a visit to the ruins of Bramblemead village; a card tells you when to go. It always ends exactly on level 25: it tops up to 3,152 XP, and the cap stops anything beyond it.
- Perks at every level from 2 to 25, in the game's perk list:
  - **Minor rows:** +0.5% Historian XP each, with the running total in the middle panel.
  - **Nose in a Book (3):** a card when new history reaches your journal.
  - **Dog-Eared Pages (6):** unread history counted on F7.
  - **Footnotes (10):** how much of a set is still missing.
  - **He Said, She Said (14):** which page disputes the one you just found.
  - **Primary Sources (19):** Cathan's journals pay 25% more.
  - **Peer Reviewed (25):** the Historian 25 requirement other Skills of Ashenfall mods check.
  - Perk names, correlation notes and card wording are fan-written mod lore, not Jagex canon. The lore entries themselves are the game's own.
- Entries from later regions are remembered and pay when their band opens in a later version. Tutorials pay nothing.
- Characters made before the mod are credited for the entries they already have the first time they load, with one card saying what was found. A new character gets a short card explaining the skill instead.
- Saves from an earlier test build are rebuilt once from the journal; old XP amounts are not carried over.

Progress is saved per character, by the character's id from the game save, in `%LOCALAPPDATA%\RSDragonwilds\Saved\ESLDragonWilds\`, beside the game's own saved data, so updating or reinstalling the mod keeps it. The game's own save files are only read, never written.

If the installed game is a different Steam build from the one Historian was tested on (25632050), one card says so; it shows once per build.

Later versions extend Historian towards level 99 as new regions open.

## Keys and settings

- **F7** opens the ledger: level and XP, records filed, each set's progress, the correlations and reconstruction, what to look for next, and entries kept for later regions. From level 6 it also counts your unread history.

`SkillsOfAshenfallHistorian\config.txt` is created on first run:

```
ledger_key=F7
quiet=false
debug=false
```

`ledger_key` takes any UE4SS key name (F1 to F12, HOME, END and so on). `quiet=true` turns off Historian's cards and keeps only the game's own XP popups and level-up banner. `debug=true` adds detail to the UE4SS log.

Developer keys load only with a `dev.txt` file next to the `Scripts` folder, and are not part of normal play: F8 grants the next unpaid starting-valley entry, F5 logs your position, F9 selects Historian in the open skills menu, F11 plays every Historian notification, F6 writes widget dumps to the log, and Bed Rolls show a Historian 5 requirement.

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

## Not affiliated

Skills of Ashenfall is a fan project by Extra Special Studio. It is not affiliated with, endorsed by, or sponsored by Jagex Ltd. RuneScape and RuneScape: Dragonwilds are trademarks of Jagex Ltd.
