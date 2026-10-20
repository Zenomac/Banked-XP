-- Native middle-row layout 0.49. Native cursor positioning is preserved.
-- Temporarily expands the native tooltip row and moves its footer below it.
-- Reversible layout edits are undone before each frame and on exit.
require('storage').register()
local selected, applied, saved, written = nil, nil, nil, nil
local quantity=nil
local selectedName=nil
local selectedID=nil
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
local warned = false
local edits={}
local nativeGeometry
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
local function restore(preserveNativeText)
    local currentText={}
    if preserveNativeText==true then
        for _,e in ipairs(edits) do
            if e.p=='content' then currentText[e.c]=e.c.content end
        end
    end
    nativeGeometry=nil
    nativeFrame.hide()
    undoLayout()
    if applied then
        pcall(function()
            -- Do not overwrite content subsequently replaced by the game.
            if applied.content == written then applied.content = saved end
        end)
    end
    applied,saved,written=nil,nil,nil
    for c,value in pairs(currentText) do c.content=value end
end
local function compact(n)
    if n>=1000000 then return string.format('%.2fm',n/1000000) end
    if n>=1000 then return string.format('%.1fk',n/1000) end
    return string.format('%.1f',n):gsub('%.0$','')
end
local function detect(event)
    local previousID=selectedID
    selected=nil;quantity=nil;selectedName=nil;selectedID=nil
    if MiniMenu.IsOpen() then restore();return end
    local entries=event.miniMenu.entries
    local e=entries[#entries]
    if not e or not string.lower(e.verbText or ''):find('withdraw',1,true) then restore();return end
    local d=e.componentData
    if not d or not d.objConfig then restore();return end
    local obj=d.objConfig
    if obj.id~=previousID then restore(true) end
    local method=catalog.lookup(obj)
    if not method then restore();return end
    local bank=Inventory.Find(config.Inv.BANK)
    local count=bank and bank:GetTotal(obj.id)
    if count and count>0 then
        local options
        local estimate
        estimate,options=methods.estimate(obj,method,bank,count)

        -- The exact same filtered options drive hover and right-click.
        -- Explicit informational previews may render without selectable recipes.
        if (not options or #options==0) and not (estimate and (estimate.artefactPreview or estimate.levelPreview or estimate.ingredientPreview)) then restore();return end
        selected=estimate;quantity=count;selectedID=obj.id
        methods.addMenu(event.miniMenu,obj,options,method)
        selectedName=string.lower(obj.name or "")
    else

    end
end
local function paint()
    nativeFrame.hide()
    undoLayout()
    if not selected or MiniMenu.IsOpen() then restore();return end
    -- ID from the user's exported registry. Dynamic children are validated
    -- every frame because the game can reuse these IDs for other content.
    local header=ui.Interfaces:GetComponent(1477,902,0,0)
    local rowOK,row=pcall(function() return ui.Interfaces:GetComponent(1477,902,0,1) end)
    if not rowOK then row=nil end
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
    if not header or not row or not footer then restore();return end
    if row.type~=ui.ComponentType.LABEL or not row.visibleGlobal then restore();return end
    -- Reuse only a visible native label. A tradeable suffix is preserved in
    -- that same label above XP; never create, unhide or reparent a component.
    local normalizedName=require('bank').normalize(selectedName)
    local tradeableAnima=normalizedName:match('^resonant anima of .+ %(tradeable%)$')~=nil
    local originalRow=(applied==row and row.content==written) and saved or (row.content or '')
    local suffix=require('bank').normalize(originalRow)
    local continuation=tradeableAnima and (suffix=='(tradeable)' or suffix=='(tradable)')
    if originalRow~='' and not continuation then restore();return end
    local plainTitle=require('bank').normalize((header.content or '')..(continuation and (' '..originalRow) or ''))
    local title=string.lower(plainTitle)
    title=string.gsub(title,'%s+','')
    local matchingName=require('bank').normalize(selectedName)
    matchingName=string.gsub(matchingName,'%s+','')
    if not title:find('withdraw',1,true) or not selectedName or selectedName=='' or not title:find(matchingName,1,true) then restore();return end
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
    if continuation then table.insert(lines,1,originalRow) end
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
    -- The client may relayout its rows between draws using our expanded
    -- parent. Keep one unmodified geometry baseline per native tooltip.
    local geometryKey=table.concat({selectedName or '',header.content or '',tostring(header.font),table.concat(detailText,'\0')},'\1')
    if not nativeGeometry or nativeGeometry.key~=geometryKey then
        nativeGeometry={key=geometryKey,width=header.width,height=header.height,containers={}}
    end
    local nativeWidth,nativeHeight=nativeGeometry.width,nativeGeometry.height
    local root=ui.Interfaces:GetComponent(96797568)
    local maxWidth=math.min(440,root and math.max(120,root.width-32) or 440)
    local plan=hoverLayout.plan(font,header.content,lines,detailText,footerText,
        nativeWidth,nativeHeight,maxWidth,header.lineSpacing,header.font,styles)
    -- Equipment details can contain native columns and precisely spaced rows.
    -- Translate the block intact rather than stacking/recentering every label.
    local preserveDetails=selected.skill~='Herblore' and #details>0
    local detailOriginX,detailOriginY,detailBottom,detailWidth
    local detailBounds={}
    if preserveDetails then
        detailOriginX,detailOriginY,detailBottom=math.huge,math.huge,-math.huge
        for i,c in ipairs(details) do
            local xy=c.xyGlobal
            local bounds={x=xy.x,y=xy.y,width=c.width,height=c.height}
            detailBounds[i]=bounds
            detailOriginX=math.min(detailOriginX,bounds.x)
            detailOriginY=math.min(detailOriginY,bounds.y)
            detailBottom=math.max(detailBottom,bounds.y+bounds.height)
        end
        if nativeGeometry.details then
            detailBounds=nativeGeometry.details.bounds
            detailOriginX=nativeGeometry.details.x
            detailOriginY=nativeGeometry.details.y
            detailBottom=nativeGeometry.details.bottom
        else
            nativeGeometry.details={bounds=detailBounds,x=detailOriginX,y=detailOriginY,bottom=detailBottom}
        end
        -- The layout plan is cached; copy before adjusting native block bounds.
        local adjusted={};for k,v in pairs(plan) do adjusted[k]=v end;plan=adjusted
        local start=plan.details[1].y
        plan.footerY=start+(detailBottom-detailOriginY)+6
        plan.height=plan.footerY+plan.footerHeight
        local right=0
        for _,b in ipairs(detailBounds) do right=math.max(right,b.x-detailOriginX+b.width) end
        detailWidth=right
        plan.width=math.max(plan.width,right)
    end
    local bg=ui.Interfaces:GetComponent(96797572)
    local oldHeight=bg and bg.height or (footer.xyGlobal.y+footer.height-nativeY+12)
    if not nativeGeometry.frameInset then
        nativeGeometry.frameInset=math.min(32,math.max(8,bg and bg.width-nativeWidth or 16))
    end
    local frameWidth=plan.width+nativeGeometry.frameInset
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
        local baseline=nativeGeometry.containers[key]
        if not baseline then
            baseline={w=c.width,h=c.height,left=nativeX-c.xyGlobal.x,top=nativeY-c.xyGlobal.y}
            nativeGeometry.containers[key]=baseline
        end
        containers[#containers+1]={c=c,x=nativeX-baseline.left,y=nativeY-baseline.top,w=baseline.w,h=baseline.h}
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
        if preserveDetails then
            -- Parents were resized above. Reading live percentage-anchored
            -- geometry here would apply their expansion a second time.
            local b=detailBounds[i]
            local centeredInset=(plan.width-detailWidth)/2
            box(c,nativeX+centeredInset+b.x-detailOriginX,
                nativeY+plan.details[1].y+b.y-detailOriginY,b.width,b.height)
            -- Center full-width prose rows, retaining native stat columns.
            if b.width>=detailWidth-2 then edit(c,'alignHorizontal',alignment) end
        else
            edit(c,'content',detailText[i])
            box(c,nativeX,nativeY+d.y,plan.width,d.height)
            edit(c,'alignVertical',ui.AlignMode.TOPLEFT)
            edit(c,'alignHorizontal',alignment)
            edit(c,'maxLines',0)
        end
    end
    box(footer,nativeX,nativeY+plan.footerY,plan.width,plan.footerHeight)
    edit(footer,'content',footerText)
    edit(footer,'maxLines',1)
    edit(footer,'alignVertical',ui.AlignMode.TOPLEFT)
    if bg then resize(bg,frameWidth,frameHeight) end
    local effectY=plan.detailDividerY and (nativeY+plan.detailDividerY)
    nativeFrame.apply(bg,header,footer,effectY,box,edit,tradeableAnima)
    local current=row.content or ''
    if current~=text then
        -- Only take ownership of an empty row; don't replace native details.
        if current~=originalRow and current~=written then restore();return end
        applied=row;saved=originalRow;written=text
        row.content=text
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
