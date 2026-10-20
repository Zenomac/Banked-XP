-- Visible, portable boost assumptions for the currently supported Herblore
-- recipes. Never add a potential boost to an already boosted gameplay level.
-- The full 29-skill review is in ../docs/BOOST_REVIEW.md; conditional/invisible boosts
-- are not universal recipe unlocks and are not applied to unrelated methods.
local M={}
function M.herblore(base,current)
    if type(base)~='number' or base<1 then return nil end
    return {level=math.max(current or base,base+6),amount=6,
        source='Brown spicy stew',note='up to +6; requires Evil Dave quest progression; random boost'}
end
function M.forSkill(skill,base,current)
    skill=skill or 'Herblore'
    if skill=='Herblore' then return M.herblore(base,current) end
    if type(base)~='number' or base<1 then return nil end
    local amount=skill=='Archaeology' and 3 or
        ({Smithing=true,Crafting=true,Fletching=true,Farming=true,Firemaking=true,Cooking=true,Construction=true})[skill] and 6
    if not amount then return nil end
    return {level=math.max(current or base,base+amount),amount=amount,
        source=skill=='Archaeology' and 'Archaeology potion' or 'Spicy stew'}
end
function M.reachable(recipe,state)
    local current=state.level
    local base=state.baseLevel
    if not current or type(base)~='number' then return false end
    if recipe.masterCape or recipe.unboostable then return base>=recipe.level end
    local boost=M.forSkill(recipe.skill or state.skill,base,current)
    return boost and boost.level>=recipe.level or false
end
function M.note(recipe,state)
    local base=state.baseLevel
    if not base or not state.level or recipe.level<=state.level then return nil end
    if recipe.masterCape or recipe.unboostable then return nil end
    if not M.reachable(recipe,state) then return nil end
    local need=recipe.level-base
    local skill=recipe.skill or state.skill or 'Herblore'
    local boost=M.forSkill(skill,base,state.level)
    if skill~='Herblore' then return 'Boost needed: +'..tostring(need):gsub('%.0$','')..' '..skill..' ('..boost.source..': up to +'..boost.amount..'; method requirements apply)' end
    return 'Boost needed: +'..tostring(need):gsub('%.0$','')..' Herblore (Brown spicy stew: up to +6; quest required, random result)'
end
return M
