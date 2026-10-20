package.path='./?.lua;banked-xp/?.lua;'..package.path
local engine=require('recipe_engine');local style=require('menu_style');local bank=require('bank')
local count,removed,refined=0,0,0
for _,r in ipairs(engine.recipes) do
 for _,i in ipairs(r.inputs) do
  count=count+1
  local result=style.contextLabel(r.shortLabel,i.name)
  for tag in result:gmatch('%[([^%]]+)%]') do assert(bank.normalize(tag)~=bank.normalize(i.name),r.id..': redundant '..tag) end
  if result~=r.shortLabel then removed=removed+1;if i.name:lower():find('refined',1,true) then refined=refined+1 end end
 end
end
assert(refined>0)
assert(style.contextLabel('Potion [Improved] [Lv 120]','Vial of water')=='Potion [Improved] [Lv 120]')
assert(style.contextLabel('Frame [Refined Maple planks]','Maple plank')=='Frame [Refined Maple planks]')
print('PASS: audited '..count..' recipe/input combinations; cleaned '..removed..' labels, including '..refined..' refined-item labels; distinct ingredients and requirement tags preserved')
