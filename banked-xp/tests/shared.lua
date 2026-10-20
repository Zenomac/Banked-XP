package.path='./?.lua;banked-xp/?.lua;'..package.path
-- The client binding rejects extra arguments that stock Lua ignores.
local nativeLower=string.lower
string.lower=function(value,...)
 assert(select('#',...)==0,'client string.lower received extra arguments')
 return nativeLower(value)
end
-- Exercise existing behavior with unowned recipes explicitly enabled.
package.loaded.settings={showRecipeOnHover=function() return true end,showUnownedIngredients=function() return true end,showUnderlevelRecipes=function() return true end,showBoostableRecipes=function() return false end}
local function clone(t) local c={};for k,v in pairs(t) do c[k]=v end;return c end
local stored={xpMethodsV1={['502']='chaos'}}
PersistentDB={GetStructuredData=function(_,key) return stored[key] and clone(stored[key]) end,
 SetStructuredData=function(_,key,value) stored[key]=clone(value);return true end}
Player={GetLevelGameplay=function() return 120 end};SkillType={HERBLORE=15}
local methods=require('methods');local catalog=require('catalog')
local bank={GetSlots=function() return {} end}
local a={id=501,name='Bones'};local b={id=502,name='Dragon bones'}
local baseA={skill='Prayer',method='Bury bones',xp=4.5}
local baseB={skill='Prayer',method='Bury bones',xp=72}
assert(methods.estimate(b,baseB,bank,2).method=='Chaos altar','legacy preserved initially')
methods.select(a.id,'ecto')
local result=methods.estimate(b,baseB,bank,2)
assert(result.method=='Ectofuntus' and result.total==576,'shared overrides other item legacy')
methods.select(b.id,'chaos')
result=methods.estimate(a,baseA,bank,2)
assert(result.method=='Chaos altar' and result.total==31.5,'latest prayer replaces all')
local spikes={id=503,name='Grenwall spikes'}
methods.select(spikes.id,'wiki:Extreme ranging:0')
local potion={id=504,name='Super ranging potion (4)'}
result=methods.estimate(potion,catalog.lookup(potion),bank,1)
assert(result.method:find('Extreme ranging',1,true),'shared recipe across ingredients')
assert(methods.estimate(a,baseA,bank,1).method=='Chaos altar','unrelated choice preserves prayer')
-- An unavailable option is skipped in favour of the last compatible selection.
methods.select(505,'clean')
assert(methods.estimate(potion,catalog.lookup(potion),bank,1).method:find('Extreme ranging',1,true))
methods.select(506,'ecto')
package.loaded.methods=nil;methods=require('methods')
assert(methods.estimate(b,baseB,bank,1).method=='Ectofuntus','shared saved across reload')
assert(methods.estimate(potion,catalog.lookup(potion),bank,1).method:find('Extreme ranging',1,true),'history survives reload')
local menu={entries={{verbText='Withdraw-All'}}}
function menu:Add(label,fn) self.entries[#self.entries+1]={verbText=label,callback=fn} end
function menu:Swap(a,b) self.entries[a],self.entries[b]=self.entries[b],self.entries[a] end
methods.addMenu(menu,b,methods.options(b,baseB),baseB)
local markers=0
for _,entry in ipairs(menu.entries) do
 if entry.verbText:find('[<col=00ff00>selected</col>]',1,true) then
  markers=markers+1;assert(entry.verbText:find('Ectofuntus',1,true),'effective shared marker')
 end
end
assert(markers==1 and menu.entries[#menu.entries].verbText=='Withdraw-All')
for _,entry in ipairs(menu.entries) do if entry.verbText=='<col=00ffff>BXP</col>: Gilded altar: 2 burners' then entry.callback() end end
assert(methods.estimate(a,baseA,bank,1).method=='Gilded altar: 2 burners','menu callback shares selection')
-- Level filtering still limits globally saved choices.
Player.GetLevelGameplay=function() return 1 end
local r,options=methods.estimate(potion,catalog.lookup(potion),bank,1)
assert(#options==0 and r.total==0,'shared choice cannot bypass level filter')
print('PASS: shared defaults, replacement, compatible fallback, unrelated skills, persisted reload, menu markers/callbacks and level filter')
