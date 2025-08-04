Utils = Utils or {}

local Core = nil
local frameworkCore = Config.Framework.core:lower()
local inventory = Config.Framework.inventory:lower()
local notify = Config.Framework.notify:lower()
local banking = Config.Framework.banking:lower()

----------------------
--  Player Utils    --
----------------------
Utils.Player = {
    ---@param player table Player object
    ---@param permission string Permission to check
    ---@return boolean hasPermission
    hasPermission = function(player, permission)
        if frameworkCore == 'qb' then
            return Core.Functions.HasPermission(player.PlayerData.source, permission)
        elseif frameworkCore == 'qbx' then
            return exports.qbx_core:HasPermission(player.PlayerData.source, permission)
        end
    end,

    ---@param source number Players server ID
    ---@return table|nil player Player object or nil if not found
    getPlayer = function(source)
        if frameworkCore == 'qb' then
            return Core.Functions.GetPlayer(source) or nil
        elseif frameworkCore == 'qbx' then
            return exports.qbx_core:GetPlayer(source) or nil
        end
    end,

    ---@param citizenid string Player's citizen ID
    ---@return table|nil player Player object or nil if not found
    getPlayerByCitizenId = function(citizenid)
        if frameworkCore == 'qb' then
            return Core.Functions.GetPlayerByCitizenId(citizenid) or nil
        elseif frameworkCore == 'qbx' then
            return exports.qbx_core:GetPlayerByCitizenId(citizenid) or nil
        end
    end,

    ---@param citizenid string Player's citizen ID
    ---@return table|nil player Player object or nil if not found
    getOfflinePlayer = function(citizenid)
        if frameworkCore == 'qb' then
            return Core.Player.GetOfflinePlayer(citizenid) or nil
        elseif frameworkCore == 'qbx' then
            return exports.qbx_core:GetOfflinePlayer(citizenid) or nil
        end
    end,

    ---@return table players Table of all online players
    getAllPlayers = function()
        if frameworkCore == 'qb' then
            return Core.Functions.GetQBPlayers()
        elseif frameworkCore == 'qbx' then
            return exports.qbx_core:GetQBPlayers()
        end
    end,

    ---@param player table Player object
    ---@return string playerName Player's full name
    getName = function(player)
        if frameworkCore == 'qb' then
            return player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
        elseif frameworkCore == 'qbx' then
            return player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
        end
    end,

    ---@param player table Player object
    ---@return string citizenid Player's citizen ID
    getCitizenId = function(player)
        if frameworkCore == 'qb' then
            return player.PlayerData.citizenid
        elseif frameworkCore == 'qbx' then
            return player.PlayerData.citizenid
        end
    end,

    ---@param player table Player object
    ---@param jobName string Job name
    ---@param grade number|string Grade level
    ---@return boolean success
    setJob = function(player, jobName, grade)
        if frameworkCore == 'qb' then
            if player.Offline then
                local jobData = Core.Shared.Jobs[jobName]
                if jobData then
                    player.PlayerData.job = {
                        name = jobName,
                        label = jobData.label,
                        onduty = jobData.defaultDuty,
                        type = jobData.type or 'none',
                        grade = {
                            name = jobData.grades[tostring(grade)].name,
                            level = tonumber(grade),
                            payment = jobData.grades[tostring(grade)].payment,
                            isboss = jobData.grades[tostring(grade)].isboss or false
                        },
                        isboss = jobData.grades[tostring(grade)].isboss or false
                    }
                    Core.Player.SaveOffline(player.PlayerData)
                    return true
                else
                    return false
                end
            else
                return player.Functions.SetJob(jobName, grade)
            end
        elseif frameworkCore == 'qbx' then
            return player.Functions.SetJob(jobName, grade)
        end
    end,

    ---@param player table Player object
    ---@param onDuty boolean Whether the player is on duty
    ---@return boolean success
    setJobDuty = function(player, onDuty)
        if frameworkCore == 'qb' then
            return player.Functions.SetJobDuty(onDuty)
        elseif frameworkCore == 'qbx' then
            return player.Functions.SetJobDuty(onDuty)
        end
    end,

    ---@param player table Player object
    ---@param gangName string Gang name
    ---@param grade number|string Grade level
    ---@return boolean success
    setGang = function(player, gangName, grade)
        if frameworkCore == 'qb' then
            if player.Offline then
                local gangData = Core.Shared.Gangs[gangName]
                if gangData then
                    player.PlayerData.gang = {
                        name = gangName,
                        label = gangData.label,
                        grade = {
                            name = gangData.grades[tostring(grade)].name,
                            level = tonumber(grade),
                            isboss = gangData.grades[tostring(grade)].isboss or false
                        },
                        isboss = gangData.grades[tostring(grade)].isboss or false
                    }
                    Core.Player.SaveOffline(player.PlayerData)
                    return true
                else
                    return false
                end
            else
                return player.Functions.SetGang(gangName, grade)
            end
        elseif frameworkCore == 'qbx' then
            return player.Functions.SetGang(gangName, grade)
        end
    end,
}

