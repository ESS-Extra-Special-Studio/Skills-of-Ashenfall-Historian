-- Player settings: config.txt next to the Scripts folder. It is written with
-- the defaults on first run; a missing or invalid value uses the default.
local Config = {}

local FIELDS = {
    { key = "ledger_key", default = "F7", kind = "key",
      help = "Key that shows or hides the Historian ledger (a UE4SS key name, such as F7 or NUM_SEVEN)." },
    { key = "quiet", default = "false", kind = "bool",
      help = "true hides Historian's own cards (journal notes, correlation notes, the catch-up card). XP and level-up notifications still show." },
    { key = "debug", default = "false", kind = "bool",
      help = "true writes extra detail to UE4SS.log, such as every journal entry filed and read." },
}

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function parse(text)
    local out = {}
    for line in (text or ""):gmatch("[^\r\n]+") do
        local k, v = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
        if k and not line:match("^%s*#") then out[k:lower()] = trim(v) end
    end
    return out
end

local function default_text()
    local lines = { "# Skills of Ashenfall: Historian settings. Restart the game after editing.", "" }
    for _, f in ipairs(FIELDS) do
        lines[#lines + 1] = "# " .. f.help
        lines[#lines + 1] = f.key .. " = " .. f.default
        lines[#lines + 1] = ""
    end
    return table.concat(lines, "\n")
end

-- Returns the settings table. log reports values that were not understood.
function Config.Load(dir, log)
    local path = dir .. "\\..\\config.txt"
    local f = io.open(path, "r")
    local raw = {}
    if f then
        raw = parse(f:read("*a"))
        f:close()
    else
        local w = io.open(path, "w")
        if w then
            w:write(default_text())
            w:close()
        end
    end
    local out = {}
    for _, field in ipairs(FIELDS) do
        local v = raw[field.key]
        local value = nil
        if field.kind == "bool" then
            if v == "true" or v == "1" or v == "yes" then value = true
            elseif v == nil or v == "" or v == "false" or v == "0" or v == "no" then value = false end
        elseif field.kind == "key" then
            local name = (v and v ~= "") and v:upper() or field.default
            if Key and Key[name] ~= nil then value = name end
        end
        if value == nil then
            if log then log("config.txt: " .. field.key .. " = " .. tostring(v) .. " is not understood; using " .. field.default) end
            if field.kind == "bool" then value = field.default == "true" else value = field.default end
        end
        out[field.key] = value
    end
    return out
end

return Config
