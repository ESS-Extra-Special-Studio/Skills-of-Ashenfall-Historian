-- Offline tests for Historian v1.0.0: runs the real main.lua, sources.lua and
-- strings against a mock ESL (same cap, paid and read rules as ESL's store)
-- and a fake journal. Run with Fengari or any Lua 5.3+:
--   node run.js run tests/historian_test.lua "<repo>\SkillsOfAshenfallHistorian\Scripts\?.lua;<esl>\ESLDragonWilds\Scripts\?.lua"
-- Needs SCRIPTS (the Historian Scripts folder) set below or in the env table.
local SCRIPTS = HISTORIAN_SCRIPTS or "<user>\\IdeaProjects\\Skills-of-Ashenfall-Historian\\SkillsOfAshenfallHistorian\\Scripts"

local Curve = require("curve")
local fails, passes = 0, 0
local function check(cond, name)
    if cond then passes = passes + 1 else fails = fails + 1 (print_orig or print)("FAIL " .. name) end
end

-- In-memory files (Fengari has no io library).
local files = {}
io = io or {}
io.open = function(path, mode)
    mode = mode or "r"
    if mode:find("r") then
        local text = files[path]
        if not text then return nil end
        local pos = 1
        return {
            read = function(_, what)
                if what == "*a" then local t = text:sub(pos) pos = #text + 1 return t end
                local line = text:match("^[^\n]*", pos)
                if pos > #text then return nil end
                pos = pos + #line + 1
                return line
            end,
            close = function() end,
        }
    end
    local buf = {}
    return {
        write = function(_, s) buf[#buf + 1] = s end,
        close = function() files[path] = table.concat(buf) end,
    }
end

-- UE4SS globals.
Key = setmetatable({}, { __index = function(_, k) if type(k) == "string" and k:match("^F%d+$") then return k end end })
local binds = {}
function RegisterKeyBindAsync(key, mods, fn) binds[key] = fn end
local printed = {}
print_orig = print
print = function(s) printed[#printed + 1] = s end

-- Mock world and journal.
local world = { inWorld = true, x = 0, y = 0, character = "Tester", build = "25632050" }
local unlocked, unreadSet = {}, {}
local function array_of(list)
    return { ForEach = function(_, fn)
        for i, id in ipairs(list) do
            fn(i, { get = function()
                return { GetFName = function() return { ToString = function() return id end } end,
                    DisplayName = { ToString = function() return "" end } }
            end })
        end
    end }
end
local journal = { IsValid = function() return true end }

-- Mock ESL, following ESLDragonWilds/Scripts/store.lua's add().
local CAP = 3152
local state, cards, announces, ticks
local function reset_state()
    state = { xp = 0, read = {}, seen = {}, order = {} }
    cards, announces, ticks = {}, {}, {}
end
reset_state()
local ESL = {}
function ESL.RequireVersion() return true end
function ESL.Every(_, _, fn) ticks[#ticks + 1] = fn end
function ESL.RunInGame(fn) fn() end
function ESL.RegisterSkill(def) ESL.def = def return {} end
function ESL.InWorld() return world.inWorld end
function ESL.Character() return world.inWorld and world.character or nil end
function ESL.LocalJournal()
    journal.UnlockedJournalEntries = array_of(unlocked)
    local u = {}
    for id in pairs(unreadSet) do u[#u + 1] = id end
    journal.UnreadJournalEntries = array_of(u)
    return journal
end
function ESL.Location() return world.x, world.y, 0 end
function ESL.GameBuild() return world.build end
function ESL.HasRead(_, id) return state.read[id] == true end
function ESL.MarkRead(_, id) state.read[id] = true return true end
function ESL.HasPaid(_, id) return state.seen[id] == true end
function ESL.Paid() return state.order end
function ESL.Reset() state.xp, state.seen, state.order = 0, {}, {} end
function ESL.Get() return { xp = state.xp, level = math.min(Curve.LevelFor(state.xp), 25) } end
function ESL.Award(_, id, amount, label, quiet)
    if state.seen[id] then return nil end
    amount = math.floor(amount)
    if amount <= 0 then return nil end
    if state.xp >= CAP then
        state.seen[id] = true
        state.order[#state.order + 1] = id
        return nil
    end
    local gain = math.min(amount, CAP - state.xp)
    state.xp = state.xp + gain
    state.seen[id] = true
    state.order[#state.order + 1] = id
    return gain
end
function ESL.Announce(_, from) announces[#announces + 1] = from end
function ESL.ShowCard(_, kicker, title, text) cards[#cards + 1] = { kicker = kicker, title = title, text = text } return true end
function ESL.ToggleStatus(_, extra) ESL.lastLedger = extra() end
function ESL.RequireSkill() end
package.loaded["esl"] = ESL

local Sources = require("sources")
local S = require("historian_strings")
local main_path = SCRIPTS .. "\\main.lua"

local function load_main(config)
    files[SCRIPTS .. "\\..\\config.txt"] = config
    files[SCRIPTS .. "\\..\\build-warned.txt"] = nil
    binds = {}
    reset_state()
    local chunk = assert(loadfile(main_path))
    chunk()
end

local function tick() for _, fn in ipairs(ticks) do fn() end end

local band1 = {}
for _, id in ipairs(Sources.ORDER) do
    if Sources.ENTRIES[id].band == 1 then band1[#band1 + 1] = id end
end
local recon
for _, s in ipairs(Sources.SETS) do
    if s.id == "reconstruction:fall_of_bramblemead" then recon = s end
end

-- Seeded shuffle, so failures repeat.
local seed = 12345
local function rand(n)
    seed = (seed * 1103515245 + 12345) % 2147483648
    return seed % n + 1
end
local function shuffled(list)
    local out = {}
    for i, v in ipairs(list) do out[i] = v end
    for i = #out, 2, -1 do
        local j = rand(i)
        out[i], out[j] = out[j], out[i]
    end
    return out
end

-- 1. Arithmetic -----------------------------------------------------------
-- Everything in band 1 except the reconstruction, at the highest rate any
-- level gives (level 25: 18 minor rows, Cathan +25%).
local highP = 0
for _, id in ipairs(band1) do
    local e = Sources.ENTRIES[id]
    highP = highP + Sources.Pay(e.xp, e.type, 25)
end
for _, s in ipairs(Sources.SETS) do
    if s.band == 1 and s.kind ~= "reconstruction" then highP = highP + Sources.Pay(s.xp, nil, 25) end
end
print_orig(string.format("proof: without the reconstruction band 1 pays at most %d XP (level %d) < %d", highP, Curve.LevelFor(highP), CAP))
check(highP < CAP, "everything but the reconstruction stays under the cap")
check(Curve.LevelFor(highP) < 25, "level 25 needs the reconstruction")
check(Sources.Need(recon) == 18 and #recon.ids == 20, "reconstruction needs 18 of 20")
check(Sources.BANDS[1].top == CAP and Curve.LevelFor(CAP) == 25, "band top is the cap and level 25")
for P = 0, highP do
    local pay = Sources.SetPay(recon, P, math.min(Curve.LevelFor(P), 25))
    if math.min(CAP, P + pay) ~= CAP then check(false, "top-up from " .. P) break end
end
check(true, "top-up lands on the cap from every P in 0.." .. highP)

-- 2. Full runs through main.lua ------------------------------------------
-- Each run files entries one at a time, in a random order, with a sync after
-- each, as the game would.
local function run(order, opts)
    opts = opts or {}
    load_main(opts.config)
    unlocked, unreadSet = {}, {}
    world.x, world.y = opts.x or 0, opts.y or 0
    tick() -- first sync with an empty journal: nothing to do
    for i, id in ipairs(order) do
        unlocked[#unlocked + 1] = id
        if i == 1 then tick() end
        tick()
    end
    tick()
end

local RUNS = 400
local okAll, okSome, okFew, maxBefore = true, true, true, 0
for r = 1, RUNS do
    local order = shuffled(band1)
    run(order)
    if state.xp ~= CAP then okAll = false print_orig("all 20 ended at " .. state.xp) end
    -- 18 or 19 entries: two can be missed.
    local k = 18 + (r % 2)
    run({ table.unpack(shuffled(band1), 1, k) })
    if state.xp ~= CAP then okSome = false print_orig(k .. " entries ended at " .. state.xp) end
    -- 17 entries: the reconstruction cannot pay, so level 25 is not reached.
    run({ table.unpack(shuffled(band1), 1, 17) })
    if state.xp >= CAP or state.seen[recon.id] then okFew = false end
    if state.xp > maxBefore then maxBefore = state.xp end
end
check(okAll, "owning all 20, in " .. RUNS .. " random orders, ends on exactly 3,152")
check(okSome, "owning 18 or 19 ends on exactly 3,152")
check(okFew, "owning 17 never reaches the cap")
print_orig(string.format("runs: %d random orders each; highest XP with 17 entries %d (level %d)", RUNS, maxBefore, Curve.LevelFor(maxBefore)))

-- Every source after the reconstruction is recorded as paid, at zero.
run(band1)
local allPaid = true
for _, id in ipairs(band1) do if not state.seen[id] then allPaid = false end end
check(allPaid, "entries filed after the cap are recorded as paid")

-- 3. Cards ----------------------------------------------------------------
-- Catch-up: the first sync with a filled journal shows one card and no burst.
load_main(nil)
unlocked = { table.unpack(band1, 1, 10) }
tick()
check(#cards == 1 and cards[1].title == string.format(S.CEREMONY_CAUGHT_UP, 10), "catch-up shows one card for 10 records")
check(#announces == 0, "catch-up card replaces the XP announce")
tick()
check(#cards == 1, "catch-up card shows once")

-- First run: an empty-journal character sees the first-run card when its
-- first history entry arrives (tutorials only before that).
load_main(nil)
unlocked = { "JOURNAL_Know_Tutorials_Test" }
tick()
check(#cards == 1 and cards[1].title == S.CEREMONY_FIRST, "first-run card for a character with no records")

-- Correlation note: shown when a correlation completes after catch-up.
load_main(nil)
unlocked = { "JOURNAL_Know_LoreScrap_A2" }
tick()
cards = {}
unlocked[#unlocked + 1] = "JOURNAL_Know_LoreScrap_B4"
tick()
local note = false
for _, c in ipairs(cards) do
    if c.kicker == S.CORRELATION_KICKER and c.text == S.CORRELATION_NOTES["correlation:dragon_attack_sides"] then note = true end
end
check(note, "correlation note shown when the pair completes")
for id, text in pairs(S.CORRELATION_NOTES) do
    local found = false
    for _, s in ipairs(Sources.SETS) do if s.id == id then found = true end end
    check(found, "note " .. id .. " belongs to a correlation")
    local sentences = select(2, text:gsub("[%.!?]%s", "")) + 1
    check(sentences >= 1 and sentences <= 3, "note " .. id .. " is 1-3 sentences")
end

-- Journal note (level 3+) waits while the lore popup is open.
local popupOpen = false
ESL.ScreenOpen = function() return popupOpen end
load_main(nil)
unlocked = {}
for _, id in ipairs(band1) do
    if id ~= "JOURNAL_Know_LoreScrap_C5" then unlocked[#unlocked + 1] = id end
end
tick()
state.xp = 300 -- level 4 for the note test
cards = {}
popupOpen = true
unlocked[#unlocked + 1] = "JOURNAL_Know_LoreScrap_C5"
tick()
local early = 0
for _, c in ipairs(cards) do if c.kicker == S.NOTE_KICKER then early = early + 1 end end
check(early == 0, "journal note waits while the lore popup is open")
popupOpen = false
tick()
local shown = 0
for _, c in ipairs(cards) do if c.kicker == S.NOTE_KICKER then shown = shown + 1 end end
check(shown == 1, "journal note shows once the popup closes")
ESL.ScreenOpen = nil

-- Quiet mode hides Historian's own cards.
load_main("quiet = true\n")
unlocked = { table.unpack(band1, 1, 5) }
tick()
unlocked[#unlocked + 1] = band1[6]
tick()
check(#cards == 0, "quiet mode shows no Historian cards")

-- 4. Site visit -------------------------------------------------------------
local site = Sources.SITES.bramblemead
site.x, site.y = 100000, 50000
run(band1, { x = 0, y = 0 })
check(state.xp < CAP and not state.seen[recon.id], "away from the site the reconstruction waits")
local prompted = 0
for _, c in ipairs(cards) do if c.kicker == S.SITE_KICKER then prompted = prompted + 1 end end
check(prompted <= 1, "site prompt shows at most once")
binds.F7()
check(ESL.lastLedger:find(site.label, 1, true) ~= nil, "ledger points to the site")
world.x, world.y = 100000 + 3000, 50000 - 3000
tick()
check(state.xp == CAP and state.seen[recon.id], "at the site the reconstruction pays to 3,152")
site.x, site.y = nil, nil

-- 5. Ledger -----------------------------------------------------------------
load_main(nil)
unlocked = { "JOURNAL_Know_LoreScrap_B1", "JOURNAL_Know_LoreScrap_B2", "JOURNAL_Know_LoreScrap_B3", "JOURNAL_Know_LoreScrap_B4", "JOURNAL_Know_LoreScrap_D1" }
tick()
binds.F7()
local L = ESL.lastLedger
print_orig("ledger sample:\n" .. L)
check(L:find("Records filed: 4 of 20", 1, true) ~= nil, "ledger counts band 1 records")
check(L:find("Goblin writings 4/5", 1, true) ~= nil, "ledger shows set progress")
check(L:find("Next: finish Goblin writings (1 to find)", 1, true) ~= nil, "ledger next goal is the closest set")
check(L:find("Kept for later: 1 records from Whispering Swamp", 1, true) ~= nil, "ledger region hint for a later band")
check(L:find("Reconstruction: 4 of 18", 1, true) ~= nil, "ledger reconstruction counts to 18")

-- Configurable key.
load_main("ledger_key = F4\n")
check(binds.F4 ~= nil and binds.F7 == nil, "ledger key from config.txt")
load_main("ledger_key = NOT_A_KEY\n")
check(binds.F7 ~= nil, "invalid key falls back to F7")
check(files[SCRIPTS .. "\\..\\config.txt"] ~= nil, "config.txt exists")
files[SCRIPTS .. "\\..\\config.txt"] = nil
load_main(nil)
check((files[SCRIPTS .. "\\..\\config.txt"] or ""):find("ledger_key = F7", 1, true) ~= nil, "config.txt written with defaults")

-- 6. Build warning ------------------------------------------------------------
world.build = "99999999"
load_main(nil)
unlocked = { band1[1] }
tick()
local warned = 0
for _, c in ipairs(cards) do if c.title == S.BUILD_TITLE then warned = warned + 1 end end
check(warned == 1, "untested build shows one warning")
local again = files[SCRIPTS .. "\\..\\build-warned.txt"]
check(again == "99999999", "warned build remembered")
world.build = "25632050"

print = print_orig
print(string.format("%d passed, %d failed", passes, fails))
if fails > 0 then error("historian tests failed") end