-----------------------
--   Shared Utils    --
-----------------------
Utils.Shared = {
    ---@param gangName string|nil Gang name or nil for all gangs
    ---@return table gangData Gang data table or all gangs
    getGangData = function(gangName)
        if frameworkCore == 'qb' then
            return gangName and Core.Shared.Gangs[gangName] or Core.Shared.Gangs
        elseif frameworkCore == 'qbx' then
            return gangName and exports.qbx_core:GetGangs()[gangName] or exports.qbx_core:GetGangs()
        end
    end,

    ---@param jobName string|nil Job name or nil for all jobs
    ---@return table jobData Job data table or all jobs
    getJobData = function(jobName)
        if frameworkCore == 'qb' then
            return jobName and Core.Shared.Jobs[jobName] or Core.Shared.Jobs
        elseif frameworkCore == 'qbx' then
            return jobName and exports.qbx_core:GetJobs()[jobName] or exports.qbx_core:GetJobs()
        end
    end,

    ---@param entityType string 'job' or 'gang'
    ---@param entityName string Name of the job or gang
    ---@param gradeLevel number|string Grade level
    ---@return table|nil gradeData Grade data table or nil if not found
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

    ---@param itemName string|nil Item name or nil for all items
    ---@return table|nil itemData Item data table or all items
    getItemData = function(itemName)
        if frameworkCore == 'qb' then
            return itemName and Core.Shared.Items[itemName] or Core.Shared.Items
        elseif frameworkCore == 'qbx' then
            return itemName and exports.qbx_core:GetItems()[itemName] or exports.qbx_core:GetItems()
        end
    end,

    ---@param itemName string Item name
    ---@return string label Item label or item name if not found
    getItemLabel = function(itemName)
        if frameworkCore == 'qb' then
            return (Core.Shared.Items[itemName] and Core.Shared.Items[itemName].label) or itemName
        elseif frameworkCore == 'qbx' then
            return (exports.qbx_core:GetItems()[itemName] and exports.qbx_core:GetItems()[itemName].label) or itemName
        end
    end
}

