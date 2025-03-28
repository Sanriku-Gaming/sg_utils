-- This file creates the export interface for both client and server
SGModule = {}
local initialized = false
local Utils = nil

-- Initialize the module and get utils
function SGModule.Init()
    if not initialized then
        Utils = _G.Utils -- Access the global Utils table
        initialized = true

        if IsDuplicityVersion() then
            -- Server-side initialization
            if Config.Debug then
                print('[sg_utils] Server module initialized')
            end
        else
            -- Client-side initialization
            if Config.Debug then
                print('[sg_utils] Client module initialized')
            end
        end
    end

    return Utils
end

-- Get the utils object (initializes if needed)
function SGModule.GetUtils()
    if not initialized then
        return SGModule.Init()
    end
    return Utils
end

-- Direct access to sub-modules for convenience
SGModule.Player = setmetatable({}, {
    __index = function(_, key)
        if not initialized then SGModule.Init() end
        if Utils and Utils.Player and Utils.Player[key] then
            return Utils.Player[key]
        end
        return function() print('[sg_utils] Player.' .. key .. ' function not found') end
    end
})

SGModule.Vehicle = setmetatable({}, {
    __index = function(_, key)
        if not initialized then SGModule.Init() end
        if Utils and Utils.Vehicle and Utils.Vehicle[key] then
            return Utils.Vehicle[key]
        end
        return function() print('[sg_utils] Vehicle.' .. key .. ' function not found') end
    end
})

SGModule.Inventory = setmetatable({}, {
    __index = function(_, key)
        if not initialized then SGModule.Init() end
        if Utils and Utils.Inventory and Utils.Inventory[key] then
            return Utils.Inventory[key]
        end
        return function() print('[sg_utils] Inventory.' .. key .. ' function not found') end
    end
})

SGModule.UI = setmetatable({}, {
    __index = function(_, key)
        if not initialized then SGModule.Init() end
        if Utils and Utils.UI and Utils.UI[key] then
            return Utils.UI[key]
        end
        return function() print('[sg_utils] UI.' .. key .. ' function not found') end
    end
})

SGModule.World = setmetatable({}, {
    __index = function(_, key)
        if not initialized then SGModule.Init() end
        if Utils and Utils.World and Utils.World[key] then
            return Utils.World[key]
        end
        return function() print('[sg_utils] World.' .. key .. ' function not found') end
    end
})

-- Server-side only modules
if IsDuplicityVersion() then
    SGModule.Economy = setmetatable({}, {
        __index = function(_, key)
            if not initialized then SGModule.Init() end
            if Utils and Utils.Economy and Utils.Economy[key] then
                return Utils.Economy[key]
            end
            return function() print('[sg_utils] Economy.' .. key .. ' function not found') end
        end
    })
end

-- Client-side only modules
if not IsDuplicityVersion() then
    SGModule.Ped = setmetatable({}, {
        __index = function(_, key)
            if not initialized then SGModule.Init() end
            if Utils and Utils.Ped and Utils.Ped[key] then
                return Utils.Ped[key]
            end
            return function() print('[sg_utils] Ped.' .. key .. ' function not found') end
        end
    })
end

-- Allow developers to register custom categories
function SGModule.RegisterCategory(categoryName, functions)
    if SGModule[categoryName] then
        print('[sg_utils] Warning: Overriding existing category ' .. categoryName)
    end

    -- Create the category with metatable for function access
    SGModule[categoryName] = setmetatable({}, {
        __index = function(_, key)
            if not initialized then SGModule.Init() end
            if functions and functions[key] then
                return functions[key]
            end
            return function() print('[sg_utils] ' .. categoryName .. '.' .. key .. ' function not found') end
        end
    })

    -- Add the functions directly
    if functions then
        for name, func in pairs(functions) do
            SGModule[categoryName][name] = func
        end
    end

    return SGModule[categoryName]
end

-- Main function to get all utils
function GetUtils()
    if IsDuplicityVersion() then -- Server-side
        return Utils
    else -- Client-side
        return Utils
    end
end

-- Get the module for easier integration with other resources
function GetModule()
    return SGModule
end