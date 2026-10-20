-- Native middle-row layout 0.49. Native cursor positioning is preserved.
-- Temporarily expands the native tooltip row and moves its footer below it.
-- Reversible layout edits are undone before each frame and on exit.
require('storage').register()
local totalProbeOK,totalProbeError=pcall(function() require('total_probe').register() end)
if not totalProbeOK then print('[BXP total probe] Initialization error: '..tostring(totalProbeError)) end
local selected, applied, saved, written = nil, nil, nil, nil
local quantity=nil
local selectedName=nil
local artefactTrace=require('artefact_trace')
require("settings_ui").register()
-- Optional skill-hover integration must not prevent item hovers loading.
local skillHover
local skillLoaded,skillError=pcall(function()
    skillHover=require("skill_hover")
    skillHover.register()
end)
if not skillLoaded then print('[banked-xp] Skill summary unavailable: '..tostring(skillError)) end
local catalog=require("catalog")
local methods=require("methods")
local hoverLayout=require("hover_layout")
local nativeFrame=require("native_frame")
require("outfits").register()
-- A reminder must never prevent the core XP plugin from loading.
local noticeOK,noticeError=pcall(function() require("startup_notice").register() end)
if not noticeOK then print('[banked-xp] Optional Diango notice unavailable: '..tostring(noticeError)) end
local warned, reported = false, false
local edits={}
local function undoLayout()
    for i=#edits,1,-1 do
        local e=edits[i]
        pcall(function()
            if e.p=='rect' then
                e.c.size=e.before.size
                -- The client can move a native label between our Draw calls.
                -- Never replace a position that it has updated in that time.
                local current=e.c.position
                local unchanged=true
                for _,field in ipairs({'x','y','xParentPc','yParentPc','xSelfPc','ySelfPc'}) do
                    if current[field]~=e.after[field] then unchanged=false;break end
                end
                if unchanged then e.c.position=e.before.position end
            elseif e.p=='resize' then e.c.size=e.before
            elseif e.p=='height' then e.c.size=e.before
            elseif e.p=='y' then e.c.position=e.before
            elseif e.c[e.p]==e.after then e.c[e.p]=e.before end
        end)
    end
    edits={}