-----------------------
--     Job Utils     --
-----------------------
Utils.Job = {
    ---@param jobInput string|table Job name or table of job names
    ---@param onDutyOnly boolean Whether to count only on-duty players
    ---@return number count Number of players with the job(s)
    getJobCount = function(jobInput, onDutyOnly)
        local count = 0
        local players = Utils.Player.getAllPlayers()

        local checkJob
        if type(jobInput) == 'string' then
            -- Handle single job name as string: 'police'
            checkJob = function(job)
                return job == jobInput
            end
        elseif type(jobInput) == 'table' then
            local jobLookup = {}
            for k, v in pairs(jobInput) do
                if type(k) == 'number' then
                    -- Handle array format: {'police', 'sheriff'}
                    jobLookup[v] = true
                else
                    -- Handle hash table format: {['police'] = true}
                    if v == true then
                        jobLookup[k] = true
                    end
                end
            end

            checkJob = function(job)
                return jobLookup[job] == true
            end
        else
            print("^1[sg_utils]^0 Error: getJobCount received invalid job input type: " .. type(jobInput))
            return 0
        end

        for _, playerObject in pairs(players) do
            if playerObject and playerObject.PlayerData and playerObject.PlayerData.job then
                local job = playerObject.PlayerData.job.name

                if job and checkJob(job) then
                    if not onDutyOnly or playerObject.PlayerData.job.onduty then
                        count = count + 1
                    end
                end
            end
        end

        return count
    end,

    ---@param onDutyOnly boolean Whether to count only on-duty police
    ---@return number count Number of police
    getPoliceCount = function(onDutyOnly)
        return Utils.Job.getJobCount(Config.PoliceJobs, onDutyOnly)
    end,

    ---@param onDutyOnly boolean Whether to count only on-duty EMS
    ---@return number count Number of EMS
    getEMSCount = function(onDutyOnly)
        return Utils.Job.getJobCount(Config.EMSJobs, onDutyOnly)
    end,
}

