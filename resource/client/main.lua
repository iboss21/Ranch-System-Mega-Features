local Config = require("shared.config")

local RanchClient = {
    ranches = {},
    zones = {},
    vegetation = {},
    props = {}
}

local function debugPrint(...)
    if not Config.Debug then return end
    print("[RanchClient]", ...)
end

RegisterNetEvent("ranch:zones:sync", function(ranchId, parcels)
    debugPrint("Received parcel sync", ranchId)
    RanchClient.zones[ranchId] = parcels
    TriggerEvent("ranch:zones:updated", ranchId, parcels)
end)

RegisterNetEvent("ranch:vegetation:update", function(zoneId, payload)
    RanchClient.vegetation[zoneId] = payload
    TriggerEvent("ranch:vegetation:updated", zoneId, payload)
end)

RegisterNetEvent("ranch:vegetation:bulk", function(payload)
    RanchClient.vegetation = payload or {}
    TriggerEvent("ranch:vegetation:bulkUpdated", payload)
end)

RegisterNetEvent("ranch:props:update", function(ranchId, props)
    RanchClient.props[ranchId] = props
    TriggerEvent("ranch:props:updated", ranchId, props)
end)

exports("GetRanchZones", function()
    return RanchClient.zones
end)

exports("GetVegetation", function()
    return RanchClient.vegetation
end)

exports("GetProps", function()
    return RanchClient.props
end)

return RanchClient
