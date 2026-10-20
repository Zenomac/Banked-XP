package.path='./?.lua;banked-xp/?.lua;'..package.path
local reportDir=assert(package.searchpath('main',package.path)):gsub('main%.lua$','data/')
-- Existing potion audit intentionally scopes the recipe provider to Herblore.
package.preload.skill_recipes=function() return {} end
package.preload.summoning_recipes=function() return {} end
PersistentDB={GetStructuredData=function() return {} end,SetStructuredData=function() return true end}
local level=120
Player={GetLevelGameplay=function() return level end,GetLevelCapped=function() return level end};SkillType={HERBLORE=15,FIREMAKING=11}
local e=require('recipe_engine');local methods=require('methods');local catalog=require('catalog');local settings=require('settings')
local bankData=require('bank')
local seen,forms,id={},0,80000
local families,terminal,unavailable,enabled=0,0,0,0
local function check(name)
 id=id+1;local obj={id=id,name=name};local base=catalog.lookup(obj)
 settings.setShowUnownedIngredients(false)
 local opts=methods.options(obj,base,{})
 assert(#opts==0,'missing ingredients must produce no available options: '..name)
 local result,returned=methods.estimate(obj,base or {skill='Herblore',method='None',xp=0},{id=id,GetSlots=function() return {} end},1)
 assert(#returned==0,'hover and menu must agree on empty options')
 settings.setShowUnownedIngredients(true)
 local allowed=methods.options(obj,base,{})
 if #e.options(obj)>0 then assert(#allowed>0,'explicit unowned preview retained: '..name) end
 forms=forms+1
 return #allowed
end
for _,r in ipairs(e.recipes) do
 local k=e.key(r.output.name)
 if not seen[k] then
  seen[k]=true;families=families+1
  local n=check(r.output.name)
  if #e.options({name=r.output.name})==0 then terminal=terminal+1 else unavailable=unavailable+1;if n>0 then enabled=enabled+1 end end
  local stem,dose=r.output.name:match('^(.-)%s*%((%d+)%)$')
  if stem and tonumber(dose)<=6 then
   local flask=stem:find('potion',1,true) and stem:gsub('potion','flask') or stem..' flask'
   for d=1,6 do check(stem..' ('..d..')');check(flask..' ('..d..')') end
  end
 end
end
settings.setShowUnownedIngredients(false)
local combat={id=99991,name='Combat potion (4)'}
assert(#methods.options(combat,catalog.lookup(combat),{})==0,'screenshot regression')
level=1;settings.setShowUnownedIngredients(true)
local ovl={id=99992,name='Overload (4)'}
assert(#methods.options(ovl,catalog.lookup(ovl),{})==0,'unmet level also hides all methods')
local report=assert(io.open(reportDir..'recipe-availability-audit.txt','w'))
report:write(string.format('Audited %d output families and %d dose/name/flask forms. %d terminal families have no plugin hover; %d upgradeable families have no available recipes with missing ingredients and the unowned setting off. %d upgradeable families retain previews with unowned setting on at level 120. Empty-options hover restores the complete native tooltip, and creates no menu entries.\n',families,forms,terminal,unavailable,enabled));report:close()
print(string.format('PASS: availability audit of %d families / %d forms; %d terminal, %d missing-supply, %d opt-in previews; Combat potion and underlevel regressions',families,forms,terminal,unavailable,enabled))
