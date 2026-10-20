package.path='./?.lua;banked-xp/?.lua;'..package.path
PersistentDB={GetStructuredData=function() return {} end,SetStructuredData=function() return true end}
local support=require('skill_support');SkillType={}
for i,s in ipairs(support.names) do SkillType[s:upper()]=i end
local level=120
Player={GetLevelGameplay=function() return level end,GetLevelCapped=function() return level end}
local e=require('recipe_engine');local catalog=require('catalog');local methods=require('methods');local policy=require('recipe_policy')
for gi,god in ipairs({'Bik','Ful','Wen','Jas'}) do
 local directs={}
 for _,suffix in ipairs({'',' (tradeable)'}) do
  local name='Resonant anima of '..god..suffix;local obj={id=970000+gi*10+#suffix,name=name};local direct
  for _,r in ipairs(e.options(obj)) do if r.category=='Resonant anima' and #r.inputs==2 then direct=r;break end end
  assert(direct and direct.level==95 and direct.xp==19 and direct.output.qty==1,'Standard per-arrow route')
  directs[#directs+1]=direct
  local counts={[name:lower()]=7,dinarrow=10}
  local result=e.estimate(obj,direct,counts)
  assert(result.craftable==2 and result.total==38,'Three anima per arrow; leave remainder')
  assert(e.estimate(obj,direct,{[name:lower()]=30,dinarrow=1}).total==19,'Dinarrow limits XP')
  assert(e.estimate(obj,direct,{[name:lower()]=2,dinarrow=5}).total==0,'Two anima cannot make an arrow')
  local base=catalog.lookup(obj);assert(base)
  local found=false;for _,r in ipairs(methods.options(obj,base,counts)) do if r.id==direct.id then found=true end end
  assert(found,'Variant reaches menu and hover')
  require('bank').invalidate()
  local preview,options=methods.estimate(obj,base,{GetSlots=function() return {{obj=obj,count=30}} end},30)
  assert(preview.ingredientPreview and preview.total==0 and #options==0,'Anima-only bank shows preview without phantom XP')
  level=94;assert(#policy.filter({direct},policy.state({},'Fletching'))==0,'Level gated');level=120
 end
 local counts={dinarrow=1,[('Resonant anima of '..god):lower()]=3,[('Resonant anima of '..god..' (tradeable)'):lower()]=3}
 local total=e.portfolio(directs,counts);assert(total==19,'Both anima variants share dinarrows once')
end
print('PASS: eight anima variants, exact ratios and XP, partial stacks, previews, level gates and shared dinarrows')
