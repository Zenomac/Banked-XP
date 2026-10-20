-- The only durable user records in this plugin. No account identifier is stored.
local M={}
local keys={'xpSettingsV1','xpMethodsV1','xpSharedMethodsV2'}
function M.erasePreferences()
    local failures={}
    for _,key in ipairs(keys) do
        local ok,deleted=pcall(function()
            if not PersistentDB:CheckExists(key) then return true end
            return PersistentDB:Delete(key)
        end)
        if not ok or deleted~=true then failures[#failures+1]=key end
    end
    require('settings').resetMemory()
    require('methods').resetMemory()
    -- Session gameplay observations are released when the plugin is unloaded.
    return #failures==0,failures
end
return M
