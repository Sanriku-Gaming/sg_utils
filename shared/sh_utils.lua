Utils = Utils or {}

local frameworkCore = Config.Framework.core:lower()

-----------------------
--  Job/Gang Utils   --
-----------------------
Utils.Shared = {
    getGangData = function(gangName)
        if frameworkCore == 'qb' then
            return Core.Shared.Gangs[gangName]
        elseif frameworkCore == 'qbx' then
            return exports.qbx_core:GetGangs()[gangName]
        end
    end,

    getJobData = function(jobName)
        if frameworkCore == 'qb' then
            return Core.Shared.Jobs[jobName]
        elseif frameworkCore == 'qbx' then
            return exports.qbx_core:GetJobs()[jobName]
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
--   Table Utils    --
----------------------
Utils.Table = {
    contains = function(table, value)
        if #table > 0 then
            for _, v in ipairs(table) do
                if v == value then
                    return true
                end
            end
        else
            for _, v in pairs(table) do
                if v == value then
                    return true
                end
            end
        end
        return false
    end,

    find = function(table, predicate)
        for k, v in pairs(table) do
            if predicate(v, k) then
                return v, k
            end
        end
        return nil
    end,

    map = function(table, mapper)
        local result = {}
        for k, v in pairs(table) do
            result[k] = mapper(v, k)
        end
        return result
    end,

    filter = function(table, predicate)
        local result = {}
        for k, v in pairs(table) do
            if predicate(v, k) then
                result[#result + 1] = v
            end
        end
        return result
    end,

    merge = function(t1, t2)
        local result = {}
        for k, v in pairs(t1) do
            result[k] = v
        end
        for k, v in pairs(t2) do
            result[k] = v
        end
        return result
    end
}

----------------------
--   String Utils   --
----------------------
Utils.String = {
    startsWith = function(str, start)
        return str:sub(1, #start) == start
    end,

    endsWith = function(str, ending)
        return ending == "" or str:sub(-#ending) == ending
    end,

    trim = function(str)
        return str:gsub("^%s*(.-)%s*$", "%1")
    end
}

----------------------
-- Date/Time Utils  --
----------------------
Utils.DateTime = {
    formatDuration = function(seconds)
        if not seconds or seconds <= 0 then
            return "0:00:00"
        end

        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        local remainingSeconds = seconds % 60

        return string.format("%d:%02d:%02d", hours, minutes, remainingSeconds)
    end,

    formatDate = function(timestamp)
        if not timestamp then return "Unknown" end
        return os.date("%d-%m-%Y %H:%M", timestamp)
    end,

    timeAgo = function(timestamp)
        if not timestamp then return "Never" end

        local now = os.time()
        local diff = now - timestamp

        if diff < 60 then
            return "Just now"
        elseif diff < 3600 then
            return math.floor(diff / 60) .. " minutes ago"
        elseif diff < 86400 then
            return math.floor(diff / 3600) .. " hours ago"
        else
            return math.floor(diff / 86400) .. " days ago"
        end
    end
}