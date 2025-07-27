local function CheckVersion(resourceName)
    if not resourceName then
        print('^1Error: Resource name is required for version check^0')
        return
    end

    local currentVersion = GetResourceMetadata(resourceName, 'version', 0)
    local githubRawURL = ('https://raw.githubusercontent.com/Sanriku-Gaming/%s/main/fxmanifest.lua'):format(resourceName)

    local function ExtractVersion(manifestContent)
        for line in manifestContent:gmatch("([^\n]*)\n?") do
            local version = line:match("^version%s+['\"]([^'\"]+)['\"]")
            if version then
                return version
            end
        end
        return nil
    end

    PerformHttpRequest(githubRawURL, function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            print('^1Failed to check version for ' .. resourceName .. '. Error code: ' .. tostring(errorCode) .. '^0')
            return
        end

        local latestVersion = ExtractVersion(resultData)

        if not latestVersion then
            print('^1Failed to extract version information from GitHub for ' .. resourceName .. '.^0')
            return
        end

        if currentVersion ~= latestVersion then
            print('^1Update available for ' .. resourceName .. '!^0')
            print('Current version: ^1' .. currentVersion .. '^0')
            print('Latest version: ^2' .. latestVersion .. '^0')
            print('Download: ^5https://github.com/Sanriku-Gaming/' .. resourceName .. '/releases/latest^0')
        else
            print('^2' .. resourceName .. ' is running the latest version (' .. currentVersion .. ').^0')
        end
    end, 'GET', '', { ['Cache-Control'] = 'no-cache' })
end

exports('CheckVersion', CheckVersion)

-- Check sg_utils version on resource start
CreateThread(function()
    Wait(2000)
    CheckVersion('sg_utils')
end)