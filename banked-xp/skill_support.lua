local M={}
M.names={'Herblore','Smithing','Crafting','Fletching','Archaeology','Farming','Firemaking','Cooking','Prayer','Construction','Summoning'}
M.supported={};for _,name in ipairs(M.names) do M.supported[name]=true end
function M.level(skill,method)
    local ok,value=pcall(function()
        local id=SkillType[(skill or 'Herblore'):upper()]
        if id==nil then return nil end
        return Player[method](id)
    end)
    if ok and type(value)=='number' and value>=1 then return value end
    return nil
end
return M
