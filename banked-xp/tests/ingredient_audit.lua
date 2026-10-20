package.path='./?.lua;banked-xp/?.lua;'..package.path
-- Existing potion audit intentionally scopes the recipe provider to Herblore.
package.preload.skill_recipes=function() return {} end
package.preload.summoning_recipes=function() return {} end
-- The client binding rejects extra arguments that stock Lua ignores.
local nativeLower=string.lower
string.lower=function(value,...)
 assert(select('#',...)==0,'client string.lower received extra arguments')
 return nativeLower(value)
end
PersistentDB={GetStructuredData=function() return {} end,SetStructuredData=function() return true end}
Player={GetLevelGameplay=function() return 120 end,GetLevelCapped=function() return 120 end}
SkillType={HERBLORE=15}
local e=require('recipe_engine');local methods=require('methods');local catalog=require('catalog');local settings=require('settings')
assert(not settings.showUnownedIngredients())
local function clone(t) local c={};for k,v in pairs(t) do c[k]=v end;return c end
local cases=0
for _,r in ipairs(e.recipes) do
 local counts,totals,required={},{},{}
 for _,i in ipairs(r.inputs) do
  local name=string.lower(i.name);counts[name]=(counts[name] or 0)+i.qty
  local k,units=e.key(name);totals[k]=(totals[k] or 0)+i.qty*units
 end
 for _,i in ipairs(r.inputsNormalized) do required[i.key]=(required[i.key] or 0)+i.qty end
 local obj={name=r.inputs[1].name}
 assert(e.inputsOwned(obj,r,counts),'complete batch rejected '..r.id)
 local full=e.estimate(obj,r,counts)
 assert(full.craftable==r.output.qty and full.total==r.xp,'exact batch '..r.id)
 cases=cases+1
 -- Remove all aliases/dose sizes for each required ingredient family.
 for missing in pairs(required) do
  local altered=clone(counts)
  for name in pairs(altered) do if e.key(name)==missing then altered[name]=nil end end
  assert(not e.inputsOwned(obj,r,altered),'missing ingredient accepted '..r.id..' '..missing)
  cases=cases+1
 end
 -- Reduce every ingredient in turn by one unit or dose. A direct-stock
 -- reference calculation independently predicts zero whole batches.
 for shortage in pairs(required) do
  local altered=clone(counts)
  for name,n in pairs(altered) do
   local k,units=e.key(name)
   if k==shortage then
    altered[name]=nil
    if k:sub(1,5)=='dose:' then
     local one=name:gsub('%(%d+%)$','(1)')
     altered[one]=n*units-1
    else altered[name]=n-1 end
    break
   end
  end
  assert(not e.inputsOwned(obj,r,altered),'shortage accepted '..r.id..' '..shortage)
  assert(e.estimate(obj,r,altered).craftable==0,'shortage XP planner '..r.id)
  cases=cases+1
 end
end
-- Audit virtual unfinished inputs and remove every leaf material in turn.
local producers={};for _,p in ipairs(require('wiki_preparations')) do producers[e.key(p.output.name)]=p end
local function expand(name,n,counts,seen)
 local k=e.key(name);local p=producers[k]
 if p and not seen[k] then
  seen[k]=true;for _,i in ipairs(p.inputs) do expand(i.name,n*i.qty/p.output.qty,counts,seen) end;seen[k]=nil
 else local norm=string.lower(name);counts[norm]=(counts[norm] or 0)+n end
end
for _,r in ipairs(e.recipes) do
 local counts={};for _,i in ipairs(r.inputs) do expand(i.name,i.qty,counts,{}) end
 local item
 for name in pairs(counts) do
  if not name:find('(unfinished)',1,true) and name~='vial of water' and name~='juju vial of water' and name~='coconut milk' then item=name;break end
 end
 local obj={name=item or r.inputs[1].name}
 assert(e.inputsOwned(obj,r,counts),'prepared batch '..r.id);cases=cases+1
 for missing in pairs(counts) do
  local altered=clone(counts);altered[missing]=nil
  assert(not e.inputsOwned(obj,r,altered),'missing preparation leaf '..r.id..' '..missing);cases=cases+1
 end
end
-- Screenshot regression: elder overload must not appear with fellstalk alone
-- or with insufficient Supreme overload doses, even as a shared preference.
local fell={id=900,name='Clean fellstalk'};local base=catalog.lookup(fell)
methods.select(fell.id,'wiki:Elder overload potion:0')
local function bank(counts) return {GetSlots=function() local t={};for n,c in pairs(counts) do t[#t+1]={obj={name=n},count=c} end;return t end} end
local incomplete={['Clean fellstalk']=886,['Supreme overload potion (1)']=1,['Primal extract']=100}
local estimate,options=methods.estimate(fell,base,bank(incomplete),886)
for _,r in ipairs(options) do assert(e.estimate(fell,r,require('bank').snapshot(bank(incomplete))).craftable>0,'zero option leak') end
assert(not estimate.method:find('Elder overload',1,true),'screenshot shared recipe leak')
local complete={['Clean fellstalk']=886,['Supreme overload potion (6)']=4,['Primal extract']=4}
estimate,options=methods.estimate(fell,base,bank(complete),886)
assert(estimate.method:find('Master cape',1,true) and estimate.craftable==5,'cape complete batch')
assert(not e.inputsOwned(fell,e.recipes[1],nil),'unknown snapshot')
print('PASS: '..cases..' whole-batch/ingredient audit cases across 251 routes, transitive preparation leaves and screenshot regression')
