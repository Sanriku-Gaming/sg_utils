Utils = {}

local Core = nil
local frameworkCore = Config.Framework.core:lower()
local target = Config.Framework.target:lower()
local inventory = Config.Framework.inventory:lower()
local notify = Config.Framework.notify:lower()
local fuel = Config.Framework.fuel

----------------------
--  Player Utils    --
----------------------
Utils.Player = {
    getData = function()
        if frameworkCore == 'qb' then
            return Core.Functions.GetPlayerData()
        elseif frameworkCore == 'qbx' then
            return exports.qbx_core:GetPlayerData()
        end
    end,

    getJob = function()
        if frameworkCore == 'qb' then
            return Core.Functions.GetPlayerData().job
        elseif frameworkCore == 'qbx' then
            return exports.qbx_core:GetPlayerData().job or {}
        end
    end,

    getName = function()
        if frameworkCore == 'qb' then
            return Core.Functions.GetPlayerData().charinfo.firstname .. ' ' .. Core.Functions.GetPlayerData().charinfo.lastname
        elseif frameworkCore == 'qbx' then
            local playerData = exports.qbx_core:GetPlayerData()
            return playerData.charinfo.firstname .. ' ' .. playerData.charinfo.lastname
        end
    end,
}

----------------------
-- Inventory Utils  --
----------------------
Utils.Inventory = {
    hasItem = function(item, amount)
        if inventory == 'qb' then
            return exports['qb-inventory']:HasItem(item, amount)
        elseif inventory == 'ps' then
            return exports['ps-inventory']:HasItem(item, amount)
        elseif inventory == 'ox' then
            local count = exports.ox_inventory:Search('count', item)
            return count >= amount
        end
    end,
}

----------------------
--  Vehicle Utils   --
----------------------
Utils.Vehicle = {
    spawn = function(model, coords, engineState)
        local hash = type(model) == 'string' and joaat(model) or model
        lib.requestModel(hash)

        local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, coords.w, true, true)
        while not DoesEntityExist(vehicle) do Wait(10) end

        -- Use provided engine state or default from config
        local useEngineState = engineState
        if useEngineState == nil then
            useEngineState = Config.Vehicle.defaultEngineState
        end

        SetVehicleEngineOn(vehicle, useEngineState, false)
        SetEntityHeading(vehicle, coords.w)
        SetModelAsNoLongerNeeded(hash)
        return vehicle
    end,

    getName = function(model)
        if frameworkCore == 'qb' then
            local data = Core.Shared.Vehicles[model]
            return data and (data.brand .. ' ' .. data.name) or 'Unknown'
        elseif frameworkCore == 'qbx' then
            local data = exports.qbx_core:GetVehiclesByName(model)
            return data and (data.brand .. ' ' .. data.name) or 'Unknown'
        end
    end,

    getPlate = function(vehicle)
        return GetVehicleNumberPlateText(vehicle)
    end,

    giveKeys = function(vehicle, plate)
        TriggerEvent('vehiclekeys:client:SetOwner', plate)
    end,

    setFuel = function(vehicle, plate, amount)
        if fuel == 'ox_fuel' then
            Entity(vehicle).state:set('fuel', amount or 100.0)
        else
            exports[fuel]:SetFuel(vehicle, amount or 100.0)
        end
    end,

    maxMods = function(vehicle, customModIndexes)
        local modIndexes = customModIndexes or Config.Vehicle.defaultModIndexes
        if not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then return end

        SetVehicleModKit(vehicle, 0)
        for _, modType in ipairs(modIndexes) do
            local max = GetNumVehicleMods(vehicle, modType) - 1
            SetVehicleMod(vehicle, modType, max, false)
        end
        ToggleVehicleMod(vehicle, 18, true) -- Turbo
        SetVehicleFixed(vehicle)
    end,
}

