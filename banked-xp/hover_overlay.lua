-- One owned layer inside the native tooltip content branch (static 1477:902).
local M={}
local owner,layer,label,plan,blocked
local canvas,canvasKey
local inspected=false
local layerID,textID,canvasID
local function identity(c) return {c.categoryID,c.dynamicID} end
local function root()
    local ok,c=pcall(function() return ui.Interfaces:GetComponent(1477,902) end)
    if ok and c and c.staticID==902 then return c end
end
local function drop()
    owner,layer,label,plan=nil,nil,nil,nil
    canvas,canvasKey=nil,nil
    layerID,textID,canvasID=nil,nil,nil
end
local function live(current)
    if not layer or not current or current~=owner then return false end
    -- Look up live children before dereferencing proxies: native rebuilds can
    -- remove dynamic children without replacing the static parent itself.
    local ok,found=pcall(function() return current:GetChild(layerID[1],layerID[2]) end)
    if not ok or found~=layer then return false end
    local textOK,text=pcall(function() return found:GetChild(textID[1],textID[2]) end)
    if not textOK or text~=label then return false end
    local canvasOK,foundCanvas=pcall(function() return found:GetChild(canvasID[1],canvasID[2]) end)
    return canvasOK and foundCanvas==canvas
end
function M.hide()
    plan=nil
    if layer then
        if live(root()) then pcall(function() layer.hidden=true end)
        else drop() end
    end
end
function M.destroy()
    if live(root()) then pcall(function() layer:Destroy() end) end
    drop();blocked=nil
end
function M.current()
    if plan and not live(root()) then drop() end
    return plan and label or nil
end
function M.sync(header)
    if not plan or not layer then return false end
    local current=root()
    if not live(current) then drop();return false end
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
    local configInfo=' textConfig=unavailable'
    pcall(function()
        local cfg=label:GetConfigCopy()
        configInfo=' textConfigFont='..tostring(cfg.font)..' textConfigAlpha='..tostring(cfg.alpha)..' textConfigRGBA='..tostring(cfg.rgba)
    end)
    print('[BXP render] text font='..field(label,'font')..' nativeFont='..field(header,'font')
        ..' object='..field(label,'associatedObjectID')..' maxLines='..field(label,'maxLines')
        ..' spacing='..field(label,'lineSpacing')..' style='..field(label,'stylesheetID')
        ..' align='..field(label,'alignHorizontal')..','..field(label,'alignVertical')..configInfo)
end
function M.show(header,offset,width,height,font,spacing,content,styleSource)
    local current=root()
    if not current or not current.visibleGlobal or blocked then return false end
    if layer and not live(current) then drop() end
    if owner~=current then owner=current end
    if not layer then
        local created
        local ok,err=pcall(function()
            -- Let the client allocate IDs, as the existing native-frame rules do.
            created=ui.Layer.new(current)
            created.hidden=true;created.clickthrough=true
            created.rgba=0xffffffff;created.alpha=1
            local text=ui.Text.new(created)
            text.clickthrough=true
            text:SetPos(0,0,0,0,0,0)
            text.hidden=false
            text.alignHorizontal=ui.AlignMode.CENTRE;text.alignVertical=ui.AlignMode.TOPLEFT
            text.maxLines=0
            local probe=ui.Canvas.new(created)
            probe:SetPos(0,0);probe.rgba=0xffffffff;probe.alpha=1
            probe.hidden=false;probe.clickthrough=true
            layerID,textID,canvasID=identity(created),identity(text),identity(probe)
            layer,label,canvas=created,text,probe
        end)
        if not ok then
            if created then pcall(function() created:Destroy() end) end
            layer,label=nil,nil;blocked=true
            error('Cannot initialize XP text layer: '..tostring(err))
        end
    end
    -- Initialize the text renderer itself, not just Component tint/opacity.
    -- TextDataConfig carries its own colour and alpha used for glyph drawing.
    local cfg
    local copied,value=pcall(function() return (styleSource or header):GetConfigCopy() end)
    if copied and value then cfg=value else cfg=ui.TextDataConfig.new() end
    cfg.font=font
    cfg.alignHorizontal=ui.AlignMode.CENTRE
    cfg.alignVertical=ui.AlignMode.TOPLEFT
    cfg.maxLines=0
    local ok,rgb=pcall(function() return (styleSource or header).rgb end)
    if not ok or type(rgb)~='number' then rgb=0xd8d3c5 end
    cfg.rgba=(rgb%0x1000000)*256+255
    -- Client log confirms TextDataConfig alpha=1 rewrites RGBA to ...01.
    -- Keep the explicit opaque FF byte; do not overwrite it via cfg.alpha.
    -- Some beta bindings omit lineSpacing on Text; configure it through the
    -- documented config object when available, otherwise retain its default.
    pcall(function() cfg.lineSpacing=spacing end)
    label:SetConfig(cfg)
    label.alpha=1
    width,height=math.ceil(width),math.ceil(height)
    if not plan or plan.width~=width or plan.height~=height then
        layer:SetSize(width,height);label:SetSize(width,height)
    end
    if label.content~=content then label.content=content end
    plan={offset=offset,width=width,height=height}
    if not M.sync(header) then return false end
    -- Temporary visual diagnostic: same bounds and parent, independent drawing
    -- path, no markup/config objects, and one known-visible native font.
    local key=table.concat({width,height,header.font,font},':')
    if canvasKey~=key then
        canvas:SetSize(width,height)
        canvas:Clear()
        canvas:AddOutline(1,1,math.max(1,width-2),math.max(1,height-2),2,0x00ffffff)
        canvas:AddText(8,20,'BXP test: heading font',header.font,0xffffffff)
        canvas:AddText(8,44,'BXP test: body font',font,0xffffffff)
        canvasKey=key
    end
    canvas:MoveToFront()
    layer:MoveToFront()
    layer.hidden=false
    inspect(header)
    return true
end
return M
