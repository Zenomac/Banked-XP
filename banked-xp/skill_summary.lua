-- Session-only bank cache. Calculation advances on Logic, never on Draw.
local M={}
local bankData=require('bank')
local catalog=require('catalog')
local methods=require('methods')
local engine=require('recipe_engine')
local settings=require('settings')
local outfits=require('outfits')
local storage=require('storage')
local snapshot,signature,job,totals,lastRecords,lastPolicy,lastBankRecords,lastStorageRevision
local warned=false
local age,ticks=0,0
local skillSupport=require('skill_support')
local supported=skillSupport.supported
local function countString(n) return string.format('%.0f',n):reverse():gsub('(%d%d%d)','%1,'):reverse():gsub('^,','') end
-- Explicit incremental job: all API calls remain on the event thread.
local function newJob(records,counts)
    local out={}
    for _,skill in ipairs(skillSupport.names) do out[skill]={min=0,max=0} end
    return {records=records,counts=counts,index=1,phase='items',routes={},seen={},out=out,recipeSeen={}}

end
local function globalExtra(j,obj,skill,xp)
    j.globalExtras=j.globalExtras or {}
    local id='total:'..skill..':'..tostring(obj.id)
    local k=engine.key(obj.name)
    j.globalExtras[id]={id=id,skill=skill,xp=xp,inputs={{name=obj.name,qty=1}},inputsNormalized={{key=k,name=obj.name,qty=1}},keys={[k]=true}}
