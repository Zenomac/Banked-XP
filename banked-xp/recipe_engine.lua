-- One recipe index for herbs, unfinished potions, finished inputs and supplies.
local M={}
local bank=require('bank')
local recipes={}
for _,row in ipairs(require('wiki_recipes')) do recipes[#recipes+1]=row end
for _,row in ipairs(require('skill_recipes')) do recipes[#recipes+1]=row end
local preparations=require('wiki_preparations')
local herbs=require('herbs').data
local function copy(t) local c={};for k,v in pairs(t) do c[k]=v end;return c end
local aliases={['ground mud runes']='ground mud rune',['wyvern bonemeal']='ground wyvern bones',
 ['desert phoenix feather']='phoenix feather',['arbuck (unf)']='arbuck potion (unfinished)'}
local function key(name)
    local n=bank.normalize(name)
    n=string.gsub(n,'%(unf%)','(unfinished)')
    n=aliases[n] or n
    if herbs[n] then n='clean '..n end
    local family,doses=n:match('^(.-)%s*%((%d+)%)$')
    if family and tonumber(doses)>=1 and tonumber(doses)<=6 then
        family=string.gsub(family,'flask','')
        family=string.gsub(family,'potion','')
        family=string.gsub(family,'[%s%p]','')
        -- Preserve antipoison/poison strength, which punctuation removal would erase.
        local plus=n:match('(%++)') or ''
        return 'dose:'..family..plus,tonumber(doses)
    end
    return 'item:'..n,1
end
M.key=key
local producers,index={},{}
local function input(raw)
    local k,units=key(raw.name)
    return {key=k,qty=raw.qty*units,name=raw.name}
end
for _,p in ipairs(preparations) do
    local k,units=key(p.output.name)
    local ins={};for _,v in ipairs(p.inputs) do ins[#ins+1]=input(v) end
    producers[k]={inputs=ins,yield=p.output.qty*units}
end
for herb in pairs(herbs) do
    producers[key('Clean '..herb)]={inputs={{key=key('Grimy '..herb),qty=1,name='Grimy '..herb}},yield=1}
end
local function ancestors(k,set,depth)
    if set[k] or depth>12 then return end
    set[k]=true
    local p=producers[k]
    if p then for _,v in ipairs(p.inputs) do ancestors(v.key,set,depth+1) end end
end
-- Improved material-saving variants require the actual skill level, not a
-- temporary level boost. Preserve alternative base recipes independently.
local improvedNames={['Adrenaline renewal potion']=true,['Poison bomb']=true,
    ['Sticky bomb']=true,['Vulnerability bomb']=true,['Powerburst of opportunity']=true,
    ['Powerburst of vitality']=true,['Powerburst of masterstroke']=true,
    ['Powerburst of sorcery']=true,['Powerburst of acceleration']=true,['Powerburst of feats']=true}
for _,r in ipairs(recipes) do
    local tableID=tonumber(r.id:match(':(%d+)$'))
    if improvedNames[r.method] and (tableID==2 or (r.method=='Adrenaline renewal potion' and tableID==5)) then
        r.unboostable=true
    end
end
-- Creation-table skill levels can be lower than a separate cape prerequisite.
-- Apply the full requirement before indexing, labels, filtering or estimates.
for _,r in ipairs(recipes) do
    r.recipeLevel=r.level
    for _,requirement in ipairs(r.requirements or {}) do
        if string.lower(requirement):find('herblore master cape',1,true) then
            r.masterCape=true;r.level=math.max(120,r.level)
            r.label=r.label:gsub('%[Lv %d+','[Lv '..r.level)
            break
        end
    end
end
-- Keep menus concise; the complete recipe belongs in the hover information.
-- Precompute all display strings once so no new work is added per Draw frame.
local groups={}
for _,r in ipairs(recipes) do
    local groupKey=(r.skill or 'Herblore')..':'..r.method
    groups[groupKey]=groups[groupKey] or {}
    groups[groupKey][#groups[groupKey]+1]=r
    local parts={}
    for _,i in ipairs(r.inputs) do
        parts[#parts+1]=tostring(i.qty):gsub('%.0$','')..' '..i.name
    end
    r.recipeText=table.concat(parts,' + ')
end
for _,group in pairs(groups) do
    local common={}
    for _,i in ipairs(group[1].inputs) do common[i.name]=true end
    local hasImproved,hasUnfinished=false,false
    local rawBases,rawBaseCount={},0
    for _,r in ipairs(group) do
        local present={}
        for _,i in ipairs(r.inputs) do present[i.name]=true end
        for name in pairs(common) do if not present[name] then common[name]=nil end end
        if r.unboostable then hasImproved=true end
        if #r.inputs==1 and r.inputs[1].name:find('(unfinished)',1,true) then hasUnfinished=true
        else
            for _,i in ipairs(r.inputs) do
                if key(i.name):match('^dose:') then
                    if not rawBases[i.name] then rawBases[i.name]=true;rawBaseCount=rawBaseCount+1 end
                    r.menuBase=i.name;break
                end
            end
        end
    end
    for _,r in ipairs(group) do
        local tags={}
        if r.masterCape then tags[#tags+1]='Master cape' end
        if hasImproved then tags[#tags+1]=r.unboostable and 'Improved' or 'Standard' end
        if hasUnfinished then
            tags[#tags+1]=#r.inputs==1 and r.inputs[1].name:find('(unfinished)',1,true) and 'Unfinished'
                or (rawBaseCount>1 and r.menuBase or 'Base potions')
        elseif #group>1 and (not hasImproved or #group>2) then
            local alternate
            for _,i in ipairs(r.inputs) do
                if not common[i.name] then
                    alternate=alternate or i.name
                    if key(i.name):match('^dose:') then alternate=i.name;break end
                end
            end
            -- Log variants are already identified by the hovered bank item.
            local logTag=alternate and (key(alternate)=='logs' or key(alternate):match(' logs$') or key(alternate):match(' log$'))
            if alternate and not logTag then tags[#tags+1]=alternate end
        end
        r.shortLabel=r.method
        if #tags>0 then r.shortLabel=r.shortLabel..' ['..table.concat(tags,', ')..']' end
        r.shortLabel=r.shortLabel..' [Lv '..tostring(r.level):gsub('%.0$','')..']'
    end
end
for _,r in ipairs(recipes) do
    if r.primalYield then r.shortLabel='Primal extract [Yield x'..r.primalYield..'] [Lv '..r.level..']' end
    r.engine=true;r.skill=r.skill or 'Herblore';r.inputsNormalized={};r.keys={}
    for _,v in ipairs(r.inputs) do
        local i=input(v);r.inputsNormalized[#r.inputsNormalized+1]=i
        ancestors(i.key,r.keys,0)
    end
    for k in pairs(r.keys) do index[k]=index[k] or {};index[k][#index[k]+1]=r end
end
for _,list in pairs(index) do
    table.sort(list,function(a,b)
        if a.method~=b.method then return a.method<b.method end
        if a.level~=b.level then return a.level<b.level end
        return a.id<b.id
    end)
end
function M.options(obj) return index[key(obj.name)] or {} end
function M.lookup(obj)
    local options=M.options(obj)
    if #options>0 then
        local r=options[1]
        return {skill=r.skill,method=r.method,xp=r.xp/r.output.qty,unit='items'}
    end
    -- Finished products without a downstream recipe have no banked XP.
    -- Leave their native game tooltip untouched; no zero-XP placeholder.
    return nil
end
local cachedCounts,stock,cache,readyDoses
local function readyKey(name,k,doses)
    local flask=doses>4 or bank.normalize(name):find('flask',1,true)~=nil
    return k..'|'..doses..'|'..(flask and 'flask' or 'vial')
end
local function snapshot(counts)
    if cachedCounts==counts then return stock end
    cachedCounts=counts;stock={};cache={};readyDoses={}
    for name,n in pairs(counts) do
        local k,units=key(name);stock[k]=(stock[k] or 0)+n*units
        if k:match('^dose:') then
            local ready=readyKey(name,k,units)
            readyDoses[ready]=(readyDoses[ready] or 0)+n
        end
    end
    return stock
end
-- Reserve all existing direct ingredients together before producing missing
-- unfinished inputs. Shared ingredients cannot be spent twice.
local function consumeMany(s,inputs,batches,blocked,visiting)
    local deficits={}
    for _,i in ipairs(inputs) do
        local need=i.qty*batches;local have=math.min(need,s[i.key] or 0)
        s[i.key]=(s[i.key] or 0)-have
        if need>have then deficits[#deficits+1]={key=i.key,qty=need-have,name=i.name} end
    end
    for _,d in ipairs(deficits) do
        local p=producers[d.key]
        if not p or blocked[d.key] or visiting[d.key] then return false,d.name end
        visiting[d.key]=true
        local n=math.ceil(d.qty/p.yield)
        local ok,missing=consumeMany(s,p.inputs,n,blocked,visiting)
        visiting[d.key]=nil
        if not ok then return false,missing end
        s[d.key]=(s[d.key] or 0)+n*p.yield-d.qty
    end
    return true
end
-- Menu availability and hover XP use exactly the same bank planner.
-- Presence alone is insufficient: require at least one whole crafting batch.
function M.inputsOwned(obj,r,counts)
    if not counts then return false end
    local result=M.estimate(obj,r,counts)
    return type(result.craftable)=='number' and result.craftable>=r.output.qty
end
function M.estimate(obj,r,counts)
    local result={method=r.shortLabel,skill=r.skill,xp=r.xp/r.output.qty,unit='items',source='wiki',outputUnit=r.outputUnit,xpUnit=r.xpUnit}
    if not counts then result.note='Bank supplies unavailable';return result end
    local initial=snapshot(counts)
    local hover=key(obj.name)
    local cacheKey=r.id..'|'..hover
    if cache[cacheKey] then return copy(cache[cacheKey]) end
    local blocked={}
    -- Hovering an unfinished item estimates only existing unfinished stock.
    if obj.name:lower():find('(unf',1,true) then blocked[hover]=true end
    -- Only this recipe's direct/preparation inputs can be consumed. Copying
    -- unrelated bank stock for every trial made large banks needlessly costly.
    local available={}
    for k in pairs(r.keys) do if initial[k] then available[k]=initial[k] end end
    -- A liquid tooltip must not count unfinished items that no longer need it.
    if hover==key('Vial of water') or hover==key('Juju vial of water') or hover==key('Coconut milk') then
        for k in pairs(producers) do
            local set={};ancestors(k,set,0)
            if set[hover] and k~=hover then available[k]=0 end
        end
    end
    local upper=0;for _,n in pairs(available) do upper=upper+n end
    upper=math.floor(upper)
    local lo,hi=0,upper
    while lo<hi do
        local mid=math.floor((lo+hi+1)/2)
        if consumeMany(copy(available),r.inputsNormalized,mid,blocked,{}) then lo=mid else hi=mid-1 end
    end
    local _,missing=consumeMany(copy(available),r.inputsNormalized,lo+1,blocked,{})
    local xp=r.xp
    if r.skill=='Herblore' and r.output.qty==1 then
        local ok,live=pcall(require('api_xp').lookup,obj,{skill='Herblore',method=r.method,xp=xp})
        if ok and live then xp=live.xp;result.source='api' end
    end
    result.xp=xp/r.output.qty
    result.craftable=lo*r.output.qty;result.total=lo*xp
    local decanting=false
    if lo>0 then
        local demands={}
        for _,i in ipairs(r.inputs) do
            local k,doses=key(i.name)
            if k:match('^dose:') then
                local ready=readyKey(i.name,k,doses)
                demands[ready]=(demands[ready] or 0)+i.qty*lo
            end
        end
        for ready,n in pairs(demands) do
            if (readyDoses[ready] or 0)<n then decanting=true;break end
        end
    end
    result.needsDecanting=decanting
    result.limitingIngredient=missing
    local limit='Limited by: '..r.recipeText
    if decanting then limit=limit..', after decanting' end
    local notes={'Lv '..tostring(r.level):gsub('%.0$','')..'; '..limit}
    for _,requirement in ipairs(r.requirements) do notes[#notes+1]='Requires: '..requirement end
    for _,i in ipairs(r.inputsNormalized) do
        if i.key==hover and not hover:match('^dose:') then result.inputPerPotion=i.qty/r.output.qty end
    end
    result.note=table.concat(notes,' | ')
    cache[cacheKey]=copy(result)
    return result
end
M.recipes=recipes
-- One shared budget across selected routes. No finished potion outputs are
-- recycled into further recipes: this matches item-hover planning semantics.
function M.newPortfolio(counts)
    return {available=copy(snapshot(counts)),total=0,used=0}
end
function M.allocatePortfolio(state,r)
    local available=state.available
    local relevant={};local upper=0
    for k in pairs(r.keys) do
        relevant[k]=available[k] or 0;upper=upper+relevant[k]
    end
    local lo,hi=0,math.floor(upper)
    while lo<hi do
        local mid=math.floor((lo+hi+1)/2)
        if consumeMany(copy(relevant),r.inputsNormalized,mid,{}, {}) then lo=mid else hi=mid-1 end
    end
    if lo>0 then
        assert(consumeMany(relevant,r.inputsNormalized,lo,{},{}))
        for k in pairs(r.keys) do available[k]=relevant[k] or 0 end
        state.minTotal=(state.minTotal or state.total)+lo*(r.minXP or r.xp)
        state.total=state.total+lo*r.xp;state.used=state.used+1
        state.bySkill=state.bySkill or {}
        local skill=r.skill or 'Herblore'
        state.bySkill[skill]=(state.bySkill[skill] or 0)+lo*r.xp
        if state.includeSecondary then
            for other,xp in pairs(r.additionalXP or {}) do
                state.bySkill[other]=(state.bySkill[other] or 0)+lo*xp
                state.total=state.total+lo*xp
            end
        end
    end
end
function M.portfolio(routes,counts)
    local state=M.newPortfolio(counts)
    for _,r in ipairs(routes) do M.allocatePortfolio(state,r) end
    return state.total,state.used,state.available
end
return M
