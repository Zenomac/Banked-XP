-- One plugin-owned layer under static 1477:896, never under recycled hover rows.
local M={}
local owner,layer,label,plan,blocked
local inspected=false
local function root()
    local c=ui.Interfaces:GetComponent(96797568)
    if c and c.staticID==896 then return c end
end
function M.hide()
    plan=nil
    if layer then
        if root()==owner then pcall(function() layer.hidden=true end)
        else owner,layer,label=nil,nil,nil end
    end
end
function M.destroy()
    local current=root()
    if layer and current==owner then pcall(function() layer:Destroy() end) end
    owner,layer,label,plan,blocked=nil,nil,nil,nil,nil
end
function M.current() return plan and label or nil end
function M.sync(header)
    if not plan or not layer then return false end
    local current=root()
    if current~=owner then
        -- The old interface owns destruction of its children. Drop stale proxies.
        owner,layer,label,plan=nil,nil,nil,nil
        return false
    end
    if not header or not header.visibleGlobal or not current.visibleGlobal then M.hide();return false end
    local xy,origin=header.xyGlobal,current.xyGlobal
    local x,y=math.floor(xy.x-origin.x),math.floor(xy.y+plan.offset-origin.y)
    if x~=plan.x or y~=plan.y then layer:SetPos(x,y);plan.x,plan.y=x,y end
    return true
end
-- Read only, once per activation: visibleGlobal does not establish clipping
-- or render order. Record both ancestor chains without changing native UI.
local function inspect(header)
    if inspected then return end
    inspected=true
    local function field(c,k)
        local ok,value=pcall(function() return c[k] end)
        return ok and tostring(value) or '?'
    end
    for _,entry in ipairs({{'owned',label},{'native',header}}) do
        local c=entry[2]
        local chain={}
        for depth=1,8 do
            if not c then break end
            local ok,description,nextParent=pcall(function()
                local xy=c.xyGlobal
                return field(c,'staticID')..':'..field(c,'categoryID')..':'..field(c,'dynamicID')
                    ..' bounds='..tostring(xy.x)..','..tostring(xy.y)..','..field(c,'width')..','..field(c,'height')
                    ..' alpha='..field(c,'alpha')..' visible='..field(c,'visibleGlobal')
                    ..' scroll='..field(c,'scrollX')..','..field(c,'scrollY')..','..field(c,'scrollWidth')..','..field(c,'scrollHeight'),c.parent
            end)
            if not ok then chain[#chain+1]='unavailable';break end
            chain[#chain+1]=description;c=nextParent
        end
        print('[BXP render] '..entry[1]..' '..table.concat(chain,' <- '))
    end
    print('[BXP render] text font='..field(label,'font')..' nativeFont='..field(header,'font')
        ..' object='..field(label,'associatedObjectID')..' maxLines='..field(label,'maxLines')
        ..' spacing='..field(label,'lineSpacing')..' style='..field(label,'stylesheetID')
        ..' align='..field(label,'alignHorizontal')..','..field(label,'alignVertical'))
end
function M.show(header,offset,width,height,font,spacing,content,styleSource)
    local current=root()
    if not current or not current.visibleGlobal or blocked then return false end
    if owner~=current then owner,layer,label,plan=current,nil,nil,nil end
    if not layer then
        local created
        local ok,err=pcall(function()
            created=ui.Layer.new(current)
            created.hidden=true;created.clickthrough=true
            created.rgba=0xffffffff;created.alpha=1
            local text=ui.Text.new(created)
            text.clickthrough=true
            text:SetPos(0,0,0,0,0,0)
            text.hidden=false
            text.alignHorizontal=ui.AlignMode.CENTRE;text.alignVertical=ui.AlignMode.TOPLEFT
            text.maxLines=0
            layer,label=created,text
        end)
        if not ok then
            if created then pcall(function() created:Destroy() end) end
            layer,label=nil,nil;blocked=true
            error('Cannot initialize XP text layer: '..tostring(err))
        end
    end
    if label.font~=font then label.font=font end
    -- A visible component can still draw transparent/black text. Initialize
    -- colour explicitly from the native body style, including opaque alpha.
    local ok,rgb=pcall(function() return (styleSource or header).rgb end)
    if not ok or type(rgb)~='number' then rgb=0xd8d3c5 end
    local rgba=(rgb%0x1000000)*256+255
    if label.rgba~=rgba then label.rgba=rgba end
    if label.alpha~=1 then label.alpha=1 end
    -- lineSpacing is read-only, including on plugin-owned Text components.
    -- Let the selected native font supply its default line spacing.
    for _,key in ipairs({'isShadowed','shadowRGBA'}) do
        local ok,value=pcall(function() return header[key] end)
        if ok and value~=nil then pcall(function() if label[key]~=value then label[key]=value end end) end
    end
    width,height=math.ceil(width),math.ceil(height)
    if not plan or plan.width~=width or plan.height~=height then
        layer:SetSize(width,height);label:SetSize(width,height)
    end
    if label.content~=content then label.content=content end
    plan={offset=offset,width=width,height=height}
    if not M.sync(header) then return false end
    layer:MoveToFront()
    layer.hidden=false
    inspect(header)
    return true
end
return M
