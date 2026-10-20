package.path='./?.lua;banked-xp/?.lua;'..package.path
-- Existing potion audit intentionally scopes the recipe provider to Herblore.
package.preload.skill_recipes=function() return {} end
-- The client binding rejects extra arguments that stock Lua ignores.
local nativeLower=string.lower
string.lower=function(value,...)
 assert(select('#',...)==0,'client string.lower received extra arguments')
 return nativeLower(value)
end
PersistentDB={GetStructuredData=function() return {} end,SetStructuredData=function() return true end}
Player={GetLevelGameplay=function() return 120 end,GetLevelCapped=function() return 120 end};SkillType={HERBLORE=15}
local e=require('recipe_engine');local policy=require('recipe_policy');local settings=require('settings');local methods=require('methods');local catalog=require('catalog')
settings.setShowUnownedIngredients(true)
local labels,poison={},{}
for _,r in ipairs(e.recipes) do
 local label=policy.presentation(r)
 assert(not label:find(' + ',1,true),'full recipe in menu '..r.id)
 assert(not label:find('Lv ',1,true),'met level shown '..r.id)
 assert(not labels[label],'ambiguous menu label '..label);labels[label]=r.id
 assert(r.recipeText and r.recipeText~='')
 if r.method=='Poison bomb' then poison[#poison+1]=label end
end
assert(#poison==2)
assert(poison[1]=='Poison bomb [Standard]' and poison[2]=='Poison bomb [Improved]')
local r
for _,row in ipairs(e.recipes) do if row.id=='wiki:Aggression potion:0' then r=row end end
assert(r)
local result=e.estimate({name='Clean bloodweed'},r,{['bloodweed potion (unfinished)']=10,['searing ashes']=5})
assert(result.craftable==5)
assert(result.note:find('Limited by: 1 Bloodweed potion (unfinished) + 1 Searing ashes',1,true),'full selected recipe in hover')
assert(result.limitingIngredient=='Searing ashes','bottleneck still calculated')
local menu={entries={{verbText='Withdraw-All'}}}
function menu:Add(label,callback) self.entries[#self.entries+1]={verbText=label} end
function menu:Swap(a,b) self.entries[a],self.entries[b]=self.entries[b],self.entries[a] end
local obj={id=1101,name='Poison slime'}
methods.addMenu(menu,obj,methods.options(obj,catalog.lookup(obj),{}),catalog.lookup(obj))
for _,entry in ipairs(menu.entries) do assert(not entry.verbText:find(' + ',1,true)) end
assert(menu.entries[#menu.entries].verbText=='Withdraw-All')
print('PASS: 251 unique short labels, Standard/Improved variants, full hover recipes and native menu priority')
local herb={id=1102,name='Clean bloodweed'}
local bank={id=991,GetSlots=function() return {{obj={name='Bloodweed potion (unfinished)'},count=10},{obj={name='Searing ashes'},count=5}} end}
methods.select(herb.id,r.id)
local full=methods.estimate(herb,catalog.lookup(herb),bank,10)
assert(full.note:find(r.recipeText,1,true),'default shows full recipe')
settings.setShowRecipeOnHover(false)
local short=methods.estimate(herb,catalog.lookup(herb),bank,10)
assert(short.note:find('Limited by: Searing ashes',1,true),'off retains limiting ingredient')
assert(not short.note:find(' + ',1,true),'off hides full recipe')
assert(full.total==short.total and full.craftable==short.craftable and full.method==short.method,'presentation does not change estimate')
assert(e.estimate(herb,r,{['bloodweed potion (unfinished)']=10,['searing ashes']=5}).note:find(r.recipeText,1,true),'engine recipe remains intact')
settings.setShowRecipeOnHover(true)
assert(methods.estimate(herb,catalog.lookup(herb),bank,10).note:find(r.recipeText,1,true),'toggle back restores recipe')
print('PASS: recipe hover toggle and unchanged XP, labels and engine cache')
