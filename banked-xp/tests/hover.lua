package.path='./?.lua;banked-xp/?.lua;'..package.path
local nativeCoroutine=coroutine
coroutine=setmetatable({}, {__index=function() error('client path must not use coroutines',0) end})
-- The client binding rejects extra arguments that stock Lua ignores.
local nativeLower=string.lower
string.lower=function(value,...)
 assert(select('#',...)==0,'client string.lower received extra arguments')
 return nativeLower(value)
end
-- Exercise existing behavior with unowned recipes explicitly enabled.
package.loaded.settings={showRecipeOnHover=function() return true end,showUnownedIngredients=function() return true end,showUnderlevelRecipes=function() return true end,showBoostableRecipes=function() return false end}
package.loaded.skill_hover={register=function() end,restore=function() end}
local callbacks={};Event={}
local borderWrites,widthCalls,lineCalls=0,0,0
for _,name in ipairs({'MiniMenuReady','Draw','MiniMenuOpened'}) do Event[name]={Subscribe=function(_,fn) callbacks[name]=fn end} end
local function clone(t) local c={};for k,v in pairs(t) do c[k]=v end;return c end
ui={Pos={new=function(x,y) if type(x)=='table' then return clone(x) end;return {x=x or 0,y=y or 0,xParentPc=0,yParentPc=0,xSelfPc=0,ySelfPc=0} end},Size={new=function(w,h) if type(w)=='table' then return clone(w) end;return {width=w or 0,height=h or 0,widthParentPc=0,heightParentPc=0} end},AlignMode={TOPLEFT=0,CENTRE=1},ComponentType={LABEL=2,SPRITE=3},Interfaces={}}
local function component(id,parent,x,y,w,h)
 local c={interfaceID=1477,staticID=id,categoryID=0,dynamicID=-1,parent=parent,position=ui.Pos.new(x,y),size=ui.Size.new(w,h),hidden=false}
 function c:SetPos(x,y) if self.staticID==998 then borderWrites=borderWrites+1 end;self.position=ui.Pos.new(x,y) end
 function c:SetSize(w,h) if self.staticID==998 then borderWrites=borderWrites+1 end;self.size=ui.Size.new(w,h) end
 function c:MoveToFront() end
 function c:MoveToBack() self.back=true end
 function c:Destroy() self.destroyed=true end
 return setmetatable(c,{__newindex=function(c,k,v)
  if k=='lineSpacing' then error('sol: cannot set (new_index) into this object: no defined new_index operation on usertype') end
  rawset(c,k,v)
 end,__index=function(c,k)
  if k=='lineSpacing' and rawget(c,'readonlySpacing') then return 0 end
  if k=='width' then return c.size.width+(c.parent and c.parent.width or 0)*(c.size.widthParentPc or 0) end
  if k=='height' then return c.size.height+(c.parent and c.parent.height or 0)*(c.size.heightParentPc or 0) end
  if k=='xyGlobal' then
   local p=c.position;local par=c.parent;local origin=par and par.xyGlobal or {x=0,y=0}
   return {x=origin.x+p.x+(par and par.width or 0)*(p.xParentPc or 0)+c.width*(p.xSelfPc or 0),y=origin.y+p.y+(par and par.height or 0)*(p.yParentPc or 0)+c.height*(p.ySelfPc or 0)}
  end
  if k=='visibleGlobal' then return not c.hidden and (not c.parent or c.parent.visibleGlobal) end
 end})
end
local root=component(896,nil,0,0,1000,800)
local bubble=component(899,root,100,100,200,80)
local bg=component(900,bubble,0,0,200,80)
local decoration=component(901,bubble,0,0,200,80)
local nativeParts={}
for i=0,8 do
 nativeParts[i]=component(900,bg,0,0,10,10);nativeParts[i].type=i==0 and 1 or 3;nativeParts[i].dynamicID=i
end
local nativeRules={}
for i=0,1 do
 nativeRules[i]=component(901,decoration,0,23+i*40,312,2)
 nativeRules[i].dynamicID=i;nativeRules[i].type=3;nativeRules[i].spriteID=35516
end
-- Match the client: dynamic separators exist but iteration is unavailable.

