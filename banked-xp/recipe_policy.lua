-- A single availability policy for all potion inputs, menus and estimates.
local M={}
local bank=require('bank')
local engine=require('recipe_engine')
local settings=require('settings')
local boosts=require('boosts')
local skillSupport=require('skill_support')
local function readLevel(method,skill) return skillSupport.level(skill,method) end
function M.presentation(r)
    local level=readLevel((r.masterCape or r.unboostable) and 'GetLevelCapped' or 'GetLevelGameplay',r.skill)
    local met=level and r.level and level>=r.level
    local label=r.shortLabel or r.label or r.method
    if met then
        label=label:gsub('%[Lv %d+, ([^%]]+)%]','[%1]'):gsub('%s*%[Lv %d+%]','')
    elseif level and r.level and not label:find('[Lv ',1,true) then
        label=label..' [Lv '..tostring(r.level):gsub('%.0$','')..']'
    end
    return label,met
end
local function isCape(name)
    name=bank.normalize(name)
    return name=='herblore master cape' or name=='inverted herblore master cape'
end
local function containsCape(counts)
    for name,count in pairs(counts or {}) do if count>0 and isCape(name) then return true end end
    return false
end
local function carriedCape()
    -- Missing optional inventory configs/containers must not break bank hovers.
    for _,name in ipairs({'INV','WORN'}) do
        local ok,found=pcall(function()
            local cfg=config.Inv[name]
            if not cfg then return false end
            local inv=Inventory.Find(cfg)
            if not inv or inv.isValid==false then return false end
            for _,slot in pairs(inv:GetSlots() or {}) do
                if slot.obj and type(slot.count)=='number' and slot.count>0 and isCape(slot.obj.name) then return true end
            end
            return false
        end)
        if ok and found then return true end
    end
    return false
end
function M.state(counts,skill)
    skill=skill or 'Herblore'
    local current=readLevel('GetLevelGameplay',skill)
    local actual=readLevel('GetLevelCapped',skill)
    return {skill=skill,level=current,baseLevel=actual,baseKnown=actual~=nil,showBoostable=settings.showBoostableRecipes(),showUnderlevel=settings.showUnderlevelRecipes(),best=(current and current>=120) or (actual and actual>=120)
        or (skill=='Herblore' and (containsCape(counts) or carriedCape()))}
end
local costs={}
local function cost(r)
    if costs[r] then return costs[r] end
    local result={}
    for _,i in ipairs(r.inputsNormalized) do result[i.key]=(result[i.key] or 0)+i.qty/r.output.qty end
    costs[r]=result
    return result
end
-- Best means the same potion with no more of any ingredient per output.
-- Distinct materials remain choices; a cheaper variant must still be offered
-- for the current source item and pass the same live level rule.
function M.better(a,b)
    if a.skill~=b.skill or a.method~=b.method or engine.key(a.output.name)~=engine.key(b.output.name) then return false end
    local ac,bc=cost(a),cost(b)
    local strict=false
    for k,n in pairs(ac) do
        if not bc[k] or n>bc[k]+0.000001 then return false end
        if n<bc[k]-0.000001 then strict=true end
    end
    for k in pairs(bc) do if not ac[k] then strict=true end end
    if strict then return true end
    -- Equivalent aliases/inputs: retain one deterministic best XP version.
    local ax,bx=a.xp/a.output.qty,b.xp/b.output.qty
    if ax~=bx then return ax>bx end
    if a.level~=b.level then return a.level<b.level end
    return a.id<b.id
end
local byID={}
for _,r in ipairs(engine.recipes) do byID[r.id]=r end
function M.replacement(id,options)
    local previous=byID[id]
    if not previous then return nil end
    for _,r in ipairs(options) do
        if r.engine and M.better(r,previous) then return r end
    end
end
function M.nextUnlock(options,state)
    if not state.level then return nil end
    local gap
    for _,r in ipairs(options) do
        local rs=state
        if r.skill and state.skill and r.skill~=state.skill then rs=M.state(nil,r.skill) end
        local reference=(r.masterCape or r.unboostable) and (rs.baseLevel or rs.level) or rs.level
        local difference=reference and r.level-reference or 0
        if difference>0 and (not gap or difference<gap) then gap=difference end
    end
    if gap then
        gap=math.floor(gap)
        return 'More recipes unlocked in '..gap..(gap==1 and ' level' or ' levels')
    end
end
function M.filter(options,state)
    local eligible={}
    local states={}
    for _,r in ipairs(options) do
        local rs=state
        if r.skill and state.skill and r.skill~=state.skill then
            if not states[r.skill] then states[r.skill]=M.state(nil,r.skill) end
            rs=states[r.skill]
        end
        local realOnly=r.masterCape or r.unboostable
        local effective=realOnly and (rs.baseLevel or rs.level) or rs.level
        local difference=effective and r.level-effective or math.huge
        local met=difference<=0 and not (realOnly and rs.baseKnown==false)
        local preview=rs.showUnderlevel and difference>0 and difference<3 and not (realOnly and rs.baseKnown==false)
        local boost=rs.showBoostable and not realOnly and boosts.reachable(r,rs)
        if met or preview or boost then eligible[#eligible+1]=r end
    end
    if not state.best then return eligible end
    local result={}
    local groups={}
    for _,r in ipairs(eligible) do
        local k=(r.skill or 'Herblore')..':'..r.method
        groups[k]=groups[k] or {};groups[k][#groups[k]+1]=r
    end
    for _,r in ipairs(eligible) do
        local replaced=false
        for _,other in ipairs(groups[(r.skill or 'Herblore')..':'..r.method]) do
            if r~=other and M.better(other,r) then replaced=true;break end
        end
        if not replaced then result[#result+1]=r end
    end
    return result
end
return M
