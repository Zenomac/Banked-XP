package.path='./?.lua;banked-xp/?.lua;'..package.path
PersistentDB={GetStructuredData=function() return {} end,SetStructuredData=function() return true end}
local support=require('skill_support');SkillType={};local levels={}
for i,s in ipairs(support.names) do SkillType[s:upper()]=i;levels[i]=120 end
Player={GetLevelGameplay=function(id) return levels[id] end,GetLevelCapped=function(id) return levels[id] end}
local e=require('recipe_engine');local p=require('recipe_policy');local m=require('methods')
local checked=0
for _,r in ipairs(e.recipes) do
 if r.id:find(':audit121:',1,true) then
  checked=checked+1
  for _,input in ipairs(r.inputs) do
   local found=false
   for _,candidate in ipairs(e.options({name=input.name})) do if candidate.id==r.id then found=true end end
   assert(found,'Unreachable ingredient: '..input.name..' -> '..r.id)
  end
 end
 assert(not (r.skill=='Cooking' and r.output.name:lower():find('urn',1,true)),'Urn-filling reward must not be a cooking recipe')
end
assert(checked>500,'expected expanded catalog')
local function find(skill,name)
 for _,r in ipairs(e.recipes) do if r.skill==skill and r.output.name==name then return r end end
 error('Missing '..name)
end
local primal=find('Smithing','Primal bar');local counts={}
for _,i in ipairs(primal.inputs) do counts[i.name:lower()]=i.qty*2 end
local value=e.estimate({name=primal.inputs[1].name},primal,counts)
assert(value.craftable==10 and value.total==62,'Primal smelting: 5 bars per batch, 31 XP per batch')
assert(find('Smithing','Platinum bar').xp==33,'Platinum smelting XP')
local fm=find('Firemaking','Impious incense sticks');local prayer=find('Prayer','Impious incense sticks')
counts={['wooden incense sticks']=1,['impious ashes']=2}
local portfolio=e.newPortfolio(counts);portfolio.includeSecondary=true
e.allocatePortfolio(portfolio,fm);e.allocatePortfolio(portfolio,prayer)
assert(portfolio.total==24 and portfolio.bySkill.Firemaking==16 and portfolio.bySkill.Prayer==8 and portfolio.used==1,'One incense batch awards both skills once')
local own=e.newPortfolio(counts);e.allocatePortfolio(own,prayer)
assert(own.total==8 and not own.bySkill.Firemaking,'Per-skill totals exclude other skill XP')
local limited=find('Prayer','Infernal magic incense sticks')
levels[SkillType.FIREMAKING]=1
assert(#p.filter({limited},p.state(counts,'Prayer'))==0,'Prayer level cannot bypass incense Firemaking requirement')
levels[SkillType.FIREMAKING]=120
for _,r in ipairs(m.options({id=930001,name='Wooden incense sticks'},{skill='Prayer',method='Impious incense sticks',xp=8},counts)) do
 assert(not r.multiplier,'Incense is not an altar offering')
end
levels[SkillType.CRAFTING]=42
local tiers=p.filter(e.options({name='Protean hide'}),p.state({},'Crafting'))
assert(#tiers==1 and tiers[1].level==42,'Only current hide tier is shown')
levels[SkillType.CRAFTING]=99
tiers=p.filter(e.options({name='Protean hide'}),p.state({},'Crafting'))
assert(#tiers==1 and tiers[1].level==99,'Tier updates when level changes')
levels[SkillType.HERBLORE]=104
tiers=p.filter(e.options({name='Protean shake'}),p.state({},'Herblore'))
assert(#tiers==1 and tiers[1].level==99 and tiers[1].xp==720,'Current protean shake tier')
print('PASS: '..checked..' audited additions; ingredient reachability, urn exclusions, smelting batches, dual-skill supply accounting, requirements and protean tiers')
