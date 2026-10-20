package.path='./?.lua;banked-xp/?.lua;'..package.path
-- The client binding rejects extra arguments that stock Lua ignores.
local nativeLower=string.lower
string.lower=function(value,...)
 assert(select('#',...)==0,'client string.lower received extra arguments')
 return nativeLower(value)
end
-- Exercise existing behavior with unowned recipes explicitly enabled.
package.loaded.settings={showRecipeOnHover=function() return true end,showUnownedIngredients=function() return true end,showUnderlevelRecipes=function() return true end,showBoostableRecipes=function() return false end}
PersistentDB={GetStructuredData=function() return {} end,SetStructuredData=function() return true end}
local level=104
Player={GetLevelGameplay=function() return level end,GetLevelCapped=function() return level end}
SkillType={HERBLORE=15}
local engine=require('recipe_engine');local policy=require('recipe_policy');local methods=require('methods');local catalog=require('catalog')
local n=0
for _,r in ipairs(engine.recipes) do
 local cape=false;for _,q in ipairs(r.requirements) do if q:lower():find('herblore master cape',1,true) then cape=true end end
 if cape then
  n=n+1;assert(r.masterCape and r.level==120,'effective requirement '..r.id)
  assert(r.label:find('[Lv 120',1,true),'label '..r.id)
  for _,lv in ipairs({98,104,106,117}) do
   assert(#policy.filter({r},{level=lv,best=true,showUnderlevel=true})==0,'cape hidden at '..lv..' '..r.id)
  end
  assert(#policy.filter({r},{level=118,best=true,showUnderlevel=true})==1,'two-level preview '..r.id)
  assert(#policy.filter({r},{level=120,best=true,showUnderlevel=true})==1,'at 120 '..r.id)
  for _,input in ipairs(r.inputs) do
   local obj={id=701,name=input.name}
   for _,o in ipairs(methods.options(obj,catalog.lookup(obj),{['herblore master cape']=1})) do assert(not o.masterCape,'ownership cannot bypass 104 '..input.name) end
  end
 end
end
assert(n==6,'all six cape variants audited')
-- A stale shared cape choice cannot leak through the tooltip on a level-104 player.
methods.select(702,'wiki:Supreme overload potion:1')
local obj={id=702,name='Overload (4)'}
local r,options=methods.estimate(obj,catalog.lookup(obj),{GetSlots=function() return {} end},4)
assert(not r.method:find('Master cape',1,true),'saved cape hidden from hover')
for _,o in ipairs(options) do assert(not o.masterCape) end
print('PASS: all six cape prerequisites/labels, 104 and 117 hidden, 118 preview, 120 available, ownership and stale saved choice')
