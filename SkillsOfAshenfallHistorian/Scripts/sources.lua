-- Historian sources: the game's own knowledge entries, keyed by journal id.
-- Each id pays once, for the entry the game filed, whatever order it is read in.
-- Bands follow where build 25632050 places each entry in the world (see
-- docs/HISTORIAN_1-99.md). Only bands listed in Sources.OPEN pay; entries from
-- later bands are remembered and pay when their band opens.
-- Tutorials (JOURNAL_Know_Tutorials_*) are not history and pay nothing.
local Sources = {}

Sources.V1_CAP = 3152

-- Band number -> levels it covers and the total XP at its top level.
Sources.BANDS = {
    { levels = "1-25", top = 3152, region = "Bramblemead Valley" },
    { levels = "26-40", top = 14929, region = "Whispering Swamp and Bloodblight Swamp" },
    { levels = "41-60", top = 86998, region = "Fractured Plains, Stormtouched Highlands, Vaults, Fellhollow, Scorned Wilderness" },
    { levels = "61-80", top = 223122, region = "Dowdun Reach and the Umbral Sands" },
    { levels = "81-99", top = 1000000, region = "Dragonkin, the Withering, the Rising Dead, and the people of Ashenfall" },
}

Sources.OPEN = { [1] = true }

Sources.ENTRIES = {}
-- Ids in table order; band 1 order is the F8 test order.
Sources.ORDER = {}

