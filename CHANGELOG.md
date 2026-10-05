# Changelog

## 1.0.0 (unreleased)

- Historian levels 1–25 from the game's journal knowledge entries in the starting valley, paid once per entry id from a fixed table, in any order. Four sets, four correlations and one reconstruction pay on top; everything together is exactly 3,152 XP. Tutorials pay nothing. Entries from later regions are remembered for later bands.
- Existing characters are credited for entries they already have, quietly, with one set of notifications. Saves from the earlier type-band build are rebuilt once by id.
- Shows on the character select grid and total level, and on the skills menu tile, detail panel and perk list.
- Uses the game's own level-up banner and XP popup, with the Historian badge. Historian never unlocks, gates or changes a vanilla skill.
- Progress is saved per character. A save from an earlier test build moves to the first character that loads.
- Character select adds every registered custom skill's level to both total-level numbers, the header and the character list, without counting twice on a redraw.
- Transparent badge, so no black box behind the icon.
- Perks at levels 2–25 (approved set; MOD LORE wording):
  - 18 minor rows of +0.5% Historian XP, with the running total in the skills menu's middle panel.
  - Majors: Nose in a Book (3), Dog-Eared Pages (6), Footnotes (10), He Said, She Said (14), Primary Sources (19) and Peer Reviewed (25, the Historian 25 gate).
  - The reconstruction tops up to the 3,152 cap, so owning every entry ends exactly on level 25 in any order.
- F7 shows level and XP, and unread history from level 6. F8 (grant the next unpaid entry) only loads with `dev.txt`.
- Needs ESL:DragonWilds 1.1.0 or later and says so in the log if ESL is missing or older. The ESLDragonWilds mod now draws Historian on every screen; Historian only registers and awards XP.
- Registers as version 1.0.0 under the stable skill id `Historian`, so other mods can require a Historian level (`ESL.GetLevel(ESL.HISTORIAN)`, `{ skill = ESL.HISTORIAN, level = n }`) and check that Historian is installed (`ESL.Depends`).
