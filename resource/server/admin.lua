local Config = require("shared.config")
local Utils = require("shared.utils")
local RanchManager = require("server.ranch_manager")

local function ensureAdmin(source)
    if not Utils.IsAdmin(source) then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "You do not have permission." } })
        return false
    end
    return true
end

local function resolveOwnerIdentifier(source, identifierArg)
    local args = {}
    if identifierArg then
        args[1] = identifierArg
    end
    local target = Utils.GetTargetIdentifier(args, source)
    if not target then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Unable to determine identifier." } })
        return nil
    end
    return target
end

RegisterCommand("ranchcreate", function(source, args)
    if not ensureAdmin(source) then return end
    local name = args[1]
    if not name then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchcreate <Name> [identifier]" } })
        return
    end
    local ownerIdentifier = resolveOwnerIdentifier(source, args[2])
    local ranch, err = RanchManager.CreateRanch(name, ownerIdentifier)
    if not ranch then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", err or "Failed to create ranch." } })
        return
    end
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", ("Created ranch %s (%s)"):format(ranch.name, ranch.id) } })
end, false)

RegisterCommand("ranchdelete", function(source, args)
    if not ensureAdmin(source) then return end
    local id = args[1]
    if not id then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchdelete <RanchId>" } })
        return
    end
    local success, err = RanchManager.DeleteRanch(id)
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and ("Deleted ranch %s"):format(id) or err } })
end, false)

RegisterCommand("ranchtransfer", function(source, args)
    if not ensureAdmin(source) then return end
    local id = args[1]
    if not id then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchtransfer <RanchId> <identifier>" } })
        return
    end
    local identifier = resolveOwnerIdentifier(source, args[2])
    if not identifier then return end
    local success, result = RanchManager.TransferOwnership(id, identifier)
    if not success then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", result or "Transfer failed" } })
        return
    end
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", ("Transferred %s to %s"):format(id, identifier) } })
end, false)

RegisterCommand("ranchsetrole", function(source, args)
    if not ensureAdmin(source) then return end
    local id, role = args[1], args[2]
    if not id or not role then
        TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", "Usage: /ranchsetrole <RanchId> <RoleId>" } })
        return
    end
    local success, err = RanchManager.SetDiscordRole(id, role)
    TriggerClientEvent("chat:addMessage", source, { args = { "Ranch", success and ("Role %s assigned to %s"):format(role, id) or err } })
end, false)

RegisterNetEvent("ranch:zones:save", function(zoneId, payload)
    if not ensureAdmin(source) then return end
    RanchManager.SaveVegetation(zoneId, payload)
end)

RegisterNetEvent("ranch:zones:assign", function(zoneId, ranchId)
    if not ensureAdmin(source) then return end
    RanchManager.AssignZone(zoneId, ranchId)
end)

RegisterNetEvent("ranch:props:save", function(ranchId, props)
    if not ensureAdmin(source) then return end
    local ranch = RanchManager.GetOrCreate(ranchId)
    ranch.props = props
    TriggerClientEvent("ranch:props:update", -1, ranchId, props)
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    -- placeholder for Discord sync or role enforcement
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for id, data in pairs(RanchManager.Ranches) do
        TriggerClientEvent("ranch:zones:sync", -1, id, data.parcels or {})
        if data.props then
            TriggerClientEvent("ranch:props:update", -1, id, data.props)
        end
    end
    TriggerClientEvent("ranch:vegetation:bulk", -1, RanchManager.Vegetation)
end)
