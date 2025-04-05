local function GetUtils(options)
    if not Utils then
        print("^1[sg_utils]^0 Error: Utils is not defined yet. Returning empty object.")
        return {}
    end

    if not options then
        if IsDuplicityVersion() then
            return Utils
        else
            return Utils
        end
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
        else
            return Utils
        end

        return UtilsModules
    end

    if IsDuplicityVersion() then
        return Utils
    else
        return Utils
    end
end

exports('GetUtils', GetUtils)