Config = {}

-- Debug settings
Config.Debug = true                                    -- Enable debug mode for additional console output

Config.Framework = {
    core        = 'qb',                                 -- 'qb' or 'qbx'
    inventory   = 'qb',                                 -- 'qb', 'ps', or 'ox'
    target      = 'qb',                                 -- 'qb' or 'ox'
    notify      = 'qb',                                 -- 'qb', 'okok', or 'ox'
    banking     = 'qb',                                 -- 'qb', 'qs', or 'renewed'
    dispatch    = 'qb',                                 -- 'qb', 'cd', 'ps', 'sonoran'
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

-- Date and time formats
Config.DateTime = {
    default = 1,
    formats = {
        [1] = "%m/%d/%Y %H:%M",
        [2] = "%Y/%m/%d %H:%M",
        [3] = "%d/%m/%Y %H:%M",
        [4] = "%m/%d/%Y %H:%M:%S",
        [5] = "%H:%M:%S %d/%m/%Y",
        [6] = "%B %d, %Y %H:%M"
    }
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

-- Dispatch defaults
Config.DispatchDefaults = {
    title = 'Alert',
    description = '',
    location = '',
    coords = vector3(0,0,0),
    code = '10-31',
    sprite = 51,
    color = 1,
    scale = 1.0,
    length = 5,
    jobs = Config.PoliceJobs,
    sound = true
}