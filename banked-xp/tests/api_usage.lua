package.path='./?.lua;banked-xp/?.lua;'..package.path
local callbacks={};Event={}
for _,name in ipairs({'Logic','InventoryAdded','InventoryUpdated','InventoryRemoved','GameStateChanged'}) do
 callbacks[name]={};Event[name]={Subscribe=function(key,fn) callbacks[name][key]=fn end}
end
local metal={id=1,configName='METAL_BANK'};local arch={id=2,configName='ARCH_MATERIAL_STORAGE'}
config={Inv={METAL_BANK=metal,ARCH_MATERIAL_STORAGE=arch}}
local finds,reads=0,0
Inventory={Find=function(cfg)
 finds=finds+1
 return {id=cfg.id,isValid=true,GetSlots=function() reads=reads+1;return {} end}
end}
HTTP=setmetatable({}, {__index=function() error('network access is forbidden in client-cache paths') end})
local storage=require('storage');storage.register()
for _=1,500 do callbacks.Logic.bankedXpStorage() end
assert(reads==4 and finds==4,'10 simulated seconds should read each storage twice, not every 0.5 seconds')
local before=reads
for _=1,100 do callbacks.InventoryUpdated.bankedXpStorage({inv=metal}) end
assert(reads==before,'inventory events enqueue instead of repeatedly scanning')
callbacks.Logic.bankedXpStorage()
assert(reads==before+1,'100 updates coalesce into one scan on the next Logic tick')
local bank=require('bank');local bankReads=0
local inv={id=95,isValid=true,GetSlots=function() bankReads=bankReads+1;return {{obj={id=1517,name='Maple logs'},count=10}} end}
bank.snapshot(inv);assert(#bank.slots(inv)==1 and bankReads==1,'summary reuses slots already read for the bank snapshot')
package.loaded.skill_summary={supports=function() return false end,totalLine=function() return 'Banked XP: 0' end}
local uiReads=0
ui={Interfaces={GetComponent=function() uiReads=uiReads+1;return nil end}}
MiniMenu={IsOpen=function() return false end}
local hover=require('skill_hover')
for _=1,600 do hover.paint() end
assert(uiReads==4800,'idle UI lookup count stays at eight direct reads per frame; no broad fallback search')
print('PASS: no HTTP access, 5-second storage fallback, 100-to-1 event coalescing, bank slot reuse and eight idle UI reads per frame')
