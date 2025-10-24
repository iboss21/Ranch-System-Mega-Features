local Config = require("shared.config")

local Utils = {}

local identifierMap = {
    license = "license:",
    steam = "steam:",
    discord = "discord:",
    cid = "cid:",
    citizenid = "cid:"
}

local function trim(str)
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end

function Utils.IsAdmin(source)
    if source <= 0 then return true end
    if Config.Admin.AcePermission and Config.Admin.AcePermission ~= "" then
        if IsPlayerAceAllowed(source, Config.Admin.AcePermission) then return true end
    end

    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if Config.Admin.Identifiers[id] then return true end
    end
    return false
end

function Utils.FindIdentifier(source, preferred)
    local identifiers = source and GetPlayerIdentifiers(source) or {}
    local needle = preferred and identifierMap[preferred]

    if needle then
        for _, identifier in ipairs(identifiers) do
            if identifier:sub(1, #needle) == needle then
                return identifier
            end
        end
    end

    for _, key in ipairs(Config.IdentifierPriority) do
        local prefix = identifierMap[key]
        if prefix then
            for _, identifier in ipairs(identifiers) do
                if identifier:sub(1, #prefix) == prefix then
                    return identifier
                end
            end
        end
    end

    return identifiers[1]
end

function Utils.NormalizeIdentifier(value)
    if not value or value == "" then return nil end
    value = trim(value)
    for key, prefix in pairs(identifierMap) do
        if value:sub(1, #prefix) == prefix then
            return value
        end
    end

    if value:match("^%d+$") then
        return identifierMap.discord .. value
    end

    if value:match("^[A-Za-z0-9]+$") then
        return identifierMap.cid .. value
    end

    return value
end

function Utils.GetTargetIdentifier(args, source)
    local supplied = args and args[1]
    if supplied then
        local normalized = Utils.NormalizeIdentifier(supplied)
        if normalized then return normalized end
    end
    if Config.AllowIdTransferFromSource and source and source > 0 then
        local sourceIdentifier = Utils.FindIdentifier(source)
        if sourceIdentifier then return sourceIdentifier end
    end
    return nil
end

function Utils.DebugLog(...)
    if not Config.Debug then return end
    print("[RanchSystem]", ...)
end

function Utils.GenerateRanchId()
    return ("ranch_%s"):format(math.random(100000, 999999))
end

function Utils.Timestamp()
    return os.time(os.date("!*t"))
end

return Utils
