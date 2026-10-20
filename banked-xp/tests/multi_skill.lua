package.path='./?.lua;banked-xp/?.lua;'..package.path
PersistentDB={GetStructuredData=function() return {} end,SetStructuredData=function() return true end}
local support=require('skill_support');SkillType={}
local levels={}
for i,skill in ipairs(support.names) do SkillType[skill:upper()]=i;levels[i]=120 end
Player={GetLevelGameplay=function(id) return levels[id] end,GetLevelCapped=function(id) return levels[id] end}
local engine=require('recipe_engine');local policy=require('recipe_policy');local methods=require('methods');local catalog=require('catalog');local settings=require('settings')
local function find(skill,name)
 for _,r in ipairs(engine.recipes) do if r.skill==skill and r.output.name==name then return r end end
 error('Missing '..skill..' '..name)
end
local countsBySkill={};local checked=0
for _,r in ipairs(engine.recipes) do
 if r.id:match('^skill:') then
  assert(support.supported[r.skill] and r.xp>0 and r.level>=1,'validated skill/XP/level')
  assert(r.output.qty>0 and #r.inputs>0 and r.recipeText~='','complete recipe')
  local counts={}
  for _,v in ipairs(r.inputs) do counts[v.name:lower()]=(counts[v.name:lower()] or 0)+v.qty end
  local result=engine.estimate({name=r.inputs[1].name},r,counts)
  assert(result.skill==r.skill,'actual result skill retained')
  assert(result.craftable>=r.output.qty,'full direct supply batch available: '..r.id)
  assert(result.total>=r.xp,'batch XP included: '..r.id)
  assert(engine.estimate({name=r.inputs[1].name},r,{}).total==0,'empty bank no XP')
  -- Each recipe uses its own skill; a high Herblore level cannot unlock it.
  levels[SkillType[r.skill:upper()]]=math.max(1,r.level-3)
  local state=policy.state({},r.skill)
  state.showBoostable=false;state.showUnderlevel=true
  if r.level>3 then assert(#policy.filter({r},state)==0,'three-level preview boundary: '..r.id) end
  levels[SkillType[r.skill:upper()]]=120
  countsBySkill[r.skill]=(countsBySkill[r.skill] or 0)+1;checked=checked+1
 end
end
local gem=find('Crafting','Sapphire')
assert(engine.estimate({name='Uncut sapphire'},gem,{['uncut sapphire']=10}).total==500,'sapphire XP')
local restore=find('Archaeology','Ork cleaver sword')
assert(restore.xp==7388.9,'Ork cleaver restoration 7388.9 XP')
local materialStock={}
for _,v in ipairs(restore.inputs) do materialStock[v.name:lower()]=v.qty*2 end
assert(engine.estimate({name='Ork cleaver sword (damaged)'},restore,materialStock).total==14777.8,'damaged artefacts and materials both required')
local changed={};for k,v in pairs(materialStock) do changed[k]=v end;materialStock=changed
materialStock['ork cleaver sword (damaged)']=0
assert(engine.estimate({name='Ork cleaver sword (repaired)'},restore,materialStock).total==0,'repaired artefact cannot be restored again')
local logMethods=engine.options({name='Maple logs'})
local seen={};for _,r in ipairs(logMethods) do seen[r.skill]=true end
assert(seen.Firemaking and seen.Fletching and seen.Construction,'logs indexed across 3 skills')
local routes={}
for _,r in ipairs(logMethods) do if #r.inputs==1 and r.inputs[1].name=='Maple logs' and (r.skill=='Firemaking' or r.skill=='Fletching') then routes[#routes+1]=r end end
local total,used,left=engine.portfolio(routes,{['maple logs']=10})
assert(used==1 and left[engine.key('Maple logs')]==0,'shared logs consumed once across skills')
local state=engine.newPortfolio({['maple logs']=10})
for _,r in ipairs(routes) do engine.allocatePortfolio(state,r) end
local sum=0;for _,n in pairs(state.bySkill) do sum=sum+n end
assert(sum==state.total,'per-skill portfolio totals reconcile')
assert(catalog.lookup({id=910001,name='Dragon bones'}).skill=='Prayer','bundled Prayer fallback without client XP params')
print('PASS: '..checked..' added routes, all skill levels, exact supplies, zero-stock cases, restoration prerequisites and cross-skill shared stock')
local summary=require('skill_summary')
settings.setShowUnownedIngredients(false)
local stock,records={},{}
local chosenRoutes={
 find('Smithing','Bronze bar'),gem,
 find('Fletching','Willow shortbow (unstrung)'),
 restore,find('Firemaking','Elder logs'),find('Cooking','Shark'),
 find('Construction','Oak chair')}
for _,r in ipairs(engine.recipes) do
 if r.skill=='Farming' and r.inputs[1].name=='Guam seed' then chosenRoutes[#chosenRoutes+1]=r end
 if r.primalYield==1 then chosenRoutes[#chosenRoutes+1]=r end
end
for _,r in ipairs(chosenRoutes) do
 for _,v in ipairs(r.inputs) do stock[v.name]=(stock[v.name] or 0)+v.qty*10 end
end
stock['Dragon bones']=10
local sid=920000
for name,n in pairs(stock) do sid=sid+1;records[#records+1]={obj={id=sid,name=name},count=n} end
for _,r in ipairs(chosenRoutes) do
 local name=r.inputs[1].name
 for _,slot in ipairs(records) do if slot.obj.name==name then methods.select(slot.obj.id,r.id) end end
end
methods.select(99999,'basic')
local bank={id=920000,GetSlots=function() return records end}
require('bank').invalidate();summary.capture(bank)
for _=1,20000 do summary.advance(1) end
for _,skill in ipairs(support.names) do
 local line=summary.line(skill)
 assert(not line:find('calculating',1,true) and not line:find('not yet supported',1,true),'summary completed for '..skill)
 assert(not line:find('Banked XP: 0 ',1,true),'positive selected bank XP for '..skill..': '..line)
end
local log={id=990001,name='Maple logs'}
local base=catalog.lookup(log)
local owned={['maple logs']=1000,['bowstring']=1000,['headless arrow']=1000,['feather']=1000}
methods.options(log,base,owned) -- warm per-bank recipe cache
local started=os.clock()
for _=1,100 do methods.options(log,base,owned) end
print(string.format('PASS: ten-skill bank summary integration; 100 cached mixed-skill hover option calculations in %.3fs',os.clock()-started))
local outfitData=require('outfit_data');local outfits=require('outfits')
local gear={}
for _,name in ipairs(outfitData.Crafting.pieces) do gear[#gear+1]={obj={name=name},count=1} end
config={Inv={WORN=200,INV=201}}
Inventory={Find=function(id) return {GetSlots=function() return id==200 and gear or {} end} end}
outfits.invalidate();outfits.refresh()
settings.setIncludeOutfitBonuses(true)
require('bank').invalidate();summary.capture({id=923999,GetSlots=function() return {{obj={id=923998,name='Uncut sapphire'},count=10}} end})
for _=1,1000 do summary.advance(1) end
assert(summary.line('Crafting'):find('530 (base + 6% outfit;',1,true),'summary includes current outfit once')
gear={};outfits.invalidate();outfits.refresh()
assert(summary.line('Crafting'):find('500 (base;',1,true),'removing outfit restores base summary without recalculating recipes')
print('PASS: outfit-adjusted skill summary and removal without duplicate application')