end
local function advanceOne(j)
    local out,routes,seen,counts=j.out,j.routes,j.seen,j.counts
    if j.phase=='items' then
        local record=j.records[j.index]
        if record then
            local obj,n=record.obj,record.count
            -- Potential restoration XP counts owned damaged artefacts once,
            -- without requiring materials held in unscanned material storage.
            local name=(obj.name or ''):lower()
            if name:match('%(damaged%)$') or name:match('^damaged soul beacon') then
                local best=0
                for _,r in ipairs(engine.options(obj)) do
                    if r.skill=='Archaeology' then
                        local policy=require('recipe_policy')
                        local state=policy.state(counts,r.skill)
                        local _,met=policy.presentation(r)
                        if met or (state.showBoostable and require('boosts').reachable(r,state)) then
                            for _,input in ipairs(r.inputs or {}) do
                                if input.name and input.name:lower()==name then best=math.max(best,r.xp/input.qty) end
                            end
                        end
                    end
                end
                out.Archaeology.potential=(out.Archaeology.potential or 0)+n*best
                if best>0 then globalExtra(j,obj,'Archaeology',best) end
            end
            local base=catalog.lookup(obj)
            if base and supported[base.skill] then
                local bestLo,bestHi=0,0
                for _,method in ipairs(methods.summaryCandidates(obj,base,counts)) do
                    if method.engine then
                        if not (obj.id==1517 and method.skill=='Firemaking') and not seen[method.id] then seen[method.id]=true;routes[#routes+1]=method end
                    elseif base.skill~='Herblore' then
                        local lo,hi
                        if method.multiplier then lo=n*base.xp*method.multiplier;hi=lo
                        elseif method.players then
                            local level=skillSupport.level('Firemaking','GetLevelCapped')
                            local scale=1+(method.players-1)*0.01
                            lo=n*135*scale;hi=n*175*scale
                            if level and level>=99 then lo=hi elseif level==45 then hi=lo end
                        elseif method.xp then lo=n*method.xp;hi=lo end
                        if lo and hi>bestHi then bestLo,bestHi=lo,hi end
                    end
                end
                if bestHi>0 then
                    out[base.skill].min=out[base.skill].min+bestLo
                    out[base.skill].max=out[base.skill].max+bestHi
                    globalExtra(j,obj,base.skill,bestHi/n)
                end
            end
            -- Resolve every supported skill independently of the catalogue's
            -- first skill match for multi-use supplies.
            for _,r in ipairs(engine.options(obj)) do
                if supported[r.skill] and not j.recipeSeen[r.id] then
                    j.recipeSeen[r.id]=true
                    local policy=require('recipe_policy')
                    local state=policy.state(counts,r.skill)
                    local _,met=policy.presentation(r)
                    local eligible=met or (state.showBoostable and require('boosts').reachable(r,state))
                    if eligible and engine.inputsOwned(obj,r,counts) then
                        if not seen[r.id] and not (obj.id==1517 and r.skill=='Firemaking') then seen[r.id]=true;routes[#routes+1]=r end
                    end
                end
            end
            local clean=require('herbs').lookup(record.obj)
            if clean and clean.method=='Clean herb' then j.cleanXP=(j.cleanXP or 0)+record.count*clean.xp end
            j.index=j.index+1
        else
            -- Prefer the highest XP per primary ingredient, with total XP
            -- as a tie-breaker. This is a deterministic greedy estimate, not
            -- a proof of the mathematical optimum for all shared recipes.
            local function higher(a,b)
                local ax=a.xp/((a.inputs and a.inputs[1] and a.inputs[1].qty) or 1)
                local bx=b.xp/((b.inputs and b.inputs[1] and b.inputs[1].qty) or 1)
                if ax~=bx then return ax>bx end
                if a.xp~=b.xp then return a.xp>b.xp end
                return a.id<b.id
            end
            table.sort(routes,higher)
            j.globalRoutes={}
            for _,route in ipairs(routes) do if route.skill~='Archaeology' then j.globalRoutes[#j.globalRoutes+1]=route end end
            for _,route in pairs(j.globalExtras or {}) do j.globalRoutes[#j.globalRoutes+1]=route end
            table.sort(j.globalRoutes,higher)
            j.globalPortfolio=engine.newPortfolio(counts)
            j.portfolios={}
            for _,skill in ipairs(skillSupport.names) do j.portfolios[skill]=engine.newPortfolio(counts) end
            j.index=1;j.phase='routes' 
        end
    elseif j.phase=='routes' then
        local route=routes[j.index]
        if route then engine.allocatePortfolio(j.portfolios[route.skill or 'Herblore'],route);j.index=j.index+1
        else
            if not j.globalDone then j.phase='global';j.index=1;return end
            out._totalBySkill=j.globalPortfolio.bySkill or {}
            out._totalBySkill.Herblore=(out._totalBySkill.Herblore or 0)+(j.cleanXP or 0)
            for skill,portfolio in pairs(j.portfolios) do
                out[skill].min=out[skill].min+portfolio.total
                out[skill].max=out[skill].max+portfolio.total
                out[skill].routes=portfolio.used
            end
            out.Herblore.min=out.Herblore.min+(j.cleanXP or 0)
            out.Herblore.max=out.Herblore.max+(j.cleanXP or 0)
            return out
        end
    elseif j.phase=='global' then
        local route=j.globalRoutes[j.index]
        if route then engine.allocatePortfolio(j.globalPortfolio,route);j.index=j.index+1
        else j.globalDone=true;j.phase='routes';j.index=#routes+1 end
    end
end
local function policyKey()
    local parts={}
    for _,skill in ipairs(skillSupport.names) do
        parts[#parts+1]=skill..':'..tostring(skillSupport.level(skill,'GetLevelGameplay'))..':'..tostring(skillSupport.level(skill,'GetLevelCapped'))
    end
    return table.concat(parts,'|')..'|'..tostring(settings.showBoostableRecipes())..'|'..tostring(settings.showUnderlevelRecipes())..'|'..tostring(settings.showUnownedIngredients())

end
function M.capture(bank)
    local counts=bankData.snapshot(bank)
    outfits.observeBank(counts)
    if not counts then return false end
    local parts={};for name,n in pairs(counts) do parts[#parts+1]=name..'='..n end
    table.sort(parts)
    local policy=policyKey()
    local sig=table.concat(parts,'\n')..'|'..policy
    age=0
    if sig==signature then lastStorageRevision=storage.revision();return true end
    local got,slots=pcall(function() return bankData.slots(bank) end)
    if not got or not slots then return false end
    local records={}
    for _,slot in pairs(slots) do
        if slot.obj and type(slot.count)=='number' and slot.count>0 then records[#records+1]={obj=slot.obj,count=slot.count} end
    end
    lastBankRecords={}
    for _,record in ipairs(records) do lastBankRecords[#lastBankRecords+1]=record end
    for _,record in ipairs(storage.records()) do records[#records+1]=record end
    lastStorageRevision=storage.revision()
    table.sort(records,function(a,b) return a.obj.name<b.obj.name end)
    signature=sig;snapshot=counts;totals=nil;lastRecords=records;lastPolicy=policy
    job=newJob(records,counts)
    return true
end
function M.advance(steps)
    for _=1,steps or 2 do
        if not job then break end
        local ok,result=pcall(advanceOne,job)
        if not ok then job=nil;totals=nil;error(tostring(result),0) end
        if result then totals=result;job=nil end
    end
end
function M.line(skill)
    if not supported[skill] then return 'Banked XP: not yet supported' end
    if not snapshot then return 'Banked XP: open your bank to scan' end
    if not totals then return 'Banked XP: calculating bank summary...' end
    local t=totals[skill]
    local handPercent=require('hand_equipment').percent(skill)
    local percent=outfits.percent(skill)+handPercent
    local factor=1+percent/100
    local minimum,maximum=t.min,t.max
    if skill=='Archaeology' then minimum=math.max(minimum,t.potential or 0);maximum=math.max(maximum,t.potential or 0) end
    local n=countString(minimum*factor)
    if maximum~=minimum then n=n..' - '..countString(maximum*factor) end
    local basis=percent>0 and ('base + '..percent..(handPercent>0 and '% equipment; ' or '% outfit; ')) or 'base; '
    return 'Banked XP: '..n..' ('..basis..(age>25 and 'last bank scan' or 'bank scan')..')'
end
function M.tooltipLine(skill)
    local line=M.line(skill)
    local text=(line:gsub(' %([^%)]*%)$',''))
    return text
end
function M.totalLine()
    if not snapshot then return 'Banked XP: Scan bank' end
    if not totals then return 'Banked XP: Calculating...' end
    local total=0
    for skill,xp in pairs(totals._totalBySkill or {}) do
        local percent=outfits.percent(skill)+require('hand_equipment').percent(skill)
        total=total+xp*(1+percent/100)
    end
    return 'Banked XP: '..countString(total)
end
function M.missingStorage(skill)
    if skill=='Total' then return storage.missingForSkill('Smithing') or storage.missingForSkill('Archaeology') end
    return storage.missingForSkill(skill)
end
function M.tooltipExtra(skill)
    if skill~='Archaeology' or not totals then return nil end
    local t=totals[skill]
    if (t.potential or 0)<=t.max then return nil end
    local percent=outfits.percent(skill)+require('hand_equipment').percent(skill)
    return countString(t.max*(1+percent/100))
end
function M.details(skill)
    if supported[skill] and totals then
        return 'High-XP methods; supplies counted once per skill<br>'..storage.status()..(settings.showBoostableRecipes() and '<br>Includes enabled boost assumptions' or '')
    end

end
function M.supports(skill) return supported[skill]==true end
function M.clear() snapshot=nil;signature=nil;job=nil;totals=nil;age=0;lastRecords=nil;lastPolicy=nil;lastBankRecords=nil;lastStorageRevision=nil end
function M.tick()
    ticks=ticks+1;age=age+1
    if ticks%25==1 then
        local ok,bank=pcall(function() return Inventory.Find(config.Inv.BANK) end)
        if ok and bank then M.capture(bank) end
    end
    if ticks%25==1 and lastBankRecords and lastStorageRevision~=storage.revision() then
        -- Rebuild with the cached bank plus the new auxiliary scan, even when
        -- the bank itself has closed. Preserve original bank slots separately.
        local records=lastBankRecords
        bankData.invalidate()
        M.capture({id=-990,isValid=true,GetSlots=function() return records end})
    end
    local policy=ticks%25==1 and snapshot and lastRecords and policyKey() or nil
    if policy and lastPolicy~=policy then
        lastPolicy=policy;totals=nil;signature=nil
        local records,counts=lastRecords,snapshot
        job=newJob(records,counts)
    end
    M.advance(2)
end
function M.register()
    if Event.Logic then Event.Logic.Subscribe('bankedXpSkillSummary',function()
        local ok,err=pcall(M.tick)
        if not ok and not warned then print('[banked-xp] Bank summary error: '..tostring(err));warned=true end
    end) end
    for _,name in ipairs({'InventoryUpdated','InventoryAdded','InventoryRemoved','SkillTransmit'}) do
        if Event[name] then Event[name].Subscribe('bankedXpSummaryRefresh',function() ticks=0;bankData.invalidate() end) end
    end
    -- Avoid carrying another character/world's bank into a new session.
    if Event.GameStateChanged then Event.GameStateChanged.Subscribe('bankedXpSummarySession',M.clear) end
end
return M
