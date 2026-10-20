-- Native item-name text uses a menu color, not the inventory bottle color.
local M={}
local function plain(s) return (s or ''):gsub('<[^>]*>',''):match('^%s*(.-)%s*$') end
function M.cancelIndex(menu)
    for i,e in ipairs(menu.entries) do
        local cancelType=MiniMenuActionType and MiniMenuActionType.CANCEL or 1006
        if e.actionType==cancelType or plain(e.verbText):lower()=='cancel'
            or plain(e.fullText):lower()=='cancel' or plain(e.overrideText):lower()=='cancel' then return i end
    end
end
function M.prepare(menu)
    local index=M.cancelIndex(menu)
    -- API order is the reverse of screen order: Cancel belongs at index 1.
    if index then for i=index,2,-1 do menu:Swap(i,i-1) end end
end
function M.placeAdded(menu,label,before)
    local entries=menu.entries
    if #entries<=before then return end
    -- Some client versions strip markup in exposed label fields. Do not
    -- require byte-for-byte equality with the colored Add() argument.
    local target=plain(label)
    local index
    for i=#entries,1,-1 do
        local e=entries[i]
        if plain(e.overrideText)==target or plain(e.fullText)==target or plain(e.verbText)==target then index=i;break end
    end
    index=index or #entries -- documented Add() insertion location
    for i=index,2,-1 do menu:Swap(i,i-1) end
end
function M.color(menu)
    for _,e in ipairs(menu.entries) do
        local color=(e.subjectText or ''):match('<col=(%x+)>')
        if color and #color==6 then return color end
    end
    return 'ffff00'
end
function M.label(method,label,color)
    if not method.engine or not method.method then return label end
    local name=method.method
    if label:sub(1,#name)~=name then return label end
    return '<col='..color..'>'..name..'</col>'..label:sub(#name+1)
end
-- Hide ingredient tags that repeat the item already being inspected.
function M.contextLabel(label,itemName)
    local normalize=require('bank').normalize
    local hovered=normalize(itemName)
    return (label:gsub('%s*%[([^%]]+)%]',function(tag)
        local name=normalize(tag)
        local log=name=='logs' or name:match(' logs$') or name:match(' log$')
        if name==hovered or log then return '' end
        return ' ['..tag..']'
    end))
end
return M
