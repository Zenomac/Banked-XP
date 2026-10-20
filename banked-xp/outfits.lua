-- Read real equipment outside Draw. Ownership evidence is session-only and
-- comes exclusively from positive bank/backpack/equipment observations.
local M={}
local data=require('outfit_data')
local function norm(s)
 local value=string.lower(s or '')
 value=string.gsub(value,'<[^>]*>','')
 value=string.gsub(value,'’',"'")
 value=string.gsub(value,'^modified ','')
 return value
end
local recognized={}
for _,set in pairs(data) do
 for _,name in ipairs(set.pieces) do recognized[norm(name)]=true end
 for _,elite in ipairs(set.elite or {}) do for _,name in ipairs(elite.pieces) do recognized[norm(name)]=true end end
end
recognized['cooking gauntlets']=true
local owned,worn,info={},{},{}
local dirty,ticks,lastTick,registered=true,0,-25,false
local function full(pieces,items)
 for _,name in ipairs(pieces) do if not items[norm(name)] then return false end end
 return true
end
function M.evaluate(skill,equipment,ownership)
 local set=data[skill]
 if not set then return {percent=0,ownedPercent=0} end
 local count,ownedCount=0,0
 local unknown=false
 local label=set.name
 for i,name in ipairs(set.pieces) do
  local key=norm(name)
  local credit=equipment[key] or false
  if ownership[key] or equipment[key] then ownedCount=ownedCount+1 end
  if skill=='Cooking' and i==4 and equipment['cooking gauntlets'] and ownership[key] then credit=true end
  for _,elite in ipairs(set.elite or {}) do
   if not elite.fullOnly and equipment[norm(elite.pieces[i])] then
    label=elite.name
    if ownership[key] then credit=true else unknown=true end
   end
  end
  if credit then count=count+1 end
 end
 local amount=set.pieceBonus or 1
 local percent=count*amount+(count==#set.pieces and 1 or 0)
 local ownedPercent=ownedCount*amount+(ownedCount==#set.pieces and 1 or 0)
 for _,elite in ipairs(set.elite or {}) do
  if full(elite.pieces,equipment) then
   label=elite.name
   if elite.fullOnly then
    if full(set.pieces,ownership) then percent=math.max(percent,6);count=#set.pieces else unknown=true end
   elseif set.minimumEliteFull then percent=math.max(percent,set.minimumEliteFull) end
  end
 end
 return {percent=percent,ownedPercent=ownedPercent,name=label,ownedName=set.name,unknownInheritance=unknown,restorationSeconds=(skill=='Archaeology' and full(set.elite[1].pieces,equipment)) and 4.8 or nil,pieceCount=#set.pieces,ownedCount=ownedCount,wornCount=count}
end
local function rebuild()
 for skill in pairs(data) do info[skill]=M.evaluate(skill,worn,owned) end
end
function M.observeBank(counts)
 local changed=false
 for name,n in pairs(counts or {}) do
  local key=norm(name)
  if n>0 and recognized[key] and not owned[key] then owned[key]=true;changed=true end
 end
 if changed then rebuild() end
end
function M.invalidate() dirty=true end
function M.refresh()
 if not dirty and ticks-lastTick<25 then return end
 lastTick=ticks;dirty=false
 local nextWorn={}
 for _,container in ipairs({'WORN','INV'}) do
  local ok,slots=pcall(function()
   local cfg=config.Inv[container]
   if not cfg then return nil end
   local inv=Inventory.Find(cfg)
   if not inv or inv.isValid==false then return nil end
   return inv:GetSlots()
  end)
  if ok and slots then
   for _,slot in pairs(slots) do
    if slot.obj and (slot.count or 1)>0 then
     local key=norm(slot.obj.name)
     if recognized[key] then owned[key]=true end
     if container=='WORN' then nextWorn[key]=true end
    end
   end
  end
 end
 worn=nextWorn;rebuild()
end
function M.clear()
 owned,worn,info={},{},{};dirty=true;lastTick=-25
end
-- Safe on Draw: returns the cached result, never reads an inventory.
function M.equipment() return worn end
function M.info(skill) return info[skill] or {percent=0,ownedPercent=0} end
function M.percent(skill)
 local settings=require('settings')
 if settings.includeOutfitBonuses and settings.includeOutfitBonuses() then return M.info(skill).percent end
 return 0
end
function M.pieceStatus(skill,detail)
 local set=data[skill]
 local total=detail.pieceCount or (set and #set.pieces or 0)
 local missing=math.max(0,total-(detail.ownedCount or 0))
 if missing>0 then return '('..missing..' not owned)' end
 return '('..math.max(0,total-(detail.wornCount or 0))..' not worn)'
end
function M.formatPercent(skill,percent)
 local maximum=skill=='Firemaking' and 5 or 6
 local color=percent<=0 and 'ff4040' or percent>=maximum and '00ff00' or 'ff9900'
 return '<col='..color..'>+'..percent..'%</col>'
end
function M.decorate(result)
 if not result then return result end
 local settings=require('settings')
 if not settings.includeOutfitBonuses or not settings.includeOutfitBonuses() then return result end
 local detail=M.info(result.skill)
 local out={};for k,v in pairs(result) do out[k]=v end
 out.outfitPercent=detail.percent
 if detail.percent>0 then
  local factor=1+detail.percent/100
  if out.total then out.outfitTotal=out.total*factor end
  if out.minXP then out.outfitMinXP=out.minXP*factor;out.outfitMaxXP=out.maxXP*factor end
  out.outfitNote='Outfit: '..M.formatPercent(result.skill,detail.percent)..' '..detail.name..' '..M.pieceStatus(result.skill,detail)
 elseif detail.ownedPercent>0 then
  out.outfitNote='Outfit: '..M.formatPercent(result.skill,0)..' '..detail.ownedName..' '..M.pieceStatus(result.skill,detail)
 else
  local set=data[result.skill]
  if set then out.outfitNote='Outfit: '..M.formatPercent(result.skill,0)..' '..set.name..' '..M.pieceStatus(result.skill,detail) end
 end
 if detail.unknownInheritance then
  out.outfitNote=(out.outfitNote and out.outfitNote..' | ' or '')..'Elite outfit: regular outfit unlocks unconfirmed; unconfirmed inherited XP excluded'
 end
 if detail.restorationSeconds then out.outfitNote=(out.outfitNote and out.outfitNote..' | ' or '')..'Master outfit: 4.8 seconds per restoration (normally 6)' end
 if out.outfitNote then out.note=(out.note and out.note..' | ' or '')..out.outfitNote end
 return out
end
function M.register()
 if registered then return end;registered=true
 if not Event then return end
 if Event.Logic then Event.Logic.Subscribe('bankedXpOutfits',function() ticks=ticks+1;M.refresh() end) end
 for _,name in ipairs({'InventoryUpdated','InventoryAdded','InventoryRemoved'}) do
  if Event[name] then Event[name].Subscribe('bankedXpOutfitsChanged',M.invalidate) end
 end
 if Event.GameStateChanged then Event.GameStateChanged.Subscribe('bankedXpOutfitsSession',M.clear) end
end
return M
