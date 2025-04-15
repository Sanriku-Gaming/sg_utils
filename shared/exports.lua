-- Function to provide access to utility modules
-- @param options string|table|nil Optional parameter to specify which modules to return
-- @return table Returns the requested utility modules or all modules if none specified
local function GetUtils(options)
    if not Utils then
        print("^1[sg_utils]^0 Error: Utils is not defined yet. Returning empty object.")
        return {}
    end

    if not options then
        return Utils
    end

    if type(options) == 'string' then
        local moduleName = options
        if Utils[moduleName] then
            return Utils[moduleName]
        else
            print("^1[sg_utils]^0 Warning: Requested module '" .. moduleName .. "' not found.")
            return {}
        end
    end

    if type(options) == 'table' then
        local UtilsModules = {}

        if #options > 0 then
            for _, moduleName in ipairs(options) do
                if Utils[moduleName] then
                    UtilsModules[moduleName] = Utils[moduleName]
                else
                    print("^1[sg_utils]^0 Warning: Requested module '" .. moduleName .. "' not found.")
                end
            end
            return UtilsModules
        else
            return Utils
        end
    end

    return Utils
end
exports('GetUtils', GetUtils)