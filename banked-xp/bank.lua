-- Read-only snapshot of the full BANK container, never the filtered UI grid.
local M={}
local storage=require('storage')
local lastStorageRevision=-1
local tick=0
local lastTick=-100
local lastBank,lastSnapshot,lastBankKey
local function norm(name)
    local value=string.lower(name or '')
    value=string.gsub(value,'<[^>]*>','')
    value=string.gsub(value,'’',"'")
    value=string.gsub(value,'%)%s*%(',') (')
    return value
end
M.normalize=norm
function M.invalidate() lastTick=-100;lastSnapshot=nil end
if Event and Event.Logic then
    Event.Logic.Subscribe('bankedXpBankClock',function() tick=tick+1 end)
end
function M.snapshot(bank)
    if not bank or bank.isValid==false then M.invalidate();return nil end
    local okID,containerID=pcall(function() return bank.id end)
    local bankKey=okID and type(containerID)=='number' and containerID or bank
    if lastSnapshot and bankKey==lastBankKey and lastStorageRevision==storage.revision() and tick-lastTick<25 then return lastSnapshot end
    local ok,slots=pcall(function() return bank:GetSlots() end)
    if not ok or not slots then M.invalidate();return nil end
    local counts={}
    for _,slot in pairs(slots) do
        if slot.obj and type(slot.count)=='number' and slot.count>0 then
            local name=norm(slot.obj.name)
            counts[name]=(counts[name] or 0)+slot.count
        end
    end
    for _,record in ipairs(storage.records()) do
        local name=norm(record.obj.name);counts[name]=(counts[name] or 0)+record.count
    end
    lastStorageRevision=storage.revision()
    lastBank,lastTick,lastBankKey=bank,tick,bankKey
    lastSnapshot=counts
    return counts
end
function M.count(counts,name)
    if name=='@bead' then
        local n=0
        for _,colour in ipairs({'Black','White','Red','Yellow'}) do n=n+(counts[norm(colour..' bead')] or 0) end
        return n
    end
    return counts[norm(name)] or 0
end
return M
