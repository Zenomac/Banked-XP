package.path='./?.lua;banked-xp/?.lua;'..package.path
local worn={}
local enabled=true
package.preload.settings=function() return {includeHandEquipment=function() return enabled end} end
package.preload.outfits=function() return {equipment=function() return worn end} end
local hands=require('hand_equipment')
for _,god in ipairs({'bandos','guthix','saradomin','zamorak','seren'}) do
 assert(hands.evaluate('Construction',{['sculpting chisel ('..god..')']=true})==1)
end
worn['sculpting chisel (guthix)']=true
local base={skill='Construction',total=1000,xp=10,craftable=100,outfitPercent=6,outfitTotal=1060}
local r=hands.decorate(base)
assert(r.equipmentTotal==1070 and r.total==1000 and r.xp==10 and r.craftable==100)
assert(base.equipmentTotal==nil and hands.percent('Construction')==1)
enabled=false;assert(hands.decorate(base)==base and hands.percent('Construction')==0);enabled=true
worn={};assert(hands.decorate(base)==base,'bank ownership does not imply equipped')
for _,test in ipairs({{'Crafting',"artificer's measure"},{'Smithing','orthen furnace core'},{'Archaeology',"balarak's sash brush"},{'Archaeology',"augmented guildmaster tony's mattock"},{'Smithing','augmented crystal hammer'},{'Fletching','fenshell knife'}}) do
 local percent,notes=hands.evaluate(test[1],{[test[2]]=true})
 assert(percent==0 and #notes==1,'conditional/gathering effects must not inflate base XP')
end
assert(hands.evaluate('Herblore',{['sculpting chisel (guthix)']=true})==0)
print('PASS: equipped hands, five chisel forms, additive outfit stacking, base preservation, conditional effects excluded, setting toggle')
