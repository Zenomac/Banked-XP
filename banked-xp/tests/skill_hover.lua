package.path='./?.lua;banked-xp/?.lua;'..package.path
local function copy(v) local t={};for k,x in pairs(v) do t[k]=x end;return t end
local function size(a,b) if type(a)=='table' then return copy(a) end;return {width=a,height=b} end
local function pos(a,b) if type(a)=='table' then return copy(a) end;return {x=a,y=b,xParentPc=0,yParentPc=0,xSelfPc=0,ySelfPc=0} end
local root={size=size(150,68),position=pos(100,200),xyGlobal={x=100,y=200}}
local function c(x,y,w,h,text)
 return setmetatable({parent=root,size=size(w,h),position=pos(x,y),content=text or '',font=207,maxLines=1,alignVertical=1,visibleGlobal=true},{__index=function(t,k)
  if k=='width' then return t.size.width elseif k=='height' then return t.size.height elseif k=='xyGlobal' then return {x=root.xyGlobal.x+t.position.x,y=root.xyGlobal.y+t.position.y} end
 end})
end
local children={}
local plan=require('native_frame').plan(150,68);plan[0]={1,1,148,66}
for i=0,8 do local b=plan[i];children[i]=c(b[1],b[2],b[3],b[4]) end
children[9]=c(6,4,140,15,'Construction: 100/100')
children[14]=c(6,49,140,16,'Remainder:')
children[15]=c(6,49,138,15,'871,818')
local calls=0
local font={GetStringWidth=function(_,s) calls=calls+1;return #s*6 end}
config={Font={FromID=function(id) assert(id==207);return font end}}
ui={Size={new=size},Pos={new=pos},Interfaces={GetComponent=function(_,i,s,cat,id) assert(i==1477 and s==923);return children[id] end},Text={new=function() error('must not create native children') end},Layer={new=function() error('must not create native layers') end}}
local open=false
MiniMenu={IsOpen=function() return open end}
package.loaded.skill_summary={register=function() end,supports=function(s) return s~='Attack' end,tooltipLine=function() return 'Banked XP: 12,685,042' end}
local callbacks={};Event={Draw={Subscribe=function(_,fn) callbacks.draw=fn end},MiniMenuOpened={Subscribe=function(_,fn) callbacks.clear=fn end}}
local hover=require('skill_hover');hover.register()
local missing=false
package.loaded.skill_summary.missingStorage=function() return missing end
local function fixture(bonus,target,extra)
 hover.restore()
 for id in pairs(children) do children[id]=nil end
 local count=3+(bonus and 1 or 0)+(target and 2 or 0)
 local height=23+count*15+(target and 15 or 0)
 root.size=size(150,height)
 local plan=require('native_frame').plan(150,height);plan[0]={1,1,148,height-2}
 for id=0,8 do local b=plan[id];children[id]=c(b[1],b[2],b[3],b[4]) end
 children[9]=c(6,4,140,15,'Herblore: 104/104')
 children[10]=c(6,19,140,15,'Current XP:');children[11]=c(6,19,138,15,'22,507,998')
 children[12]=c(6,34,140,15,'Next level:');children[13]=c(6,34,138,15,'23,611,006')
 children[14]=c(6,49,140,16,'Remainder:');children[15]=c(6,49,138,15,'1,103,008')
 local id,baseline=16,64
 if bonus then
  children[id]=c(6,baseline,140,16,'Bonus XP:');children[id+1]=c(6,baseline,138,15,'<col=00ff00>187,024</col>')
  id=id+2;baseline=baseline+15
 end
 if target then
  children[id]=c(6,baseline,140,15,target);children[id+1]=c(6,baseline,138,15,'120')
  children[id+2]=c(6,baseline+15,140,15,'Remainder:');children[id+3]=c(6,baseline+15,138,15,'81,765,169')
  children[id+4]=c(6,baseline+30,130,12,'1%') -- existing native progress sibling
 end
 package.loaded.skill_summary.tooltipExtra=function() return extra end
 return height,id
end
for _,bonus in ipairs({false,true}) do
 for _,target in ipairs({'Target level:','Target XP:'}) do
  local height,id=fixture(bonus,target)
  local originalBarY=children[id+4].position.y
  callbacks.draw()
  local expected='Current XP:<br>Next level:<br>Remainder:'..(bonus and '<br>Bonus XP:' or '')..'<br>Banked XP:<br>'..target..'<br>Remainder:'
  assert(children[10].content==expected,children[10].content)
  assert(children[10].content:find('Next level:',1,true),'preserve Next level')
  assert(children[12].content=='' and children[14].content=='','old text is cleared')
  assert(children[10].position.y==children[11].position.y,'columns align')
  assert(children[id+4].position.y==originalBarY+19 and root.size.height==height+23,'replacement of Next level keeps progress correctly positioned')
  local measured=calls
  for n=1,20 do callbacks.draw() end
  assert(calls==measured,'metric cache stable')
  callbacks.clear()
  assert(children[12].content=='Next level:' and children[14].content=='Remainder:' and children[id].content==target)
  assert(root.size.height==height and children[10].maxLines==1,'restoration')
 end
end
local height,id=fixture(true,'Target XP:','0')
callbacks.draw()
assert(children[10].content:find('Banked XP:<br>Ready XP:<br>Target XP:',1,true))
assert(root.size.height==height+38 and children[id+4].position.y==23+8*15,'ready row moves progress down one row')
callbacks.clear()
fixture(false,nil)
missing=true;callbacks.draw()
assert(children[11].content:find('<col=ff0000>12,685,042</col>',1,true),'only banked amount coloured')
assert(not children[10].content:find('<col',1,true))
callbacks.clear();missing=false
for _,skill in ipairs({'Herblore','Smithing','Crafting','Fletching','Archaeology','Farming','Firemaking','Cooking','Prayer','Construction'}) do
 children[9].content=skill..': 100/100';callbacks.draw();assert(children[10].content:find('Banked XP:',1,true));callbacks.clear()
end
open=true;callbacks.draw();assert(children[10].content=='Current XP:');open=false
children[9].content='Attack: 99/99';callbacks.draw();assert(children[10].content=='Current XP:')
print('PASS: ordered native rows with/without Bonus XP, level and XP targets, native progress preserved, extra Ready row, cached metrics, storage colour, full restoration and no new UI children')

fixture(true,'Target level:')
children[17].content='<col=00ff00>187,024' -- native unclosed green tag
callbacks.draw()
assert(children[11].content:find('<br><col=e3d7bf>12,685,042</col>',1,true),'banked XP explicitly resets to neutral after bonus')
assert(children[11].content:find('<col=00ff00>187,024</col>',1,true),'Bonus XP retains green')
callbacks.clear()
fixture(false,'Target XP:')
children[24]=c(6,56,140,15,'Other native XP:');children[25]=c(6,56,138,15,'42')
callbacks.draw()
assert(children[10].content:find('Remainder:<br>Other native XP:<br>Banked XP:<br>Target XP:',1,true),'preserve other native numeric rows before banked XP')
callbacks.clear()
print('PASS: native order retained, Next level restored, extra native row retained, unclosed bonus green cannot leak into banked XP')

local noTargetHeight=fixture(false,nil)
callbacks.draw()
assert(root.size.height==noTargetHeight+19,'banked XP gets 4px extra bottom padding')
callbacks.clear();assert(root.size.height==noTargetHeight,'padding restores')
local readyHeight=fixture(false,nil,'0')
callbacks.draw()
assert(root.size.height==readyHeight+34,'Ready XP also gets 4px extra bottom padding')
callbacks.clear();assert(root.size.height==readyHeight)
print('PASS: 4px progress gap and 4px bottom padding with Banked XP or Ready XP, reversible sizing')
-- Total XP: inline and caption/value variants, with optional Bonus XP.
package.loaded.skill_summary.totalLine=function() return 'Banked XP: 99,123,456' end
package.loaded.skill_summary.missingStorage=function() return false end
local function totalFixture(bonus,paired)
 hover.restore();for id in pairs(children) do children[id]=nil end
 root.size=size(150,bonus and 43 or 28)
 local bounds=require('native_frame').plan(150,root.size.height)
 for id=0,8 do local b=bounds[id];children[id]=c(b[1],b[2],b[3],b[4]) end
 children[9]=c(6,4,138,15,paired and 'Total XP:' or 'Total XP: 822,089,452')
 if paired then children[10]=c(6,4,136,15,'822,089,452') end
 if bonus then
  children[11]=c(6,19,138,15,paired and 'Bonus XP:' or 'Bonus XP: <col=00ff00>187,024')
  if paired then children[12]=c(6,19,136,15,'<col=00ff00>187,024') end
 end
end
for _,paired in ipairs({false,true}) do
 for _,bonus in ipairs({false,true}) do
  totalFixture(bonus,paired)
  local height=root.size.height
  callbacks.draw()
  local last=bonus and children[11] or children[9]
  assert(last.content:find('<br><col=e3d7bf>Banked XP:',1,true),'total banked row follows last native XP row')
  local val=paired and (bonus and children[12] or children[10]) or last
  assert(val.content:find('<col=e3d7bf>99,123,456</col>',1,true),'neutral total after native green')
  assert(root.size.height==height+19)
  callbacks.clear();assert(root.size.height==height and not last.content:find('Banked XP:',1,true))
 end
end
totalFixture(true,false)
package.loaded.skill_summary.missingStorage=function() return true end
callbacks.draw();assert(children[11].content:find('<col=ff0000>99,123,456</col>',1,true))
callbacks.clear()
print('PASS: total-XP hover, bonus/no bonus, inline/paired rows, native colours, storage warning, padding and restoration')

package.loaded.skill_summary.missingStorage=function() return false end
totalFixture(false,false)
children[9].content='Total XP: 822,089,452<br>Bonus XP: <col=00ff00>187,024'
children[9].size.height=30
callbacks.draw()
assert(children[9].content:find('<br><col=e3d7bf>Banked XP: <col=e3d7bf>99,123,456</col>',1,true),'combined native text retains neutral added row')
callbacks.clear()
print('PASS: total XP and Bonus XP sharing a single native text component')
-- Total XP may render in another exported native hover root.
local oldGet=ui.Interfaces.GetComponent
ui.Interfaces.GetComponent=function(_,interface,static,category,id)
 if interface==1477 and static==904 then return children[id] end
 return nil
end
totalFixture(true,false)
for _=1,12 do callbacks.draw() end
assert(children[11].content:find('Banked XP:',1,true),'discover alternate native hover root')
callbacks.clear()
local oldCornerWidth=children[1].size.width
children[1].size.width=12
callbacks.draw()
assert(not children[11].content:find('Banked XP:',1,true),'unrecognized frame is not modified')
children[1].size.width=oldCornerWidth
ui.Interfaces.GetComponent=oldGet
print('PASS: alternate total tooltip root discovery and conservative frame-shape guard')
