package.path='./?.lua;banked-xp/?.lua;'..package.path
-- Existing potion audit intentionally scopes the recipe provider to Herblore.
package.preload.skill_recipes=function() return {} end
-- The client binding rejects extra arguments that stock Lua ignores.
local nativeLower=string.lower
string.lower=function(value,...)
 assert(select('#',...)==0,'client string.lower received extra arguments')
 return nativeLower(value)
end
-- Exercise existing behavior with unowned recipes explicitly enabled.
package.loaded.settings={showRecipeOnHover=function() return true end,showUnownedIngredients=function() return true end,showUnderlevelRecipes=function() return true end,showBoostableRecipes=function() return false end}
local engine=require('recipe_engine');local policy=require('recipe_policy')
local function has(list,id) for _,r in ipairs(list) do if r.id==id then return r end end end
local count=0
for _,r in ipairs(engine.recipes) do
 for _,best in ipairs({false,true}) do
  assert(#policy.filter({r},{level=r.level-3,best=best,showUnderlevel=true})==0,r.id..' boundary3')
  assert(#policy.filter({r},{level=r.level-2,best=best,showUnderlevel=true})==1,r.id..' boundary2')
 end
 count=count+1
end
assert(count==262)
-- Every possible direct and transitive item source uses the policy in methods.
local level=75
Player={GetLevelGameplay=function() return level end,GetLevelCapped=function() return level end}
SkillType={HERBLORE=15}
local methods=require('methods');local catalog=require('catalog')
local sources={}
for _,r in ipairs(engine.recipes) do
 for _,i in ipairs(r.inputs) do sources[i.name]=true end
 for k in pairs(r.keys) do if k:sub(1,5)=='item:' then sources[k:sub(6)]=true end end
end
local checked=0
for _,lv in ipairs({1,50,75,99,110,117,118,119,120}) do
 level=lv
 for name in pairs(sources) do
  local obj={id=600,name=name};local base=catalog.lookup(obj)
  for _,r in ipairs(methods.options(obj,base)) do
   if r.engine then assert(r.level-lv<3,'source bypass '..name..' '..r.id) end
  end
  checked=checked+1
 end
end
local raw=engine.options({name='Clean torstol'})
local at117=policy.filter(raw,{level=117,best=true,showUnderlevel=true})
assert(not has(at117,'wiki:Overload:1'),'cape never bypasses level boundary')
local at120=policy.filter(raw,{level=120,best=true,showUnderlevel=true})
assert(has(at120,'wiki:Overload:1') and not has(at120,'wiki:Overload:0'),'cape best over raw normal')
raw=engine.options({name='Overload (3) (unfinished)'})
at120=policy.filter(raw,{level=120,best=true,showUnderlevel=true})
assert(has(at120,'wiki:Overload:3') and not has(at120,'wiki:Overload:2'),'cape best over unfinished normal')
for _,name in ipairs({'Supreme overload potion','Elder overload potion'}) do
 local list={};for _,r in ipairs(engine.recipes) do if r.method==name then list[#list+1]=r end end
 local filtered=policy.filter(list,{level=120,best=true,showUnderlevel=true})
 assert(#filtered==2 and has(filtered,'wiki:'..name..':1') and has(filtered,'wiki:'..name..':3'),'cape collapse '..name)
end
for _,name in ipairs({'Poison bomb','Sticky bomb','Vulnerability bomb','Powerburst of opportunity','Powerburst of vitality','Powerburst of masterstroke','Powerburst of sorcery','Powerburst of acceleration','Powerburst of feats'}) do
 local list={};for _,r in ipairs(engine.recipes) do if r.method==name then list[#list+1]=r end end
 local filtered=policy.filter(list,{level=120,best=true,showUnderlevel=true})
 assert(#filtered==1 and has(filtered,'wiki:'..name..':2'),'improved variant '..name)
end
raw={};for _,r in ipairs(engine.recipes) do if r.method=='Archaeology potion' then raw[#raw+1]=r end end
assert(#policy.filter(raw,{level=120,best=true,showUnderlevel=true})==7,'soil alternatives preserved')
-- Ownership checks: bank, backpack and optional worn containers; no placeholders.
level=118
assert(policy.state({['herblore master cape']=1}).best)
assert(not policy.state({['herblore master cape']=0}).best)
assert(not policy.state({['herblore cape']=1}).best)
config={Inv={INV='backpack',WORN='equipment'}}
local where='backpack'
Inventory={Find=function(cfg) return {isValid=true,GetSlots=function() return cfg==where and {{obj={name='Inverted herblore master cape'},count=1}} or {} end} end}
assert(policy.state({}).best,'backpack cape')
where='equipment';assert(policy.state({}).best,'worn cape')
where='none';assert(not policy.state({}).best)
Player.GetLevelCapped=function() return 120 end
assert(policy.state({}).best,'base 120 while drained')
Player.GetLevelGameplay=function() error('unavailable') end
assert(#policy.filter(raw,policy.state({}))==0,'unavailable current level never bypassed')
-- Old shared selections upgrade to the best matching variant, not an unrelated
-- older compatible recipe from selection history.
Player.GetLevelGameplay=function() return 120 end
methods.select(601,'wiki:Zamorak brew:0')
methods.select(601,'wiki:Overload:0')
local obj={id=601,name='Clean torstol'}
local result=methods.estimate(obj,catalog.lookup(obj),{GetSlots=function() return {} end},1)
assert(result.method:find('Master cape',1,true),'saved normal auto upgrades')
print('PASS: all 251 boundaries, '..checked..' source/level combinations, cape/improved best variants, ownership, alternatives and shared migration')
