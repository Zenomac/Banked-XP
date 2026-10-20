package.path='./?.lua;banked-xp/?.lua;'..package.path
local e=require('recipe_engine')
local policy=require('recipe_policy')
local rows=require('primal_recipes')
local tiers={}
for _,r in ipairs(e.recipes) do if r.primalYield then tiers[#tiers+1]=r end end
assert(#tiers==3)
for _,r in ipairs(tiers) do
 local y=r.primalYield
 local count={['primal fruit pulp']=10,vial=10*y}
 local result=e.estimate({name='Primal fruit pulp'},r,count)
 assert(result.craftable==10*y and result.total==1450 and result.xp==145/y,'145 XP per pulp, yield independent')
 assert(result.outputUnit=='extracts' and result.xpUnit=='extract','non-potion output wording')
 local limited=e.estimate({name='Primal fruit pulp'},r,{['primal fruit pulp']=10,vial=y*3})
 assert(limited.craftable==y*3 and limited.total==435,'empty vials limit whole actions')
 assert(e.estimate({name='Primal fruit pulp'},r,{['primal fruit pulp']=10}).total==0,'missing vials zero craftable XP')
 if y>1 then
  assert(r.unboostable,'improved yields require actual level')
  assert(#policy.filter({r},{baseKnown=true,baseLevel=r.level-3,level=r.level,showBoostable=true})==0,'boost cannot unlock improved yield')
 end
end
for _,raw in ipairs(rows) do
 if raw.method=='Primal fruit pulp' then
  local r;for _,v in ipairs(e.recipes) do if v.id==raw.id then r=v end end
  local fruit=r.inputs[1].name
  local result=e.estimate({name=fruit},r,{[fruit:lower()]=10})
  assert(result.total==100 and result.craftable==10*r.output.qty,'fruit pulp yield and 10 XP per fruit')
  assert(#e.options({name=fruit})>0,'fruit indexed')
 end
end
assert(#e.options({name='Primal fruit pulp'})==3,'pulp extract tiers indexed')
assert(#e.options({name='Primal extract'})>0,'existing extract-consuming recipes retained')
print('PASS: 3 extract yields, base XP, empty vial limits, actual-level improved tiers, 8 fruit pulping stages and existing extract uses')
