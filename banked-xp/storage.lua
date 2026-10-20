-- Read-only auxiliary inventories. Store copied slot data, never Inv proxies.
local M={}
local states={metal={label='Metal bank'},arch={label='Archaeology storage'}}
local candidates={metal={'METAL_BANK'},arch={'ARCH_MATERIAL_STORAGE','ARCHAEOLOGY_MATERIAL_STORAGE','ARCH_MATERIALS','ARCHAEOLOGY_MATERIALS'}}
local revision,ticks=0,0
local logged,unknownCount={},0
local function safe(fn) local ok,v=pcall(fn);if ok then return v end end
local function identify(name)
 name=(name or ''):upper()
 if name=='METAL_BANK' then return 'metal' end
 if name:find('ARCH',1,true) and name:find('MATERIAL',1,true) and (name:find('STOR',1,true) or name:match('MATERIALS$')) then return 'arch' end
end
local function configName(cfg) return safe(function() return cfg.configName end) or '' end
local function fingerprint(records)
 local parts={};for _,r in ipairs(records) do parts[#parts+1]=tostring(r.obj.id)..':'..r.obj.name..'='..r.count end
 table.sort(parts);return table.concat(parts,'|')
end
local function read(kind,cfg)
 local s=states[kind]
 local inv=safe(function() return Inventory.Find(cfg) end)
 if not inv or safe(function() return inv.isValid end)==false then
  if s.live then s.live=false;revision=revision+1;print('[BXP storage] '..s.label..': using last scan (container unavailable).') end
  return false
 end
 local slots=safe(function() return inv:GetSlots() end)
 if type(slots)~='table' then return false end
 local records={}
 for _,slot in pairs(slots) do
  if slot.obj and type(slot.count)=='number' and slot.count>0 then
   local name=safe(function() return slot.obj.name end)
   local id=safe(function() return slot.obj.id end)
   if type(name)=='string' and type(id)=='number' then records[#records+1]={obj={name=name,id=id},count=slot.count} end
  end
 end
 local sig=fingerprint(records)
 if sig~=s.signature or not s.live then
  revision=revision+1
  print('[BXP storage] '..s.label..': scanned '..#records..' item types; config='..configName(cfg)..'; id='..tostring(safe(function() return inv.id end))..'.')
 end
 s.signature=sig;s.records=records;s.live=true;s.cfg=cfg
 return true
end
function M.observe(cfg)
 if not cfg then return end
 local name=configName(cfg)
 local kind=identify(name)
 if kind then read(kind,cfg);return end
 -- Bounded discovery only: do not count an unidentified container as supplies.
 if name~='' and name~='BANK' and name~='INV' and name~='WORN' and not logged[name] and unknownCount<12 then
  logged[name]=true;unknownCount=unknownCount+1
  print('[BXP storage probe] Inventory available: '..name..'; id='..tostring(safe(function() return cfg.id end))..' (not counted).')
 end
end
function M.poll()
 for kind,s in pairs(states) do
  local found=false
  if s.cfg then found=read(kind,s.cfg) end
  if not found then
   for _,name in ipairs(candidates[kind]) do
    local cfg=safe(function() return config.Inv[name] end)
    if cfg and read(kind,cfg) then break end
   end
  end
 end
end
function M.records()
 local records={}
 for _,s in pairs(states) do for _,r in ipairs(s.records or {}) do records[#records+1]=r end end
 return records
end
function M.revision() return revision end
function M.missingForSkill(skill)
 local kind=({Archaeology='arch',Smithing='metal'})[skill]
 return kind~=nil and states[kind].records==nil
end
function M.hasCached()
 for _,s in pairs(states) do if s.records and not s.live then return true end end
 return false
end
function M.status()
 local parts={}
 for _,kind in ipairs({'metal','arch'}) do
  local s=states[kind]
  parts[#parts+1]=s.label..': '..(s.records and (s.live and 'live' or 'last scan') or 'not scanned')
 end
 return table.concat(parts,'; ')
end
function M.clear()
 for _,s in pairs(states) do s.records=nil;s.signature=nil;s.live=nil;s.cfg=nil end
 revision=revision+1;logged={};unknownCount=0
end
function M.register()
 if M.registered then return end;M.registered=true
 for _,name in ipairs({'InventoryAdded','InventoryUpdated'}) do
  if Event[name] then Event[name].Subscribe('bankedXpStorage',function(e) safe(function() M.observe(e and e.inv) end) end) end
 end
 if Event.InventoryRemoved then Event.InventoryRemoved.Subscribe('bankedXpStorage',function(e)
  local kind=e and identify(configName(e.inv))
  local s=kind and states[kind]
  if s and s.live then s.live=false;revision=revision+1;print('[BXP storage] '..s.label..': using last scan (container removed).') end
 end) end
 if Event.Logic then Event.Logic.Subscribe('bankedXpStorage',function()
  ticks=ticks+1;if ticks%25==1 then safe(M.poll) end
 end) end
 if Event.GameStateChanged then Event.GameStateChanged.Subscribe('bankedXpStorage',M.clear) end
 print('[BXP storage] Read-only metal/Archaeology scan enabled. Open each storage once; detection is not yet verified in-game.')
end
return M