local function add(band, kind, xp, rows)
    for _, row in ipairs(rows) do
        local id = "JOURNAL_Know_" .. row[1]
        Sources.ENTRIES[id] = { xp = xp, label = row[2], band = band, type = kind }
        Sources.ORDER[#Sources.ORDER + 1] = id
    end
end

-- Band 1, levels 1-25: Bramblemead Valley (Brynmoor). 20 entries, 1,148 XP.
-- Everything but the reconstruction pays at most 2,798 XP, even with every
-- perk, so level 25 always comes from the reconstruction. It needs 18 of the
-- 20 entries (two can be missed) and tops up to exactly 3,152 (level 25) in
-- any order; anything paid after it is clamped by the cap.
add(1, "place", 79, {
    { "Place_BramblemeadValley", "Bramblemead Valley" },
    { "Place_TempleWoods", "Temple Woods" },
})
add(1, "scrap", 45, {
    { "LoreScrap_A1", "Dust-Covered Diary" },
    { "LoreScrap_A2", "Bloodstained Journal" },
    { "LoreScrap_B1", "Grimy Parchment" },
    { "LoreScrap_B2", "Grubby Note" },
    { "LoreScrap_A3", "Priest's Journal" },
    { "LoreScrap_B3", "Weathered Diary" },
    { "LoreScrap_C2", "Druid's Memoirs" },
    { "LoreScrap_A4", "Scrawled Diary Page" },
    { "LoreScrap_B4", "Pungent Scribble" },
    { "LoreScrap_C3", "Soot-Stained Diary" },
    { "LoreScrap_A5", "Tear-Stained Journal" },
    { "LoreScrap_B5", "Muddy Scrawl" },
    { "LoreScrap_C4", "Ancient Journal Page" },
    { "LoreScrap_C5", "Forgotten Diary" },
    { "LoreScrap_CastleExtra1", "Servant's Secret Diary" },
    { "LoreScrap_CastleExtra2", "Duke's Diary" },
})
add(1, "cathan", 135, {
    { "CathanJournal_Vannaka", "Cathan's note" },
    { "CathanJournal_Castle", "Cathan's journal" },
})

-- Band 2, levels 26-40: the swamps. C1 and HltP share a cell with no region
-- marker, so they wait here rather than pay in v1.
add(2, "place", 400, {
    { "Place_WhisperingSwamp", "Whispering Swamp" },
    { "Place_BloodblightSwamp", "Bloodblight Swamp" },
})
add(2, "scrap", 300, {
    { "LoreScrap_D1", "Torn Journal Page" },
    { "LoreScrap_D2", "Garou Writings" },
    { "LoreScrap_D5", "Elder's Storybook Page" },
    { "LoreScrap_E1", "Dragonkin Journal Page" },
    { "LoreScrap_F1", "Bloodstained Page" },
    { "LoreScrap_F2", "Leaf-Scented Page" },
    { "LoreScrap_C1", "Preserved Diary" },
    { "LoreScrap_HltP", "Vault Hunter's Journal" },
})
add(2, "cathan", 600, {
    { "CathanJournal_Velgarslair", "Cathan's farewell" },
})

-- Band 3, levels 41-60: Fractured Plains, Stormtouched Highlands, the Vaults,
-- the Fellhollow story series and the Scorned Wilderness books.
add(3, "place", 1500, {
    { "Place_FracturedPlains", "Fractured Plains" },
    { "Place_StormtouchedHighlands", "Stormtouched Highlands" },
    { "Place_Vaults", "Vaults" },
})
add(3, "scrap", 1000, {
    { "LoreScrap_D3", "Scorched Journal" },
    { "LoreScrap_D4", "Leathery Parchment" },
    { "LoreScrap_E2", "Dragonkin Diary Page" },
    { "LoreScrap_E3", "Infused Journal" },
    { "LoreScrap_E4", "Dragonkin Notebook Page" },
})
add(3, "story", 1500, {
    { "DogDays", "Ritual of Purification" },
    { "Vault_Puzzle_1", "Lacrussa's Memoir" },
    { "Vault_Puzzle_2", "Rot-covered Journal" },
})
add(3, "scrap", 1500, {
    { "SW_LoreScrap_CriticalPath_Book1", "Anima-infused Tome" },
    { "SW_LoreScrap_CriticalPath_Book2", "Lavish Dragonkin Tome" },
    { "SW_LoreScrap_CriticalPath_Book3", "Flame-licked Journal" },
    { "SW_LoreScrap_CriticalPath_Book4", "Rasthin's Journal" },
    { "SW_LoreScrap_CriticalPath_Book5", "Scorched Tome" },
    { "SW_LoreScrap_CriticalPath_Book6", "Hate-filled Tome" },
})
add(3, "scrap", 1000, {
    { "SW_LoreScrap_Optional_Book1", "Confusing Notebook" },
    { "SW_LoreScrap_Optional_Book2", "Aviansie Tome" },
    { "SW_LoreScrap_Optional_Book3", "Damaged Journal" },
    { "SW_LoreScrap_PuzzleText", "Rasthin's Riddle of Faith" },
})
add(3, "story", 1000, {
    { "Dragonwolves_1", "Laboratory Note" },
    { "Dragonwolves_2", "Experiment Log" },
    { "Dragonwolves_3", "The Tale of the Ghost Wolves" },
    { "Zogres_1", "Farmer Fred's Journal" },
    { "Zogres_2", "Ulgo's Diary" },
    { "Zogres_3", "Captain Rainer's Journal" },
    { "Necromancer_And_The_Wolf_1", "Ravanna's First Journal" },
    { "Necromancer_And_The_Wolf_2", "Ravanna's Second Journal" },
    { "Necromancer_And_The_Wolf_3", "Ravanna's Third Journal" },
    { "Necromancer_And_The_Wolf_4", "Ravanna's Fourth Journal" },
    { "Necromancer_And_The_Wolf_5", "Ravanna's Fifth Journal" },
    { "Necromancer_And_The_Wolf_6", "Ravanna's Sixth Journal" },
    { "Necromancer_And_The_Wolf_7", "Ravanna's Seventh Journal" },
})

-- Band 4, levels 61-80: Dowdun Reach and the Umbral Sands.
add(4, "scrap", 1500, {
    { "DRLoreScrap_L1", "Badly Scrawled Note" },
    { "DRLoreScrap_L2", "Archmage's Note to Students" },
    { "DRLoreScrap_L3", "A Transport Network" },
    { "DRLoreScrap_L4", "Rasmodel's Diary" },
    { "DRLoreScrap_L5", "Alric's Journal" },
    { "DRLoreScrap_L6", "Quartermaster's Journal" },
    { "DRLoreScrap_L8", "The Gospel of Zamorak" },
    { "DRLoreScrap_L11", "Alric's Plan (Part 1)" },
    { "DRLoreScrap_L12", "Alric's Plan (Part 2)" },
    { "DRLoreScrap_L13", "A New Pestilence" },
    { "DRLoreScrap_L14", "An Acolyte's Guide to Demon Handling" },
    { "DRLoreScrap_L15", "Goblins of da Reach Unite!" },
    { "DRLoreScrap_L16", "A Report on the Withering" },
    { "DRLoreScrap_L17", "Hall of Heroes" },
})
add(4, "story", 2000, {
    { "UmS_FirstPeople_1", "Sand-worn Leather Tome" },
    { "UmS_FirstPeople_2", "Sun-scorched Recipe Book" },
    { "UmS_FirstPeople_3", "Chewed Doodle-Covered Journal" },
    { "UmS_FirstPeople_4", "Gold-plated Tome" },
    { "UmS_FirstPeople_5", "Ancient Text" },
    { "UmS_Kalphite_1", "Dragonkin Journal" },
    { "UmS_Kalphite_2", "Avisk's Musings" },
    { "UmS_Kalphite_3", "Entomologist's Journal" },
    { "UmS_Kalphite_4", "Avisk's Experiment Log" },
    { "UmS_Kalphite_5", "Bug Catcher's Diary" },
    { "UmS_KotHaar_1", "Dusty Tome" },
    { "UmS_KotHaar_2", "Obsidian-carved Book" },
    { "UmS_KotHaar_3", "Soot-stained Ledger" },
    { "UmS_KotHaar_4", "Partially-melted Journal" },
    { "UmS_KotHaar_5", "Sand-scoured Diary" },
    { "UmS_QoA_1", "Black-plated Tome" },
    { "UmS_QoA_2", "Child's Storybook" },
    { "UmS_QoA_3", "Dragonscorched Ledger" },
    { "UmS_QoA_4", "Everburning Book" },
    { "UmS_QoA_5", "Sand-weathered Book" },
    { "UmS_CampA_Task1_01", "Saga, verse 1" },
    { "UmS_CampA_Task1_02", "Saga, verse 2" },
    { "UmS_CampA_Task1_03", "Saga, verse 3" },
    { "UmS_CampA_Task1_04", "Saga, verse 4" },
    { "UmS_CampA_Task1_05", "Saga, verse 5" },
    { "UmS_CampA_Task1_06", "Saga, verse 6" },
    { "UmS_WolfandGoddess", "The Wolf and the Goddess" },
})

-- Band 5, levels 81-99.
add(5, "story", 5000, {
    { "The_Dragonkin_1", "Lacrussa's Journal" },
    { "The_Dragonkin_2", "Lacrussa's Notes" },
    { "The_Dragonkin_3", "Lacrussa's Ravings" },
    { "The_Dragonkin_4", "Lacrussa's Writings" },
    { "The_Dragonkin_5", "Lacrussa's Diary" },
    { "The_Withering_1", "Weathered Diary" },
    { "The_Withering_2", "Lazily-penned Diary" },
    { "The_Withering_3", "Dragon-embossed Journal" },
    { "The_Withering_4", "Battered Diary" },
    { "The_Withering_5", "Weathered Journal" },
    { "The_Withering_6", "Withered Diary" },
    { "The_Rising_Dead_1", "Mould-covered Journal" },
    { "The_Rising_Dead_2", "Withered Journal" },
    { "The_Rising_Dead_3", "Soot-stained Journal" },
    { "The_Rising_Dead_4", "Red-stained Diary" },
    { "The_Rising_Dead_5", "Priestly Journal" },
})
add(5, "place", 5000, {
    { "Place_DragonAltar", "Dragon Altar" },
})
add(5, "people", 3000, {
    { "People_Armadyl", "Armadyl" },
    { "People_Bandos", "Bandos" },
    { "People_Cathan", "Cathan" },
    { "People_Doric", "Doric" },
    { "People_Guthix", "Guthix" },
    { "People_Saradomin", "Saradomin" },
    { "People_Vannaka", "Vannaka" },
    { "People_WiseOldMan", "Wise Old Man" },
    { "People_Zamorak", "Zamorak" },
    { "People_Zanik", "Zanik" },
})

-- Filed under DeletedEntries in the build, so no player can get them. They
-- never pay; the plan does not count on them.
Sources.DELETED = {
    JOURNAL_Know_CathanJournal_Vault = true,
    JOURNAL_Know_Artefact_GraniteMaulHandle = true,
    JOURNAL_Know_Artefact_GraniteMaulHead = true,
    JOURNAL_Know_Artefact_GraniteMaulWrappings = true,
}

local function ids(...)
    local out = {}
    for _, s in ipairs({ ... }) do out[#out + 1] = "JOURNAL_Know_" .. s end
    return out
end

local function series(prefix, count, pad)
    local out = {}
    for i = 1, count do
        out[i] = "JOURNAL_Know_" .. prefix .. (pad and string.format("%02d", i) or tostring(i))
    end
    return out
end

local function band_ids(band)
    local out = {}
    for _, id in ipairs(Sources.ORDER) do
        if Sources.ENTRIES[id].band == band then out[#out + 1] = id end
    end
    return out
end

local function live_ids()
    local out = {}
    for _, id in ipairs(Sources.ORDER) do out[#out + 1] = id end
    return out
end

-- Places a reconstruction is pieced together at: the player must stand within
-- radius (Unreal units, centimetres) of x, y with the evidence owned. A site
-- with no coordinates is not enforced, so the reconstruction pays anywhere.
Sources.SITES = {
    bramblemead = { label = "the ruins of Bramblemead village", x = nil, y = nil, radius = 6000 },
}

-- Awards for owning a whole set (series), two pages that disagree
-- (correlation), or most of a band's record (reconstruction). Each pays once,
-- in its own band, as soon as its ids are owned: every id for a series or
-- correlation, need of them for a reconstruction.
Sources.SETS = {
    -- Band 1: 650 + 700 + 654 = 2,004 XP. The reconstruction needs 18 of the
    -- 20 band 1 entries; it pays at least what is left to the band's top
    -- (Sources.SetPay).
    { id = "set:dragon_attack", band = 1, kind = "series", xp = 175, label = "The dragon attack, five accounts", ids = series("LoreScrap_A", 5) },
    { id = "set:goblin_writings", band = 1, kind = "series", xp = 175, label = "Goblin writings", ids = series("LoreScrap_B", 5) },
    { id = "set:valley_druids", band = 1, kind = "series", xp = 150, label = "The valley's Guthixian pages", ids = ids("LoreScrap_C2", "LoreScrap_C3", "LoreScrap_C4", "LoreScrap_C5") },
    { id = "set:keep_papers", band = 1, kind = "series", xp = 150, label = "Papers from the Keep of Blue Flames", ids = ids("LoreScrap_CastleExtra1", "LoreScrap_CastleExtra2", "CathanJournal_Castle") },
    { id = "correlation:dragon_attack_sides", band = 1, kind = "correlation", xp = 175, label = "Two sides of the dragon attack", ids = ids("LoreScrap_A2", "LoreScrap_B4") },
    { id = "correlation:abandoned_village", band = 1, kind = "correlation", xp = 175, label = "Who abandoned Bramblemead", ids = ids("LoreScrap_A1", "LoreScrap_C4") },
    { id = "correlation:goblin_alliance", band = 1, kind = "correlation", xp = 175, label = "The goblin alliance", ids = ids("LoreScrap_A3", "LoreScrap_B3") },
    { id = "correlation:velgar_chant", band = 1, kind = "correlation", xp = 175, label = "Why the goblins chant Velgar", ids = ids("CathanJournal_Castle", "LoreScrap_B5") },
    { id = "reconstruction:fall_of_bramblemead", band = 1, kind = "reconstruction", xp = 654, label = "The fall of Bramblemead", ids = band_ids(1), need = 18, site = "bramblemead" },

    -- Band 2: 900 + 700 + 2,400 + 2,477 = 6,477 XP (plus 1,500 from the three skill books).
    { id = "set:guthixian_pages", band = 2, kind = "series", xp = 900, label = "The Guthixian pages", ids = series("LoreScrap_C", 5) },
    { id = "set:bloodblight_pages", band = 2, kind = "series", xp = 700, label = "The Bloodblight pages", ids = series("LoreScrap_F", 2) },
    { id = "correlation:horn_and_farewell", band = 2, kind = "correlation", xp = 1200, label = "The horn and the farewell", ids = ids("CathanJournal_Castle", "CathanJournal_Velgarslair") },
    { id = "correlation:garou_beasts_or_kings", band = 2, kind = "correlation", xp = 1200, label = "Garou: beasts or kings", ids = ids("LoreScrap_D1", "LoreScrap_D5") },
    { id = "reconstruction:swamp_road", band = 2, kind = "reconstruction", xp = 2477, label = "The swamp road", ids = band_ids(2) },

    -- Band 3: 24,000 + 5,000 + 3,069 = 32,069 XP.
    { id = "set:garou_pages", band = 3, kind = "series", xp = 2500, label = "The garou pages", ids = series("LoreScrap_D", 5) },
    { id = "set:dragonkin_pages", band = 3, kind = "series", xp = 2500, label = "The dragonkin pages", ids = series("LoreScrap_E", 4) },
    { id = "set:vault_puzzle", band = 3, kind = "series", xp = 2000, label = "The Vault puzzle", ids = series("Vault_Puzzle_", 2) },
    { id = "set:sw_critical_path", band = 3, kind = "series", xp = 5000, label = "Rasthin's tomes", ids = series("SW_LoreScrap_CriticalPath_Book", 6) },
    { id = "set:sw_optional", band = 3, kind = "series", xp = 2000, label = "The Scorned Wilderness strays", ids = ids("SW_LoreScrap_Optional_Book1", "SW_LoreScrap_Optional_Book2", "SW_LoreScrap_Optional_Book3", "SW_LoreScrap_PuzzleText") },
    { id = "set:dragonwolves", band = 3, kind = "series", xp = 2500, label = "Dragonwolves", ids = series("Dragonwolves_", 3) },
    { id = "set:zogres", band = 3, kind = "series", xp = 2500, label = "Zogres", ids = series("Zogres_", 3) },
    { id = "set:necromancer", band = 3, kind = "series", xp = 5000, label = "The Necromancer and the Wolf", ids = series("Necromancer_And_The_Wolf_", 7) },
    { id = "correlation:vault_memoir", band = 3, kind = "correlation", xp = 2500, label = "The Vaults, two accounts", ids = ids("Place_Vaults", "Vault_Puzzle_1") },
    { id = "correlation:ritual_and_garou", band = 3, kind = "correlation", xp = 2500, label = "The ritual and the garou", ids = ids("DogDays", "LoreScrap_D4") },
    { id = "reconstruction:plains_and_vaults", band = 3, kind = "reconstruction", xp = 3069, label = "The plains and the Vaults", ids = band_ids(3) },

    -- Band 4: 50,000 + 5,000 + 6,124 = 61,124 XP.
    { id = "set:first_people", band = 4, kind = "series", xp = 8000, label = "The First People", ids = series("UmS_FirstPeople_", 5) },
    { id = "set:kalphite", band = 4, kind = "series", xp = 8000, label = "The Kalphite", ids = series("UmS_Kalphite_", 5) },
    { id = "set:kothaar", band = 4, kind = "series", xp = 8000, label = "The KotHaar", ids = series("UmS_KotHaar_", 5) },
    { id = "set:qoa", band = 4, kind = "series", xp = 8000, label = "The Queen's books", ids = series("UmS_QoA_", 5) },
    { id = "set:saga", band = 4, kind = "series", xp = 8000, label = "The Saga", ids = series("UmS_CampA_Task1_", 6, true) },
    { id = "set:dowdun_reach", band = 4, kind = "series", xp = 10000, label = "The Dowdun Reach papers", ids = ids("DRLoreScrap_L1", "DRLoreScrap_L2", "DRLoreScrap_L3", "DRLoreScrap_L4", "DRLoreScrap_L5", "DRLoreScrap_L6", "DRLoreScrap_L8", "DRLoreScrap_L11", "DRLoreScrap_L12", "DRLoreScrap_L13", "DRLoreScrap_L14", "DRLoreScrap_L15", "DRLoreScrap_L16", "DRLoreScrap_L17") },
    { id = "correlation:wolf_and_goddess", band = 4, kind = "correlation", xp = 5000, label = "The wolf, the goddess and the elder's tale", ids = ids("UmS_WolfandGoddess", "LoreScrap_D5") },
    { id = "reconstruction:umbral_sands", band = 4, kind = "reconstruction", xp = 6124, label = "The Umbral Sands", ids = band_ids(4) },

    -- Band 5: 300,000 + 150,000 + 211,878 = 661,878 XP.
    { id = "set:the_dragonkin", band = 5, kind = "series", xp = 100000, label = "The Dragonkin", ids = series("The_Dragonkin_", 5) },
    { id = "set:the_withering", band = 5, kind = "series", xp = 100000, label = "The Withering", ids = series("The_Withering_", 6) },
    { id = "set:the_rising_dead", band = 5, kind = "series", xp = 100000, label = "The Rising Dead", ids = series("The_Rising_Dead_", 5) },
    { id = "correlation:people_of_ashenfall", band = 5, kind = "correlation", xp = 150000, label = "The people of Ashenfall", ids = ids("People_Armadyl", "People_Bandos", "People_Cathan", "People_Doric", "People_Guthix", "People_Saradomin", "People_Vannaka", "People_WiseOldMan", "People_Zamorak", "People_Zanik") },
    { id = "reconstruction:history_of_ashenfall", band = 5, kind = "reconstruction", xp = 211878, label = "The history of Ashenfall", ids = live_ids() },
}

-- Every reconstruction can be finished with two of its entries missing.
for _, s in ipairs(Sources.SETS) do
    if s.kind == "reconstruction" and not s.need then s.need = #s.ids - 2 end
end

-- Ids a set needs owned before it pays.
function Sources.Need(set)
    return set.need or #set.ids
end

-- How many of a set's ids are owned, given owns(id).
function Sources.Have(set, owns)
    local n = 0
    for _, id in ipairs(set.ids) do
        if owns(id) then n = n + 1 end
    end
    return n
end

-- The site a set must be finished at, or nil when there is none to enforce.
function Sources.Site(set)
    local site = set.site and Sources.SITES[set.site]
    if site and site.x and site.y then return site end
    return nil
end

-- Skill lore books placed by later mods. They are normal journal entries in
-- the game's lore popup; ids are added when the books exist.
Sources.BOOKS = {
    { key = "horticulture", band = 2, xp = 500, label = "Horticulture lore book" },
    { key = "demolition", band = 2, xp = 500, label = "Demolition lore book" },
    { key = "composition", band = 2, xp = 500, label = "Composition lore book" },
}

-- Returns kind, entry for a journal id. kind is "entry", "tutorial",
-- "deleted", or nil for anything that is not a knowledge entry.
function Sources.Classify(id)
    local e = Sources.ENTRIES[id]
    if e then return "entry", e end
    if id:find("^JOURNAL_Know_Tutorials_") then return "tutorial" end
    if Sources.DELETED[id] then return "deleted" end
    return nil
end

function Sources.IsOpen(band)
    return Sources.OPEN[band] == true
end

-- Perks, levels 2-25 (approved 2026-10-05; names and wording are MOD LORE).
-- Minor rows add 0.5% to all Historian XP. Majors are journal messages built
-- in main.lua, Cathan's journals paying more, and the Historian 25 gate.
Sources.MINOR_STEP = 5 -- tenths of a percent per minor row
Sources.MINOR_LEVELS = { 2, 4, 5, 7, 8, 9, 11, 12, 13, 15, 16, 17, 18, 20, 21, 22, 23, 24 }
Sources.PERK_NOSE = 3
Sources.PERK_DOG_EARED = 6
Sources.PERK_FOOTNOTES = 10
Sources.PERK_HE_SAID = 14
Sources.PERK_PRIMARY = 19
Sources.PRIMARY_PERCENT = 125

-- Rows for RegisterSkill, in level order. strings: historian_strings.lua.
function Sources.PerkRows(strings)
    local rows = {}
    for level, p in pairs(strings.PERKS) do rows[#rows + 1] = { level = level, name = p[1], description = p[2] } end
    for _, lv in ipairs(Sources.MINOR_LEVELS) do
        rows[#rows + 1] = { level = lv, minor = true, name = strings.MINOR_PERK[1], description = strings.MINOR_PERK[2] }
    end
    table.sort(rows, function(a, b) return a.level < b.level end)
    return rows
end

function Sources.MinorRows(level)
    local n = 0
    for _, lv in ipairs(Sources.MINOR_LEVELS) do
        if lv <= level then n = n + 1 end
    end
    return n
end

-- XP an award pays at the Historian level held before it. Integer maths:
-- base x (1000 + 5 per minor row) / 1000, x 1.25 for Cathan's journals from
-- level 19, rounded half up. ESL's store then clamps at the cap.
function Sources.Pay(base, entryType, level)
    local permille = 1000 + Sources.MINOR_STEP * Sources.MinorRows(level)
    local percent = (entryType == "cathan" and level >= Sources.PERK_PRIMARY) and Sources.PRIMARY_PERCENT or 100
    return math.floor((base * permille * percent + 50000) / 100000)
end

-- XP a set pays. A band's reconstruction pays at least what is left to the
-- band's top, so finishing it always ends exactly there, whatever order the
-- perks' bonus and rounding saw. Overshoot is clamped by the cap.
function Sources.SetPay(set, xp, level)
    local pay = Sources.Pay(set.xp, nil, level)
    local band = Sources.BANDS[set.band]
    if set.kind == "reconstruction" and band and xp < band.top then
        pay = math.max(pay, band.top - xp)
    end
    return pay
end

-- XP each band pays in total: entries + sets + books.
function Sources.BandTotal(band)
    local sum = 0
    for _, e in pairs(Sources.ENTRIES) do if e.band == band then sum = sum + e.xp end end
    for _, s in ipairs(Sources.SETS) do if s.band == band then sum = sum + s.xp end end
    for _, b in ipairs(Sources.BOOKS) do if b.band == band then sum = sum + b.xp end end
    return sum
end

return Sources
