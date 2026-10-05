# Changelog

## 1.0.0 (2026-10-05)

- Historian levels 1–25 from the game's journal knowledge entries in the starting valley, paid once per entry id from a fixed table, in any order. Four sets, four correlations and one reconstruction pay on top; everything together is exactly 3,152 XP. Tutorials pay nothing. Entries from later regions are remembered for later bands.
- Existing characters are credited for entries they already have, quietly, with one set of notifications. Saves from the earlier type-band build are rebuilt once by id.
- Shows on the character select grid and total level, and on the skills menu tile, detail panel and perk list.
- Uses the game's own level-up banner and XP popup, with the Historian badge. Historian never unlocks, gates or changes a vanilla skill.
- Progress is saved per character, keyed by the character's id in the game save, in `%LOCALAPPDATA%\RSDragonwilds\Saved\ESLDragonWilds` (via ESL:DragonWilds). A save from an earlier test build moves to the first character that loads.
- Character select adds every registered custom skill's level to both total-level numbers, the header and the character list, without counting twice on a redraw.
- Transparent badge, so no black box behind the icon.
- Perks at levels 2–25 (approved set; MOD LORE wording):
  - 18 minor rows of +0.5% Historian XP, with the running total in the skills menu's middle panel.
  - Majors: Nose in a Book (3), Dog-Eared Pages (6), Footnotes (10), He Said, She Said (14), Primary Sources (19) and Peer Reviewed (25, the Historian 25 gate).
  - The reconstruction tops up to the 3,152 cap, so finishing the valley ends exactly on level 25 in any order. The perk bonuses are not trimmed to make this work.
- The reconstruction needs any 18 of the 20 valley entries, then a visit to the ruins of Bramblemead village, announced by a card.
- Each correlation files a short note on what its two pages share, after the game's lore popup closes.
- A first-run card for new characters; a catch-up card for existing ones, saying what was credited from the journal. A one-time card at Historian 25 instead of a plain announcement.
- F7 opens the ledger: records, set progress, correlations, the reconstruction, the next thing to look for, entries kept for later regions, and unread history from level 6.
- `config.txt` (created on first run): `ledger_key`, `quiet` (no cards) and `debug` (extra log detail).
- A one-time card when the Steam build differs from the tested build 25632050.
- A source that the 3,152 cap clamps to nothing is still recorded as paid, so it can never pay later.
- F8 (grant the next unpaid entry) and F5 (log your position) only load with `dev.txt`.
- `tools\package.ps1` builds the release zip from an allowlist of tracked files.
- Needs ESL:DragonWilds 1.0.0 or later and says so in the log if ESL is missing or older. The ESLDragonWilds mod now draws Historian on every screen; Historian only registers and awards XP.
- Registers as version 1.0.0 under the stable skill id `Historian`, so other mods can require a Historian level (`ESL.GetLevel(ESL.HISTORIAN)`, `{ skill = ESL.HISTORIAN, level = n }`) and check that Historian is installed (`ESL.Depends`).
