Config = {}

-- ## ADMINISTRATION ##
Config.Admin = {
    AcePermission = "ranch.admin",
    Identifiers = {
        -- Add identifiers (license:, steam:, discord:) that should have admin access
    }
}

Config.IdentifierPriority = { "license", "citizenid", "cid", "discord" }

Config.Discord = {
    UseRoles = true,
    BotToken = "", -- supply if you implement HTTP webhook sync
    GuildId = "",
    OwnershipRolePrefix = "Ranch Owner - ",
    WebhookUrl = ""
}

-- ## RANCH SETTINGS ##
Config.MaxRanchesPerPlayer = 2
Config.AutoCreateDiscordRoles = true
Config.AllowCitizenIdFallback = true
Config.AllowIdTransferFromSource = true

-- ## ZONING & VEGETATION ##
Config.ZoneDefaults = {
    VegetationState = 1.0, -- 0 barren, 1 lush
    WildlifeDensity = 1.0,
    SoilFertility = 1.0
}

Config.Zoning = {
    EnablePZCreate = true,
    CreatorCommand = "pzcreate",
    SaveCommand = "pzsave",
    CancelCommand = "pzcancel",
    PreviewBlipSprite = 1873519383,
    PreviewBlipColor = 0
}

Config.Props = {
    PlacerCommand = "ranchprop",
    RemoverCommand = "ranchpropdel",
    UsableProps = {
        ["p_barrel03x"] = { label = "Water Barrel", type = "utility" },
        ["p_haybale02x"] = { label = "Hay Bale", type = "fodder" },
        ["p_trough01x"] = { label = "Feeding Trough", type = "utility" }
    }
}

Config.Storage = {
    RanchFile = "data/ranches.json",
    VegetationFile = "data/vegetation.json"
}

Config.Debug = false

return Config
