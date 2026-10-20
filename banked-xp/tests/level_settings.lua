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
local stored={xpSettingsV1={showUnownedIngredients=true}}
local function copy(t) local c={};for k,v in pairs(t) do c[k]=v end;return c end
PersistentDB={GetStructuredData=function(_,key) return stored[key] and copy(stored[key]) end,SetStructuredData=function(_,key,v) stored[key]=copy(v);return true end}
local level=104
Player={GetLevelGameplay=function() return level end,GetLevelCapped=function() return level end}
SkillType={HERBLORE=15}
local settings=require('settings');local policy=require('recipe_policy');local engine=require('recipe_engine');local methods=require('methods');local catalog=require('catalog')
assert(settings.showUnownedIngredients() and not settings.showUnderlevelRecipes(),'migrate ingredient setting, new default off')
local super={id=950,name='Super adrenaline potion (2)'}
local r=methods.estimate(super,catalog.lookup(super),{GetSlots=function() return {} end},1)
assert(r.note:find('More recipes unlocked in 11 levels',1,true),'screenshot exact gap: '..r.note)
local arch={id=951,name='Ancient gravel'};local base=catalog.lookup(arch)
level=77
assert(#methods.options(arch,base,{})==0,'off hides one level away')
r=methods.estimate(arch,base,{GetSlots=function() return {} end},1)
assert(r.note:find('More recipes unlocked in 1 level',1,true),'singular')
assert(r.levelPreview and r.method:find('<col=ff9900>[Lv 78]</col>',1,true))
level=73
r=methods.estimate(arch,base,{GetSlots=function() return {} end},1)
assert(r.levelPreview and r.method:find('<col=ff0000>[Lv 78]</col>',1,true))
level=74
r=methods.estimate(arch,base,{GetSlots=function() return {} end},1)
assert(r.method:find('<col=ff9900>[Lv 78]</col>',1,true),'four levels orange')
level=77
assert(settings.setShowUnderlevelRecipes(true))
assert(#methods.options(arch,base,{})==1,'on enables one level preview')
level=76;assert(#methods.options(arch,base,{})==1,'on enables two level preview')
level=75;assert(#methods.options(arch,base,{})==0,'on preserves 3-level limit')
level=78;assert(#methods.options(arch,base,{})==1,'at level')
assert(policy.nextUnlock(engine.options(arch),policy.state({}))==nil,'no countdown after final unlock')
settings.setShowUnderlevelRecipes(false)
local checked=0
for _,recipe in ipairs(engine.recipes) do
 assert(#policy.filter({recipe},{level=recipe.level-1,showUnderlevel=false})==0,recipe.id..' off hides')
 assert(#policy.filter({recipe},{level=recipe.level,showUnderlevel=false})==1,recipe.id..' met shown')
 assert(#policy.filter({recipe},{level=recipe.level-2,showUnderlevel=true})==1,recipe.id..' preview')
 assert(#policy.filter({recipe},{level=recipe.level-3,showUnderlevel=true})==0,recipe.id..' three hidden')
 checked=checked+1
end
settings.setShowUnderlevelRecipes(true);settings.setShowUnownedIngredients(false)
package.loaded.settings=nil
local loaded=require('settings');assert(loaded.showUnderlevelRecipes() and not loaded.showUnownedIngredients(),'both saved independently')
print('PASS: exact next unlock and singular/plural, independent settings/migration/persistence and all '..checked..' recipe boundaries')
