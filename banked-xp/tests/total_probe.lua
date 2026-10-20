package.path='./?.lua;banked-xp/?.lua;'..package.path
local writes=0
local function readonly(data)
 return setmetatable({}, {__index=data,__newindex=function() writes=writes+1;error('probe wrote native UI') end})
end
local text=readonly({visibleGlobal=true,content='Total XP: 822,089,452<br>Bonus XP: 187,024',font=207,interfaceID=320,staticID=16,categoryID=3,dynamicID=7,xyGlobal={x=10,y=20},width=140,height=30})
local nested=readonly({visibleGlobal=true,IterateStaticComponents=function(_,fn) fn(text,true) end})
local root=readonly({visibleGlobal=true,IterateDynamicComponents=function(_,fn) fn(nested,true) end})
ui={Interfaces={GetComponent=function(_,i,s,c,d) if i==320 and s==16 and c==nil then return root end end}}
local callback,drawCallback
Event={Logic={Subscribe=function(_,fn) callback=fn end},Draw={Subscribe=function(_,fn) drawCallback=fn end}}
local messages={};local originalPrint=print
print=function(s) messages[#messages+1]=s end
local probe=require('total_probe');probe.register()
callback()
assert(writes==0)
local joined=table.concat(messages,'\n')
assert(joined:find('TOTAL MATCH',1,true) and joined:find('320:16:3:7',1,true),'nested text path identified')
assert(joined:find('read-only pass 1',1,true),'heartbeat confirms scan ran')
local before=#messages
for _=1,24 do callback() end
assert(#messages==before,'Logic probe throttled')
for _=1,200 do callback() end
assert(#messages<12,'identical text and initial heartbeat output bounded')
ui.Interfaces.GetComponent=function() error('native lookup unavailable') end
probe.scan();assert(writes==0,'lookup failures isolated')
print=originalPrint
print('PASS: nested total-XP discovery, exact component coordinates, Logic throttling, bounded output, read-only access and unavailable lookups')

local duringDraw=false
local directRoot=readonly({visibleGlobal=true,GetChild=function(_,category,id)
 if duringDraw and category==2 and id==7 then return text end
end})
ui.Interfaces.GetComponent=function(_,i,s,c,d) if i==320 and s==16 and c==nil then return directRoot end end
messages={};print=function(s) messages[#messages+1]=s end
probe.scan('Logic')
assert(not table.concat(messages,'\n'):find('TOTAL MATCH',1,true))
duringDraw=true;drawCallback()
local output=table.concat(messages,'\n')
assert(output:find('TOTAL MATCH',1,true) and output:find('phase=Draw',1,true) and output:find('/child/2/7',1,true),'direct GetChild and Draw-only visibility')
assert(writes==0)
print=originalPrint
print('PASS: direct collection GetChild category lookup and Draw-only total text discovery without writes')
