-- Use the hovered item's native effects, never the selected crafting output.
local M={}
local skills={'attack','strength','defence','ranged','magic','necromancy','constitution','prayer','agility','herblore','thieving','crafting','fletching','slayer','hunter','mining','smithing','fishing','cooking','firemaking','woodcutting','runecrafting','farming','construction','summoning','dungeoneering','divination','invention','archaeology'}
function M.statBoost(skill,details)
    if skill~='Herblore' then return false end
    local joined=table.concat(details,' ')
    local text=string.gsub(joined,'<[^>]*>','')
    text=string.lower(text)
    local increases=text:find('temporarily increases',1,true) or text:find('temporarily boosts',1,true) or text:find('boosts your',1,true)
    for _,stat in ipairs(skills) do
        if text:find('%f[%a]'..stat..'%f[%A]') then
            if increases or text:find('%f[%a]'..stat..'%f[%A][^<;\n]-[+]%s*%d') then return true end
        end
    end
    return false
end
return M
