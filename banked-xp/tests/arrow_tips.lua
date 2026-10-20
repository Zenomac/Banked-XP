package.path='./?.lua;banked-xp/?.lua;'..package.path
PersistentDB={GetStructuredData=function() return {} end,SetStructuredData=function() return true end}
local support=require('skill_support');SkillType={}
for i,s in ipairs(support.names) do SkillType[s:upper()]=i end
Player={GetLevelGameplay=function() return 120 end,GetLevelCapped=function() return 120 end}
local e=require('recipe_engine');local catalog=require('catalog');local methods=require('methods')
for _,case in ipairs({{'Black stone',12.6,92},{'Deathspore',20,95},{'Splintering',20,95}}) do
 local name,xp,level=case[1]..' arrow tips',case[2],case[3]
 local direct,raw
 for _,r in ipairs(e.options({name=name})) do
  for _,i in ipairs(r.inputs) do
   if i.name=='Elder headless shaft' then direct=r end
   if i.name=='Yellow feather' then raw=r end
  end
 end
 assert(direct and raw and direct.level==level,'Direct and preparation routes')
 local counts={[name:lower()]=3,['elder headless shaft']=2}
 local result=e.estimate({name=name},direct,counts)
 assert(result.craftable==2 and math.abs(result.total-xp*2)<0.000001,'Partial stacks limited by shafts')
 assert(e.estimate({name=name},direct,{[name:lower()]=3}).total==0,'Missing shafts do not produce XP')
 result=e.estimate({name=name},raw,{[name:lower()]=3,['elder shaft']=3,['yellow feather']=3})
 assert(math.abs(result.total-(xp+1)*3)<0.000001,'Only remaining feathering XP included')
 local base=catalog.lookup({id=980000+level,name=name});assert(base)
 local found=false
 for _,r in ipairs(methods.options({name=name},base,counts)) do if r.id==direct.id then found=true end end
 assert(found,'Ingredient reaches hover/menu options')
 assert(e.key(name)==e.key(name:sub(1,-2)),'Singular tip alias')
end
assert(e.key('Elder headless arrow')==e.key('Elder headless shaft'),'Legacy shaft alias')
print('PASS: three arrow-tip families, partial stacks, limiting supplies, preparation XP, levels, aliases and hover/menu options')