----------------------
--    Ped Utils     --
----------------------
Utils.Ped = {
    spawn = function(model, coords)
        local hash = type(model) == 'string' and joaat(model) or model
        lib.requestModel(hash)

        local ped = CreatePed(4, hash, coords.x, coords.y, coords.z - 1, coords.w, false, true)
        while not DoesEntityExist(ped) do Wait(10) end

        SetEntityAsMissionEntity(ped, true, true)
        SetEntityHeading(ped, coords.w)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetModelAsNoLongerNeeded(hash)
        return ped
    end,

    scenario = function(ped, scenario)
        TaskStartScenarioInPlace(ped, scenario, 0, true)
    end,
}

----------------------
--    UI Utils      --
----------------------
Utils.UI = {
    sendNotify = function(message, type, duration, title)
        local notifyDuration = duration or Config.Notifications.defaultDuration
        local notifyTitle = title or Config.Notifications.title

        if notify == 'qb' then
            Core.Functions.Notify(message, type, notifyDuration)
        elseif notify == 'okok' then
            exports['okokNotify']:Alert(notifyTitle, message, notifyDuration, type, false)
        elseif notify == 'ox' then
            lib.notify({
                title = notifyTitle,
                description = message,
                type = type,
                duration = notifyDuration
            })
        end
    end,

    addTarget = function(entity, options, distance, name)
        local targetDistance = distance or Config.UI.defaultTargetDistance

        if target == 'qb' then
            return exports['qb-target']:AddTargetEntity(entity, {
                options = options,
                distance = targetDistance
            })
        elseif target == 'ox' then
            local oxOptions = {}

            for i, option in ipairs(options) do
                local oxOption = {
                    name = name .. i,
                    label = option.label,
                    distance = targetDistance
                }

                if option.canInteract then
                    oxOption.canInteract = option.canInteract
                end

                if option.action then
                    oxOption.onSelect = option.action
                end

                table.insert(oxOptions, oxOption)
            end

            return exports.ox_target:addLocalEntity(entity, oxOptions)
        end
    end,

    removeTarget = function(target, name)
        if target == 'qb' then
            exports['qb-target']:RemoveZone(target)
        elseif target == 'ox' then
            exports.ox_target:removeLocalEntity(target, name)
        end
    end,

    sendDispatch = function(options)
        -- Default options
        local defaults = {
            title = 'Alert',          -- Alert title
            description = '',         -- Alert description
            location = '',            -- Location description (can be empty)
            coords = vector3(0,0,0),  -- Alert coordinates
            code = '10-31',           -- Alert code
            sprite = 51,              -- Blip sprite
            color = 1,                -- Blip color
            scale = 1.0,              -- Blip scale
            length = 5,               -- Alert duration in minutes
            jobs = {'police'},        -- Jobs to receive the alert
            sound = true              -- Play sound (boolean)
        }

        for k, v in pairs(defaults) do
            if not options[k] then options[k] = v end
        end

        local dispatch = Config.Framework.dispatch:lower()

        if dispatch == 'cd' then
            local data = exports['cd_dispatch']:GetPlayerInfo()
            local jobsTable = {}

            for _, jobName in ipairs(options.jobs) do
                table.insert(jobsTable, jobName)
            end

            TriggerServerEvent('cd_dispatch:AddNotification', {
                job_table = jobsTable,
                coords = options.coords or data.coords,
                title = options.title,
                message = options.description,
                flash = 0,
                unique_id = tostring(math.random(0000000, 9999999)),
                blip = {
                    sprite = options.sprite,
                    scale = options.scale,
                    colour = options.color,
                    flashes = false,
                    text = options.title,
                    time = (options.length * 60 * 1000),
                    sound = options.sound and 1 or 0,
                }
            })
        elseif dispatch == 'ps' then
            exports['ps-dispatch']:CustomAlert({
                coords = options.coords,
                message = options.title,
                dispatchCode = options.code,
                description = options.description,
                radius = 0,
                sprite = options.sprite,
                color = options.color,
                scale = options.scale,
                length = options.length,
            })
        else
            local description = options.location ~= ''
                and options.description .. ' | ' .. options.location
                or options.description

            TriggerServerEvent('police:server:policeAlert', description)
        end
    end
}