end
local function edit(c,p,value)
    local readable,old=pcall(function() return c[p] end)
    -- Native LABEL proxies expose fewer style setters than plugin ui.Text.
    -- An unknown member can read as nil but rejects writes via __newindex.
    if not readable or old==nil or old==value then return end
    local before=old
    if p=='height' then
        before=ui.Size.new(c.size)
        local after=ui.Size.new(c.size)
        after.height=after.height+value-old
        edits[#edits+1]={c=c,p=p,before=before,after=value}
        c.size=after
    elseif p=='y' then
        before=ui.Pos.new(c.position)
        local after=ui.Pos.new(c.position)
        after.y=after.y+value-old
        edits[#edits+1]={c=c,p=p,before=before,after=value}
        c.position=after
    else
        local ok,err=pcall(function() c[p]=value end)
        if ok then
            edits[#edits+1]={c=c,p=p,before=before,after=value}
        elseif p~='lineSpacing' and p~='isShadowed' and p~='shadowRGBA' then
            error('Cannot set native hover property '..p..': '..tostring(err))
        end
    end
end
-- Native tooltip components use percentage anchors. During our measured
-- layout, place text inside its native parent. The parent itself retains
-- its client-controlled position so it can follow the cursor.
local function box(c,x,y,width,height)
    edits[#edits+1]={c=c,p='rect',before={size=ui.Size.new(c.size),position=ui.Pos.new(c.position)}}
    local parent=c.parent
    local origin=parent and parent.xyGlobal or {x=0,y=0}
    c.size=ui.Size.new(math.ceil(width),math.ceil(height))
    local position=ui.Pos.new(math.floor(x-origin.x),math.floor(y-origin.y))
    edits[#edits].after=ui.Pos.new(position)
    c.position=position
end
local function resize(c,width,height)
    edits[#edits+1]={c=c,p='resize',before=ui.Size.new(c.size)}
    c.size=ui.Size.new(math.ceil(width),math.ceil(height))
end
local function restore()
    nativeFrame.hide()
    undoLayout()
    if applied then
        pcall(function()
            -- Do not overwrite content subsequently replaced by the game.
            if applied.content == written then applied.content = saved end
        end)
    end
    applied,saved,written=nil,nil,nil
end
local function compact(n)
    if n>=1000000 then return string.format('%.2fm',n/1000000) end
    if n>=1000 then return string.format('%.1fk',n/1000) end
    return string.format('%.1f',n):gsub('%.0$','')
end
local function detect(event)
    selected=nil;quantity=nil;selectedName=nil
    if MiniMenu.IsOpen() then restore();return end
    local entries=event.miniMenu.entries
    local e=entries[#entries]
    if not e or not string.lower(e.verbText or ''):find('withdraw',1,true) then restore();return end
    local d=e.componentData
    if not d or not d.objConfig then restore();return end
    local obj=d.objConfig
    local method=catalog.lookup(obj)
    if not method then artefactTrace.log(obj.name,'No catalogue match; object ID '..tostring(obj.id));restore();return end
    local bank=Inventory.Find(config.Inv.BANK)
    local count=bank and bank:GetTotal(obj.id)
    if count and count>0 then
        local options
        local estimate
        estimate,options=methods.estimate(obj,method,bank,count)
        artefactTrace.selection(obj,method,estimate,options,count)
        -- The exact same filtered options drive hover and right-click.
        -- No available method means no plugin section, not a zero-XP warning.
        if (not options or #options==0) and not (estimate and estimate.artefactPreview) then artefactTrace.log(obj.name,'Hover blocked: no eligible options or preview');restore();return end
        selected=estimate;quantity=count
        methods.addMenu(event.miniMenu,obj,options,method)
        selectedName=string.lower(obj.name or "")
    else
        artefactTrace.log(obj.name,'Bank count unavailable: '..tostring(count)..', object ID '..tostring(obj.id))
    end
end
local function paint()
    nativeFrame.hide()
    undoLayout()
    if not selected or MiniMenu.IsOpen() then restore();return end
    -- ID from the user's exported registry. Dynamic children are validated
    -- every frame because the game can reuse these IDs for other content.
    local header=ui.Interfaces:GetComponent(1477,902,0,0)
    local row=ui.Interfaces:GetComponent(1477,902,0,1)
    -- Native dynamic rows may throw for missing IDs, and the options
    -- label may be rendered by the client without literal content text.
    -- Keep the proven slot-2 footer as a fallback; optional rows must never
    -- prevent the XP section from appearing.
    local function optionalRow(i)
        local ok,c=pcall(function() return ui.Interfaces:GetComponent(1477,902,0,i) end)
        if ok then return c end
    end
    local footer=optionalRow(2)
    local candidates,details={},{}
    for i=2,31 do
        pcall(function()
            local c=optionalRow(i)
            if c and c.type==ui.ComponentType.LABEL then
                local plain=(c.content or ''):gsub('<[^>]*>','')
                if c.visibleGlobal and plain:match('^%s*%+%d+%s*options?') then footer=c end
                if c.visibleGlobal and plain:find('%S') then candidates[#candidates+1]=c end
            end
        end)
    end
    for _,c in ipairs(candidates) do if c~=footer then details[#details+1]=c end end
    if not header or not row or not footer then artefactTrace.log(selectedName,'Native layout missing: header='..tostring(header~=nil)..', row='..tostring(row~=nil)..', footer='..tostring(footer~=nil));restore();return end
    if row.type~=ui.ComponentType.LABEL or not row.visibleGlobal then artefactTrace.log(selectedName,'Native details row unavailable: type='..tostring(row.type)..', visible='..tostring(row.visibleGlobal));restore();return end
    local plainTitle=string.gsub(header.content or '', '<[^>]*>', '')
    local title=string.lower(plainTitle)
    title=string.gsub(title,'%s+','')
    local matchingName=string.gsub(selectedName or '', '<[^>]*>', '')
    matchingName=string.gsub(matchingName,'%s+','')
    if not title:find('withdraw',1,true) or not selectedName or selectedName=='' or not title:find(matchingName,1,true) then artefactTrace.log(selectedName,'Native title mismatch: '..tostring(header.content));restore();return end
    local function number(n)
        return string.format('%.0f',n):reverse():gsub('(%d%d%d)','%1,'):reverse():gsub('^,','')
    end
    local total
    if selected.equipmentTotal~=nil then total=compact(selected.equipmentTotal)..' '..selected.skill..' XP (with equipment)'
    elseif selected.outfitTotal~=nil then total=compact(selected.outfitTotal)..' '..selected.skill..' XP (with outfit)'
    elseif selected.outfitMinXP then total=compact(quantity*selected.outfitMinXP)..' - '..compact(quantity*selected.outfitMaxXP)..' '..selected.skill..' XP (with outfit)'
    elseif selected.total~=nil then total=compact(selected.total)..' '..selected.skill..' XP'
    elseif selected.minXP then total=compact(quantity*selected.minXP)..' - '..compact(quantity*selected.maxXP)..' '..selected.skill..' XP'
    else total='Bank XP unavailable' end
    artefactTrace.log(selectedName,'Native tooltip matched; rendering XP section')
    local nativeTextColour=(header.content or ''):match('<col=(%x+)>') or 'e3d7bf'
    local nativeTextTag='<col='..nativeTextColour..'>'
    local lines={
        '<col=f8d56b>'..total..'</col>',
        nativeTextTag..'Method: '..selected.method..'</col>',
        nativeTextTag..'Banked: '..number(quantity)..' '..(selected.unit or 'items')..'</col>',
    }
    if (selected.equipmentTotal or selected.outfitTotal) and selected.total then
        lines[#lines+1]=nativeTextTag..'Base total: '..compact(selected.total)..' XP</col>'
    end
    if selected.craftable~=nil then
        lines[#lines+1]=nativeTextTag..'Can make: '..number(selected.craftable)..' '..(selected.outputUnit or 'potions')..'</col>'
    end
    if selected.xp then
        lines[#lines+1]=nativeTextTag..''..string.format('%.1f',selected.xp):gsub('%.0$','')..(selected.craftable~=nil and (' base XP / '..(selected.xpUnit or 'potion')) or ' base XP each')..'</col>'
    end
    if selected.inputPerPotion and selected.inputPerPotion>1 then
        lines[#lines+1]=nativeTextTag..'Uses '..selected.inputPerPotion..' per '..(selected.xpUnit or 'potion')..'</col>'
    end
    if selected.note then
        -- Pass separate lines to the font layout so height and dividers account
        -- for every requirement, limiter and unlock message.
        for part in selected.note:gmatch('[^|]+') do
            part=part:match('^%s*(.-)%s*$')
            if part~='' then
                -- Explicitly restore the native color after a percentage tag.
                part=part:gsub('(<col=%x+>%+[%d%.]+%%)</col>',function(token) return token..nativeTextTag end)
                local level,body=part:match('^(Lv %d+); (.+)$')
                if level then lines[#lines+1]=nativeTextTag..''..level..'</col>';part=body end
                lines[#lines+1]=nativeTextTag..''..part..'</col>'
            end
        end
    end
    local text=table.concat(lines,'<br>')
    local fontOK,font=pcall(function() return config.Font.FromID(header.font) end)
    if not fontOK or not font then
        -- A font lookup failure should not erase supported XP information.
        -- Keep the native font for drawing; approximate only the bounds.
        local step=math.max(14,header.height)
        font={baseline=step,maxAscent=step-3,maxDescent=3}
        function font:GetStringWidth(value)
            return #(value or ''):gsub('<[^>]*>','')*math.ceil(step*0.55)
        end
        function font:GetStringLineCount(value,width)
            local total=0
            local plain=(value or ''):gsub('<br>','\n'):gsub('<[^>]*>','')
            for line in (plain..'\n'):gmatch('(.-)\n') do
                total=total+math.max(1,math.ceil(self:GetStringWidth(line)/width))
            end
            return total
        end
    end
    local detailText={}
    for _,c in ipairs(details) do detailText[#detailText+1]=hoverLayout.trimTrailingBreaks(c.content) end
    -- Native effects and options can use a smaller font than the heading.
    -- Keep each native row's font/spacing and measure with the same font.
    local fontCache={[header.font]=font}
    local function nativeStyle(c)
        local id=c.font or header.font
        if not fontCache[id] then
            local ok,value=pcall(function() return config.Font.FromID(id) end)
            fontCache[id]=ok and value or font
        end
        local f=fontCache[id] or font
        local step=c.lineSpacing
        return {id=id,font=f,spacing=step and step>0 and step or f.baseline}
    end
    local bodyStyle=nativeStyle(details[1] or footer)
    local footerStyle=nativeStyle(footer)
    local styles={bodyFont=bodyStyle.font,bodySpacing=bodyStyle.spacing,
        footerFont=footerStyle.font,footerSpacing=footerStyle.spacing,details={}}
    for i,c in ipairs(details) do styles.details[i]=nativeStyle(c) end
    local alignment=ui.AlignMode.CENTRE
    -- Some long effect tooltips leave a trailing blank footer line. Keep
    -- options as a single native-colored line, without inherited line breaks.
    local footerText=string.gsub(footer.content or '', '<br%s*/?>', '')
    footerText=string.gsub(footerText,'[\r\n]','')
    local nativeX,nativeY=header.xyGlobal.x,header.xyGlobal.y
    local nativeWidth,nativeHeight=header.width,header.height
    local root=ui.Interfaces:GetComponent(96797568)
    local maxWidth=math.min(440,root and math.max(120,root.width-32) or 440)
    local plan=hoverLayout.plan(font,header.content,lines,detailText,footerText,
        nativeWidth,nativeHeight,maxWidth,header.lineSpacing,header.font,styles)
    local bg=ui.Interfaces:GetComponent(96797572)
    local oldHeight=bg and bg.height or (footer.xyGlobal.y+footer.height-nativeY+12)
    local frameWidth=plan.width+(bg and bg.width-nativeWidth or 16)
    local topInset=bg and nativeY-bg.xyGlobal.y or 6
    local bottomInset=bg and bg.xyGlobal.y+bg.height-footer.xyGlobal.y-footer.height or 6
    -- Native standard footer inset is 8px. Larger values on expanded
    -- potion effects are spare rows, not padding to carry into our layout.
    local frameHeight=plan.height+math.max(4,topInset)+math.min(8,math.max(4,bottomInset))
    local dw=plan.width-nativeWidth
    local dh=frameHeight-oldHeight
    local containers,seen={},{}
    local function addContainer(c)
        if not c then return end
        local key=tostring(c.interfaceID)..':'..tostring(c.staticID)..':'
            ..tostring(c.categoryID)..':'..tostring(c.dynamicID)
        if seen[key] then return end
        seen[key]=true
        containers[#containers+1]={c=c,x=c.xyGlobal.x,y=c.xyGlobal.y,w=c.width,h=c.height}
    end
    local parent=row.parent
    for _=1,10 do
        if not parent or parent.interfaceID~=1477 then break end
        if parent.staticID<899 or parent.staticID>902 then break end
        addContainer(parent);parent=parent.parent
    end
    for _,static in ipairs({902,901,899}) do addContainer(ui.Interfaces:GetComponent(1477,static)) end
    -- Resize clipping containers only. Their positions are owned by the
    -- client's hover/cursor placement and must never be pinned or restored.
    for i=#containers,1,-1 do
        local c=containers[i]
        resize(c.c,math.max(c.w+dw,nativeX+plan.width+8-c.x),
            math.max(c.h+dh,nativeY+plan.height+6-c.y))
    end
    box(header,nativeX,nativeY,plan.width,plan.headerHeight)
    edit(header,'alignHorizontal',alignment)
    box(row,nativeX,nativeY+plan.bodyY,plan.width,plan.bodyHeight)
    edit(row,'font',bodyStyle.id)
    edit(row,'alignHorizontal',alignment)
    edit(row,'alignVertical',ui.AlignMode.TOPLEFT)
    edit(row,'maxLines',0)
    edit(row,'lineSpacing',bodyStyle.spacing)
    for _,p in ipairs({'isShadowed','shadowRGBA'}) do
        local ok,value=pcall(function() return header[p] end)
        if ok and value~=nil then edit(row,p,value) end
    end
    for i,c in ipairs(details) do
        local d=plan.details[i]
        edit(c,'content',detailText[i])
        box(c,nativeX,nativeY+d.y,plan.width,d.height)
        edit(c,'alignVertical',ui.AlignMode.TOPLEFT)
        edit(c,'alignHorizontal',alignment)
        edit(c,'maxLines',0)
    end
    box(footer,nativeX,nativeY+plan.footerY,plan.width,plan.footerHeight)
    edit(footer,'content',footerText)
    edit(footer,'maxLines',1)
    edit(footer,'alignVertical',ui.AlignMode.TOPLEFT)
    if bg then resize(bg,frameWidth,frameHeight) end
    local effectY=plan.detailDividerY and (nativeY+plan.detailDividerY)
    nativeFrame.apply(bg,header,footer,effectY,box,edit)
    local current=row.content or ''
    if current~=text then
        -- Only take ownership of an empty row; don't replace native details.
        if current~='' and current~=written then restore();return end
        applied=row;saved='';written=text
        row.content=text
        if not reported then
            print('[banked-xp] Measured native hover layout active: font metrics, wrapped lines, native details and footer.')
            print('[banked-xp] Middle row size '..row.width..'x'..row.height..'; native background expanded with content.')
            reported=true
        end
    end
end
local function safe(fn,...)
    local ok,err=pcall(fn,...)
    if not ok then
        restore()
        if not warned then print('[banked-xp] Hover layout error: '..tostring(err));warned=true end
    end
end
Event.MiniMenuReady.Subscribe('bankedXpRowSelection',function(e) safe(detect,e) end)
Event.Draw.Subscribe('bankedXpNativeRow',function() safe(paint) end)
Event.MiniMenuOpened.Subscribe('bankedXpRowClear',restore)
function PluginShutdown()
    nativeFrame.destroy()
    if skillHover then pcall(skillHover.restore) end
    restore()
end
print('[banked-xp] 0.108 multi-skill recipe catalog. Hover bank supplies for supported skilling recipes. Base XP only; no XP/hr claim. Move off before disabling.')

-- Temporary read-only discovery for extending the item catalog.
-- Diagnostics retained in the folder; disabled during ordinary use.
-- require("diagnostics")
