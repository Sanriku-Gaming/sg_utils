Utils = Utils or {}

local Core = nil
local frameworkCore = Config.Framework.core:lower()
local targetScript = Config.Framework.target:lower()
local inventory = Config.Framework.inventory:lower()
local notify = Config.Framework.notify:lower()
local dispatch = Config.Framework.dispatch:lower()
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

    isOnDuty = function()
        local PlayerData = Utils.Player.getData()
        return PlayerData.job.onduty
    end,

    toggleDuty = function()
        TriggerServerEvent("QBCore:ToggleDuty")
        Wait(200)
        local PlayerData = Utils.Player.getData()
        return PlayerData.job.onduty
    end,

    setDuty = function(state)
        local currentState = Utils.Player.isOnDuty()
        if state == currentState then
            return currentState
        end

        TriggerServerEvent("QBCore:ToggleDuty")
        Wait(200)
        local PlayerData = Utils.Player.getData()
        return PlayerData.job.onduty
    end,
}

-----------------------
--   Shared Utils    --
-----------------------
Utils.Shared = {
    getGangData = function(gangName)
        if frameworkCore == 'qb' then
            return gangName and Core.Shared.Gangs[gangName] or Core.Shared.Gangs
        elseif frameworkCore == 'qbx' then
            return gangName and exports.qbx_core:GetGangs()[gangName] or exports.qbx_core:GetGangs()
        end
    end,

    getJobData = function(jobName)
        if frameworkCore == 'qb' then
            return jobName and Core.Shared.Jobs[jobName] or Core.Shared.Jobs
        elseif frameworkCore == 'qbx' then
            return jobName and exports.qbx_core:GetJobs()[jobName] or exports.qbx_core:GetJobs()
        end
    end,

    getGradeData = function(entityType, entityName, gradeLevel)
        if entityType == 'job' then
            if frameworkCore == 'qb' then
                return Core.Shared.Jobs[entityName].grades[tostring(gradeLevel)]
            elseif frameworkCore == 'qbx' then
                return exports.qbx_core:GetJobs()[entityName].grades[gradeLevel]
            end
        elseif entityType == 'gang' then
            if frameworkCore == 'qb' then
                return Core.Shared.Gangs[entityName].grades[tostring(gradeLevel)]
            elseif frameworkCore == 'qbx' then
                return exports.qbx_core:GetGangs()[entityName].grades[gradeLevel]
            end
        end
        return nil
    end,

    getItemLabel = function(itemName)
        if frameworkCore == 'qb' then
            return Core.Shared.Items[itemName]?.label or itemName
        elseif frameworkCore == 'qbx' then
            return exports.qbx_core:GetItems()[itemName]?.label or itemName
        end
    end
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

    addCircleZone = function(name, coords, radius, zoneOptions, targetOptions)
        local zoneName = name or "circle_" .. math.random(1000, 9999)

        if targetScript == 'qb' then
            return exports['qb-target']:AddCircleZone(zoneName, coords, radius, {
                name = zoneName,
                useZ = zoneOptions.useZ,
                debugPoly = zoneOptions.debugPoly
            }, {
                options = targetOptions,
                distance = zoneOptions.distance or 2.5
            })
        elseif targetScript == 'ox' then
            local oxOptions = {}
            for i, option in ipairs(targetOptions) do
                local oxOption = {
                    name = zoneName .. i,
                    label = option.label
                }
                if option.icon then
                    oxOption.icon = option.icon
                end
                if option.canInteract then
                    oxOption.canInteract = option.canInteract
                end
                if option.action then
                    oxOption.onSelect = option.action
                end
                table.insert(oxOptions, oxOption)
            end
            return exports.ox_target:addSphereZone({
                coords = coords,
                radius = radius,
                debug = zoneOptions.debugPoly,
                options = oxOptions
            })
        end
    end,

    addBoxZone = function(name, coords, length, width, menuOptions, zoneOptions)
        local zoneName = name or "box_" .. math.random(1000, 9999)
        local heading = zoneOptions.heading or 0
        local distance = zoneOptions.distance or 2.5

        if targetScript == 'qb' then
            return exports['qb-target']:AddBoxZone(zoneName, coords, length, width, {
                name = zoneName,
                heading = heading,
                debugPoly = zoneOptions.debugPoly or false,
                minZ = zoneOptions.minZ,
                maxZ = zoneOptions.maxZ
            }, {
                options = menuOptions or {},
                distance = distance
            })
        elseif targetScript == 'ox' then
            local oxOptions = {}
            for i, option in ipairs(menuOptions or {}) do
                local oxOption = {
                    name = zoneName .. i,
                    label = option.label
                }
                if option.icon then
                    oxOption.icon = option.icon
                end
                if option.canInteract then
                    oxOption.canInteract = option.canInteract
                end
                if option.action then
                    oxOption.onSelect = option.action
                end
                table.insert(oxOptions, oxOption)
            end

            local height = 2.0
            if zoneOptions.minZ and zoneOptions.maxZ then
                height = zoneOptions.maxZ - zoneOptions.minZ
            end

            return exports.ox_target:addBoxZone({
                coords = coords,
                size = vec3(length, width, height),
                rotation = heading,
                debug = zoneOptions.debugPoly or false,
                options = oxOptions
            })
        end
    end,

    addTargetEntity = function(name, entity, options, distance)
        local targetName = name or "target_" .. math.random(1000, 9999)
        local targetDistance = distance or Config.UI.defaultTargetDistance

        if targetScript == 'qb' then
            return exports['qb-target']:AddTargetEntity(entity, {
                options = options,
                distance = targetDistance
            })
        elseif targetScript == 'ox' then
            local oxOptions = {}

            for i, option in ipairs(options) do
                local oxOption = {
                    name = targetName .. i,
                    label = option.label,
                    distance = targetDistance
                }

                if option.icon then
                    oxOption.icon = option.icon
                end

                if option.canInteract then
                    oxOption.canInteract = option.canInteract
                end

                if option.action then
                    oxOption.onSelect = option.action
                end

                table.insert(oxOptions, oxOption)
            end

            if NetworkGetEntityIsNetworked(entity) then
                local netId = NetworkGetNetworkIdFromEntity(entity)
                return exports.ox_target:addNetworkEntity({netId}, oxOptions)
            else
                return exports.ox_target:addLocalEntity(entity, oxOptions)
            end
        end
    end,

    removeZone = function(target, name)
        if targetScript == 'qb' then
            exports['qb-target']:RemoveZone(target)
        elseif targetScript == 'ox' then
            if name then
                exports.ox_target:removeZone(name)
            else
                exports.ox_target:removeZone(target)
            end
        end
    end,

    removeTarget = function(target, name, type)
        if targetScript == 'qb' then
            exports['qb-target']:RemoveZone(target)
        elseif targetScript == 'ox' then
            type = type or 'entity'

            if type == 'entity' then
                exports.ox_target:removeLocalEntity(target, name)
            elseif type == 'networked' then
                exports.ox_target:removeNetworkEntity(target, name)
            elseif type == 'zone' then
                exports.ox_target:removeZone(name or target)
            end
        end
    end,

    sendDispatch = function(options)
        -- Default options
        local defaults = {
            title = 'Alert',                    -- Alert title
            description = '',                   -- Alert description
            location = '',                      -- Location description (can be empty)
            coords = vector3(0,0,0),            -- Alert coordinates
            code = '10-31',                     -- Alert code
            sprite = 51,                        -- Blip sprite
            color = 1,                          -- Blip color
            scale = 1.0,                        -- Blip scale
            length = 5,                         -- Alert duration in minutes
            jobs = {'police'},                  -- Jobs to receive the alert
            sound = true                        -- Play sound (boolean)
        }

        for k, v in pairs(defaults) do
            if not options[k] then options[k] = v end
        end

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
        elseif dispatch == 'sonoran' then
            TriggerServerEvent('sg_utils:server:SonoranDispatch', options)
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
        local radiusSquared = radius * radius

        for _, vehicle in ipairs(vehicles) do
            if vehicle ~= missionVehicleHandle and DoesEntityExist(vehicle) then
                local vehicleCoords = GetEntityCoords(vehicle)

                local dx, dy, dz = coords.x - vehicleCoords.x, coords.y - vehicleCoords.y, coords.z - vehicleCoords.z
                local distSquared = dx*dx + dy*dy + dz*dz

                if distSquared <= radiusSquared then
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

    getZoneName = function(coords)
        return GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
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

return Utils