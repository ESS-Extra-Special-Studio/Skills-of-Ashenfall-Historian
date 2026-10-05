local Sources = require("sources")

local function log(msg)
    print("[Skills of Ashenfall: Historian] " .. msg .. "\n")
end

local function script_dir()
    local source = debug.getinfo(1, "S").source
    source = source:match("^@(.*)$") or source
    return source:match("^(.*)[/\\]")
end

local dir = script_dir()
if not dir then
    log("Could not find the script folder")
    return
end

package.path = dir .. "\\..\\..\\ESLDragonWilds\\Scripts\\?.lua;" .. package.path
local okESL, ESL = pcall(require, "esl")
if not okESL then
    log("ESL:DragonWilds is missing or failed to load. Install it next to this mod. (" .. tostring(ESL) .. ")")
    return
end
if not (ESL.RequireVersion and ESL.RequireVersion("1.1.0", "Skills of Ashenfall: Historian")) then
    log("ESL:DragonWilds is too old for this Historian. Install ESL:DragonWilds 1.1.0 or later.")
    return
end

log("Loaded")

-- Stable id other mods use to require Historian (ESL.HISTORIAN).
local SKILL = "Historian"
local VERSION = "1.0.0"

-- Entry titles as the journal shows them (JournalEntryData.DisplayName).
local titles = {}

local devFlag = io.open(dir .. "\\..\\dev.txt", "r")
local DEV = devFlag ~= nil
if devFlag then devFlag:close() end

ESL.RegisterSkill({
    id = SKILL,
    name = "Historian",
    version = VERSION,
    mod = "Skills of Ashenfall: Historian",
    iconFile = dir .. "\\..\\Textures\\historian-skill-icon.png",
    capXp = Sources.V1_CAP,
    -- v1.0.0 content ends at 25; every max-level display uses this.
    maxLevel = 25,
    maxLevelText = "Historian 25: all v1.0.0 has to teach",
    flavour = "Piece together the history of Ashenfall from what its people left behind.",
    levelUpText = "Find lore scraps, journals and place records to gain Historian XP.",
    panelLabel = "Progress to next level",
    trainingText = "Find lore scraps, journals and place records; each one your journal files, and each set or contradiction you complete, levels this skill.",
    perks = Sources.PerkRows(),
    -- The middle panel shows the minor rows' running total, as vanilla does.
    perkSummary = { label = "Historian XP", step = Sources.MINOR_STEP / 10, prefix = "+" },
})

local function valid(obj)
    local ok, yes = pcall(function() return obj ~= nil and obj:IsValid() end)
    return ok and yes
end

local function in_world()
    local UEHelpers = require("UEHelpers")
    local ok, pc = pcall(UEHelpers.GetPlayerController)
    return ok and valid(pc) and ESL.Character() ~= nil
end

local TYPE_LABEL = {
    scrap = "Lore scrap",
    place = "Place record",
    people = "Account",
    story = "Story page",
    cathan = "Cathan's journal",
}
local KIND_LABEL = {
    series = "Set complete",
    correlation = "Correlation",
    reconstruction = "Reconstruction",
}

-- The read list holds every Historian entry this character owns, in any band,
-- so a later band can pay what was found before it opened.
local function owns(id)
    return ESL.HasRead(SKILL, id)
end

local function band_name(band)
    local b = Sources.BANDS[band]
    return b and ("levels " .. b.levels) or "a later version"
end

-- Records an owned entry and pays it if its band is open. Returns the gain.
local function grant(id, quiet)
    local kind, e = Sources.Classify(id)
    if kind ~= "entry" then return nil end
    ESL.MarkRead(SKILL, id)
    if not Sources.IsOpen(e.band) then return nil end
    local pay = Sources.Pay(e.xp, e.type, ESL.Get(SKILL).level)
    return ESL.Award(SKILL, id, pay, TYPE_LABEL[e.type] .. ": " .. (titles[id] or e.label), quiet)
