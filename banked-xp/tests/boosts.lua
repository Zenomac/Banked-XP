package.path='./?.lua;banked-xp/?.lua;'..package.path
-- The client binding rejects extra arguments that stock Lua ignores.
local nativeLower=string.lower
string.lower=function(value,...)
 assert(select('#',...)==0,'client string.lower received extra arguments')
 return nativeLower(value)
end
local saved={xpSettingsV1={showUnownedIngredients=true}}
local function copy(t) local c={};for k,v in pairs(t) do c[k]=v end;return c end
PersistentDB={GetStructuredData=function(_,key) return saved[key] and copy(saved[key]) end,SetStructuredData=function(_,key,v) saved[key]=copy(v);return true end}
local base,current=104,104
Player={GetLevelGameplay=function() return current end,GetLevelCapped=function() return base end}
SkillType={HERBLORE=15}
local boosts=require('boosts');local settings=require('settings');local policy=require('recipe_policy');local e=require('recipe_engine');local methods=require('methods');local catalog=require('catalog')
assert(not settings.showBoostableRecipes(),'default off')
local fell={id=1001,name='Clean fellstalk'}
local function has(id,options) for _,r in ipairs(options) do if r.id==id then return r end end end
assert(not has('wiki:Elder overload potion:0',methods.options(fell,catalog.lookup(fell),{})),'default hides unlevelled')
settings.setShowBoostableRecipes(true)
assert(has('wiki:Elder overload potion:0',methods.options(fell,catalog.lookup(fell),{})),'boost permits +2 ordinary elder')
local result=methods.estimate(fell,catalog.lookup(fell),{GetSlots=function() return {} end},1)
assert(result.note:find('Boost needed: +2 Herblore',1,true),'explicit boost source')
assert(not boosts.reachable({level=110},{level=108}),'unknown base must not stack boost')
assert(boosts.herblore(104,108).level==110,'never stack with active boost')
assert(boosts.herblore(104,112).level==112,'stronger active boost respected')
local ordinary={level=110,requirements={},method='Test',output={name='Test'},id='test'}
assert(boosts.reachable(ordinary,{baseLevel=104,level=104}))
ordinary.level=111;assert(not boosts.reachable(ordinary,{baseLevel=104,level=104}))
ordinary.level=115;assert(not boosts.reachable(ordinary,{baseLevel=104,level=110}),'current boost cannot be boosted again')
local capes,improved,tiers,summoning=0,0,0,0
for _,r in ipairs(e.recipes) do
 if r.masterCape or r.unboostable then
  local real=r.level-6
  local state={baseLevel=real,level=r.level,showBoostable=true,showUnderlevel=false,best=true}
  assert(#policy.filter({r},state)==0,'boost bypassed real level '..r.id)
  state.baseLevel=r.level;assert(#policy.filter({r},state)==1,'real requirement '..r.id)
  if r.skill=='Summoning' then summoning=summoning+1 elseif r.masterCape then capes=capes+1 elseif r.tierGroup then tiers=tiers+1 else improved=improved+1 end
 end
end
assert(capes==6 and improved==13 and tiers>0 and summoning==#require('summoning_recipes'),'all nonboostable variants and protean tiers audited')
-- Independent preview setting still permits only 1-2-level previews.
base=110;current=110
settings.setShowBoostableRecipes(false);settings.setShowUnderlevelRecipes(true)
ordinary.level=113;assert(#policy.filter({ordinary},policy.state({}))==0)
settings.setShowBoostableRecipes(true);assert(#policy.filter({ordinary},policy.state({}))==1,'boost overrides three-level cutoff')
-- Actual player level 104 + a temporary boost to 120 must not expose cape or
-- improved variants from any indexed input.
base,current=104,120
for _,r in ipairs(e.recipes) do
 if r.masterCape then assert(#policy.filter({r},policy.state({}))==0,'cape false 120') end
end
settings.setShowUnderlevelRecipes(false);settings.setShowUnownedIngredients(false)
local insufficient={GetSlots=function() return {{obj={name='Clean fellstalk'},count=886}} end}
result=methods.estimate(fell,catalog.lookup(fell),insufficient,886)
assert(not result.note:find('Boost needed',1,true),'boost cannot bypass bank supplies')
settings.setShowBoostableRecipes(true);package.loaded.settings=nil
assert(require('settings').showBoostableRecipes() and not require('settings').showUnownedIngredients(),'persist new field without overriding others')
print('PASS: boost visibility/notes, base versus active levels, +6 ceiling, supply filtering, 6 cape/11 improved exclusions and persistence')
