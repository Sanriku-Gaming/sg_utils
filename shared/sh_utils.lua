Utils = Utils or {}

----------------------
--   Table Utils    --
----------------------
Utils.Table = {
    ---@param table table Table to search
    ---@param value any Value to find
    ---@return boolean found True if value is found in table
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

    ---@param table table Table to search
    ---@param predicate function Predicate function (value, key)
    ---@return any value The found value or nil
    ---@return any key The found key or nil
    find = function(table, predicate)
        for k, v in pairs(table) do
            if predicate(v, k) then
                return v, k
            end
        end
        return nil
    end,

    ---@param table table Table to map
    ---@param mapper function Mapper function (value, key)
    ---@return table result Mapped table
    map = function(table, mapper)
        local result = {}
        for k, v in pairs(table) do
            result[k] = mapper(v, k)
        end
        return result
    end,

    ---@param table table Table to filter
    ---@param predicate function Predicate function (value, key)
    ---@return table result Filtered table
    filter = function(table, predicate)
        local result = {}
        for k, v in pairs(table) do
            if predicate(v, k) then
                result[#result + 1] = v
            end
        end
        return result
    end,

    ---@param t1 table First table
    ---@param t2 table Second table
    ---@return table result Merged table
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
    ---@param str string String to check
    ---@param start string Prefix to check for
    ---@return boolean startsWith True if str starts with start
    startsWith = function(str, start)
        return str:sub(1, #start) == start
    end,

    ---@param str string String to check
    ---@param ending string Suffix to check for
    ---@return boolean endsWith True if str ends with ending
    endsWith = function(str, ending)
        return ending == "" or str:sub(-#ending) == ending
    end,

    ---@param str string String to trim
    ---@return string trimmedStr Trimmed string
    trim = function(str)
        return str:gsub("^%s*(.-)%s*$", "%1")
    end
}

----------------------
-- Date/Time Utils  --
----------------------
Utils.DateTime = {
    ---@param seconds number Number of seconds
    ---@return string duration Formatted duration string
    formatDuration = function(seconds)
        if not seconds or seconds <= 0 then
            return "0:00:00"
        end

        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        local remainingSeconds = seconds % 60

        return string.format("%d:%02d:%02d", hours, minutes, remainingSeconds)
    end,

    ---@param timestamp number Timestamp (seconds since epoch)
    ---@param formatId number|nil Format ID (optional)
    ---@return string formattedDate Formatted date string
    formatDate = function(timestamp, formatId)
        if not timestamp then return "Unknown" end

        local formatId = formatId or Config.DateTime.default
        local format = Config.DateTime.formats[formatId] or Config.DateTime.formats[1]

        if IsDuplicityVersion() then
            local time = timestamp
            if time > 1000000000000 then
                time = time / 1000
            end
            return os.date(format, time)
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

    ---@param timestamp number Timestamp (seconds since epoch)
    ---@return string timeAgoStr Human-readable time ago string
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

    ---@return number timestamp Current timestamp (seconds since epoch)
    getCurrentTimestamp = function()
        if IsDuplicityVersion() then
            return os.time()
        else
            return GetGameTimer() / 1000
        end
    end
}

----------------------
--   Debug Utils    --
----------------------
Utils.Debug = {
    ---@param value any Value to print (string, table, etc)
    ---@param indent number|nil Indentation level for tables (optional)
    ---@param _isRecursive boolean|nil Internal flag for recursion (do not set manually)
    ---@param ... any Additional arguments for string.format if value is a string
    print = function(value, indent, _isRecursive, ...)
        indent = indent or 0

        if not _isRecursive then
            local info = debug.getinfo(2, "Sl")
            local file = info and info.short_src or "unknown"
            local line = info and info.currentline or 0
            print(string.format("[Debug] Called from %s:%d", file, line))
        end

        if type(value) == 'table' then
            for k, v in pairs(value) do
                local spacing = string.rep(" ", indent)
                if type(v) == 'table' then
                    print(spacing .. tostring(k) .. ":")
                    Utils.Debug.print(v, indent + 2, true, ...)
                else
                    print(spacing .. tostring(k) .. ": " .. tostring(v))
                end
            end
        elseif type(value) == 'string' and select('#', ...) > 0 then
            print(string.format(value, ...))
        else
            print(value)
        end
    end
}