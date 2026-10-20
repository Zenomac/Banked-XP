-- Tradeable anima have a visible title/footer but a non-visible empty middle
-- label. Extend the visible title only; never create or unhide UI components.
local M={}
local bank=require('bank')
local function plain(text) return bank.normalize(text):gsub('%s+','') end
function M.render(header,footer,selected,name,quantity,box,edit,resize)
    if not header or not footer or not header.visibleGlobal or not footer.visibleGlobal then return false end
    local title=header.content or ''
    if not plain(title):find('withdraw',1,true) or not plain(title):find(plain(name),1,true) then return false end
    local ok,font=pcall(function() return config.Font.FromID(header.font) end)
    if not ok or not font then return false end
    local total=selected.equipmentTotal or selected.outfitTotal or selected.total
    local lines={title}
    local function number(n) return string.format('%.1f',n):gsub('%.0$','') end
    lines[#lines+1]='<col=f8d56b>'..(total and number(total)..' '..selected.skill..' XP' or 'Bank XP unavailable')..'</col>'
    lines[#lines+1]='<col=e3d7bf>Method: '..selected.method..'</col>'
    if selected.craftable~=nil then lines[#lines+1]='<col=e3d7bf>Can make: '..number(selected.craftable)..' arrows</col>' end
    if selected.xp then lines[#lines+1]='<col=e3d7bf>'..number(selected.xp)..' base XP / arrow</col>' end
    if selected.note and selected.note~='' then lines[#lines+1]='<col=e3d7bf>'..selected.note..'</col>' end
    local content=table.concat(lines,'<br>')
    local width=math.min(440,math.max(240,header.width,font:GetStringWidth(title)))
    local step=math.max(14,font.baseline or 16)
    local height=math.max(1,font:GetStringLineCount(content,width))*step
    local titleHeight=math.max(1,font:GetStringLineCount(title,width))*step
    local x,y=header.xyGlobal.x,header.xyGlobal.y
    local footerHeight=math.max(14,footer.height)
    local footerY=y+height+6
    local bg=ui.Interfaces:GetComponent(96797572)
    if not bg or not bg.visibleGlobal then return false end
    local left=math.min(16,math.max(4,x-bg.xyGlobal.x))
    local top=math.min(16,math.max(4,y-bg.xyGlobal.y))
    local frameWidth=width+left*2
    local frameHeight=top+height+6+footerHeight+8
    -- Existing containers only. No child enumeration or constructor calls.
    for _,static in ipairs({899,901,902}) do
        local c=ui.Interfaces:GetComponent(1477,static)
        if c then resize(c,math.max(c.width,x+width+8-c.xyGlobal.x),math.max(c.height,footerY+footerHeight+8-c.xyGlobal.y)) end
    end
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
