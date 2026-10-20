package.path='./?.lua;banked-xp/?.lua;'..package.path
local saved={}
PersistentDB={GetStructuredData=function() return saved end,SetStructuredData=function(_,_,value) saved=value;return true end}
local data=require('outfit_data');local outfits=require('outfits');local settings=require('settings')
local function names(pieces)
 local out={};for _,name in ipairs(pieces) do out[name:lower()]=true end;return out
end
for skill,set in pairs(data) do
 local equipment=names(set.pieces)
 local full=outfits.evaluate(skill,equipment,equipment)
 assert(full.percent==(skill=='Firemaking' and 5 or 6),'full set '..skill)
 equipment[set.pieces[#set.pieces]:lower()]=nil
 local partial=outfits.evaluate(skill,equipment,equipment)
 assert(partial.percent==(skill=='Firemaking' and 2 or 4),'partial set '..skill)
 local absent=outfits.evaluate(skill,{},names(set.pieces))
 assert(absent.percent==0 and absent.ownedPercent==(skill=='Firemaking' and 5 or 6),'ownership does not apply worn XP '..skill)
end
local arch=data.Archaeology
local master=names(arch.elite[1].pieces)
local unknown=outfits.evaluate('Archaeology',master,{})
assert(unknown.percent==1 and unknown.unknownInheritance,'master archaeology intrinsic 1%, unknown regular unlocks')
assert(outfits.evaluate('Archaeology',master,names(arch.pieces)).percent==6,'master archaeology verified regular inheritance')
local farmer=data.Farming
assert(outfits.evaluate('Farming',names(farmer.elite[1].pieces),{}).percent==0,'elite farmer does not invent owned standard outfit')
assert(outfits.evaluate('Farming',names(farmer.elite[1].pieces),names(farmer.pieces)).percent==6,'elite farmer inherits known ownership')
local ctor=data.Construction
assert(outfits.evaluate('Construction',names(ctor.elite[1].pieces),names(ctor.pieces)).percent==6,'master constructor verified full-set inheritance')
local chef=names(data.Cooking.pieces);chef["sous chef's mitts"]=nil;chef['cooking gauntlets']=true
assert(outfits.evaluate('Cooking',chef,{}).percent==4,'cooking gauntlets require owned mitts')
assert(outfits.evaluate('Cooking',chef,{["sous chef's mitts"]=true}).percent==6,'owned mitts enable cooking gauntlet substitution')
local equipmentSlots,backpackSlots={},{}
local calls=0
config={Inv={WORN=1,INV=2}}
Inventory={Find=function(cfg)
 return {GetSlots=function() calls=calls+1;return cfg==1 and equipmentSlots or backpackSlots end}
end}
for _,name in ipairs(data.Herblore.pieces) do equipmentSlots[#equipmentSlots+1]={obj={name=name},count=1} end
equipmentSlots[1].obj.name="Modified botanist's mask"
outfits.invalidate();outfits.refresh()
assert(outfits.percent('Herblore')==6,'real equipment snapshot and modified headpiece alias')
local base={skill='Herblore',xp=100,total=10000,craftable=100,note='Supplies'}
local adjusted=outfits.decorate(base)
assert(adjusted.total==10000 and adjusted.xp==100,'base XP and quantity preserved')
assert(adjusted.outfitTotal==10600 and adjusted.outfitPercent==6,'adjusted total includes worn set')
assert(not base.outfitTotal and base.note=='Supplies','cached engine result not mutated')
local before=calls
for _=1,100 do outfits.info('Herblore');outfits.percent('Herblore');outfits.decorate(base) end
assert(calls==before,'Draw/presentation cannot rescan inventories')
equipmentSlots={};outfits.invalidate();outfits.refresh()
assert(outfits.percent('Herblore')==0,'removing equipment removes bonus')
assert(outfits.decorate(base).outfitNote:find('(5 not worn)',1,true),'known owned outfit reported without XP inflation')
settings.setIncludeOutfitBonuses(false)
assert(not outfits.decorate(base).outfitTotal,'toggle disables outfit display')
settings.setIncludeOutfitBonuses(true)
-- Ownership in the bank unlocks inherited effects, but does not equip base gear.
outfits.clear();outfits.observeBank({["farmer's hat"]=1,["farmer's jacket"]=1,["farmer's legwear"]=1,["farmer's cuffs"]=1,["farmer's boots"]=1})
for _,name in ipairs(data.Farming.elite[1].pieces) do equipmentSlots[#equipmentSlots+1]={obj={name=name},count=1} end
outfits.invalidate();outfits.refresh()
assert(outfits.percent('Farming')==6,'bank ownership + elite equipment')
outfits.clear();assert(outfits.info('Farming').percent==0 and outfits.info('Farming').ownedPercent==0,'session reset clears character evidence')
print('PASS: all ten outfits, partial/full sets, modified pieces, elite inheritance, unknown unlocks, cooking gauntlets, equipment changes, base preservation, setting and no Draw scans')

assert(outfits.formatPercent('Crafting',0)=='<col=ff4040>+0%</col>','zero red')
assert(outfits.formatPercent('Crafting',4)=='<col=ff9900>+4%</col>','partial orange')
assert(outfits.formatPercent('Crafting',6)=='<col=00ff00>+6%</col>','full green')
assert(outfits.formatPercent('Firemaking',2)=='<col=ff9900>+2%</col>','single fired-up piece orange')
assert(outfits.formatPercent('Firemaking',5)=='<col=00ff00>+5%</col>','full fired-up set green')
local zero=outfits.decorate({skill='Crafting',total=500})
assert(zero.outfitNote:find('<col=ff4040>+0%</col>',1,true),'zero bonus explicitly displayed')
assert(not zero.outfitNote:find('<col=ff4040>Artisan',1,true),'outfit name stays native colored')
print('PASS: zero/partial/full outfit percentage colors and Firemaking maximum')

outfits.observeBank({["artisan's bandana"]=1})
assert(not outfits.decorate({skill='Crafting',total=500}).outfitNote:find('Available outfit bonus',1,true),'available bonus line removed')

local set=data.Crafting
local two={[set.pieces[1]:lower()]=true,[set.pieces[2]:lower()]=true}
local partial=outfits.evaluate('Crafting',two,two)
assert(outfits.pieceStatus('Crafting',partial)=='(3 not owned)','missing ownership count')
local ownedFull=names(set.pieces)
assert(outfits.pieceStatus('Crafting',outfits.evaluate('Crafting',two,ownedFull))=='(3 not worn)','owned but unequipped count')
assert(outfits.pieceStatus('Crafting',outfits.evaluate('Crafting',ownedFull,ownedFull))=='(0 not worn)','full worn status')
assert(outfits.pieceStatus('Firemaking',outfits.evaluate('Firemaking',{['ring of fire']=true},{['ring of fire']=true}))=='(1 not owned)','two-piece set count')
assert(outfits.pieceStatus('Construction',outfits.evaluate('Construction',names(data.Construction.elite[1].pieces),names(data.Construction.pieces)))=='(0 not worn)','master constructor counts as worn')
print('PASS: missing-owned and missing-worn counts, full outfit and two-piece/elite sets')