local props=component(902,bubble,8,6,184,68)
local labels={}
for i=0,3 do labels[i]=component(902,props,0,i*18,184,i==1 and 8 or 16);labels[i].dynamicID=i;labels[i].type=2;labels[i].font=12;labels[i].alignHorizontal=0;labels[i].alignVertical=1;rawset(labels[i],'lineSpacing',nil) end
labels[0].content='Withdraw-All Prayer potion (4)'
labels[1].content=''
labels[2].alignHorizontal=2
labels[2].content='+7 options';labels[2].position=ui.Pos.new(0,0,0,1);labels[2].position.yParentPc=1;labels[2].position.ySelfPc=-1
labels[3].content='Restores <col=00ff00>317</col> prayer points.'
local originalFooter=clone(labels[2].position)
local function strip(s) return s:gsub('<br>','\n'):gsub('<[^>]*>','') end
local font={baseline=16,maxAscent=10,maxDescent=3}
function font:GetStringWidth(s) widthCalls=widthCalls+1;local longest=0;for line in (strip(s)..'\n'):gmatch('(.-)\n') do longest=math.max(longest,#line*6) end;return longest end
function font:GetStringLineCount(s,width) lineCalls=lineCalls+1;local n=0;for line in (strip(s)..'\n'):gmatch('(.-)\n') do n=n+math.max(1,math.ceil(#line*6/width)) end;return n end
config={Font={FromID=function(id) assert(id==12);return font end},Inv={BANK=1}}
function ui.Interfaces:GetComponent(a,b,c,d)
 if a==96797568 then return root end
 if a==96797572 then return bg end
 if b==900 and d~=nil then return nativeParts[d] end
 if b==902 and d~=nil then if not labels[d] then error('Missing native dynamic component') end;return labels[d] end
 if b==902 then return props end
 if b==899 then return bubble end
 if b==901 and d~=nil then return nativeRules[d] end
 if b==901 then return decoration end
 return nil
end
ui.Layer={new=function(parent) return component(999,parent,0,0,0,0) end}
ui.Sprite={new=function(parent) return component(997,parent,0,0,0,0) end}
ui.Rectangle={new=function(parent) return component(998,parent,0,0,0,0) end}
local selected={skill='Herblore',method='Super prayer',total=52920,craftable=196,xp=270,unit='items',inputPerPotion=5,note='After decanting; limit: Wyvern bonemeal'}
package.loaded.catalog={lookup=function() return selected end}
local availableOptions={{id='test'}}
local menuCalls=0
package.loaded.methods={estimate=function() return selected,availableOptions end,options=function() return availableOptions end,addMenu=function() menuCalls=menuCalls+1 end}
MiniMenu={IsOpen=function() return false end}
Inventory={Find=function() return {GetTotal=function() return 568 end} end}
dofile(assert(package.searchpath('main',package.path)))
local event={miniMenu={entries={{verbText='Withdraw-All',componentData={objConfig={id=1,name='Prayer potion (4)'}}}}}}
callbacks.MiniMenuReady(event);callbacks.Draw()
local header,row,footer,detail=labels[0],labels[1],labels[2],labels[3]
assert(not bg.hidden,'native background must stay visible for potion effects')
assert(not nativeRules[0].hidden and not nativeRules[1].hidden,'native separators reused')
assert(nativeRules[0].xyGlobal.x==bg.xyGlobal.x+1 and nativeRules[0].width==bg.width-2,'header divider meets inner borders')
assert(nativeRules[1].xyGlobal.x==bg.xyGlobal.x+1 and nativeRules[1].width==bg.width-2,'footer divider meets inner borders')
assert(nativeRules[1].xyGlobal.y==labels[2].xyGlobal.y-4,'native footer rule relocated below XP and effects')
assert(nativeParts[4].xyGlobal.y+10==bg.xyGlobal.y+bg.height,'native rounded bottom corner follows resized background')
assert(row.xyGlobal.y>=header.xyGlobal.y+header.height+5)
assert(detail.xyGlobal.y>=row.xyGlobal.y+row.height)
assert(footer.xyGlobal.y>=detail.xyGlobal.y+detail.height+5)
assert(bg.xyGlobal.y+bg.height>=footer.xyGlobal.y+footer.height)
assert(row.width>=font:GetStringWidth(selected.note))
assert(row.alignVertical==0 and row.lineSpacing==nil and row.font==header.font)
local y,h,w=footer.xyGlobal.y,bg.height,row.width
local beforeWidth,beforeLines,beforeBorder=widthCalls,lineCalls,borderWrites
for _=1,100 do callbacks.Draw() end
assert(widthCalls==beforeWidth and lineCalls==beforeLines,'unchanged hover remeasured native font')
assert(borderWrites==beforeBorder,'unchanged border geometry rewritten')
assert(footer.xyGlobal.y==y and bg.height==h and row.width==w,'layout drift')
callbacks.MiniMenuOpened()
assert(row.content=='' and row.height==8 and bg.height==80)
assert(not bg.hidden,'native background restored on leaving tooltip')
assert(not nativeRules[0].hidden and not nativeRules[1].hidden,'both native separator sprites restored on leave')
assert(footer.position.yParentPc==originalFooter.yParentPc and footer.position.ySelfPc==-1)
assert(detail.position.y==54 and header.width==184)
-- Simulate client cursor movement while the plugin's layout is applied.
callbacks.MiniMenuReady(event);callbacks.Draw()
local oldX,oldY=labels[1].xyGlobal.x,labels[1].xyGlobal.y
bubble.position=ui.Pos.new(150,130)
callbacks.Draw()
assert(bubble.position.x==150 and bubble.position.y==130,'plugin pinned cursor container')
assert(labels[1].xyGlobal.x==oldX+50 and labels[1].xyGlobal.y==oldY+30,'XP did not follow cursor')
local movedX,movedY=labels[1].xyGlobal.x,labels[1].xyGlobal.y
callbacks.Draw()
assert(labels[1].xyGlobal.x==movedX and labels[1].xyGlobal.y==movedY,'follow drift')
-- Preserve a direct native label position update too.
labels[0].position=ui.Pos.new(5,0)
callbacks.Draw()
assert(labels[0].position.x==5,'cleanup discarded native position update')
callbacks.MiniMenuOpened()
assert(bubble.position.x==150 and bubble.position.y==130)
assert(labels[0].position.x==5)
-- Long notes must wrap within cap and grow; short notes must shrink again.
local layout=require('hover_layout')
local short=layout.plan(font,'Title',{'XP','Method'}, {},'+7 options',120,16,200,0)
local long=layout.plan(font,'Title',{'XP',string.rep('long ',100)}, {'Native description'},'+7 options',120,16,200,0)
assert(long.width==200 and long.bodyHeight>short.bodyHeight and long.footerY>short.footerY)
local newfont=clone(font);newfont.baseline=24;newfont.maxAscent=16;newfont.maxDescent=5
local large=layout.plan(newfont,'Title',{'XP','Method'}, {},'+7 options',120,16,200,0)
assert(large.bodyHeight>short.bodyHeight and large.spacing==24)
-- Readable but non-writable native style: setter must not abort rendering.
labels[1].readonlySpacing=true
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[1].content:find('Herblore XP',1,true),'read-only style hid XP')
callbacks.MiniMenuOpened()
labels[1].readonlySpacing=nil
-- Client-rendered footer: visible label with an empty content string.
labels[2].content=''
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[1].content:find('Herblore XP',1,true),'empty footer hid XP')
callbacks.MiniMenuOpened()
-- Distinct notes must be separate measured body lines.
selected.note='Limited by: Overload (4), after decanting | Requires: Meilyr recipe | More recipes unlocked in 16 levels'
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[1].content:find('Limited by: Overload (4), after decanting</col><br><col=e3d7bf>Requires: Meilyr recipe</col><br><col=e3d7bf>More recipes unlocked in 16 levels',1,true),'notes not split into measured lines')
callbacks.MiniMenuOpened()
-- Font registry lookup failure must use native drawing with safe bounds.
config.Font.FromID=function() error('font unavailable') end
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[1].content:find('Herblore XP',1,true),'font failure hid XP')
callbacks.MiniMenuOpened()
assert(labels[1].content=='' and labels[1].height==8)
print('PASS: cursor movement between Draw frames, native position updates, stable measured formatting, native style guards and restoration')

