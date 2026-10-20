-- Temporary, read-only diagnostic. At most three distinct snapshots per
-- tradeable anima per plugin load. No bank counts, XP or identifiers logged.
local M={}
local seen,counts={},{}
local function read(c,key)
    if not c then return 'missing' end
    local ok,value=pcall(function() return c[key] end)
    return ok and tostring(value) or 'unavailable'
end
function M.report(name,reason,rows)
    name=require('bank').normalize(name)
    if not name:match('^resonant anima of .+ %(tradeable%)$') then return end
    if (counts[name] or 0)>=3 then return end
    local parts={reason}
    for i=0,3 do
        local c=rows and rows[i]
        local text=read(c,'content'):gsub('[\r\n]',' '):sub(1,120)
        if text:find('<col=f8d56b>',1,true) then text='[plugin XP content omitted]' end
        parts[#parts+1]=string.format('row%d type=%s hidden=%s visible=%s text=%s',
            i,read(c,'type'),read(c,'hidden'),read(c,'visibleGlobal'),text)
    end
    local signature=table.concat(parts,' | ')
    local key=name..signature
    if seen[key] or (counts[name] or 0)>=3 then return end
    seen[key]=true;counts[name]=(counts[name] or 0)+1
    print('[BXP hover probe] '..name..' | '..signature)
end
return M