end

-- Pays every open set, correlation and reconstruction whose ids are all owned.
local function check_sets(quiet)
    local n = 0
    for _, s in ipairs(Sources.SETS) do
        if Sources.IsOpen(s.band) and not ESL.HasPaid(SKILL, s.id) then
            local all = true
            for _, id in ipairs(s.ids) do
                if not owns(id) then all = false break end
            end
            local now = ESL.Get(SKILL)
            if all and ESL.Award(SKILL, s.id, Sources.SetPay(s, now.xp, now.level), KIND_LABEL[s.kind] .. ": " .. s.label, quiet) then n = n + 1 end
        end
    end
    return n
end

-- Saves from before the id table paid by entry type and click order. The
-- first load under the id table clears that record once; the journal pass
-- then pays every entry the character owns, by id.
local SCHEME = "scheme:id-table"
local function migrate()
    if owns(SCHEME) then return end
    local old = ESL.Get(SKILL)
    local count = #ESL.Paid(SKILL)
    if count > 0 or old.xp > 0 then
        ESL.Reset(SKILL)
        log(string.format("Old save (%d XP from %d sources) cleared once; owned journal entries are paid again by id", old.xp, count))
    end
    ESL.MarkRead(SKILL, SCHEME)
end

-- The JournalComponent read functions are called from native code, so hooks
-- on them never fire; the journal is polled instead.
-- JournalComponent (build 25632050): UnlockedJournalEntries and
-- UnreadJournalEntries are arrays of journal entry assets. An entry pays when
-- the game files it (unlocked), read or not. The first pass after a character
-- loads pays everything already filed quietly, then shows one set of
-- notifications, so characters and worlds made before the mod keep their
-- history. Only the local player's JournalComponent is read.
local function entry_names(arr)
    local out = {}
    pcall(function()
        arr:ForEach(function(_, e)
            local obj = e:get()
            local ok, n = pcall(function() return obj:GetFName():ToString() end)
            if ok and n then
                out[#out + 1] = n
                if not titles[n] then
                    local okT, t = pcall(function() return obj.DisplayName:ToString() end)
                    if okT and type(t) == "string" and t ~= "" and not t:find("MISSING", 1, true) then titles[n] = t end
                end
            end
        end)
    end)
    return out
end

local guardSaid = {}
local function local_journal()
    local UEHelpers = require("UEHelpers")
    local pc = UEHelpers.GetPlayerController()
    if not valid(pc) then return nil end
    -- Journal and character name must come from the same player at the same
    -- moment, or a character switch could credit one character's journal to
    -- another.
    local name = nil
    pcall(function() name = pc.PlayerState.PlayerNamePrivate:ToString() end)
    if name ~= ESL.Character() then
        local key = tostring(name) .. "|" .. tostring(ESL.Character())
        if not guardSaid[key] then
            guardSaid[key] = true
            log("Journal skipped: player " .. tostring(name) .. " is not the loaded character " .. tostring(ESL.Character()))
        end
        return nil
    end
    if not guardSaid["ok|" .. name] then
        guardSaid["ok|" .. name] = true
        log("Journal belongs to " .. name .. ", the loaded character")
    end
    local prefix = pc:GetFullName():match("^%S+%s+(.+)$")
    for _, comp in ipairs(FindAllOf("JournalComponent") or {}) do
        local f = comp:GetFullName()
        if prefix and f:find(prefix, 1, true) then return comp end
    end
    return nil
end

local function title_of(id)
    local _, e = Sources.Classify(id)
    return titles[id] or (e and e.label) or id
end

-- What a newly filed or newly read entry is worth, for the log.
local function describe(id)
    local kind, e = Sources.Classify(id)
    if kind == "tutorial" then return "tutorial, no XP" end
    if kind == "deleted" then return "deleted entry, no XP" end
    if kind ~= "entry" then return nil end
    if not Sources.IsOpen(e.band) then return "kept for " .. band_name(e.band) .. ", no XP yet" end
    if ESL.HasPaid(SKILL, id) then return "paid when filed" end
    return nil
end

local syncedFor = nil
local wasUnread = {}
local filed = {}

local PLURAL = {
    scrap = "lore scraps", place = "place records", people = "accounts",
    story = "story pages", cathan = "Cathan's journals",
}

-- Dog-Eared Pages (level 6): unread history in the journal, by kind.
local function unread_summary()
    if ESL.Get(SKILL).level < Sources.PERK_DOG_EARED then return nil end
    local counts, order = {}, { "scrap", "place", "people", "story", "cathan" }
    for id in pairs(wasUnread) do
        local kind, e = Sources.Classify(id)
        if kind == "entry" then counts[e.type] = (counts[e.type] or 0) + 1 end
    end
    local parts = {}
    for _, t in ipairs(order) do
        local n = counts[t]
        if n then parts[#parts + 1] = n .. " " .. (n == 1 and TYPE_LABEL[t]:lower() or PLURAL[t]) end
    end
    if #parts == 0 then return "Unread history: none" end
    return "Unread history: " .. table.concat(parts, ", ")
end

-- Nose in a Book (3), Footnotes (10) and He Said, She Said (14): one card for
-- a newly filed history entry. Never shown for the catch-up pass.
local function journal_note(id, more)
    if not ESL.ShowCard then return end
    local level = ESL.Get(SKILL).level
    if level < Sources.PERK_NOSE then return end
    local _, e = Sources.Classify(id)
    local parts = { TYPE_LABEL[e.type] }
    if level >= Sources.PERK_FOOTNOTES then
        for _, s in ipairs(Sources.SETS) do
            if (s.kind == "series" or s.kind == "reconstruction") and not ESL.HasPaid(SKILL, s.id) then
                local has, mine = 0, false
                for _, sid in ipairs(s.ids) do
                    if owns(sid) then has = has + 1 end
                    if sid == id then mine = true end
                end
                if mine and has < #s.ids then
                    parts[#parts + 1] = string.format("%s: %d of %d", s.label, has, #s.ids)
                    break
                end
            end
        end
    end
    if level >= Sources.PERK_HE_SAID then
        for _, s in ipairs(Sources.SETS) do
            if s.kind == "correlation" and not ESL.HasPaid(SKILL, s.id) then
                local mine, missing = false, nil
                for _, sid in ipairs(s.ids) do
                    if sid == id then mine = true elseif not owns(sid) then missing = missing or sid end
                end
                if mine and missing then
                    parts[#parts + 1] = "Disputed by: " .. title_of(missing)
                    break
                end
            end
        end
    end
    if more > 0 then parts[#parts + 1] = string.format("and %d more", more) end
    ESL.ShowCard(SKILL, "UNREAD IN YOUR JOURNAL", title_of(id), table.concat(parts, "  ·  "))
end

local function sync_journal()
    if not in_world() then return end
    local comp = local_journal()
    if not valid(comp) then return end
    local unread = {}
    for _, n in ipairs(entry_names(comp.UnreadJournalEntries)) do unread[n] = true end
    local unlocked = entry_names(comp.UnlockedJournalEntries)
    if #unlocked == 0 then return end
    local character = ESL.Character()
    local first = syncedFor ~= character
    local before = ESL.Get(SKILL).xp
    if first then
        wasUnread = {}
        filed = {}
        migrate()
    end
    local paidCount, kept, tutorials, deleted = 0, 0, 0, 0
    local newHistory = {}
    for _, n in ipairs(unlocked) do
        local kind, e = Sources.Classify(n)
        local new = not first and not filed[n]
        filed[n] = true
        if new and kind == "entry" then newHistory[#newHistory + 1] = n end
        local paidNow = false
        if kind == "entry" and (not owns(n) or (Sources.IsOpen(e.band) and not ESL.HasPaid(SKILL, n))) then
            if grant(n, first) then
                paidCount = paidCount + 1
                paidNow = true
            end
        end
        if new and kind and not paidNow then
            log("Filed " .. title_of(n) .. " (" .. n .. "): " .. (describe(n) or "no XP"))
        end
        if kind == "entry" and not Sources.IsOpen(e.band) then kept = kept + 1 end
        if kind == "tutorial" then tutorials = tutorials + 1 end
        if kind == "deleted" then deleted = deleted + 1 end
        if not first and wasUnread[n] and not unread[n] and kind then
            log("Read " .. title_of(n) .. " (" .. n .. "): " .. (describe(n) or "no XP"))
        end
    end
    wasUnread = unread
    local sets = check_sets(first)
    if #newHistory > 0 then pcall(journal_note, newHistory[#newHistory], #newHistory - 1) end
    if first then
        syncedFor = character
        local skill = ESL.Get(SKILL)
        log(string.format("Historian caught up for %s: %d journal entries filed, %d paid now plus %d sets, %d kept for later bands, %d tutorials and %d deleted entries pay nothing. %d XP, level %d",
            character, #unlocked, paidCount, sets, kept, tutorials, deleted, skill.xp, skill.level))
        if skill.xp > before then ESL.Announce(SKILL, before) end
    end
end

if LoopAsync then
    local lastError = nil
    LoopAsync(2000, function()
        local ok, err = pcall(sync_journal)
        if not ok and tostring(err) ~= lastError then
            lastError = tostring(err)
            log("Journal check failed: " .. lastError)
        end
        return false
    end)
end

RegisterKeyBindAsync(Key.F7, {}, function()
    if not in_world() then log("Load into a world first") return end
    ESL.ToggleStatus(SKILL, unread_summary)
end)

-- Test key, dev only: grants the next unpaid entry from an open band, as if
-- the game had filed it, then checks sets. The entry is unearned, so release
-- builds never register it.
if DEV then
    RegisterKeyBindAsync(Key.F8, {}, function()
        if not in_world() then log("Load into a world first") return end
        for _, id in ipairs(Sources.ORDER) do
            local e = Sources.ENTRIES[id]
            if Sources.IsOpen(e.band) and not ESL.HasPaid(SKILL, id) then
                log("Test grant " .. id)
                grant(id)
                check_sets()
                return
            end
        end
        log("Every open Historian entry is already paid")
    end)
end

-- Developer keys, only when a dev.txt file sits next to the mod's Scripts folder.
if DEV then
    -- Test requirement on bed rolls, to check the prompt plumbing. Shipped
    -- requirements go only on our own lore books and mod content.
    ESL.RequireSkill(SKILL, 5, "Bed Roll")
    RegisterKeyBindAsync(Key.F9, {}, function()
        ESL.SelectInSkillsMenu(SKILL)
    end)
    RegisterKeyBindAsync(Key.F11, {}, function()
        ESL.TestNotifications(SKILL)
    end)
    RegisterKeyBindAsync(Key.F6, {}, function()
        local Probe = require("probe")
        Probe.Perks()
        for _, prompt in ipairs(FindAllOf("WBP_HUD_InteractionPrompt_C") or {}) do
            pcall(function()
                local actor = prompt.CurrentWorldActor
                if actor:IsValid() then
                    Probe.log("prompt actor " .. actor:GetFullName())
                    local cls = actor:GetClass()
                    for _ = 1, 6 do
                        if not cls:IsValid() then break end
                        Probe.log("  class " .. cls:GetFullName())
                        cls = cls:GetSuperStruct()
                    end
                end
            end)
        end
    end)
    log("Developer keys on: F9 selects Historian in the skills menu, F11 tests notifications, F6 dumps widget classes")
end

log("Using ESL:DragonWilds. F7 shows Historian." .. (DEV and " F8 grants the next unpaid Historian entry (dev test)." or ""))