----------------------
-- Inventory Utils  --
----------------------
Utils.Inventory = {
    ---@param itemName string Name of the item
    ---@return table|nil itemInfo Item information or nil if not found
    getItemData = function(itemName)
        if inventory == 'qb' then
            return Core.Shared.Items[itemName]
        elseif inventory == 'ps' then
            return Core.Shared.Items[itemName]
        elseif inventory == 'ox' then
            local item = exports.ox_inventory:Items(itemName)
            if item then
                return {
                    name = itemName,
                    label = item.label,
                    unique = item.stack == false
                }
            end
            return nil
        else
            print('Invalid inventory type: ' .. inventory)
            return nil
        end
    end,

    ---@param player table Player object
    ---@param itemName string Name of the item to add
    ---@param amount number Amount of items to add
    ---@param info table|nil Optional metadata for the item
    ---@param isUnique boolean Whether the item should be added one at a time
    ---@return boolean success Whether the operation was successful
    addItem = function(player, itemName, amount, info, isUnique)
        if inventory == 'qb' then
            if isUnique then
                local success = true
                for i = 1, amount do
                    success = success and exports['qb-inventory']:AddItem(player.PlayerData.source, itemName, 1, nil, info or nil)
                end
                return success
            else
                return exports['qb-inventory']:AddItem(player.PlayerData.source, itemName, amount, nil, info or nil)
            end
        elseif inventory == 'ps' then
            if isUnique then
                local success = true
                for i = 1, amount do
                    success = success and exports['ps-inventory']:AddItem(player.PlayerData.source, itemName, 1, nil, info or nil)
                end
                return success
            else
                return exports['ps-inventory']:AddItem(player.PlayerData.source, itemName, amount, nil, info or nil)
            end
        elseif inventory == 'ox' then
            if isUnique then
                local success = true
                for i = 1, amount do
                    success = success and exports.ox_inventory:AddItem(player.PlayerData.source, itemName, 1, info or nil)
                end
                return success
            else
                return exports.ox_inventory:AddItem(player.PlayerData.source, itemName, amount, info or nil)
            end
        else
            print('Invalid inventory type: ' .. inventory)
            return false
        end
    end,

    ---@param player table Player object
    ---@param itemName string Name of the item to remove
    ---@param amount number Amount of items to remove
    ---@return boolean success Whether the operation was successful
    removeItem = function(player, itemName, amount)
        if inventory == 'qb' then
            return exports['qb-inventory']:RemoveItem(player.PlayerData.source, itemName, amount)
        elseif inventory == 'ps' then
            return exports['ps-inventory']:RemoveItem(player.PlayerData.source, itemName, amount)
        elseif inventory == 'ox' then
            return exports.ox_inventory:RemoveItem(player.PlayerData.source, itemName, amount)
        else
            print('Invalid inventory type: ' .. inventory)
            return false
        end
    end,

    ---@param player table Player object
    ---@param itemName string Name of the item to check
    ---@param amount number Amount of items to check for
    ---@return boolean hasItem Whether the player has the specified item(s)
    hasItem = function(player, itemName, amount)
        if inventory == 'qb' then
            return exports['qb-inventory']:HasItem(player.PlayerData.source, itemName, amount)
        elseif inventory == 'ps' then
            return exports['ps-inventory']:HasItem(player.PlayerData.source, itemName, amount)
        elseif inventory == 'ox' then
            local count = exports.ox_inventory:Search(player.PlayerData.source, 'count', itemName)
            return count >= amount
        else
            print('Invalid inventory type: ' .. inventory)
            return false
        end
    end,

    ---@param player table|number Player Table or source ID
    ---@return table items Table of player's inventory items
    getPlayerItems = function(player)
        local playerSource = type(player) == 'table' and player.PlayerData.source or player
        local playerObject = type(player) == 'table' and player or Utils.Player.getPlayer(player)
        local items = {}
        if not playerObject then return items end

        if inventory == 'ox' then
            local inventoryItems = exports.ox_inventory:GetInventoryItems(playerSource) or {}
            for _, item in pairs(inventoryItems) do
                if item then
                    table.insert(items, {
                        name = item.name,
                        label = item.label,
                        count = item.count,
                        metadata = item.metadata or {}
                    })
                end
            end
        else
            local inventoryItems = playerObject.PlayerData.items or {}
            for _, item in pairs(inventoryItems) do
                if item then
                    local itemData = Utils.Inventory.getItemData(item.name)
                    if itemData then
                        table.insert(items, {
                            name = item.name,
                            label = itemData.label,
                            count = item.amount,
                            metadata = item.info or {}
                        })
                    end
                end
            end
        end
        return items
    end,

    openStash = function(src, stashId, stashData)
        if inventory == 'qb' then
            return exports['qb-inventory']:OpenInventory(src, stashId, {
                maxweight = stashData.maxWeight,
                slots = stashData.maxSlots,
                label = stashData.label or 'stash-'..stashId,
            })
        elseif inventory == 'ps' then
            return exports['ps-inventory']:OpenInventory(src, stashId, {
                maxweight = stashData.maxWeight,
                slots = stashData.maxSlots,
            })
        elseif inventory == 'ox' then
            return exports.ox_inventory:forceOpenInventory(src, 'stash', stashId)
        end
    end,

    createUseableItem = function(itemName, metadata)
        if frameworkCore == 'qb' then
            return Core.Functions.CreateUseableItem(itemName, metadata)
        elseif frameworkCore == 'qbx' then
            return exports.qbx_core:CreateUseableItem(itemName, metadata)
        end
    end,
}

----------------------
--  Economy Utils   --
----------------------
Utils.Economy = {
    ---@param player table Player object
    ---@param account string Account type ('cash', 'bank', etc)
    ---@param amount number Amount to add
    ---@return boolean success Whether the operation was successful
    addMoney = function(player, account, amount)
        if frameworkCore == 'qb' then
            return player.Functions.AddMoney(account, amount, 'sg_utils')
        elseif frameworkCore == 'qbx' then
            return player.Functions.AddMoney(account, amount, 'sg_utils')
        end
    end,

    ---@param player table Player object
    ---@param account string Account type ('cash', 'bank', etc)
    ---@param amount number Amount to remove
    ---@return boolean success Whether the operation was successful
    removeMoney = function(player, account, amount)
        if frameworkCore == 'qb' then
            return player.Functions.RemoveMoney(account, amount, 'sg_utils')
        elseif frameworkCore == 'qbx' then
            return player.Functions.RemoveMoney(account, amount, 'sg_utils')
        end
    end,

    ---@param player table Player object
    ---@param account string Account type ('cash', 'bank', etc)
    ---@return number balance Current balance in account
    getBalance = function(player, account)
        if frameworkCore == 'qb' then
            return player.PlayerData.money[account]
        elseif frameworkCore == 'qbx' then
            return player.PlayerData.money[account]
        end
    end,

    ---@param society string Society account name
    ---@param amount number Amount to add
    ---@return boolean success Whether the operation was successful
    addSocietyMoney = function(society, amount)
        amount = math.max(0, tonumber(amount) or 0)
        if amount <= 0 then return false end

        if banking == 'qb' then
            exports['qb-banking']:AddMoney(society, amount)
            return true
        elseif banking == 'qs' then
            exports['qs-banking']:AddMoney(society, amount)
            return true
        elseif banking == 'renewed' then
            exports['Renewed-Banking']:addAccountMoney(society, amount)
            return true
        else
            -- Fallback or custom script handling
            print(string.format("Unsupported banking script: %s", banking))
            return false
        end
    end
}

