-- Main function to get all utils
function GetUtils()
    if IsDuplicityVersion() then -- Server-side
        return Utils
    else -- Client-side
        return Utils
    end
end