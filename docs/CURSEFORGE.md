# CurseForge page draft: Skills of Ashenfall: Historian

Draft text for the CurseForge project page. No project exists yet; links are added only once real URLs exist.

## Project

- **Name:** Skills of Ashenfall: Historian
- **Summary (one line):** A new skill: piece together the history of Ashenfall from what its people left behind.
- **Category:** Gameplay
- **Game version:** Steam build 25632050
- **Licence:** see LICENSE in the zip

## Description

Historian is a new skill for RuneScape: Dragonwilds, levels 1 to 25, and the first Skills of Ashenfall mod from Extra Special Studio. It sits on the game's own screens like any vanilla skill: the character select grid and total level, the skills menu tile, detail panel and perk list, and the game's level-up banner and XP popup, all with the Historian badge.

**How it trains.** Historian XP comes from the knowledge entries your journal files: lore scraps, place records and Cathan's journals in the starting valley. Each pays once, in any order. Completing a set, or owning two pages that answer each other, pays on top. The last step, the fall of Bramblemead, needs 18 of the 20 entries and a visit to the ruins of Bramblemead village, and takes you exactly to level 25.

**Perks at every level.** Small XP bonuses on most rows, plus Nose in a Book (3), Dog-Eared Pages (6), Footnotes (10), He Said, She Said (14), Primary Sources (19) and Peer Reviewed (25).

**Existing characters** are credited for what their journal already holds the first time they load, with one card that says what was found.

**Ledger.** F7 shows your level, sets, correlations, what to look for next and, from level 6, your unread history. `config.txt` (written on first run) changes the key or turns Historian's own cards off.

Historian never unlocks, gates or changes a vanilla skill. The game's own save files are only read.

### Install

1. Install UE4SS for RuneScape: Dragonwilds (3.0.1, the "UE4SS Steam (latest)" build).
2. Install ESL:DragonWilds (Required Dependency; the CurseForge app installs it for you).
3. Install Historian. Both folders sit side by side in `RSDragonwilds\Content\Paks\~mods` and ship with `enabled.txt`.

To uninstall, remove Historian in the CurseForge app (or delete its folder). Your progress stays in `%LOCALAPPDATA%\RSDragonwilds\Saved\ESLDragonWilds` in case you come back; the game's own saves are never changed.

## Relations

- **Required Dependency:** ESL:DragonWilds 1.0.0 or later.
- **Not on CurseForge:** UE4SS for RuneScape: Dragonwilds (see Install).
- **Used by:** Skills of Ashenfall: Horticulture (needs Historian 25).

## Lore and affiliation

**MOD LORE.** The lore entries Historian pays for are the game's own. Perk names, correlation notes and card wording are fan-written for this mod, not Jagex canon.

Skills of Ashenfall is a fan project by Extra Special Studio. It is not affiliated with, endorsed by, or sponsored by Jagex Ltd. RuneScape and RuneScape: Dragonwilds are trademarks of Jagex Ltd.

## Screenshots

From `<studio>\docs\screenshots\release-1.0.0\`, taken on the release install (vanilla skills plus Historian only, no dev tools showing):

1. `historian-character-select.png`: Historian 12/25 on the character select grid, total level 126 on both sides.
2. `historian-skills-detail.png`: the skills menu with the Historian tile selected: level 12, 693/736 XP, +4% Historian XP, perks 9 to 12 reached and 13 onward locked.
3. `historian-perk-footnotes.png`: the game's own tooltip for the Footnotes perk (level 10).
4. `historian-skills-perks-later.png`: the later perk rows up to Peer Reviewed at 25.
5. `historian-ledger-f7.png`: the F7 ledger over the world.

From `test-session-2026-10-05\`: `83-l6-card-09.png`, a Historian card over the world.

Not captured: the game's level-up banner and XP popup with the Historian badge (they need a real Historian gain on the release character; the same banner with the Horticulture badge is in Horticulture's `horticulture-level-up-badge.png`).
