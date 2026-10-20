package.path='./?.lua;banked-xp/?.lua;'..package.path
-- The client binding rejects extra arguments that stock Lua ignores.
local nativeLower=string.lower
string.lower=function(value,...)
 assert(select('#',...)==0,'client string.lower received extra arguments')
 return nativeLower(value)
end
-- Exercise existing behavior with unowned recipes explicitly enabled.
package.loaded.settings={showRecipeOnHover=function() return true end,showUnownedIngredients=function() return true end,showUnderlevelRecipes=function() return true end,showBoostableRecipes=function() return false end}
local level=75
Player={GetLevelGameplay=function(skill) assert(skill==15);return level end,GetLevelCapped=function() return level end}
SkillType={HERBLORE=15}
PersistentDB={GetStructuredData=function() return {} end,SetStructuredData=function() return true end}
local methods=require('methods');local catalog=require('catalog')
local obj={id=401,name='Clean avantoe'};local base=catalog.lookup(obj)
local function archaeology()
 local n=0;for _,r in ipairs(methods.options(obj,base)) do if r.method=='Archaeology potion' then n=n+1 end end;return n
end
assert(archaeology()==0,'3 below hidden')
level=76;assert(archaeology()==7,'2 below shown')
level=77;assert(archaeology()==7,'1 below shown')
level=78;assert(archaeology()==7,'at level shown')
local torstol={id=402,name='Clean torstol'};local tb=catalog.lookup(torstol)
local function capeCount()
 local n=0;for _,r in ipairs(methods.options(torstol,tb)) do if r.level==120 then n=n+1 end end;return n
end
level=117;assert(capeCount()==0,'cape 3 below hidden')
level=118;assert(capeCount()>0,'cape 2 below preview')
level=120;assert(capeCount()>0,'cape at level')
methods.select(obj.id,'wiki:Archaeology potion:0')
level=75
local bank={GetSlots=function() return {} end}
local selected=methods.estimate(obj,base,bank,10)
assert(not selected.method:find('Archaeology potion',1,true),'hidden saved choice not used')
level=1
local spikes={id=403,name='Grenwall spikes'}
local result,options=methods.estimate(spikes,catalog.lookup(spikes),bank,50)
assert(#options==0 and result.total==0 and result.method=='No available recipes','no fallback XP leak')
Player.GetLevelGameplay=function() error('unavailable') end
result,options=methods.estimate(spikes,catalog.lookup(spikes),bank,50)
assert(#options==0 and result.total==0 and result.note=='Herblore level unavailable')
local grimy={id=404,name='Grimy guam'}
assert(methods.options(grimy,catalog.lookup(grimy))[1].cleaning,'cleaning preserved')
local prayer=methods.options({id=405,name='Bones'},{skill='Prayer',method='Bury bones',xp=4.5})
assert(#prayer==6,'prayer preserved')
assert(#methods.options({id=1517,name='Maple logs'},{skill='Firemaking',method='Burn logs',xp=135})==6,'firemaking preserved')
print('PASS: live 3-level boundary, cape previews, hidden saved selection, zero eligible, API recovery fallback and other skills')
