-- Use only the existing native 1477:923 components observed in the probe.
-- No native UI children are allocated, destroyed, or moved in the child list.
local M={}
local summary=require('skill_summary')
local edits={}
local key,cachedWidth
local function get(i)
 local ok,c=pcall(function() return ui.Interfaces:GetComponent(1477,923,0,i) end)
 return ok and c or nil
end
local function plain(text)
 local value=(text or ''):gsub('<[^>]*>','')
 return value
end
local function positionEquals(a,b)
 for _,k in ipairs({'x','y','xParentPc','yParentPc','xSelfPc','ySelfPc'}) do if a[k]~=b[k] then return false end end
 return true
end
function M.restore()
 for i=#edits,1,-1 do
  local e=edits[i]
  pcall(function()
   if e.kind=='box' then
    if e.c.size.width==e.afterSize.width and e.c.size.height==e.afterSize.height then e.c.size=e.size end
    if positionEquals(e.c.position,e.afterPosition) then e.c.position=e.position end
   elseif e.kind=='size' then
    if e.c.size.width==e.after.width and e.c.size.height==e.after.height then e.c.size=e.before end
   elseif e.c[e.field]==e.after then e.c[e.field]=e.before end
  end)
 end
 edits={}
end
local function field(c,name,value)
 local ok,before=pcall(function() return c[name] end)
 if not ok or before==nil then return end
 local success=pcall(function() c[name]=value end)
 if success then edits[#edits+1]={c=c,field=name,before=before,after=value} end
end
local function box(c,x,y,w,h)
 local beforeSize,beforePosition=ui.Size.new(c.size),ui.Pos.new(c.position)
 local origin=c.parent and c.parent.xyGlobal or {x=0,y=0}
 local afterSize=ui.Size.new(math.ceil(w),math.ceil(h))
 local afterPosition=ui.Pos.new(math.floor(x-origin.x),math.floor(y-origin.y))
 edits[#edits+1]={kind='box',c=c,size=beforeSize,position=beforePosition,afterSize=afterSize,afterPosition=afterPosition}
 c.size=afterSize;c.position=afterPosition
end
-- Total-XP uses a shorter native tooltip. Recognize its actual text rather
-- than assuming the per-skill caption/value child IDs are present.
local totalScopes={{1477,923},{1477,904},{1477,902},{1477,897},{1477,898},{1477,924},{320,16}}
local totalScope,totalDraws=nil,0
local function scopedGet(scope,id)
 local ok,c=pcall(function()
  if id==nil then return ui.Interfaces:GetComponent(scope[1],scope[2]) end
  return ui.Interfaces:GetComponent(scope[1],scope[2],0,id)
 end)
 return ok and c or nil
end
local function paintTotal(scope)
 local found,last,pair
 local components={}
 for id=-1,64 do
  local c=scopedGet(scope,id>=0 and id or nil)
  if c and c.visibleGlobal then
   local ok,content=pcall(function() return c.content end)
   if ok and type(content)=='string' then
    local text=plain(content)
    components[#components+1]={c=c,text=text,id=id}
    if text:find('Total XP:',1,true) then found=c end
   end
  end
 end
 if not found then return false end

 local root=found.parent
 if not root then return false end
 last=found
 for _,record in ipairs(components) do
  if record.c.parent==root and record.text:match('^%s*Bonus XP:') and record.c.xyGlobal.y>=last.xyGlobal.y then last=record.c end
 end
 -- A caption-only row has a numeric partner at the next native child ID.
 for _,record in ipairs(components) do
  if record.c==last and record.text:match('^%s*[%a%s]+:%s*$') then
   local v=scopedGet(scope,record.id+1)
   if v and v.visibleGlobal and v.parent==root and plain(v.content):match('^%s*[%d,%.]+%s*$') then pair=v end
  end
 end
 local frame={}
 for id=0,8 do
  frame[id]=scopedGet(scope,id)
  if not frame[id] or not frame[id].visibleGlobal then

   return false
  end
 end
 -- Accept only the segmented frame shape already established in the client.
 for id=1,4 do
  if frame[id].width~=10 or frame[id].height~=10 then

   return false
  end
 end
 local x,y=frame[1].xyGlobal.x,frame[1].xyGlobal.y
 local w=frame[2].xyGlobal.x+frame[2].width-x
 local h=frame[3].xyGlobal.y+frame[3].height-y
 if w<80 or w>600 or h<20 or h>200 then return false end
 totalScope=scope

 local amount=summary.totalLine():gsub('^Banked XP:%s*','')
 local firstLine=found.content:match('^(.-)<[bB][rR]') or found.content
 local neutral=firstLine:match('<col=(%x+)>') or 'e3d7bf'
 local tag='<col='..neutral..'>'
 local shown=tag..amount..'</col>'
 if summary.missingStorage('Total') and amount:match('^[%d,%.]+$') then shown='<col=ff0000>'..amount..'</col>' end
 local font=config.Font.FromID(found.font)
 if not font then return false end
 local measureKey='total:'..w..':'..found.font..':'..amount
 if measureKey~=key then cachedWidth=math.max(w,font:GetStringWidth('Banked XP:')+font:GetStringWidth(amount)+20);key=measureKey end
 local lastY,lastH=last.xyGlobal.y,last.height
 local pairY,pairH=pair and pair.xyGlobal.y,pair and pair.height
 local valueText=pair and pair.content
 local lastText=last.content
 local growth=19 -- one native 15px row plus 4px bottom space
 local before=ui.Size.new(root.size)
 local after=ui.Size.new(root.size);after.width=after.width+cachedWidth-w;after.height=after.height+growth
 edits[#edits+1]={kind='size',c=root,before=before,after=after}
 local ox,oy=root.xyGlobal.x,root.xyGlobal.y;root.size=after
 local dx,dy=root.xyGlobal.x-ox,root.xyGlobal.y-oy
 x=x+dx;y=y+dy
 local bounds=require('native_frame').plan(cachedWidth,h+growth);bounds[0]={1,1,cachedWidth-2,h+growth-2}
 for id=0,8 do local b=bounds[id];box(frame[id],x+b[1],y+b[2],b[3],b[4]) end
 box(last,x+6,lastY+dy,cachedWidth-12,lastH+15)
 field(last,'maxLines',0);field(last,'alignVertical',0)
 field(last,'content',lastText..'<br>'..tag..'Banked XP:'..(pair and '</col>' or (' '..shown..'</col>')))
 if pair then
  box(pair,x+6,pairY+dy,cachedWidth-14,pairH+15)
  field(pair,'maxLines',0);field(pair,'alignVertical',0)
  field(pair,'content',valueText..'<br>'..shown)
 end
 return true
end

-- The exported registry also defines TEXT_TOOLTIP (1486), distinct from
-- the shared per-skill tooltip. Its native RS3 artwork uses static sprites.
local function paintTextTotal()
 local function static(id)
  local ok,c=pcall(function() return ui.Interfaces:GetComponent(1486,id) end)
  return ok and c or nil
 end
 local body
 -- Client capture: actual text is 1486:14:0:0 (font 27, 125x32),
 -- while static 15 is a zero-sized template containing 'Tooltip text'.
 local candidates={}
 local ok,dynamic=pcall(function() return ui.Interfaces:GetComponent(1486,14,0,0) end)
 if ok and dynamic then candidates[#candidates+1]=dynamic end
 for _,id in ipairs({15,14}) do local c=static(id);if c then candidates[#candidates+1]=c end end
 for _,c in ipairs(candidates) do
  local readable,text=pcall(function() return c.content end)
  if c.visibleGlobal and c.width>0 and c.height>0 and readable and type(text)=='string' and plain(text):find('Total XP:',1,true) then body=c;break end
 end
 if not body then return false end

 local sprites={}
 for id=16,33 do
  local c=static(id)
  if id~=25 and c and c.visibleGlobal and c.width>0 and c.height>0 then
   sprites[#sprites+1]={id=id,c=c,x=c.xyGlobal.x,y=c.xyGlobal.y,w=c.width,h=c.height}
  end
 end
 if #sprites<8 then

  return false
 end
 local font=config.Font.FromID(body.font)
 if not font then return false end
 local raw=body.content
 local firstLine=raw:match('^(.-)<[bB][rR]') or raw
 local neutral=firstLine:match('<col=(%x+)>') or 'e3d7bf'
 local amount=summary.totalLine():gsub('^Banked XP:%s*','')
 local tag='<col='..neutral..'>'
 local shown=tag..amount..'</col>'
 if summary.missingStorage('Total') and amount:match('^[%d,%.]+$') then shown='<col=ff0000>'..amount..'</col>' end
 local text=raw..'<br>'..tag..'Banked XP: '..shown..'</col>'
 local lineWidth=font:GetStringWidth('Banked XP: '..amount)
 local dw=math.max(0,math.ceil(lineWidth+2-body.width))
 local lineHeight=15
 local ok,fh=pcall(function() return font:GetStringHeight() end)
 if ok and type(fh)=='number' and fh>=10 and fh<=30 then lineHeight=fh end
 local measured,lines=pcall(function() return font:GetStringLineCount(raw,body.width) end)
 if measured and type(lines)=='number' and lines>=1 then
  local nativeStep=body.height/lines
  if nativeStep>=10 and nativeStep<=30 then lineHeight=math.ceil(nativeStep) end
 end
 local growth=lineHeight -- preserve the native top/bottom inset; no added bottom padding
 local textX,textY,textW,textH=body.xyGlobal.x,body.xyGlobal.y,body.width,body.height
 local layers={}
 for _,id in ipairs({0,1,11,12,13,14}) do
  local c=static(id)
  if c and c~=body and c.visibleGlobal then layers[#layers+1]={c=c,size=ui.Size.new(c.size)} end
 end
 local anchor=static(1) or body.parent
 local ax,ay=anchor.xyGlobal.x,anchor.xyGlobal.y
 for _,entry in ipairs(layers) do
  local after=ui.Size.new(entry.size);after.width=after.width+dw;after.height=after.height+growth
  edits[#edits+1]={kind='size',c=entry.c,before=entry.size,after=after}
  entry.c.size=after
 end
 local dx,dy=anchor.xyGlobal.x-ax,anchor.xyGlobal.y-ay
 -- Static 16..24: NW,N,NE,W,centre,E,SW,S,SE.
 -- Static 26..33: NW,N,NE,W,E,SW,S,SE.
 local right={[18]=true,[21]=true,[24]=true,[28]=true,[30]=true,[33]=true}
 local bottom={[22]=true,[23]=true,[24]=true,[31]=true,[32]=true,[33]=true}
 local stretchW={[17]=true,[20]=true,[23]=true,[27]=true,[32]=true}
 local stretchH={[19]=true,[20]=true,[21]=true,[29]=true,[30]=true}
 for _,v in ipairs(sprites) do
  box(v.c,v.x+dx+(right[v.id] and dw or 0),v.y+dy+(bottom[v.id] and growth or 0),v.w+(stretchW[v.id] and dw or 0),v.h+(stretchH[v.id] and growth or 0))
 end
 box(body,textX+dx,textY+dy,textW+dw,textH+lineHeight)
 field(body,'maxLines',0);field(body,'alignVertical',0);field(body,'content',text)

 return true
end

function M.paint()
 M.restore()
 if MiniMenu.IsOpen() then return end
 if summary.totalLine then
  if paintTextTotal() then return end
  totalDraws=totalDraws+1
  if totalScope and paintTotal(totalScope) then return end
  -- Probe alternate exported roots only while not rendering a total hover.
  -- One bounded discovery pass every ten draws; a found scope is reused.
  if totalDraws%10==1 then
   for _,scope in ipairs(totalScopes) do
    if scope~=totalScope and paintTotal(scope) then return end
   end
  end
 end
 local heading,current,currentValue,remainder,remainderValue=get(9),get(10),get(11),get(14),get(15)
 if not heading or not current or not currentValue or not remainder or not remainderValue then return end
 if not heading.visibleGlobal or not current.visibleGlobal or not remainder.visibleGlobal then return end
 local skill=plain(heading.content):match('^%s*(%a+):%s*%d+%s*/%s*%d+')
 if not skill or not summary.supports(skill) then return end
 if not plain(current.content):match('^%s*Current XP:%s*$') or not plain(remainder.content):match('^%s*Remainder:%s*$') then return end
 local function numeric(c) return c and c.visibleGlobal and plain(c.content):match('^%s*[%d,%.]+%s*$') end
 if not numeric(currentValue) or not numeric(remainderValue) then return end
 local root=current.parent
 if not root or root~=currentValue.parent then return end
 local frame={}
 for i=0,8 do frame[i]=get(i);if not frame[i] or not frame[i].visibleGlobal then return end end
 local x,y=frame[1].xyGlobal.x,frame[1].xyGlobal.y
 local w=frame[2].xyGlobal.x+frame[2].width-x
 local h=frame[3].xyGlobal.y+frame[3].height-y
 if w<80 or w>600 or h<40 or h>300 then return end
 local pairsToClear={{current,currentValue},{remainder,remainderValue}}
 local oldLast=math.max(current.xyGlobal.y,remainder.xyGlobal.y)
 local occupied={[9]=true,[10]=true,[11]=true,[14]=true,[15]=true}
 local originals={{current.content,currentValue.content,y=current.xyGlobal.y},{remainder.content,remainderValue.content,y=remainder.xyGlobal.y}}
 local firstTarget
 local native={}
 for i=12,48 do native[i]=get(i) end
 local i=12
 while i<=47 do
  local c,v=native[i],native[i+1]
  if not occupied[i] and c and c.visibleGlobal and c.parent==root and numeric(v) and v.parent==root then
   local label=plain(c.content):lower():match('^%s*(.-)%s*$')
   local isBonus=label=='bonus xp:'
   local isTarget=label:match('^target.*:')~=nil
   if label:match(':$') then
    pairsToClear[#pairsToClear+1]={c,v};occupied[i]=true;occupied[i+1]=true
    oldLast=math.max(oldLast,c.xyGlobal.y,v.xyGlobal.y)
    local text=isBonus and ('<col=00ff00>'..plain(v.content)..'</col>') or v.content
    originals[#originals+1]={c.content,text,y=c.xyGlobal.y}
    if isTarget then firstTarget=math.min(firstTarget or c.xyGlobal.y,c.xyGlobal.y) end
    i=i+1
   end
  end
  i=i+1
 end
 table.sort(originals,function(a,b) return a.y<b.y end)
 local amount=summary.tooltipLine(skill):gsub('^Banked XP:%s*','')
 if amount:find('open your bank',1,true) then amount='Scan bank' end
 if amount:find('calculating',1,true) then amount='Calculating...' end
 if summary.missingStorage and summary.missingStorage(skill) and amount:match('^[%d,%.%s%-]+$') then amount='<col=ff0000>'..amount..'</col>' end
 local rows={}
 local inserted=false
 local extra=summary.tooltipExtra and summary.tooltipExtra(skill)
 local function insertBanked()
  rows[#rows+1]={'Banked XP:',amount}
  if extra then rows[#rows+1]={'Ready XP:',extra} end
  inserted=true
 end
 for _,row in ipairs(originals) do
  if firstTarget and row.y>=firstTarget and not inserted then insertBanked() end
  rows[#rows+1]=row
 end
 if not inserted then insertBanked() end
 local font=config.Font.FromID(current.font)
 if not font then return end
 local neutral=currentValue.content:match('<col=(%x+)>') or current.content:match('<col=(%x+)>') or heading.content:match('<col=(%x+)>') or 'e3d7bf'
 local captions,values,measureParts={},{},{tostring(w),tostring(current.font)}
 for _,row in ipairs(rows) do
  captions[#captions+1]=row[1]
  -- Native Bonus XP may use an unclosed colour tag or a separate colour
  -- property. Reset each value independently so colours cannot cross rows.
  values[#values+1]='<col='..neutral..'>'..row[2]..'</col>'
  measureParts[#measureParts+1]=plain(row[1])..'|'..plain(row[2])
 end
 local measureKey=table.concat(measureParts,';')
 if measureKey~=key then
  cachedWidth=w
  for _,row in ipairs(rows) do cachedWidth=math.max(cachedWidth,font:GetStringWidth(plain(row[1]))+font:GetStringWidth(plain(row[2]))+20) end
  key=measureKey
 end
 local step=15
 local startY=current.xyGlobal.y
 local delta=startY+(#rows-1)*step-oldLast
 -- Capture lower siblings before resizing. Move existing target progress
 -- components as a group; never create or modify their children.
 local lower={}
 for id=12,48 do
  local c=native[id]
  if not occupied[id] and c and c.visibleGlobal and c.parent==root and c.xyGlobal.y>oldLast then
   lower[#lower+1]={c=c,x=c.xyGlobal.x,y=c.xyGlobal.y,w=c.width,h=c.height}
  end
 end
 local progressGap=#lower>0 and 4 or 0
 local bottomPadding=4
 local growth=delta+progressGap+bottomPadding
 local before=ui.Size.new(root.size)
 local after=ui.Size.new(root.size);after.width=after.width+(cachedWidth-w);after.height=after.height+growth
 edits[#edits+1]={kind='size',c=root,before=before,after=after}
 local oldX,oldY=root.xyGlobal.x,root.xyGlobal.y
 root.size=after
 local dx,dy=root.xyGlobal.x-oldX,root.xyGlobal.y-oldY
 x=x+dx;y=y+dy;startY=startY+dy
 local bounds=require('native_frame').plan(cachedWidth,h+growth)
 bounds[0]={1,1,cachedWidth-2,h+growth-2}
 for id=0,8 do local b=bounds[id];box(frame[id],x+b[1],y+b[2],b[3],b[4]) end
 for _,pair in ipairs(pairsToClear) do field(pair[1],'content','');field(pair[2],'content','') end
 box(current,x+6,startY,cachedWidth-12,#rows*step+1)
 box(currentValue,x+6,startY,cachedWidth-14,#rows*step)
 field(current,'maxLines',0);field(currentValue,'maxLines',0)
 field(current,'alignVertical',0);field(currentValue,'alignVertical',0)
 field(current,'content',table.concat(captions,'<br>'))
 field(currentValue,'content',table.concat(values,'<br>'))
 for _,v in ipairs(lower) do box(v.c,v.x+dx,v.y+dy+delta+progressGap,v.w,v.h) end
end
function M.register()
 summary.register()
 Event.Draw.Subscribe('bankedXpSkillTotals',function()
  local ok,err=pcall(M.paint)
  if not ok then M.restore();if not M.warned then print('[BXP skill] Display error: '..tostring(err));M.warned=true end end
 end)
 if Event.MiniMenuOpened then Event.MiniMenuOpened.Subscribe('bankedXpSkillTotalsClear',M.restore) end
end
return M
