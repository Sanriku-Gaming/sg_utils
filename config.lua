Config = {}

-- Debug settings
Config.Debug = true                                    -- Enable debug mode for additional console output

Config.Framework = {
    core        = 'qb',                                 -- 'qb' or 'qbx'
    inventory   = 'qb',                                 -- 'qb', 'ps', or 'ox'
    target      = 'qb',                                 -- 'qb' or 'ox'
    notify      = 'qb',                                 -- 'qb', 'okok', or 'ox'
    banking     = 'qb',                                 -- 'qb', 'qs', or 'renewed'
    dispatch    = 'qb',                                 -- 'qb', 'cd', 'ps'
    fuel        = 'LegacyFuel',                         -- 'LegacyFuel', 'ps-fuel', 'ox_fuel', etc.
}

-- Notification settings
Config.Notifications = {
    title = 'Notification',                             -- Default notification title
    defaultDuration = 5000,                             -- Default notification duration in ms
}

-- UI settings
Config.UI = {
    defaultTargetDistance = 2.0,                        -- Default target interaction distance
}

-- Vehicle settings
Config.Vehicle = {
    defaultEngineState = false,                         -- Default engine state when spawning vehicles
    defaultModIndexes = { 11, 12, 13, 15, 16 },         -- Default mod indexes for maxMods function
}

Config.PoliceJobs = {                                   -- Default police jobs, used in Utils.Player.getPoliceCount()
    'police',
    'sheriff'
}

Config.EMSJobs = {                                      -- Default EMS jobs, used in Utils.Player.getEMSCount()
    'ambulance',
}