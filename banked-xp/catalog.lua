-- Client API first; bundled records preserve coverage for unavailable data.
local M={}
local herbs=require('herbs')
local engine=require('recipe_engine')
local api=require('api_xp')
local observed={}
local prayerData=require('prayer_data')
local function fallback(obj)
    local result=herbs.lookup(obj) or prayerData[string.lower(obj.name or '')] or engine.lookup(obj)
    if obj.id==1517 then
        result={skill='Firemaking',method='Burn logs',xp=135}
    end
    if result then result.source='bundled' end
    return result
end
function M.lookup(obj)
    if not observed[obj.id] then
        local ok=pcall(api.observe,obj,fallback)
        if ok then observed[obj.id]=true end
    end
    local backup=fallback(obj)
    local ok,result=pcall(api.lookup,obj,backup)
    if ok and result then return result end
    return backup
end
return M
