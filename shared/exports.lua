-- This file creates the export interface for both client and server

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
    return require('shared.module')
end