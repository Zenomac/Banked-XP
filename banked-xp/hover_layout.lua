-- Pure sizing: all font metrics come from the current native header font.
local M={}
local lastKey,lastPlan
function M.trimTrailingBreaks(text)
    -- Tokenize the tail rather than assuming one specific break spelling.
    -- Preserve formatting tags and all internal spacing/visible stat lines.
    text=text or ''
    local tokens={}
    local i=1
    while i<=#text do
        local token=text:match('^<[^>]*>',i)
            or text:match('^&[Nn][Bb][Ss][Pp];',i)
        if not token then
            if text:sub(i,i+1)=='\194\160' then token=text:sub(i,i+1)
            else token=text:sub(i,i) end
        end
        tokens[#tokens+1]=token;i=i+#token
    end
    local tail=true
    for j=#tokens,1,-1 do
        local token=tokens[j]
        local lower=token:lower()
        if tail then
            if token:match('^%s+$') or token=='\194\160' or lower=='&nbsp;'
                or lower:match('^<br%s*/?%s*>$') then tokens[j]=''
            elseif not token:match('^<[^>]*>$') then tail=false end
        end
    end
    return table.concat(tokens)
end
local function measured(font,text)
    return font:GetStringWidth(text or '',false)
end
local function height(font,text,width,spacing)
    local lines=math.max(1,font:GetStringLineCount(text or '',width,false))
    return math.ceil(font.maxAscent+font.maxDescent+(lines-1)*spacing+2)
end
function M.plan(font,title,body,details,footer,nativeWidth,nativeHeight,maxWidth,lineSpacing,fontID,styles)
    local spacing=lineSpacing and lineSpacing>0 and lineSpacing or font.baseline
    spacing=math.max(1,spacing)
    styles=styles or {}
    local bodyFont=styles.bodyFont or font
    local bodySpacing=styles.bodySpacing or spacing
    local footerFont=styles.footerFont or font
    local footerSpacing=styles.footerSpacing or spacing
    local detailStyles=styles.details or {}
    local styleKey={tostring(bodyFont),tostring(bodySpacing),tostring(footerFont),tostring(footerSpacing)}
    for _,v in ipairs(detailStyles) do styleKey[#styleKey+1]=tostring(v.font)..':'..tostring(v.spacing) end
    local key=table.concat({tostring(fontID or font),tostring(font.baseline),tostring(font.maxAscent),
        tostring(font.maxDescent),tostring(spacing),tostring(nativeWidth),tostring(nativeHeight),
        table.concat(styleKey,':'),tostring(maxWidth),title or '',table.concat(body,'<br>'),table.concat(details,'<br>'),footer or ''},'\0')
    if key==lastKey then return lastPlan end
    local natural=measured(font,title)
    for _,line in ipairs(body) do natural=math.max(natural,measured(bodyFont,line)) end
    for i,detail in ipairs(details) do natural=math.max(natural,measured(detailStyles[i] and detailStyles[i].font or font,detail)) end
    natural=math.max(natural,measured(footerFont,footer))
    local width=math.min(math.max(100,maxWidth or 440),math.max(120,nativeWidth,natural+4))
    width=math.ceil(width)
    local headHeight=math.max(height(font,title,width,spacing),math.min(nativeHeight,spacing+6))
    local y=headHeight+7 -- rule below title, then a clear text inset
    local plan={width=width,headerHeight=headHeight,bodyY=y,spacing=spacing}
    plan.bodyHeight=height(bodyFont,table.concat(body,'<br>'),width,bodySpacing)
    y=y+plan.bodyHeight
    plan.details={}
    if #details>0 then
        plan.detailDividerY=y+3
        y=y+6 -- dedicated rule gap before the first native effect line
    end
    for i,text in ipairs(details) do
        y=y+3
        local style=detailStyles[i]
        local h=height(style and style.font or font,text,width,style and style.spacing or spacing)
        plan.details[#plan.details+1]={y=y,height=h}
        y=y+h
    end
    y=y+(#details>0 and 6 or 7) -- compact effect/footer gap, clear of descenders
    plan.footerY=y
    plan.footerHeight=height(footerFont,footer,width,footerSpacing)
    plan.height=y+plan.footerHeight
    lastKey,lastPlan=key,plan
    return plan
end
return M