----------------------
--   World Utils    --
----------------------
Utils.World = {
    isSpawnClear = function(coords, radius)
        if coords then
            coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
        else
            coords = GetEntityCoords(PlayerPedId())
        end

        local vehicles = GetGamePool('CVehicle')

        for i = 1, #vehicles do
            if DoesEntityExist(vehicles[i]) then
                local vehicleCoords = GetEntityCoords(vehicles[i])
                local distance = #(vehicleCoords - coords)
                if distance <= radius then
                    return false
                end
            end
        end

        return true
    end,

    clearAreaOfNPCVehicles = function(coords, radius)
        local vehicles = GetGamePool('CVehicle')
        local missionVehicleHandle = missionVehicle or 0
        local deletedCount = 0

        for _, vehicle in ipairs(vehicles) do
            if vehicle ~= missionVehicleHandle and DoesEntityExist(vehicle) then
                local distance = #(coords - GetEntityCoords(vehicle))

                if distance <= radius then
                    local isPlayerVehicle = IsVehiclePreviouslyOwnedByPlayer(vehicle)
                    local hasDriver = GetPedInVehicleSeat(vehicle, -1) ~= 0

                    if not isPlayerVehicle and not hasDriver then
                        if IsEntityAttached(vehicle) then
                            DetachEntity(vehicle, true, true)
                            Wait(50)
                        end

                        SetEntityAsMissionEntity(vehicle, true, true)
                        DeleteEntity(vehicle)
                        deletedCount = deletedCount + 1
                    end
                end
            end
        end

        if Config.Debug and deletedCount > 0 then
            print('Cleared area: deleted ' .. deletedCount .. ' vehicles')
        end

        return deletedCount > 0
    end,

    getStreetName = function(coords)
        local street, crossing = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        return {
            main = GetStreetNameFromHashKey(street),
            cross = GetStreetNameFromHashKey(crossing)
        }
    end,

    getClosestPed = function(coords, peds)
        local closestPed, closestDistance = nil, -1
        for _, ped in ipairs(peds) do
            local pedCoords = GetEntityCoords(ped)
            local distance = #(coords - pedCoords)
            if closestDistance == -1 or distance < closestDistance then
                closestPed = ped
                closestDistance = distance
            end
        end
        return closestPed, closestDistance
    end,

    isPedNearby = function(radius, ignorePeds)
        radius = radius or 20.0
        ignorePeds = ignorePeds or {}

        local ignoreList = {}
        for _, ped in ipairs(ignorePeds) do
            ignoreList[ped] = true
        end

        local playerPed = PlayerPedId()
        ignoreList[playerPed] = true

        local peds = GetGamePool('CPed')
        local coords = GetEntityCoords(playerPed)

        for _, ped in ipairs(peds) do
            if DoesEntityExist(ped) and not ignoreList[ped] then
                if not IsPedAPlayer(ped) then
                    local distance = #(coords - GetEntityCoords(ped))
                    if distance <= radius then
                        return true
                    end
                end
            end
        end

        return false
    end,

    setOutline = function(entity, enable, r, g, b, a)
        if not entity or not DoesEntityExist(entity) then return end

        if enable then
            NetworkRequestControlOfEntity(entity)
            SetEntityDrawOutline(entity, true)
            SetEntityDrawOutlineColor(r or 0, g or 0, b or 253, a or 255)
            return true
        else
            SetEntityDrawOutline(entity, false)
            return false
        end
    end
}

----------------------
--    Framework     --
----------------------
CreateThread(function()
    if frameworkCore == 'qb' then
        Core = exports['qb-core']:GetCoreObject()
    elseif frameworkCore == 'qbx' then
        -- QBX doesn't use a Core object, it uses direct exports
        -- No initialization needed
    end
end)

-- Return Utils so it can be accessed via the export
return Utils