package.loaded.skill_hover={register=function() error('simulated skill integration failure',0) end,restore=function() end}
local ok,err=pcall(dofile,assert(package.searchpath('main',package.path)))
assert(ok,'optional skill feature must not block item startup: '..tostring(err))
print('PASS: item startup survives optional skill-hover registration failure')

config.Font.FromID=function() return font end
labels[3].content='Temporarily increases <col=00ff00>Necromancy +20</col><br>Stat changes are diminished by 1 point per minute.'
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[1].alignHorizontal==1 and labels[3].alignHorizontal==1,'boost potion information centered')
callbacks.MiniMenuOpened()
labels[3].content='Restores <col=00ff00>317</col> prayer points.'
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[1].alignHorizontal==1 and labels[3].alignHorizontal==1,'nonboost information centered')
assert(labels[0].alignHorizontal==1,'header centered')
assert(labels[2].alignHorizontal==2,'native options footer alignment preserved')
callbacks.MiniMenuOpened()
local effects=layout.plan(font,'Title',{'XP','Method'}, {'Temporarily increases Necromancy +20'},'+7 options',120,16,200,0)
assert(effects.detailDividerY>effects.bodyY+effects.bodyHeight,'rule below full XP block')
assert(effects.detailDividerY<effects.details[1].y,'rule before native stats')
assert(short.detailDividerY==nil,'no unnecessary effect rule without native details')
print('PASS: all text centered and measured divider before native effects')

callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[1].content~='','supported hover appears first')
local priorMenuCalls=menuCalls
availableOptions={}
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[1].content=='' and not bg.hidden,'empty options restores native tooltip completely')
assert(menuCalls==priorMenuCalls,'empty options adds no menu entries')
availableOptions={{id='test'}}
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[1].content:find('Herblore XP',1,true),'eligible hover resumes normally')
callbacks.MiniMenuOpened()
print('PASS: unavailable recipe hides plugin hover/menu, restores native background and eligible hover recovers')

-- Simulate a long-effect variant with a trailing footer line and oversized
-- native bottom padding. No extra row may remain under the options.
labels[2].content='<col=e3d7bf>+7 options<br></col>'
labels[2].maxLines=0
local oldNativeBg=clone(bg.size)
bg.size.height=bg.size.height+40
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(not labels[2].content:find('<br>',1,true),'footer break removed')
assert(labels[2].maxLines==1,'options uses one line')
local inset=bg.xyGlobal.y+bg.height-labels[2].xyGlobal.y-labels[2].height
assert(inset>=4 and inset<=8,'no blank footer row, padding='..inset)
assert(labels[2].alignHorizontal==2,'options remains right aligned')
callbacks.MiniMenuOpened()
assert(labels[2].content=='<col=e3d7bf>+7 options<br></col>' and labels[2].maxLines==0,'native footer formatting restored')
bg.size=oldNativeBg
print('PASS: long-potion footer trailing line, excessive bottom inset and native restoration')

labels[2].content='+7 options'
labels[3].content='<col=e3d7bf>Stat changes are diminished by 1 point per minute.<br><br></col>'
local originalDescription=labels[3].content
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[3].content=='<col=e3d7bf>Stat changes are diminished by 1 point per minute.</col>','empty effect rows removed without losing color closure')
assert(nativeRules[1].xyGlobal.y-(labels[3].xyGlobal.y+labels[3].height)==2,'effect divider has compact 2px gap')
callbacks.MiniMenuOpened()
assert(labels[3].content==originalDescription,'original native description restored')
assert(layout.trimTrailingBreaks('First<br>Second<br></col>')=='First<br>Second</col>','visible effect lines retained')
print('PASS: trailing empty stat rows removed, compact divider gap and native description restoration')

local endings={'\n','\r\n','   ','<BR>','<br />','<br/>','&nbsp;','\194\160','<br>\r\n   <col=ffffff></col>'}
for _,name in ipairs({'Overload','Saradomin brew'}) do
 for _,ending in ipairs(endings) do
  callbacks.MiniMenuOpened()
  local native='<col=e3d7bf>'..name..' effects<br>Last effect.'..ending..'</col>'
  labels[3].content=native
  callbacks.MiniMenuReady(event);callbacks.Draw()
  local plain=labels[3].content:gsub('<[^>]*>','')
  assert(plain:sub(-12)=='Last effect.','no trailing blank content: '..name..' '..ending)
  assert(nativeRules[1].xyGlobal.y-(labels[3].xyGlobal.y+labels[3].height)==2,'consistent stat/footer gap')
  callbacks.MiniMenuOpened()
  assert(labels[3].content==native,'native content restored')
 end
