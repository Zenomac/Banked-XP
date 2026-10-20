-- Geometry from the player's native frame export: 10px corners/edges.
-- Reuse the client sprites, including their tint, flips and transparency.
local M={}
local rules={}
function M.plan(w,h)
    return {
        [0]={2,2,w-4,h-4},
        [1]={0,0,10,10},[2]={w-10,0,10,10},
        [3]={0,h-10,10,10},[4]={w-10,h-10,10,10},
        [5]={10,0,w-20,10},[6]={10,h-10,w-20,10},
        [7]={0,10,10,h-20},[8]={w-10,10,10,h-20},
    }
end
local function get(static,dynamic)
    local ok,c=pcall(function() return ui.Interfaces:GetComponent(1477,static,0,dynamic) end)
    if ok then return c end
end
function M.hide()
    for _,r in pairs(rules) do pcall(function() r.layer.hidden=true end) end
end
function M.destroy()
    for _,r in pairs(rules) do pcall(function() r.layer:Destroy() end) end
    rules={}
end
-- Plain ingredient tooltips may omit either native divider. Supply the same
-- client sprite without changing their native background or corner styling.
local function spriteRule(key,x,y,width)
    local root=ui.Interfaces:GetComponent(96797568)
    if not root then return end
    local r=rules[key]
    if not r then
        local layer=ui.Layer.new(root);layer.clickthrough=true;layer.hidden=true
        local sprite=ui.Sprite.new(layer);sprite.sprite=35516;sprite.clickthrough=true
        r={layer=layer,sprite=sprite};rules[key]=r
    end
    local dx,dy=x-root.xyGlobal.x,y-root.xyGlobal.y
    if dx~=r.x or dy~=r.y then r.layer:SetPos(dx,dy);r.x,r.y=dx,dy end
    if width~=r.width then
        r.layer:SetSize(width,2);r.sprite:SetPos(0,0);r.sprite:SetSize(width,2);r.width=width
    end
    r.layer.hidden=false;r.layer:MoveToFront()
end
function M.apply(bg,header,footer,detailY,box,edit)
    if not bg then return false end
    local parts={}
    for i=0,8 do
        parts[i]=get(900,i)
        if not parts[i] or (i>0 and parts[i].type~=ui.ComponentType.SPRITE) then return false end
    end
    local first,last=get(901,0),get(901,1)
    local bounds=M.plan(bg.width,bg.height)
    for i=0,8 do
        local b=bounds[i]
        box(parts[i],bg.xyGlobal.x+b[1],bg.xyGlobal.y+b[2],b[3],b[4])
        -- Never unhide a native component; the client owns its visibility.
    end
    -- Join the inner border instead of leaving a gap at each end.
    local x,width=bg.xyGlobal.x+1,bg.width-2
    local function divider(c,key,y)
        if c and c.type==ui.ComponentType.SPRITE and c.hidden~=true then
            box(c,x,y,width,2)
        else
            -- Missing/hidden native rules stay untouched. Draw our own rule.
            spriteRule(key,x,y,width)
        end
    end
    divider(first,'header',header.xyGlobal.y+header.height+1)
    divider(last,'footer',footer.xyGlobal.y-4)
    if detailY then spriteRule('effects',x,detailY,width) end
    return true
end
return M
