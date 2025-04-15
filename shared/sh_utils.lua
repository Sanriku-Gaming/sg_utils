Utils = Utils or {}

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

    formatDate = function(timestamp, formatId)
        if not timestamp then return "Unknown" end

        local formatId = formatId or Config.DateTime.default
        local format = Config.DateTime.formats[formatId] or Config.DateTime.formats[1]

        if IsDuplicityVersion() then
            return os.date(format, timestamp)
        else
            local time = timestamp
            if timestamp > 1000000000000 then
                time = timestamp / 1000
            end

            local date = {}
            date.year = 1970
            date.month = 1
            date.day = 1
            date.hour = 0
            date.min = 0
            date.sec = 0

            local days_per_month = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

            local total_days = math.floor(time / 86400)
            date.sec = time % 60
            date.min = math.floor((time % 3600) / 60)
            date.hour = math.floor((time % 86400) / 3600)

            local days_since_1970 = total_days
            date.year = 1970

            while true do
                local days_in_year = 365
                if date.year % 4 == 0 and (date.year % 100 ~= 0 or date.year % 400 == 0) then
                    days_in_year = 366
                    days_per_month[2] = 29
                else
                    days_per_month[2] = 28
                end

                if days_since_1970 < days_in_year then
                    break
                end

                days_since_1970 = days_since_1970 - days_in_year
                date.year = date.year + 1
            end

            date.month = 1
            for i = 1, 12 do
                if days_since_1970 < days_per_month[i] then
                    date.month = i
                    date.day = days_since_1970 + 1
                    break
                end
                days_since_1970 = days_since_1970 - days_per_month[i]
            end

            local result = format

            result = result:gsub("%%Y", string.format("%04d", date.year))
            result = result:gsub("%%m", string.format("%02d", date.month))
            result = result:gsub("%%d", string.format("%02d", date.day))
            result = result:gsub("%%H", string.format("%02d", date.hour))
            result = result:gsub("%%M", string.format("%02d", date.min))
            result = result:gsub("%%S", string.format("%02d", date.sec))

            local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
            result = result:gsub("%%B", months[date.month])

            return result
        end
    end,

    timeAgo = function(timestamp)
        if not timestamp then return "Never" end

        local now
        if IsDuplicityVersion() then
            now = os.time()
        else
            now = GetGameTimer() / 1000
        end

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
    end,

    getCurrentTimestamp = function()
        if IsDuplicityVersion() then
            return os.time()
        else
            return GetGameTimer() / 1000
        end
    end
}