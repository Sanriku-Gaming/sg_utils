-- Version checker for sg_utils

local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
local resourceName = '^3[sg_utils]^0'
local githubRawURL = 'https://raw.githubusercontent.com/Sanriku-Gaming/sg_utils/main/fxmanifest.lua'

-- Function to extract version from fxmanifest content
local function ExtractVersion(manifestContent)
    for line in manifestContent:gmatch("([^\n]*)\n?") do
        local version = line:match("^version%s+['\"]([^'\"]+)['\"]")
        if version then
            return version
        end
    end
    return nil
end

CreateThread(function()
    Wait(2000) -- Wait a bit after resource start

    PerformHttpRequest(githubRawURL, function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            print(resourceName .. ' Failed to check version. Error code: ' .. tostring(errorCode))
            return
        end

        -- Extract version from the fxmanifest content
        local latestVersion = ExtractVersion(resultData)

        if not latestVersion then
            print(resourceName .. ' Failed to extract version information from GitHub.')
            return
        end

        if currentVersion ~= latestVersion then
            print('\n')
            print(resourceName .. ' ^1Update available!^0')
            print(resourceName .. ' Current version: ^1' .. currentVersion .. '^0')
            print(resourceName .. ' Latest version: ^2' .. latestVersion .. '^0')
            print(resourceName .. ' Download: ^5https://github.com/Sanriku-Gaming/sg_utils/releases/latest^0')
            print(resourceName .. ' Changelog: ^5https://github.com/Sanriku-Gaming/sg_utils/blob/main/CHANGELOG.md^0')
            print('\n')
        else
            print(resourceName .. ' You are running the latest version (' .. currentVersion .. ').')
        end
    end, 'GET', '', { ['Cache-Control'] = 'no-cache' })
end)