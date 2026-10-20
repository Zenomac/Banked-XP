package.path='./?.lua;banked-xp/?.lua;'..package.path
PersistentDB={GetStructuredData=function() return {} end,SetStructuredData=function() return true end}
local support=require('skill_support');SkillType={}
for i,s in ipairs(support.names) do SkillType[s:upper()]=i end
Player={GetLevelGameplay=function() return 120 end,GetLevelCapped=function() return 120 end}
local e=require('recipe_engine');local catalog=require('catalog');local methods=require('methods')
local function route(item,output,inputName)
 for _,r in ipairs(e.options({name=item})) do
  if r.output.name==output then
   for _,i in ipairs(r.inputs) do if i.name==inputName then return r end end
  end
 end
 error('Missing '..item..' -> '..output..' via '..inputName)
end
local function check(item,output,inputName,stock,xp)
 local r=route(item,output,inputName)
 local result=e.estimate({name=item},r,stock)
 assert(math.abs(result.total-xp)<0.000001,item..': expected '..xp..', got '..tostring(result.total))
 assert(e.inputsOwned({name=item},r,stock),item..' available with supplies')
 assert(e.estimate({name=item},r,{}).total==0,'No phantom XP')
 local base=catalog.lookup({id=981000+#item,name=item});assert(base,'Catalog reaches '..item)
 local opts=methods.options({id=981000+#item,name=item},base,stock);local found=false
 for _,o in ipairs(opts) do if o.id==r.id then found=true end end
 assert(found,'Hover/menu policy reaches '..item)
 return r
end
check('Battlestaff','Air battlestaff','Air orb',{battlestaff=2,['air orb']=2},275)
check('Battlestaves','Water battlestaff','Water orb',{battlestaff=1,['water orb']=1},100)
check('Broad arrowheads','Broad arrow','Headless shaft',{['broad arrowheads']=1,['headless shaft']=1},15)
check('Rune arrowheads','Rune arrow','Headless shaft',{['rune arrowheads']=14,['headless arrow']=14},175)
check('Dragon arrowheads','Dragon arrow','Shaft',{['dragon arrowheads']=3,shaft=3,feather=3},48)
check('Ascension fragment','Fragment arrows','Bronze arrow',{['ascension fragment']=1,['bronze arrow']=1},0.5)
check('Ascension fragments','Fragment bolts','Bronze bolts',{['ascension fragment']=3,['bronze bolts']=3},1.5)
check('Ascension fragment','Fragment arrows','Bronze arrowheads',{['ascension fragment']=2,['bronze arrowheads']=2,['headless shaft']=2},3.6)
check('Refined Maple planks','Maple frame','Refined Maple planks',{['refined maple planks']=3},216)
check('Wooden frame','Workshop (Tier 1)','Stone wall segment',{['wooden frame']=8,['stone wall segment']=6},2304)
local r=route('Wooden frame','Workshop (Tier 1)','Stone wall segment')
assert(e.estimate({name='Wooden frame'},r,{['wooden frame']=8}).total==0,'Frame building requires wall segments')
assert(e.key('Headless arrow')==e.key('Headless shaft') and e.key('Arrow shaft')==e.key('Shaft'),'Legacy shaft names resolve')
assert(route('Dark arrowheads','Dark arrow','Headless shaft').level==70,'Current dark arrow level')
assert(math.abs(route('Elder rune arrowheads','Elder rune arrow','Headless shaft').xp-18.7)<0.000001,'Current elder rune arrow XP')
print('PASS: battlestaves, arrowheads, frames and fragments; hover/menu reachability, aliases, partial ammo, preparation XP and missing supplies')
