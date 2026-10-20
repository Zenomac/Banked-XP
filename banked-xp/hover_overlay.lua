-- One plugin-owned layer under static 1477:896, never under recycled hover rows.
local M={}
local owner,layer,label,plan,blocked
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
function M.show(header,offset,width,height,font,spacing,content)
    local current=root()
    if not current or not current.visibleGlobal or blocked then return false end
    if owner~=current then owner,layer,label,plan=current,nil,nil,nil end
    if not layer then
        local created
        local ok,err=pcall(function()
            created=ui.Layer.new(current)
            created.hidden=true;created.clickthrough=true
            local text=ui.Text.new(created)
            text.clickthrough=true
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
    if label.lineSpacing~=spacing then label.lineSpacing=spacing end
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
    return true
end
return M