end
assert(layout.trimTrailingBreaks('First<br>Second  <br>Third')=='First<br>Second  <br>Third','internal formatting retained')
print('PASS: Overload and Saradomin brew trailing newline, whitespace, nonbreaking space, mixed tags and break variants')
callbacks.MiniMenuOpened()
local originalFromID=config.Font.FromID
local small={baseline=12,maxAscent=8,maxDescent=2}
function small:GetStringWidth(s) return font:GetStringWidth(s)*0.8 end
function small:GetStringLineCount(s,w) return font:GetStringLineCount(s,w/0.8) end
config.Font.FromID=function(id) if id==13 then return small end;return originalFromID(id) end
labels[3].font=13;labels[2].font=13
rawset(labels[3],'lineSpacing',12)
rawset(labels[2],'lineSpacing',12)
labels[3].content='Temporarily increases:<br>Attack +17<br>Strength +18<br>Last effect.'
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[0].font==12,'native heading font preserved')
assert(labels[3].font==13 and labels[2].font==13,'native stats and footer keep their smaller font')
assert(labels[1].font==13,'plugin information matches native smaller text')
assert(labels[3].height==8+2+3*12+2,'stats measured with their own font and spacing, without spare line')
assert(nativeRules[1].xyGlobal.y-labels[3].xyGlobal.y-labels[3].height==2,'divider follows actual smaller stat block')
callbacks.MiniMenuOpened()
assert(labels[3].font==13 and labels[2].font==13,'native font preserved after restore')
config.Font.FromID=originalFromID
print('PASS: different native heading/stat/footer fonts, compact stat height and native font restoration')
callbacks.MiniMenuOpened()
selected.outfitTotal=selected.total*1.06;selected.outfitPercent=6
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[1].content:find('XP (with outfit)',1,true),'adjusted total clearly labeled')
assert(labels[1].content:find('Base total:',1,true),'base total remains visible')
assert(labels[1].content:find('base XP / potion',1,true),'base unit XP remains visible')
callbacks.MiniMenuOpened()
selected.outfitTotal=nil;selected.outfitPercent=nil
print('PASS: outfit-adjusted heading and preserved base total/unit XP in native hover')
callbacks.MiniMenuOpened()
local oldNote=selected.note
selected.note='Outfit: <col=ff9900>+3%</col> Artisan outfit (worn)'
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[1].content:find('<col=ff9900>+3%<col=e3d7bf> Artisan outfit',1,true),'only percentage colored; rest explicitly returns to native color')
callbacks.MiniMenuOpened();selected.note=oldNote
print('PASS: percentage color ends immediately before outfit name')
package.loaded.startup_notice={register=function() error('simulated unavailable chat API',0) end}
local noticeOK,noticeError=pcall(dofile,assert(package.searchpath('main',package.path)))
assert(noticeOK,'notification failure must not block XP plugin startup: '..tostring(noticeError))
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[1].content:find('Herblore XP',1,true),'notification failure must preserve working XP hover')
callbacks.MiniMenuOpened()
print('PASS: failed optional notice preserves startup and XP hover')
-- Native item names may contain a literal newline or a <br> soft wrap.
package.loaded.startup_notice={register=function() end}
dofile(assert(package.searchpath('main',package.path)))
for _,title in ipairs({'Withdraw-All Prayer potion<br>(4)','Withdraw-All Prayer potion\n(4)'}) do
 labels[0].content=title
 callbacks.MiniMenuReady(event);callbacks.Draw()
 assert(labels[1].content:find('Herblore XP',1,true),'wrapped native name must retain plugin hover')
 callbacks.MiniMenuOpened()
end
print('PASS: native newline and br name wrapping')

-- Equipment stat blocks retain their native dimensions, typography and alignment.
selected.skill='Crafting';labels[0].content='Withdraw-All Prayer potion (4)'
labels[3].content='Damage: 100<br>Accuracy: 200'
labels[3].alignHorizontal=0;labels[3].font=12
local nativeStatWidth,nativeStatHeight=labels[3].width,labels[3].height
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(labels[3].width==nativeStatWidth and labels[3].height==nativeStatHeight)
assert(labels[3].font==12 and labels[3].alignHorizontal==ui.AlignMode.CENTRE)
assert(labels[3].content=='Damage: 100<br>Accuracy: 200')
callbacks.MiniMenuOpened()
print('PASS: native equipment stat dimensions, font, alignment and content preserved')

