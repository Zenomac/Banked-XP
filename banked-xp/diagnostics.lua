-- Read-only schema discovery. No game values, actions or UI are modified.
local seen,seenRows={},{}
local remaining=12
local function display(v)
    if v==nil then return 'nil' end
    local ok,name=pcall(function() return v.configName end)
    if ok and name then return tostring(name) end
    return tostring(v)
end
local function dumpRow(row)
    if not row then return end
    local key=display(row)
    if seenRows[key] then return end
    seenRows[key]=true
    print('[xp-data] DBROW '..key..' columns='..tostring(row.columnCount))
    local ownerOK,owner=pcall(function() return row.ownerDBTable end)
    if ownerOK then print('[xp-data] TABLE '..display(owner)) end
    for column=1,math.min(row.columnCount or 0,40) do
        local ok,values=pcall(function() return row:GetColumnValues(column) end)
        local text={}
        local typeOK,types=pcall(function() return row:GetColumnValueTypes(column) end)
        local typeText={}
        if typeOK then
            for i,v in pairs(types) do
                local label=tostring(v)
                -- Compare named enum values too, because enum tostring may
                -- only print a number in some client builds.
                for _,name in ipairs({'INTEGER','STRING','OBJ','STRUCT','DBROW','SPRITE','GRAPHIC','MODEL','BOOLEAN','STAT'}) do
                    local known,value=pcall(function() return ValueType[name] end)
                    if known and value~=nil and v==value then label=name;break end
                end
                typeText[#typeText+1]=tostring(i)..'='..label
            end
        end
        print('[xp-data] types '..column..' '..(typeOK and table.concat(typeText,', ') or 'unavailable'))
        if ok then
            for i,v in pairs(values) do
                if #text>=24 then break end
                text[#text+1]=tostring(i)..'='..display(v)
            end
        end
        print('[xp-data] column '..column..' '..(ok and table.concat(text,', ') or 'unavailable'))
    end
end
local function dump(obj)
    print('[xp-data] ITEM '..tostring(obj.name)..' id='..tostring(obj.id)..' config='..display(obj))
    for _,param in pairs(obj.params or {}) do
        local name=string.upper(param.configName or '')
        if name:find('XP',1,true) or name:find('RECIPE',1,true)
            or name:find('ARCH_',1,true) or name:find('COOK',1,true)
            or name:find('LOGS_',1,true) or name:find('HERB',1,true) then
            local ok,value=pcall(function() return obj:GetParamValue(param) end)
            print('[xp-data] '..name..' = '..(ok and display(value) or 'unavailable'))
            if name=='ARCH_RESTORATION_DATA' and ok then
                local row=value
                if type(value)=='number' then row=config.DBRow.FromID(value) end
                dumpRow(row)
            end
        end
    end
    -- Damaged artefacts can omit ARCH_RESTORATION_DATA. Use the exported
    -- matching DBRow name instead, without assuming a column schema.
    local name=obj.configName or ''
    if name:match('^ARCH_RESTORATION_') and name:match('_DAMAGED$') then
        local rowName=name:gsub('_DAMAGED$','')
        local ok,row=pcall(function() return config.DBRow[rowName] end)
        if ok and row then dumpRow(row)
        else print('[xp-data] No named restoration row: '..rowName) end
    end
    print('[xp-data] END ITEM')
end
Event.MiniMenuReady.Subscribe('bankedXpSchemaDiscovery',function(event)
    if remaining<=0 or MiniMenu.IsOpen() then return end
    local entries=event.miniMenu.entries
    local entry=entries[#entries]
    if not entry or not string.lower(entry.verbText or ''):find('withdraw',1,true) then return end
    local obj=entry.componentData and entry.componentData.objConfig
    if not obj or seen[obj.id] then return end
    seen[obj.id]=true;remaining=remaining-1
    local ok,err=pcall(dump,obj)
    if not ok then print('[xp-data] ERROR '..tostring(err)) end
end)
print('[xp-data] Read-only diagnostic active for the next 12 distinct bank items. Reload resets it.')
