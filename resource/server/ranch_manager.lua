local Config = require("shared.config")
local Utils = require("shared.utils")
local Storage = require("server.storage")

local RanchManager = {}
RanchManager.Ranches = Storage.Ranches:Get()
RanchManager.Vegetation = Storage.Vegetation:Get()

local function ensureRanch(id)
    if not RanchManager.Ranches[id] then
        RanchManager.Ranches[id] = {
            id = id,
            name = "",
            owner = nil,
            members = {},
            parcels = {},
            props = {},
            metadata = {},
            discordRoleId = nil,
            createdAt = Utils.Timestamp()
        }
    end
    return RanchManager.Ranches[id]
end

local function save()
    Storage.Ranches:Persist()
    Storage.Vegetation:Persist()
end

function RanchManager.CreateRanch(name, ownerIdentifier, metadata)
    if not name or name == "" then return nil, "Name required" end
    local id = Utils.GenerateRanchId()
    while RanchManager.Ranches[id] do
        id = Utils.GenerateRanchId()
    end
    local ranch = ensureRanch(id)
    ranch.name = name
    ranch.owner = ownerIdentifier
    ranch.metadata = metadata or {}
    RanchManager.Ranches[id] = ranch
    save()
    return ranch
end

function RanchManager.DeleteRanch(id)
    if not RanchManager.Ranches[id] then
        return false, "Ranch not found"
    end
    RanchManager.Ranches[id] = nil
    Storage.Ranches:Delete(id)
    return true
end

function RanchManager.TransferOwnership(id, newOwner)
    local ranch = RanchManager.Ranches[id]
    if not ranch then return false, "Ranch not found" end
    ranch.owner = newOwner
    save()
    TriggerEvent("ranch:ownershipChanged", id, newOwner)
    return true, ranch
end

function RanchManager.SetDiscordRole(id, roleId)
    local ranch = RanchManager.Ranches[id]
    if not ranch then return false, "Ranch not found" end
    ranch.discordRoleId = roleId
    save()
    return true, ranch
end

function RanchManager.GetOrCreate(id)
    return ensureRanch(id)
end

function RanchManager.Get(id)
    return RanchManager.Ranches[id]
end

function RanchManager.UpdateParcels(id, parcels)
    local ranch = ensureRanch(id)
    ranch.parcels = parcels
    save()
    TriggerClientEvent("ranch:zones:sync", -1, id, parcels)
end

function RanchManager.List()
    return RanchManager.Ranches
end

-- Vegetation & zoning

local function ensureZone(zoneId)
    if not RanchManager.Vegetation[zoneId] then
        RanchManager.Vegetation[zoneId] = {
            id = zoneId,
            vegetation = Config.ZoneDefaults.VegetationState,
            wildlife = Config.ZoneDefaults.WildlifeDensity,
            fertility = Config.ZoneDefaults.SoilFertility,
            points = {},
            ranchId = nil
        }
    end
    return RanchManager.Vegetation[zoneId]
end

function RanchManager.SaveVegetation(zoneId, data)
    local zone = ensureZone(zoneId)
    for key, value in pairs(data or {}) do
        zone[key] = value
    end
    save()
    TriggerClientEvent("ranch:vegetation:update", -1, zoneId, zone)
    return zone
end

function RanchManager.AssignZone(zoneId, ranchId)
    local zone = ensureZone(zoneId)
    zone.ranchId = ranchId
    save()
    return zone
end

function RanchManager.GetZone(zoneId)
    return RanchManager.Vegetation[zoneId]
end

function RanchManager.AllZones()
    return RanchManager.Vegetation
end

-- Discord bridging (placeholder HTTP integration)
local function dispatchDiscord(eventName, payload)
    if Config.Discord.WebhookUrl == "" then return end
    PerformHttpRequest(Config.Discord.WebhookUrl, function(err, text, headers)
        if err ~= 200 then
            print("[RanchSystem] Discord webhook error", err, text or "")
        end
    end, "POST", json.encode({ username = "Ranch System", embeds = { payload } }), { ["Content-Type"] = "application/json" })
end

AddEventHandler("ranch:ownershipChanged", function(ranchId, ownerIdentifier)
    if not Config.Discord.UseRoles then return end
    local ranch = RanchManager.Ranches[ranchId]
    if not ranch then return end
    local embed = {
        title = "Ranch Ownership Updated",
        description = ("Ranch **%s** now owned by `%s`"):format(ranch.name, ownerIdentifier or "Unknown"),
        color = 65280,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    dispatchDiscord("ownershipChanged", embed)
end)

return RanchManager
