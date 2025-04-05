Utils = {}

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

    getJobCount = function(jobList, onDutyOnly)
        local count = 0
        local players = Utils.Player.getAllPlayers()

        for _, playerObject in pairs(players) do
            if playerObject then
                local job = playerObject.PlayerData.job.name
                if job and Utils.Table.contains(jobList, job) then
                    if not onDutyOnly or playerObject.PlayerData.job.onduty then
                        count = count + 1
                    end
                end
            end
        end
        return count
    end,

    getPoliceCount = function(onDutyOnly)
        return Utils.Player.getJobCount(Config.PoliceJobs, onDutyOnly)
    end,

    getEMSCount = function(onDutyOnly)
        return Utils.Player.getJobCount(Config.EMSJobs, onDutyOnly)
    end,
}

-----------------------
--     Job Utils     --
-----------------------
Utils.Job = {
    setJob = function(player, jobName, grade)
        if frameworkCore == 'qb' then
            return player.Functions.SetJob(jobName, grade)
        elseif frameworkCore == 'qbx' then
            return player.Functions.SetJob(jobName, grade)
        end
    end,

    setJobDuty = function(player, onDuty)
        if frameworkCore == 'qb' then
            return player.Functions.SetJobDuty(onDuty)
        elseif frameworkCore == 'qbx' then
            return player.Functions.SetJobDuty(onDuty)
        end
    end,
}

----------------------
--    Gang Utlils   --
----------------------
Utils.Gang = {
    setGang = function(player, gangName, grade)
        if frameworkCore == 'qb' then
            return player.Functions.SetGang(gangName, grade)
        elseif frameworkCore == 'qbx' then
            return player.Functions.SetGang(gangName, grade)
        end
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

    openStash = function(source, stashId, maxWeight, maxSlots)
        if inventory == 'qb' then
            TriggerClientEvent('inventory:client:SetCurrentStash', source, stashId)
            return Core.Functions.ExecuteSql('SELECT * FROM stashitems WHERE stash = ?', {stashId})
        elseif inventory == 'ps' then
            return exports['ps-inventory']:OpenInventory('stash', stashId, {
                maxweight = maxWeight,
                slots = maxSlots,
            })
        elseif inventory == 'ox' then
            return exports.ox_inventory:OpenInventory('stash', {id = stashId, weight = maxWeight, slots = maxSlots}, source)
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
--    Framework     --
----------------------
CreateThread(function()
    if frameworkCore == 'qb' then
        if GetResourceState('qb-core') ~= 'started' then
            print('QBCore not started. Please start qb-core before this resource or change Config.Framework.core.')
            return
        end
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

-- Return Utils so it can be accessed via the export
return Utils