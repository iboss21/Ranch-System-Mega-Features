local Config = require("shared.config")
local Utils = require("shared.utils")

local Storage = {}
Storage.__index = Storage

local function loadJson(path, fallback)
    local jsonData = LoadResourceFile(GetCurrentResourceName(), path)
    if jsonData then
        local success, decoded = pcall(json.decode, jsonData)
        if success and decoded then
            return decoded
        end
    end
    return fallback or {}
end

local function saveJson(path, payload)
    SaveResourceFile(GetCurrentResourceName(), path, json.encode(payload, { indent = true }), -1)
end

function Storage.new(path)
    local self = setmetatable({}, Storage)
    self.path = path
    self.cache = loadJson(path, {})
    return self
end

function Storage:Get(key)
    if not key then return self.cache end
    return self.cache[key]
end

function Storage:Set(key, value)
    if not key then return end
    self.cache[key] = value
    self:Persist()
end

function Storage:Delete(key)
    if not key then return end
    self.cache[key] = nil
    self:Persist()
end

function Storage:Persist()
    saveJson(self.path, self.cache)
end

function Storage:All()
    return self.cache
end

local RanchStorage = Storage.new(Config.Storage.RanchFile)
local VegetationStorage = Storage.new(Config.Storage.VegetationFile)

return {
    Storage = Storage,
    Ranches = RanchStorage,
    Vegetation = VegetationStorage
}
