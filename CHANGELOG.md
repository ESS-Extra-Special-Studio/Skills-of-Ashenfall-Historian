# Changelog

## 1.0.0 (2026-10-05)

The first release. Needs ESL:DragonWilds 1.0.0.

### Features

- Historian, levels 1 to 25 (3,152 XP), trained from the knowledge entries in your journal.
- The 20 starting-valley entries each pay once, in any order: lore scraps, place records and Cathan's journals. Tutorials pay nothing.
- Four sets and four correlations (two pages that answer each other) pay on top. Each correlation files a short note on what the two pages say together, once the game's lore popup closes.
- The fall of Bramblemead: once you have 18 of the 20 entries, a card sends you to the ruins of Bramblemead village. Finishing it always lands you on level 25.
- Entries from later regions are remembered and pay when their part of Historian opens in a later version.
- A perk at every level from 2 to 25. Eighteen of them add 0.5% Historian XP each, and the running total shows in the skills menu. The rest are Nose in a Book (3), Dog-Eared Pages (6), Footnotes (10), He Said, She Said (14), Primary Sources (19) and Peer Reviewed (25, the Historian 25 requirement other mods check).
- Historian shows on the character select grid and in the total level, and has its own tile, detail panel and perk list in the skills menu. It uses the game's own level-up banner and XP popup, with the Historian badge.
- Characters made before the mod are credited for what their journal already holds, with one card saying what was found. New characters get a short card explaining the skill instead.
- F7 opens the ledger: records filed, set progress, correlations, the reconstruction, what to look for next and entries kept for later. From level 6 it also counts your unread history.
- `config.txt` is written on first run: `ledger_key`, `quiet` (no Historian cards) and `debug` (more detail in the log).
- A one-time card if your game build differs from the one Historian was tested on (25632050).
- Historian never unlocks, gates or changes a vanilla skill, and only ever reads the game's own saves.

### Changes

- Saves from the earlier test build are rebuilt once from the journal. Old XP amounts are not carried over.

### Fixes

- The Historian badge no longer goes missing on character select.

### Technical notes

- Skill id `Historian`, version 1.0.0. Other mods can require it with `ESL.Depends(ESL.HISTORIAN, "1.0.0", ...)`, read it with `ESL.GetLevel(ESL.HISTORIAN)`, or gate on `{ skill = ESL.HISTORIAN, level = n }`.
- Progress is saved per character, by the character's id from the game save, in `%LOCALAPPDATA%\RSDragonwilds\Saved\ESLDragonWilds`.
- An entry is paid once by its id, from a fixed table. An entry the 3,152 cap clamps to nothing still counts as paid, so it can never pay later.
- Developer keys (F8, F5, F9, F11, F6) only load when a `dev.txt` sits next to the `Scripts` folder.
- `tools\package.ps1` builds the release zip from a list of tracked files.
