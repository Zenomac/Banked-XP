package.path='./?.lua;banked-xp/?.lua;'..package.path
local reportDir=assert(package.searchpath('main',package.path)):gsub('main%.lua$','data/')
-- Existing potion audit intentionally scopes the recipe provider to Herblore.
package.preload.skill_recipes=function() return {} end
PersistentDB={GetStructuredData=function() return {} end,SetStructuredData=function() return true end}
Player={GetLevelGameplay=function() return 120 end,GetLevelCapped=function() return 120 end};SkillType={HERBLORE=15,FIREMAKING=11}
local engine=require('recipe_engine');local catalog=require('catalog');local methods=require('methods')
local seen,rows={},{}
local terminal,upgradeable,cases,id=0,0,0,70000
local function escape(s) return '"'..tostring(s):gsub('"','""')..'"' end
local function audit(name)
 id=id+1;local obj={id=id,name=name}
 local routes=engine.options(obj)
 local result=catalog.lookup(obj)
 if #routes==0 then
  assert(result==nil,'terminal potion still gets XP tooltip: '..name)
  assert(#methods.options(obj,result,{})==0,'terminal potion still has menu choices: '..name)
 else
  assert(result and result.skill=='Herblore','upgradeable potion was hidden: '..name)
 end
 cases=cases+1
 return routes
end
for _,r in ipairs(engine.recipes) do
 local key=engine.key(r.output.name)
 if not seen[key] then
  seen[key]=true
  local routes=audit(r.output.name)
  local state=#routes==0 and 'No further catalog route; native tooltip only' or 'Upgradeable; XP tooltip retained'
  if #routes==0 then terminal=terminal+1 else upgradeable=upgradeable+1 end
  local next={};for _,option in ipairs(routes) do next[#next+1]=option.id end
  rows[#rows+1]=table.concat({escape(r.output.name),escape(key),escape(state),escape(table.concat(next,'; '))},',')
  local stem,dose=r.output.name:match('^(.-)%s*%((%d+)%)$')
  if stem and tonumber(dose)<=6 then
   local flaskStem=stem:find('potion',1,true) and stem:gsub('potion','flask') or stem..' flask'
   for n=1,6 do
    assert((#audit(stem..' ('..n..')')>0)==(#routes>0),'dose classification differs')
    assert((#audit(flaskStem..' ('..n..')')>0)==(#routes>0),'flask classification differs')
   end
  end
 end
end
for _,name in ipairs({'Super Saradomin brew (4)','Super Saradomin brew flask (6)'}) do assert(catalog.lookup({id=99998,name=name})==nil) end
for _,name in ipairs({'Saradomin brew (4)','Super attack (4)','Overload (4)','Attack potion (3)'}) do
 assert(catalog.lookup({id=99999,name=name}),'existing upgrade input hidden: '..name)
end
-- Do not confuse a player's filtered options with a terminal recipe graph.
Player.GetLevelGameplay=function() return 1 end;Player.GetLevelCapped=function() return 1 end
assert(catalog.lookup({id=99997,name='Overload (4)'}),'underlevel ingredients retain their catalog routes')
assert(catalog.lookup({id=1517,name='Maple logs'}),'Firemaking remains supported')
assert(catalog.lookup({id=99996,name='Grimy ranarr'}),'herb cleaning remains supported')
table.sort(rows)
local out=assert(io.open(reportDir..'terminal-potion-audit.csv','w'))
out:write('Potion,Canonical key,Behavior,Downstream recipe IDs\n',table.concat(rows,'\n'),'\n');out:close()
local report=assert(io.open(reportDir..'terminal-potion-audit.txt','w'))
report:write(string.format('Catalog graph audit: %d recipe routes; %d distinct output families; %d terminal families hidden; %d upgradeable families retained; %d name/dose/flask cases checked.\n',#engine.recipes,terminal+upgradeable,terminal,upgradeable,cases))
report:write('Scope: bundled normal-bank Potions catalog. No claim of all RuneScape crafting transformations outside that catalog.\n');report:close()
print(string.format('PASS: %d routes, %d families (%d terminal / %d upgradeable), %d form checks; screenshot regression and upgrade retention',#engine.recipes,terminal+upgradeable,terminal,upgradeable,cases))
