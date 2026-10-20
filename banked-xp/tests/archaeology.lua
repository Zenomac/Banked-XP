package.path='./?.lua;banked-xp/?.lua;'..package.path
PersistentDB={GetStructuredData=function() return {} end,SetStructuredData=function() return true end}
SkillType={ARCHAEOLOGY=27};local level=120
Player={GetLevelGameplay=function() return level end,GetLevelCapped=function() return level end}
local worn={};config={Inv={WORN=1,INV=2}}
local bankItems={}
local function slots(items)
 local t={};for name,n in pairs(items) do t[#t+1]={obj={name=name},count=n} end;return t
end
Inventory={Find=function(id) return {GetSlots=function() return slots(id==1 and worn or {}) end} end}
local bank={GetSlots=function() return slots(bankItems) end}
local catalog=require('catalog');local methods=require('methods');local outfits=require('outfits')
local settings=require('settings');local bankData=require('bank')
local obj={name='Venator dagger (damaged)',id=987654}
local base=catalog.lookup(obj);assert(base and base.skill=='Archaeology')
bankItems={['venator dagger (damaged)']=2};bankData.invalidate()
local r,options=methods.estimate(obj,base,bank,2)
assert(#options==0 and r.artefactPreview and r.total==0 and r.craftable==0)
assert(r.note:find('610.2',1,true) and r.note:find('Archaeology storage',1,true))
bankItems={['venator dagger (damaged)']=2,['third age iron']=32,['zarosian insignia']=24};bankData.invalidate()
r,options=methods.estimate(obj,base,bank,2)
assert(#options>0 and math.abs(r.total-610.2)<0.001 and r.craftable==2)
local full={}
for _,piece in ipairs(require('outfit_data').Archaeology.pieces) do full[piece:lower()]=true end
local elite={}
for _,piece in ipairs(require('outfit_data').Archaeology.elite[1].pieces) do elite[piece:lower()]=true end
assert(outfits.evaluate('Archaeology',full,{}).percent==6)
local d=outfits.evaluate('Archaeology',elite,{})
assert(d.percent==1 and d.unknownInheritance and d.restorationSeconds==4.8)
d=outfits.evaluate('Archaeology',elite,full)
assert(d.percent==6 and not d.unknownInheritance and d.restorationSeconds==4.8)
local partial={['master archaeologist\'s hat']=true}
assert(outfits.evaluate('Archaeology',partial,full).restorationSeconds==nil)
for k in pairs(elite) do worn[k]=1 end
for k in pairs(full) do bankItems[k]=1 end
outfits.invalidate();bankData.invalidate()
r=methods.estimate(obj,base,bank,2)
assert(r.outfitPercent==6 and math.abs(r.outfitTotal-610.2*1.06)<0.001)
assert(r.note:find('4.8 seconds',1,true))
assert(catalog.lookup({name='Teleportation crystal (damaged)',id=987655}).skill=='Archaeology')
assert(catalog.lookup({name='Venator dagger',id=987656})==nil,'restored artefact has no repeat restoration XP')
print('PASS: missing materials preview, bank supply XP, potential XP, both outfits, elite unlock evidence, restore speed and new artefact')
local beacon={name='Damaged soul beacon (base)',id=987657}
local beaconBase=catalog.lookup(beacon);assert(beaconBase and beaconBase.skill=='Archaeology')
bankItems={['damaged soul beacon (base)']=1,['damaged soul beacon (core)']=1,['white marble']=30,['white oak']=30,['greater ensouled bar']=5};bankData.invalidate()
r=methods.estimate(beacon,beaconBase,bank,1)
assert(r.craftable==1 and r.total==9333.3,'base and core share exactly one restoration')
bankItems={['damaged soul beacon (base)']=1,['white marble']=30,['white oak']=30,['greater ensouled bar']=5};bankData.invalidate()
r,options=methods.estimate(beacon,beaconBase,bank,1)
assert(r.artefactPreview and r.total==0,'missing core cannot create restoration XP')
local screenshots={"Inquisitor's ceremonial mask (damaged)",'Funerary urn of miasma (damaged)','Funerary urn of smoke (damaged)',"'Incite Fear' spell scroll (damaged)",'Prototype godsword (damaged)','Zarosian training dummy (damaged)',"'Solem in Umbra' painting (damaged)",'Legatus Maximus figurine (damaged)'}
for i,name in ipairs(screenshots) do
 local object={name=name,id=988000+i};local entry=catalog.lookup(object)
 assert(entry and entry.skill=='Archaeology','screenshot name missing: '..name)
 bankItems={[name:lower()]=1};bankData.invalidate()
 local estimate,choices=methods.estimate(object,entry,bank,1)
 assert(estimate.artefactPreview and estimate.total==0 and #choices==0,'missing supply preview: '..name)
end
assert(catalog.lookup({name='Folded-arm figurine (female)(damaged)',id=988100}),'adjacent parentheses alias')
print('PASS: quest soul beacon pairing, missing core, all eight screenshot names and adjacent parentheses')
