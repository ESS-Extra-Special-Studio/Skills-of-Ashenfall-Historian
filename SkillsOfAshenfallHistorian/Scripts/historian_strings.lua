-- Every player-facing Historian string, in one table so a translation only
-- replaces this file. Journal entry titles are the game's own (read from the
-- journal at runtime); the labels in sources.lua are only their fallbacks.
-- Perk names, perk wording and correlation notes are MOD LORE.
local S = {}

S.SKILL_NAME = "Historian"
S.MOD_NAME = "Skills of Ashenfall: Historian"
S.MAX_LEVEL_TEXT = "Historian 25: Bramblemead's past, pieced together"
S.FLAVOUR = "Piece together the history of Ashenfall from what its people left behind."
S.LEVEL_UP_TEXT = "Find lore scraps, journals and place records to gain Historian XP."
S.PANEL_LABEL = "Progress to next level"
S.TRAINING_TEXT = "Find lore scraps, journals and place records; each one your journal files, and each set or contradiction you complete, levels this skill."
S.PERK_SUMMARY_LABEL = "Historian XP"

S.TYPE = {
    scrap = "Lore scrap",
    place = "Place record",
    people = "Account",
    story = "Story page",
    cathan = "Cathan's journal",
}
-- Inside a sentence ("1 lore scrap"); Cathan keeps his capital.
S.TYPE_ONE = {
    scrap = "lore scrap",
    place = "place record",
    people = "account",
    story = "story page",
    cathan = "Cathan's journal",
}
S.TYPE_PLURAL = {
    scrap = "lore scraps",
    place = "place records",
    people = "accounts",
    story = "story pages",
    cathan = "Cathan's journals",
}
S.KIND = {
    series = "Set complete",
    correlation = "Correlation",
    reconstruction = "Reconstruction",
    investigation = "Investigation",
}

-- Perks, levels 2-25 (approved 2026-10-05).
S.PERKS = {
    [3] = { "Nose in a Book", "Picking up a new piece of history tells you it's waiting in your journal." },
    [6] = { "Dog-Eared Pages", "Your Historian ledger now counts the unread history in your journal, by kind." },
    [10] = { "Footnotes", "Finding part of a set now tells you how much of it is still missing." },
    [14] = { "He Said, She Said", "When a page you find is contradicted elsewhere, you learn which page to look for." },
    [19] = { "Primary Sources", "Cathan's journals grant 25% more Historian XP. He did go to a lot of trouble." },
    [25] = { "Peer Reviewed", "Other scholars now take your notes seriously. Opens doors that ask for a Historian." },
}
S.MINOR_PERK = { "+0.5% Historian XP", "All Historian XP is increased by a further 0.5%." }

-- Journal notes (Nose in a Book, Footnotes, He Said She Said).
S.NOTE_KICKER = "FILED IN YOUR JOURNAL"
S.NOTE_SET = "%s: %d of %d"
S.NOTE_DISPUTED = "Disputed by: %s"
S.NOTE_MORE = "and %d more"
S.SEP = "  ·  "

-- Correlation notes: what the two pages say together. 1-3 sentences, in the
-- journal-narrator voice of docs/LORE_VOICE_GUIDE.md, drawn from the game's
-- own text for both entries (build 25632050).
S.CORRELATION_KICKER = "CORRELATION"
S.CORRELATION_NOTES = {
    ["correlation:dragon_attack_sides"] = "A goblin who watched a dragon land on his chieftain could not work out why dragons would fight for the beastmen. A priest hiding under broken timber, writing in his own blood, had already seen why: the moon goddess was riding one.",
    ["correlation:abandoned_village"] = "The new priest found a village abandoned by its old god and eager for a new one. The village's own page explains the abandonment: Guthix left, sickened by what his people had done to the Amalgamated. The priest does not appear to have asked.",
    ["correlation:goblin_alliance"] = "One settler shared a winter fire with a goblin called Globfinger and decided goblins weren't so bad. A few weeks later, a priest of the same alliance still called them horrible little creatures. Same war; the difference seems to have been dinner.",
    ["correlation:velgar_chant"] = "The goblins chose Velgar on sound theological grounds: he beat their last god. Cathan, studying goblin faith from inside a goblin cell, concluded that anyone set on beating Velgar could recruit the congregation. It seems to have worked; he left with goblins of his own.",
}

-- Site visit for a band's reconstruction.
S.SITE_KICKER = "THE EVIDENCE IS COMPLETE"
S.SITE_TITLE = "%s"
S.SITE_CARD = "Take it to %s to piece the story together."
S.SITE_DETAIL = "take the evidence to %s to piece the story together"
S.SITE_DONE_KICKER = "RECONSTRUCTED ON SITE"

-- First run and catch-up, one card per character.
S.CEREMONY_KICKER = "HISTORIAN"
S.CEREMONY_CAUGHT_UP = "Your journal already held %d records"
S.CEREMONY_CAUGHT_UP_DETAIL = "Read with a historian's eye, that makes you level %d. Press %s for your ledger."
S.CEREMONY_FIRST = "A new skill: Historian"
S.CEREMONY_FIRST_DETAIL = "Every lore scrap, journal and place record you find now teaches you history. Press %s for your ledger."

-- Ledger (status panel).
S.LEDGER_TITLE = "Ledger: %s (levels %s)"
S.LEDGER_RECORDS = "Records filed: %d of %d"
S.LEDGER_SETS = "Sets:"
S.LEDGER_SET_ITEM = "%s %d/%d"
S.LEDGER_SET_DONE = "%s done"
S.LEDGER_CORRELATIONS = "Correlations found: %d of %d"
S.LEDGER_RECONSTRUCTION = "Reconstruction: %d of %d records needed"
S.LEDGER_RECONSTRUCTION_SITE = "Reconstruction: evidence complete, take it to %s"
S.LEDGER_RECONSTRUCTION_DONE = "Reconstruction: %s, done"
S.LEDGER_NEXT = "Next: %s"
S.LEDGER_NEXT_SET = "finish %s (%d to find)"
S.LEDGER_NEXT_CORRELATION = "find %s, which disputes a page you have"
S.LEDGER_NEXT_RECONSTRUCTION = "%d more records for %s"
S.LEDGER_NEXT_DONE = "more of Ashenfall's history arrives in a later version"
S.LEDGER_KEPT = "Kept for later: %d records from %s"
S.LEDGER_UNREAD = "Unread history: %s"
S.LEDGER_UNREAD_NONE = "Unread history: none"

-- Setup messages.
S.BUILD_KICKER = "MOD SETUP"
S.BUILD_TITLE = "Untested game build"
S.BUILD_DETAIL = "Historian was tested on game build %s; this is build %s. If something looks wrong, check for a Historian update."

S.LOG_WORLD_FIRST = "Load into a world first"

return S
