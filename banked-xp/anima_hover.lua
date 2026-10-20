-- Tradeable anima have a visible title/footer but a non-visible empty middle
-- label. Extend the visible title only; never create or unhide UI components.
local M={}
local bank=require('bank')
local fonts={}
local plans,order={},{}
local function plain(text) return bank.normalize(text):gsub('%s+','') end
function M.render(header,footer,selected,name,quantity,box,edit,resize)
    if not header or not footer or not header.visibleGlobal or not footer.visibleGlobal then return false end
    local title=header.content or ''
    if not plain(title):find('withdraw',1,true) or not plain(title):find(plain(name),1,true) then return false end
    -- The visible title is the only safe content surface on these hovers.
    -- Retain the native title font: changing it leaves the client label's
    -- native line advance unchanged, making smaller-font bounds too short.
    local fontID=header.font
    local font=fonts[fontID]
    if not font then
        local ok,value=pcall(function() return config.Font.FromID(fontID) end)
        if not ok or not value then return false end
        font=value;fonts[fontID]=font
    end
    local total=selected.equipmentTotal or selected.outfitTotal or selected.total
    local function number(n)
        return string.format('%.0f',n):reverse():gsub('(%d%d%d)','%1,'):reverse():gsub('^,','')
    end
    local function compact(n)
        if n>=1000000 then return string.format('%.2fm',n/1000000) end
        if n>=1000 then return string.format('%.1fk',n/1000) end
        return string.format('%.1f',n):gsub('%.0$','')
    end
    local lines={title}
    local bonus=selected.equipmentTotal and ' (with equipment)' or selected.outfitTotal and ' (with outfit)' or ''
    lines[#lines+1]='<col=f8d56b>'..(total and compact(total)..' '..selected.skill..' XP'..bonus or 'Bank XP unavailable')..'</col>'
    lines[#lines+1]='<col=e3d7bf>Method: '..selected.method..'</col>'
    lines[#lines+1]='<col=e3d7bf>Banked: '..number(quantity)..' '..(selected.unit or 'items')..'</col>'
    if bonus~='' and selected.total then lines[#lines+1]='<col=e3d7bf>Base total: '..compact(selected.total)..' XP</col>' end
    if selected.craftable~=nil then lines[#lines+1]='<col=e3d7bf>Can make: '..number(selected.craftable)..' '..(selected.outputUnit or 'arrows')..'</col>' end
    if selected.xp then lines[#lines+1]='<col=e3d7bf>'..string.format('%.1f',selected.xp):gsub('%.0$','')..' base XP / '..(selected.xpUnit or 'arrow')..'</col>' end
    if selected.inputPerPotion and selected.inputPerPotion>1 then
        lines[#lines+1]='<col=e3d7bf>Uses '..tostring(selected.inputPerPotion)..' per '..(selected.xpUnit or 'arrow')..'</col>'
    end
    for part in (selected.note or ''):gmatch('[^|]+') do
        part=part:match('^%s*(.-)%s*$')
        if part~='' then
            part=part:gsub('(<col=%x+>%%+[%d%.]+%%)</col>','%1<col=e3d7bf>')
            lines[#lines+1]='<col=e3d7bf>'..part..'</col>'
        end
    end
    local content=table.concat(lines,'<br>')
    local spacing=header.lineSpacing
    local step=spacing and spacing>0 and spacing or font.baseline or 14
    local key=table.concat({content,tostring(fontID),tostring(header.width),tostring(step)},'\0')
    local plan=plans[key]
    if not plan then
        local natural=120
        for _,line in ipairs(lines) do natural=math.max(natural,font:GetStringWidth(line,false)+4) end
        local width=math.min(440,math.max(header.width,natural))
        local function height(text)
            local count=math.max(1,font:GetStringLineCount(text,width,false))
            return math.ceil((font.maxAscent or step-3)+(font.maxDescent or 3)+(count-1)*step+2)
        end
        plan={width=width,height=height(content),titleHeight=height(title)}
        plans[key]=plan;order[#order+1]=key
        if #order>8 then plans[table.remove(order,1)]=nil end
    end
    local width,height,titleHeight=plan.width,plan.height,plan.titleHeight
    local x,y=header.xyGlobal.x,header.xyGlobal.y
    local footerHeight=math.max(14,footer.height)
    local footerY=y+height+9
    local bg=ui.Interfaces:GetComponent(96797572)
    if not bg or not bg.visibleGlobal then return false end
    local left=math.min(16,math.max(4,x-bg.xyGlobal.x))
    local top=math.min(16,math.max(4,y-bg.xyGlobal.y))
    local frameWidth=width+left*2
    local frameHeight=top+height+9+footerHeight+8
    -- Existing containers only. No child enumeration or constructor calls.
    for _,static in ipairs({899,901,902}) do
        local c=ui.Interfaces:GetComponent(1477,static)
        if c then resize(c,math.max(c.width,x+width+8-c.xyGlobal.x),math.max(c.height,footerY+footerHeight+8-c.xyGlobal.y)) end
    end
    edit(header,'font',fontID)
    edit(header,'content',content)
    edit(header,'maxLines',0)
    edit(header,'alignHorizontal',ui.AlignMode.CENTRE)
    edit(header,'alignVertical',ui.AlignMode.TOPLEFT)
    box(header,x,y,width,height)
    box(footer,x,footerY,width,footerHeight)
    resize(bg,frameWidth,frameHeight)
    require('native_frame').apply(bg,{xyGlobal={x=x,y=y},height=titleHeight},footer,nil,box,edit,true)
    return true
end
return M