----------------------
--    UI Utils      --
----------------------
Utils.UI = {
    ---@param source number Player server id
    ---@param message string Message to show
    ---@param type string Notification type ('success', 'error', 'info')
    ---@param duration number Optional duration in ms
    sendNotify = function(source, message, type, duration, title)
        local notifyDuration = duration or Config.Notifications.defaultDuration
        local notifyTitle = title or Config.Notifications.title

        if notify == 'qb' then
            Core.Functions.Notify(source, message, type, notifyDuration)
        elseif notify == 'okok' then
            TriggerClientEvent('okokNotify:Alert', source, notifyTitle, message, notifyDuration, type, false)
        elseif notify == 'ox' then
            TriggerClientEvent('ox_lib:notify', source, {
                title = notifyTitle,
                description = message,
                type = type,
                duration = notifyDuration
            })
        end
    end
}

----------------------
--      Events      --
----------------------
RegisterNetEvent('sg_utils:server:SonoranDispatch', function(options)
    local caller = math.random(0, 1) == 1 and 'A man' or 'A woman'
    local location = options.location .. ', ' .. options.zone
    exports["sonorancad"]:performApiRequest({{
        ["serverId"] = GetConvar("sonoran_serverId", 1),
        ["isEmergency"] = true,
        ["caller"] = caller,
        ["location"] = location,
        ["description"] = options.description,
        ["metaData"] = {
            ["useCallLocation"] = true,
            ["plate"] = options.plate,
            ["postal"] = options.postal or 'Unk'
        }
    }}, "CALL_911")
end)

----------------------
--    Framework     --
----------------------
CreateThread(function()
    if frameworkCore == 'qb' then
        local waited = 0
        while GetResourceState('qb-core') ~= 'started' do
            Wait(100)
            waited = waited + 100
            if waited > 10000 then
                print('^1[sg_utils]^0 Error: qb-core not started after 10 seconds!')
                return
            end
        end
        Wait(500)
        Core = exports['qb-core']:GetCoreObject()
    elseif frameworkCore == 'qbx' then
        if GetResourceState('qbx_core') ~= 'started' then
            print('QBX Core not started. Please start qbx_core before this resource or change Config.Framework.core.')
            return
        end
        -- QBX doesn't use a Core object, it uses direct exports
        -- No initialization needed
    else
        print('Invalid framework core: ' .. frameworkCore)
        return
    end
end)

----------------------
--      Events      --
----------------------
RegisterNetEvent('QBCore:Server:UpdateObject', function()
    if frameworkCore == 'qb' then
        Core = exports['qb-core']:GetCoreObject()
    end
end)

--------------------------------
--         Exports            --
--------------------------------
exports('GetJobCount', Utils.Job.getJobCount)
exports('GetPoliceCount', Utils.Job.getPoliceCount)
exports('GetAmbulanceCount', Utils.Job.getAmbulanceCount)

-- Return Utils so it can be accessed via the export
return Utils