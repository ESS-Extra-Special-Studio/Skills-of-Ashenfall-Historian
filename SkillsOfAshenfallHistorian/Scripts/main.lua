local Sources = require("sources")
local S = require("historian_strings")

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
if not (ESL.RequireVersion and ESL.RequireVersion("1.1.0", S.MOD_NAME) and ESL.Every) then
    log("ESL:DragonWilds is too old for this Historian. Install the latest ESL:DragonWilds 1.1.0 or later.")
    return
end

local Config = require("historian_config").Load(dir, log)

log("Loaded")

-- Stable id other mods use to require Historian (ESL.HISTORIAN).
local SKILL = "Historian"
local VERSION = "1.0.0"
local TESTED_BUILD = "25632050"

-- Entry titles as the journal shows them (JournalEntryData.DisplayName).
local titles = {}

local devFlag = io.open(dir .. "\\..\\dev.txt", "r")
local DEV = devFlag ~= nil
if devFlag then devFlag:close() end
local VERBOSE = DEV or Config.debug

local function detail(msg)
    if VERBOSE then log(msg) end
end

ESL.RegisterSkill({
    id = SKILL,
    name = S.SKILL_NAME,
    version = VERSION,
    mod = S.MOD_NAME,
    iconFile = dir .. "\\..\\Textures\\historian-skill-icon.png",
    capXp = Sources.V1_CAP,
    -- v1.0.0 content ends at 25; every max-level display uses this.
    maxLevel = 25,
    maxLevelText = S.MAX_LEVEL_TEXT,
    flavour = S.FLAVOUR,
    levelUpText = S.LEVEL_UP_TEXT,
    panelLabel = S.PANEL_LABEL,
    trainingText = S.TRAINING_TEXT,
    perks = Sources.PerkRows(S),
    -- The middle panel shows the minor rows' running total, as vanilla does.
    perkSummary = { label = S.PERK_SUMMARY_LABEL, step = Sources.MINOR_STEP / 10, prefix = "+" },
})

local function valid(obj)
    local ok, yes = pcall(function() return obj ~= nil and obj:IsValid() end)
    return ok and yes
end

-- Historian's own cards; quiet mode hides them.
local function card(kicker, title, text, seconds)
    if Config.quiet then return end
    ESL.ShowCard(SKILL, kicker, title, text, seconds)
end

-- The read list holds every Historian entry this character owns, in any band,
-- so a later band can pay what was found before it opened.
local function owns(id)
    return ESL.HasRead(SKILL, id)
end

local function title_of(id)
    local _, e = Sources.Classify(id)
    return titles[id] or (e and e.label) or id
end

-- Records an owned entry and pays it if its band is open. Returns the gain.
local function grant(id, quiet)
    local kind, e = Sources.Classify(id)
    if kind ~= "entry" then return nil end
    ESL.MarkRead(SKILL, id)
    if not Sources.IsOpen(e.band) then return nil end
    local pay = Sources.Pay(e.xp, e.type, ESL.Get(SKILL).level)
    return ESL.Award(SKILL, id, pay, S.TYPE[e.type] .. ": " .. title_of(id), quiet)
end

-- Site visits: a reconstruction with a site pays only while the player stands
-- there with the evidence owned.
local function at_site(site)
    local x, y = ESL.Location()
    if not x then return false end
    local dx, dy = (x - site.x) + 0.0, (y - site.y) + 0.0
    local r = site.radius + 0.0
    return dx * dx + dy * dy <= r * r
end

local sitePrompted = {}