-- Percentage-anchored stat rows must be measured before parent expansion.
labels[3].size=ui.Size.new(-16,32);labels[3].size.widthParentPc=1
labels[3].position=ui.Pos.new(0,54);labels[3].position.xParentPc=0.5;labels[3].position.xSelfPc=-0.5
local expectedWidth=labels[3].width
callbacks.MiniMenuReady(event)
local stableWidth,stableOffset
for i=1,100 do
 callbacks.Draw()
 assert(labels[3].width==expectedWidth,'Parent expansion must not enlarge native stat row')
 local offset=labels[3].xyGlobal.x-labels[0].xyGlobal.x
 if i==1 then stableWidth=bg.width;stableOffset=offset end
 assert(bg.width==stableWidth and offset==stableOffset,'Tooltip geometry must not drift across repeated draws')
end
callbacks.MiniMenuOpened()
assert(labels[3].size.widthParentPc==1 and labels[3].position.xParentPc==0.5,'Native anchors restored')
print('PASS: 100 repeated draws preserve percentage-anchored native stats without horizontal growth')

-- The client relayouts individual rows between Draw callbacks. Those positions
-- are legitimate native writes, so undo cannot simply overwrite them.
labels[3].size=ui.Size.new(100,32);labels[3].position=ui.Pos.new(90,54)
labels[4]=component(902,props,0,90,300,32);labels[4].dynamicID=4
labels[4].type=2;labels[4].font=12;labels[4].alignHorizontal=0
labels[4].content='Charge dinarrows with resonant anima to upgrade them.'
callbacks.MiniMenuReady(event)
local firstWidth,firstX
for i=1,100 do
 callbacks.Draw()
 if i==1 then firstWidth=bg.width;firstX=labels[3].xyGlobal.x-labels[0].xyGlobal.x end
 assert(bg.width==firstWidth,'Client relayout must not feed width back into tooltip sizing')
 assert(math.abs((labels[4].xyGlobal.x+labels[4].width/2)-(labels[0].xyGlobal.x+labels[0].width/2))<=0.5,'Native description block centered beneath XP')
 assert(labels[4].alignHorizontal==ui.AlignMode.CENTRE,'Description lines centered')
 assert(labels[2].alignHorizontal==2,'Options footer remains right aligned')
 assert(labels[3].xyGlobal.x-labels[0].xyGlobal.x==firstX,'Native stat offset stays stable')
 -- Simulate the client moving a stat row in response to the expanded panel.
 local changed=ui.Pos.new(labels[3].position);changed.x=changed.x+12;labels[3].position=changed
end
callbacks.MiniMenuOpened();labels[4]=nil
print('PASS: 100 client-interleaved relayouts keep native stat offsets and tooltip width stable')



-- Reproduce the probe: visible title/footer, middle label visibleGlobal=false.
callbacks.MiniMenuOpened()
labels[3]=nil -- tradeable anima has no equipment stat block
ui.Text={new=function() error('no text constructors') end}
ui.Layer={new=function() error('no layer constructors') end}
ui.Sprite={new=function() error('no sprite constructors') end}
local componentReads=0
local originalGet=ui.Interfaces.GetComponent
ui.Interfaces.GetComponent=function(self,...)
 componentReads=componentReads+1;return originalGet(self,...)
