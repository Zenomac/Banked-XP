package.path='./?.lua;banked-xp/?.lua;'..package.path
local callbacks={}
Event={}
for _,name in ipairs({'Logic','InventoryAdded','InventoryUpdated','InventoryRemoved','GameStateChanged'}) do
 callbacks[name]={};Event[name]={Subscribe=function(key,fn) callbacks[name][key]=fn end}
end
local metal={id=1001,configName='METAL_BANK'}
local arch={id=1002,configName='ARCH_MATERIAL_STORAGE'}
local bankCfg={id=95,configName='BANK'}
config={Inv={METAL_BANK=metal,ARCH_MATERIAL_STORAGE=arch,BANK=bankCfg}}
local live={}
Inventory={Find=function(cfg) return live[cfg.id] end}
local function inv(cfg,rows)
 return {id=cfg.id,isValid=true,GetSlots=function() return rows end}
end
local function slot(name,id,n) return {obj={name=name,id=id},count=n} end
local storage=require('storage');storage.register()
local bank=require('bank')
local base=inv(bankCfg,{slot('Iron bar',2351,2)})
live[metal.id]=inv(metal,{slot('Iron bar',2351,10)})
live[arch.id]=inv(arch,{slot('Third Age iron',99991,20)})
storage.poll()
assert(#storage.records()==2 and storage.status():find('live',1,true))
assert(bank.snapshot(base)['iron bar']==12,'metal bank adds to bank supplies')
local rev=storage.revision();storage.poll();assert(storage.revision()==rev,'unchanged poll is stable')
live[metal.id]=inv(metal,{slot('Iron bar',2351,4)})
callbacks.InventoryUpdated.bankedXpStorage({inv=metal})
assert(bank.snapshot(base)['iron bar']==6,'storage update invalidates merged bank cache')
live[metal.id]=nil
callbacks.InventoryRemoved.bankedXpStorage({inv=metal})
assert(storage.hasCached() and storage.status():find('last scan',1,true))
assert(bank.snapshot(base)['iron bar']==6,'removed container retains copied last scan')
live[metal.id]=inv(metal,{})
storage.poll();assert(bank.snapshot(base)['iron bar']==2,'known empty storage replaces old stock')
local unknown={id=1003,configName='SHOP_EXAMPLE'}
live[unknown.id]=inv(unknown,{slot('Iron bar',2351,500)})
storage.observe(unknown);assert(bank.snapshot(base)['iron bar']==2,'unknown containers are never added')
PersistentDB={GetStructuredData=function() return {} end,SetStructuredData=function() return true end}
Player={GetLevelGameplay=function() return 104 end,GetLevelCapped=function() return 104 end}
SkillType={ARCHAEOLOGY=28,SMITHING=13,HERBLORE=15}
local engine=require('recipe_engine')
local artifact
for _,r in ipairs(engine.recipes) do if r.skill=='Archaeology' and r.level<=104 and r.inputs[1].name:match('%(damaged%)$') then artifact=r;break end end
assert(artifact)
local mats={}
for i,input in ipairs(artifact.inputs) do if i>1 then mats[#mats+1]=slot(input.name,99000+i,input.qty) end end
live[arch.id]=inv(arch,mats);storage.poll()
local summary=require('skill_summary')
base=inv(bankCfg,{slot(artifact.inputs[1].name,99999,1)})
bank.invalidate();summary.capture(base);summary.advance(5000)
assert(summary.tooltipExtra('Archaeology')==nil,'storage supplies complete artefact restoration')
assert(not summary.tooltipLine('Archaeology'):find('Banked XP: 0',1,true))
-- Storage changes must rebuild the last bank scan while bank is closed.
live[arch.id]=inv(arch,{});storage.poll();summary.tick();summary.advance(5000)
assert(summary.tooltipExtra('Archaeology')=='0','closed-bank refresh responds to storage depletion')
live[arch.id]=nil;storage.poll()
assert(not summary.tooltipLine('Archaeology'):find('(last scan)',1,true),'no scan suffix in compact hover')
assert(not summary.missingStorage('Archaeology'),'a successful empty scan is still scanned')
callbacks.GameStateChanged.bankedXpStorage()
assert(#storage.records()==0 and not storage.hasCached(),'session change discards storage')
assert(bank.snapshot(base)['third age iron']==nil,'session change invalidates merged cache')
print('PASS: storage discovery, events, live/last scan, empty and unavailable distinction, merge, no unknown supplies, restoration integration, closed-bank refresh and session clearing')

assert(storage.missingForSkill('Archaeology') and storage.missingForSkill('Smithing'),'each storage is unscanned after reset')
assert(not storage.missingForSkill('Cooking'),'unrelated skills unaffected')
live[metal.id]=inv(metal,{})
storage.poll()
assert(not storage.missingForSkill('Smithing') and storage.missingForSkill('Archaeology'),'scan flags are independent; empty scan counts')