-- Pays every open set whose ids are owned (all of them, or need of them for
-- a reconstruction). quiet: the catch-up pass, which shows no cards.
local function check_sets(quiet)
    local n = 0
    for _, s in ipairs(Sources.SETS) do
        if Sources.IsOpen(s.band) and not ESL.HasPaid(SKILL, s.id) and Sources.Have(s, owns) >= Sources.Need(s) then
            local site = Sources.Site(s)
            local here = not site or at_site(site)
            if not here then
                if not sitePrompted[s.id] and not quiet then
                    sitePrompted[s.id] = true
                    card(S.SITE_KICKER, string.format(S.SITE_TITLE, s.label), string.format(S.SITE_CARD, site.label), 8)
                end
            else
                local now = ESL.Get(SKILL)
                if ESL.Award(SKILL, s.id, Sources.SetPay(s, now.xp, now.level), S.KIND[s.kind] .. ": " .. s.label, quiet) then
                    n = n + 1
                    if not quiet then
                        local note = S.CORRELATION_NOTES[s.id]
                        if note then card(S.CORRELATION_KICKER, s.label, note, 10) end
                        if site then card(S.SITE_DONE_KICKER, s.label, site.label, 5) end
                    end
                end
            end
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
-- on them never fire; the journal is read on a game-thread timer instead.
-- JournalComponent (build 25632050): UnlockedJournalEntries and
-- UnreadJournalEntries are arrays of journal entry assets. An entry pays when
-- the game files it (unlocked), read or not. The first pass after a character
-- loads pays everything already filed quietly, then shows one card, so
-- characters and worlds made before the mod keep their history. Only the
-- local player's JournalComponent is read (ESL.LocalJournal).
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