end
local expectedWidth,measuredWidths,measuredLines,readCount
selected.inputPerPotion=3;selected.xpUnit='arrow'
selected.note='Limited by: Dinarrow | Requires: Standard imbuing | Outfit: <col=ff0000>+0%</col> Fletcher'
for cycle=1,3 do
 for index,god in ipairs({'Bik','Ful','Wen','Jas'}) do
  selected.total=1000+index
  local title='Withdraw-All Resonant anima of '..god..' (tradeable)'
  labels[0].content=title;labels[1].content='';labels[1].hidden=false
  rawset(labels[1],'visibleGlobal',false)
  event.miniMenu.entries[1].componentData.objConfig={id=600+index,name='Resonant anima of '..god..' (tradeable)'}
  callbacks.MiniMenuReady(event)
  for frame=1,20 do
   callbacks.Draw()
   assert(labels[1].content:find('XP',1,true),'XP in existing native body label')
   assert(labels[0].content==title,'native title remains separate and unchanged')
   assert(labels[1].content:find('Uses 3 per arrow',1,true),'same consumption information as normal hover')
   assert(labels[2].xyGlobal.y>=labels[1].xyGlobal.y+labels[1].height+7,'footer clear of body')
   assert(not labels[1].hidden,'never change native visibility flags')
   assert(labels[1].font==labels[2].font,'same smaller native body font as non-tradeable renderer')
   assert(labels[0].font==12,'retain native title font and line advance')
   assert(labels[1].content:find('</col><br><col=e3d7bf>Requires:',1,true),'notes on separate lines')
   if frame==1 then
    expectedWidth=bg.width;measuredWidths=widthCalls;measuredLines=lineCalls;readCount=componentReads
   else
    assert(bg.width==expectedWidth,'width stable')
    assert(widthCalls==measuredWidths and lineCalls==measuredLines,'warm draws must not remeasure text')
    assert(componentReads==readCount,'unchanged hover must not scan or rebuild native components')
   end
  end
  callbacks.MiniMenuOpened()
  assert(labels[0].content==title,'native title restored')
  assert(labels[0].font==12,'original title font restored')
 end
end
print('PASS: empty native body uses shared renderer, separate title, smaller body font, no visibility changes or constructors')

-- Switch directly between gods without opening/closing a menu.
for index,god in ipairs({'Jas','Wen','Bik','Ful','Jas'}) do
 local title='Withdraw-All Resonant anima of '..god..' (tradeable)'
 labels[0].content=title;labels[1].content=''
 event.miniMenu.entries[1].componentData.objConfig={id=800+index,name='Resonant anima of '..god..' (tradeable)'}
 callbacks.MiniMenuReady(event);callbacks.Draw()
 assert(labels[0].content:find(title,1,true),'direct switch keeps current item title')
 assert(labels[1].content:find('XP',1,true),'direct switch renders immediately')
 local before=componentReads
 bubble.position.x=bubble.position.x+3
 callbacks.Draw()
 assert(componentReads==before,'cursor parent movement reuses relative layout')
end
callbacks.MiniMenuOpened()
print('PASS: direct anima transitions and cursor movement reuse stable native layout')

-- Client repositions the body before visibility catches up: keep our text.
labels[0].content='Withdraw-All Resonant anima of Wen (tradeable)'
labels[1].content='';labels[1].hidden=false
rawset(labels[1],'visibleGlobal',false)
event.miniMenu.entries[1].componentData.objConfig={id=901,name='Resonant anima of Wen (tradeable)'}
callbacks.MiniMenuReady(event);callbacks.Draw()
for frame=1,12 do
 labels[1].position.x=labels[1].position.x+1
 callbacks.Draw()
 assert(labels[1].content:find('XP',1,true),'visibility lag during native relayout must not clear XP')
end
callbacks.MiniMenuOpened()
assert(labels[1].content=='','original empty body restored')
print('PASS: native relayout with delayed visibility retains XP without clear/retry oscillation')

-- Content setters capture native font/bounds at assignment time.
local body=labels[1]
local mt=getmetatable(body);local baseIndex,baseNew=mt.__index,mt.__newindex
local bodyText=body.content;rawset(body,'content',nil)
local commits=0;local committedWidth,committedHeight,committedFont
mt.__index=function(c,k)
 if c==body and k=='content' then return bodyText end
 return baseIndex(c,k)
end
mt.__newindex=function(c,k,v)
 if c==body and k=='content' then
  bodyText=v
  if v:find('XP',1,true) then
   commits=commits+1;committedWidth=c.width;committedHeight=c.height;committedFont=c.font
  end
  return
 end
 return baseNew(c,k,v)
end
labels[0].content='Withdraw-All Resonant anima of Wen (tradeable)'
body.content=''
callbacks.MiniMenuReady(event);callbacks.Draw()
assert(committedWidth==body.width and committedHeight==body.height and committedFont==body.font,
 'final text commit must see final native font and bounds')
local count=commits
for i=1,30 do callbacks.Draw() end
assert(commits==count,'unchanged hovers must not rewrite text')
callbacks.MiniMenuOpened()
mt.__index=baseIndex;mt.__newindex=baseNew;rawset(body,'content',bodyText)
print('PASS: final native text commit follows geometry; no content writes during 30 stable draws')
