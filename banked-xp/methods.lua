local M={}
local herbs=require('herbs')
local api=require('api_xp')
local engine=require('recipe_engine')
local policy=require('recipe_policy')
local settings=require('settings')
local boosts=require('boosts')
local bankData=require('bank')
local outfits=require('outfits')
local choices={}
local revision=0
function M.summaryRevision() return revision end
local ok,stored=pcall(function() return PersistentDB:GetStructuredData('xpMethodsV1') end)
if ok and type(stored)=='table' then
    for k,v in pairs(stored) do if type(k)=='string' and type(v)=='string' then choices[k]=v end end
end
-- Most recently selected compatible method wins across every item.
-- Legacy per-item choices remain a fallback until a shared method applies.
local shared={}
local loaded,history=pcall(function() return PersistentDB:GetStructuredData('xpSharedMethodsV2') end)
if loaded and type(history)=='table' then
    local seen={}
    for _,id in ipairs(history) do
        if type(id)=='string' and not seen[id] then shared[#shared+1]=id;seen[id]=true end
    end
end
local function copy(t) local c={};for k,v in pairs(t) do c[k]=v end;return c end
function M.select(objID,id)
    revision=revision+1
    choices[tostring(objID)]=id
    for i=#shared,1,-1 do if shared[i]==id then table.remove(shared,i) end end
    table.insert(shared,1,id)
    local ok,saved=pcall(function()
        local sharedSaved=PersistentDB:SetStructuredData('xpSharedMethodsV2',shared)
        local legacySaved=PersistentDB:SetStructuredData('xpMethodsV1',choices)
        return sharedSaved and legacySaved
    end)
    if not ok or not saved then print('[banked-xp] Shared method selected for this session; preference could not be saved.') end
    bankData.invalidate()
end
-- Called only by the explicit local-data reset control.
function M.resetMemory()
    choices={}
    shared={}
    revision=revision+1
    bankData.invalidate()
end
local function identity(obj)
    local name=bankData.normalize(obj.name)
    local grimy=name:match('^grimy (.+)$')
    return grimy or name:gsub('^clean ',''),grimy~=nil
end
function M.options(obj,base,counts)
    if not base then return {} end
    local result={}
    if base.skill=='Herblore' then
        local herb,grimy=identity(obj)
        if grimy then result[#result+1]={id='clean',method='Clean herb',xp=base.xp,cleaning=true,skill='Herblore'} end
    elseif base.skill=='Prayer' and (base.method=='Bury bones' or base.method=='Scatter ashes') then
        result={{id='basic',method=base.method,multiplier=1,skill='Prayer'},
            {id='gilded0',method='Gilded altar: 0 burners',multiplier=2.5,skill='Prayer'},
            {id='gilded1',method='Gilded altar: 1 burner',multiplier=3,skill='Prayer'},
            {id='gilded2',method='Gilded altar: 2 burners',multiplier=3.5,skill='Prayer'},
            {id='chaos',method='Chaos altar',multiplier=3.5,skill='Prayer'},
            {id='ecto',method='Ectofuntus',multiplier=4,skill='Prayer'}}
    elseif obj.id==1517 then
        result={{id='regular',method='Burn logs',xp=135,skill='Firemaking'}}
        for n=1,5 do result[#result+1]={id='bonfire'..n,method='Bonfire: '..n..(n==5 and '+ players' or n==1 and ' player' or ' players'),players=n,skill='Firemaking'} end
    end
    local state=policy.state(counts,base.skill)
    for _,option in ipairs(policy.filter(engine.options(obj),state)) do
        if settings.showUnownedIngredients() or engine.inputsOwned(obj,option,counts) then
            result[#result+1]=option
        end
    end
    return result
end
local function chosen(obj,base,options)
    for _,id in ipairs(shared) do
        for _,c in ipairs(options) do if c.id==id then return c end end
        local replacement=policy.replacement(id,options)
        if replacement then return replacement end
    end
    local wanted=choices[tostring(obj.id)]
    if not wanted then
        for _,c in ipairs(options) do if c.method==base.method then return c end end
        return options[1]
    end
    for _,c in ipairs(options) do if c.id==wanted then return c end end
    return policy.replacement(wanted,options) or options[1]
end
-- Summary uses the same saved method preference without counting every
-- alternative as additional XP. Level previews are never banked XP.
function M.summaryMethod(obj,base,counts)
    local available={}
    local state=policy.state(counts,base.skill)
    for _,r in ipairs(M.options(obj,base,counts)) do
        local _,met=policy.presentation(r)
        local rs=policy.state(counts,r.skill or base.skill)
        if not r.engine or met or (rs.showBoostable and boosts.reachable(r,rs)) then
            available[#available+1]=r
        end
    end
    return chosen(obj,base,available)
end
-- Skill totals use all usable methods, independently of item menu choices.
function M.summaryCandidates(obj,base,counts)
    local result={}
    for _,r in ipairs(M.options(obj,base,counts)) do
        local _,met=policy.presentation(r)
        local state=policy.state(counts,r.skill or base.skill)
        if not r.engine or met or (state.showBoostable and boosts.reachable(r,state)) then result[#result+1]=r end
    end
    return result
end
function M.summaryPriority(id)
    for i,v in ipairs(shared) do if v==id then return i end end
    return #shared+1
end
function M.estimate(obj,base,bank,count)
    local counts=bankData.snapshot(bank)
    outfits.observeBank(counts);outfits.refresh()
    local options=M.options(obj,base,counts)
    local method=chosen(obj,base,options)
    -- A level-locked item may still show an informational hover. Keep this
    -- fallback out of the selectable options and skill-summary candidates.
    local levelPreview=false
    local ingredientPreview=false
    -- Arrow tips should remain identifiable even when no complete recipe is
    -- available. This informational route never enters menus or summaries.
    if not method and (bankData.normalize(obj.name):match('arrow tips?$') or bankData.normalize(obj.name):match('^resonant anima of ')) then
        for _,candidate in ipairs(engine.options(obj)) do
            if (candidate.category=='Specialist arrow tips' or candidate.category=='Resonant anima') and #candidate.inputs==2 then
                method=candidate;ingredientPreview=true;break
            end
        end
    end
    if not method then
        local bestGap
        for _,candidate in ipairs(engine.options(obj)) do
            local state=policy.state(counts,candidate.skill or base.skill)
            local level=(candidate.masterCape or candidate.unboostable) and state.baseLevel or state.level
            local gap=level and candidate.level and candidate.level-level
            if gap and gap>0 and (settings.showUnownedIngredients() or engine.inputsOwned(obj,candidate,counts))
                and (not bestGap or gap<bestGap) then
                method=candidate;bestGap=gap;levelPreview=true
            end
        end
    end
    if not method then
        local result=copy(base)
        if #engine.options(obj)>0 then
            result.method='No available recipes';result.xp=0;result.total=0
            local level=require('skill_support').level(base.skill,'GetLevelGameplay')
            local ok=level~=nil
            if not ok or type(level)~='number' or level<1 then result.note=base.skill..' level unavailable'
            elseif #policy.filter(engine.options(obj),policy.state(counts,base.skill))==0 then
                result.note=policy.nextUnlock(engine.options(obj),policy.state(counts,base.skill)) or 'No recipes available at your level'
            elseif not counts then result.note='Bank supplies unavailable'
            else
                result.note='Missing or insufficient bank ingredients; enable unowned ingredients in settings to show more recipes'
                local unlock=policy.nextUnlock(engine.options(obj),policy.state(counts,base.skill))
                if unlock then result.note=result.note..' | '..unlock end
            end
        else result.total=count*(base.xp or 0) end
        return result,options
    end
    if method.engine then
        local result=copy(engine.estimate(obj,method,counts))
        result.ingredientPreview=ingredientPreview
        if not settings.showRecipeOnHover() and result.note then
            local prefix=result.note:match('^(Lv %d+; )') or ''
            local detail=result.limitingIngredient and ('Limited by: '..result.limitingIngredient) or 'Bank supplies'
            if result.needsDecanting then detail=detail..', after decanting' end
            -- Replace presentation only; the shared recipe estimate stays cached.
            result.note=prefix..detail..(result.note:match(' | .*$') or '')
        end
        if method.additionalXP then
            local extra={}
            for skill,xp in pairs(method.additionalXP) do extra[#extra+1]=tostring(xp)..' '..skill..' XP per action' end
            table.sort(extra)
            if #extra>0 then result.note=(result.note and result.note..' | ' or '')..'Also grants: '..table.concat(extra,', ') end
        end
        if ingredientPreview then
            result.note=(result.note and result.note..' | ' or '')..((result.total or 0)>0 and 'Recipe unavailable at current level; preview only' or 'Supplies missing; preview only')
        end
        local label,met=policy.presentation(method)
        result.method=label
        if result.note then result.note=result.note:gsub('^Lv %d+; ','') end
        local state=policy.state(counts,method.skill)
        if (method.masterCape or method.unboostable) and not met then
            result.note=(result.note and result.note..' | ' or '')..'Requires real '..method.skill..' level '..tostring(method.level):gsub('%.0$','')..'; cannot be boosted'
        end
        local boostNote=state.showBoostable and boosts.note(method,state)
        if boostNote then result.note=(result.note and result.note..' | ' or '')..boostNote end
        for skill,required in pairs(method.requiredLevels or {}) do
            result.note=(result.note and result.note..' | ' or '')..'Requires '..skill..' level '..tostring(required):gsub('%.0$','')
        end
        local required=method.level
        local effective=(method.masterCape or method.unboostable) and state.baseLevel or state.level
        if required and effective and required>effective then
            local color=required-effective>=5 and 'ff0000' or 'ff9900'
            result.method=result.method:gsub('(%[Lv %d+%])','<col='..color..'>%1</col>')
            result.levelPreview=levelPreview
        end
        local unlock=policy.nextUnlock(engine.options(obj),state)
        if unlock then result.note=(result.note and result.note..' | ' or '')..unlock end
        return result,options
    end
    local result=copy(base)
    result.method=method.method;result.skill=method.skill or base.skill;result.potential=nil;result.note=nil
    if method.cleaning then
        result.xp=base.xp;result.total=count*result.xp
    elseif method.multiplier then
        result.xp=base.xp*method.multiplier;result.total=count*result.xp
    elseif method.players then
        local ok,level=pcall(function() return Player.GetLevelCapped(SkillType.FIREMAKING) end)
        local scale=1+(method.players-1)*0.01
        if ok and type(level)=='number' and level>=99 then result.xp=175*scale
        elseif ok and level==45 then result.xp=135*scale
        else
            -- Endpoints are verified; do not invent an intermediate formula.
            result.xp=nil;result.minXP=135*scale;result.maxXP=175*scale
            result.note='Level-dependent XP range'
        end
        if result.xp then result.total=count*result.xp end
    else result.xp=method.xp;result.total=count*method.xp end
    if base.skill=='Herblore' then
        local unlock=policy.nextUnlock(engine.options(obj),policy.state(counts,base.skill))
        if unlock then result.note=(result.note and result.note..' | ' or '')..unlock end
    end
    return result,options
end
local menuStyle=require('menu_style')
local pages={}
local function addEntry(menu,label,callback)
    local before=#menu.entries
    menu:Add(label,callback)
    menuStyle.placeAdded(menu,label,before)
end
function M.addMenu(menu,obj,options,base)
    menuStyle.prepare(menu)
    local nameColor=menuStyle.color(menu)
    local selected=chosen(obj,base or {},options)
    local size=10
    local lastPage=math.max(1,math.ceil(#options/size))
    local page=math.min(pages[obj.id] or 1,lastPage)
    for i=(page-1)*size+1,math.min(page*size,#options) do
        local method=options[i]
        local id=method.id
        local presentation=policy.presentation(method)
        presentation=menuStyle.contextLabel(presentation,obj.name)
        local label='<col=00ffff>BXP</col>: '..menuStyle.label(method,presentation,nameColor)
        if selected and selected.id==id then label=label..' [<col=00ff00>selected</col>]' end
        addEntry(menu,label,function() M.select(obj.id,id) end)
    end
    if lastPage>1 then
        if page>1 then addEntry(menu,'<col=00ffff>BXP</col>: Previous methods ('..(page-1)..'/'..lastPage..')',function() pages[obj.id]=page-1 end) end
        if page<lastPage then addEntry(menu,'<col=00ffff>BXP</col>: Next methods ('..(page+1)..'/'..lastPage..')',function() pages[obj.id]=page+1 end) end
    end
    -- Add() may insert below Cancel. Normalize only after every addition.
    menuStyle.prepare(menu)
end
local baseEstimate=M.estimate
function M.estimate(...)
    local result,options=baseEstimate(...)
    result=require('archaeology').decorate(result,options,...)
    if (not options or #options==0) and not (result and result.artefactPreview) then return result,options end
    return require('hand_equipment').decorate(outfits.decorate(result)),options
end
return M