local function band_name(band)
    local b = Sources.BANDS[band]
    return b and ("levels " .. b.levels) or "a later version"
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
local pendingNote = nil
local LORE_POPUP = "WBP_LorePopupMainPanel_C"

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
        if n then parts[#parts + 1] = n .. " " .. (n == 1 and S.TYPE[t]:lower() or S.TYPE_PLURAL[t]) end
    end
    if #parts == 0 then return S.LEDGER_UNREAD_NONE end
    return string.format(S.LEDGER_UNREAD, table.concat(parts, ", "))
end

-- Nose in a Book (3), Footnotes (10) and He Said, She Said (14): one card for
-- a newly filed history entry. Never shown for the catch-up pass.
local function journal_note(id, more)
    local level = ESL.Get(SKILL).level
    if level < Sources.PERK_NOSE then return end
    local _, e = Sources.Classify(id)
    local parts = { S.TYPE[e.type] }
    if level >= Sources.PERK_FOOTNOTES then
        for _, s in ipairs(Sources.SETS) do
            if (s.kind == "series" or s.kind == "reconstruction") and Sources.IsOpen(s.band) and not ESL.HasPaid(SKILL, s.id) then
                local mine = false
                for _, sid in ipairs(s.ids) do
                    if sid == id then mine = true break end
                end
                local has, need = Sources.Have(s, owns), Sources.Need(s)
                if mine and has < need then
                    parts[#parts + 1] = string.format(S.NOTE_SET, s.label, has, need)
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
                    parts[#parts + 1] = string.format(S.NOTE_DISPUTED, title_of(missing))
                    break
                end
            end
        end
    end
    if more > 0 then parts[#parts + 1] = string.format(S.NOTE_MORE, more) end
    card(S.NOTE_KICKER, title_of(id), table.concat(parts, S.SEP))
end

-- Historian's Ledger (the status panel): the open band's sets, correlations
-- and reconstruction, a next goal, what is kept for later bands, and (from
-- Dog-Eared Pages) the unread history.
local function open_band()
    local top = 1
    for band in pairs(Sources.OPEN) do
        if Sources.OPEN[band] and band > top then top = band end
    end
    return top
end

local function ledger()
    local band = open_band()
    local b = Sources.BANDS[band]
    local lines = { string.format(S.LEDGER_TITLE, b.region, b.levels) }

    local total, have = 0, 0
    for _, id in ipairs(Sources.ORDER) do
        if Sources.ENTRIES[id].band == band then
            total = total + 1
            if owns(id) then have = have + 1 end
        end
    end
    lines[#lines + 1] = string.format(S.LEDGER_RECORDS, have, total)

    local setLines, corrTotal, corrFound = {}, 0, 0
    local nextGoal, bestMissing = nil, math.huge
    local reconLine, reconGoal, sitePending = nil, nil, nil
    local level = ESL.Get(SKILL).level
    for _, s in ipairs(Sources.SETS) do
        if s.band == band then
            local paid = ESL.HasPaid(SKILL, s.id)
            local got, need = Sources.Have(s, owns), Sources.Need(s)
            if s.kind == "series" then
                setLines[#setLines + 1] = "  " .. (paid and string.format(S.LEDGER_SET_DONE, s.label) or string.format(S.LEDGER_SET_ITEM, s.label, got, need))
                if not paid and need - got < bestMissing then
                    bestMissing = need - got
                    nextGoal = string.format(S.LEDGER_NEXT_SET, s.label, need - got)
                end
            elseif s.kind == "correlation" then
                corrTotal = corrTotal + 1
                if paid then
                    corrFound = corrFound + 1
                elseif level >= Sources.PERK_HE_SAID and got == need - 1 and bestMissing > 1 then
                    for _, sid in ipairs(s.ids) do
                        if not owns(sid) then
                            bestMissing = 1
                            nextGoal = string.format(S.LEDGER_NEXT_CORRELATION, title_of(sid))
                            break
                        end
                    end
                end
            elseif s.kind == "reconstruction" then
                local site = s.site and Sources.SITES[s.site]
                if paid then
                    reconLine = string.format(S.LEDGER_RECONSTRUCTION_DONE, s.label)
                elseif got >= need and Sources.Site(s) then
                    reconLine = string.format(S.LEDGER_RECONSTRUCTION_SITE, site.label)
                    sitePending = string.format(S.SITE_DETAIL, site.label)
                else
                    reconLine = string.format(S.LEDGER_RECONSTRUCTION, got, need)
                    reconGoal = string.format(S.LEDGER_NEXT_RECONSTRUCTION, need - got, s.label)
                end
            end
        end
    end
    if #setLines > 0 then
        lines[#lines + 1] = S.LEDGER_SETS
        for _, l in ipairs(setLines) do lines[#lines + 1] = l end
    end
    lines[#lines + 1] = string.format(S.LEDGER_CORRELATIONS, corrFound, corrTotal)
    if reconLine then lines[#lines + 1] = reconLine end
    lines[#lines + 1] = string.format(S.LEDGER_NEXT, sitePending or nextGoal or reconGoal or S.LEDGER_NEXT_DONE)

    local kept = {}
    for _, id in ipairs(Sources.ORDER) do
        local e = Sources.ENTRIES[id]
        if not Sources.IsOpen(e.band) and owns(id) then kept[e.band] = (kept[e.band] or 0) + 1 end
    end
    for later = band + 1, #Sources.BANDS do
        if kept[later] then lines[#lines + 1] = string.format(S.LEDGER_KEPT, kept[later], Sources.BANDS[later].region) end
    end

    local unread = unread_summary()
    if unread then lines[#lines + 1] = unread end
    return table.concat(lines, "\n")
end

-- First run and catch-up: one card per character, the first time Historian
-- sees it.
local CEREMONY = "ceremony:shown"
local function ceremony()
    if owns(CEREMONY) then return false end
    ESL.MarkRead(SKILL, CEREMONY)
    local records = 0
    for _, id in ipairs(Sources.ORDER) do
        if owns(id) then records = records + 1 end
    end
    local skill = ESL.Get(SKILL)
    if records > 0 then
        card(S.CEREMONY_KICKER, string.format(S.CEREMONY_CAUGHT_UP, records),
            string.format(S.CEREMONY_CAUGHT_UP_DETAIL, skill.level, Config.ledger_key), 9)
    else
        card(S.CEREMONY_KICKER, S.CEREMONY_FIRST, string.format(S.CEREMONY_FIRST_DETAIL, Config.ledger_key), 9)
    end
    return true
end

-- One card per install when the game build is not the one Historian was
-- tested on; the build is remembered in build-warned.txt.
local buildChecked = false
local function check_build()
    if buildChecked then return end
    buildChecked = true
    local build = ESL.GameBuild and ESL.GameBuild()
    if not build or build == TESTED_BUILD then return end
    local path = dir .. "\\..\\build-warned.txt"
    local f = io.open(path, "r")
    local warned = f and f:read("*l")
    if f then f:close() end
    log("Game build " .. build .. "; Historian was tested on " .. TESTED_BUILD)
    if warned == build then return end
    local w = io.open(path, "w")
    if w then w:write(build) w:close() end
    ESL.ShowCard(SKILL, S.BUILD_KICKER, S.BUILD_TITLE, string.format(S.BUILD_DETAIL, TESTED_BUILD, build), 10)
end

local function sync_journal()
    if not ESL.InWorld() then return end
    check_build()
    local comp = ESL.LocalJournal()
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
        pendingNote = nil
        migrate()
        detail("Journal belongs to " .. tostring(character) .. ", the loaded character")
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
            detail("Filed " .. title_of(n) .. " (" .. n .. "): " .. (describe(n) or "no XP"))
        end
        if kind == "entry" and not Sources.IsOpen(e.band) then kept = kept + 1 end
        if kind == "tutorial" then tutorials = tutorials + 1 end
        if kind == "deleted" then deleted = deleted + 1 end
        if not first and wasUnread[n] and not unread[n] and kind then
            detail("Read " .. title_of(n) .. " (" .. n .. "): " .. (describe(n) or "no XP"))
        end
    end
    wasUnread = unread
    local sets = check_sets(first)
    if #newHistory > 0 then
        local more = pendingNote and (pendingNote.more + 1) or 0
        pendingNote = { id = newHistory[#newHistory], more = more + #newHistory - 1, since = os.time() }
    end
    -- The note waits for the game's lore popup to close, so it never covers
    -- the page being read (at most a minute).
    if pendingNote and not (ESL.ScreenOpen and ESL.ScreenOpen(LORE_POPUP) and os.time() - pendingNote.since < 60) then
        pcall(journal_note, pendingNote.id, pendingNote.more)
        pendingNote = nil
    end
    if first then
        syncedFor = character
        local skill = ESL.Get(SKILL)
        log(string.format("Historian caught up for %s: %d journal entries filed, %d paid now plus %d sets, %d kept for later bands, %d tutorials and %d deleted entries pay nothing. %d XP, level %d",
            character, #unlocked, paidCount, sets, kept, tutorials, deleted, skill.xp, skill.level))
        if not ceremony() and skill.xp > before then ESL.Announce(SKILL, before) end
    end
end

ESL.Every(2000, "Historian journal check", sync_journal)

RegisterKeyBindAsync(Key[Config.ledger_key], {}, function()
    ESL.RunInGame(function()
        if not ESL.InWorld() then log(S.LOG_WORLD_FIRST) return end
        ESL.ToggleStatus(SKILL, ledger)
    end, "Historian ledger")
end)

-- Developer keys, only when a dev.txt file sits next to the mod's Scripts
-- folder. The F8 grant is unearned, so release builds never register it.
if DEV then
    RegisterKeyBindAsync(Key.F8, {}, function()
        ESL.RunInGame(function()
            if not ESL.InWorld() then log(S.LOG_WORLD_FIRST) return end
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
        end, "Historian test grant")
    end)
    -- Logs the player's position, to record a reconstruction site.
    RegisterKeyBindAsync(Key.F5, {}, function()
        ESL.RunInGame(function()
            local x, y, z = ESL.Location()
            log(x and string.format("Site capture: x = %.0f, y = %.0f, z = %.0f", x, y, z) or "Site capture: no position (load into a world)")
        end, "Historian site capture")
    end)
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
        ESL.RunInGame(function()
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
        end, "Historian probe")
    end)
    log("Developer keys on: F8 grants the next unpaid entry, F5 logs your position, F9 selects Historian in the skills menu, F11 tests notifications, F6 dumps widget classes")
end

log("Using ESL:DragonWilds. " .. Config.ledger_key .. " shows the Historian ledger." .. (Config.quiet and " Quiet mode is on." or ""))
