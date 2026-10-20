package.path='./?.lua;banked-xp/?.lua;'..package.path
local current={staticID=902,visibleGlobal=true,xyGlobal={x=0,y=0}}
local function parentLookup(self,category,dynamic) return self.children and self.children[category..':'..dynamic] end
current.GetChild=parentLookup
local creates,destroys=0,0
ui={Interfaces={GetComponent=function() return current end},AlignMode={CENTRE=1,TOPLEFT=0},Layer={},Text={}}
local function object(parent)
 return {parent=parent,GetChild=parentLookup,hidden=true,rgba=0,alpha=0,SetPos=function(self,x,y) self.x=x;self.y=y end,
 SetSize=function(self,w,h) self.w=w;self.h=h end,MoveToFront=function() end,
 Destroy=function() destroys=destroys+1 end}
end
ui.Layer.new=function(parent,category,dynamic)
 assert(parent.staticID==902 and category~=0 and dynamic==0)
 creates=creates+1;local c=object(parent);parent.children={[category..':'..dynamic]=c};return c
end
ui.Text.new=function(parent,category,dynamic)
 local c=setmetatable(object(parent),{
  __index=function(_,key) if key=='lineSpacing' then return 0 end end,
  __newindex=function(self,key,value)
   assert(key~='lineSpacing','lineSpacing is read-only on owned Text too')
   rawset(self,key,value)
  end})
 parent.children={[category..':'..dynamic]=c};return c
end
local savedPrint=print
local renderLogs={}
print=function(message) if message:find('[BXP render]',1,true) then renderLogs[#renderLogs+1]=message end end
local m=require('hover_overlay')
local header={visibleGlobal=true,xyGlobal={x=20,y=40}}
assert(m.show(header,20,200,80,13,16,'XP'))
local body=m.current()
assert(body.rgba==0xd8d3c5ff and body.alpha==1 and not body.hidden)
assert(body.x==0 and body.y==0 and body.parent.alpha==1)
assert(m.show(header,20,200,80,13,16,'XP',{rgb=0xaabbcc}))
assert(body.rgba==0xaabbccff,'native body tint copied with opaque alpha')
for i=1,100 do header.xyGlobal.x=i;assert(m.sync(header)) end
assert(creates==1,'cursor movement does not allocate')
assert(#renderLogs==3,'render diagnostics run once, not on cursor updates or repeated shows')
assert(renderLogs[1]:find('owned',1,true) and renderLogs[2]:find('native',1,true))
print=savedPrint
current=nil
assert(not m.sync(header) and m.current()==nil)
assert(destroys==0,'do not call Destroy on proxies from unloaded interfaces')
current={staticID=902,GetChild=parentLookup,visibleGlobal=true,xyGlobal={x=0,y=0}}
assert(m.show(header,20,200,80,13,16,'XP'))
assert(creates==2 and m.current()~=body,'new interface receives new owned components')
-- Static parent survives while its dynamic children are removed by client.
local stale=m.current();local staleLayer=stale.parent
current.children={}
setmetatable(staleLayer,{__index=function() error('stale proxy accessed') end,__newindex=function() error('stale proxy written') end})
assert(m.current()==nil and not m.sync(header))
assert(destroys==0,'never destroy an already-removed layer')
assert(m.show(header,20,200,80,13,16,'XP') and creates==3,'rebuild only after confirmed removal')
header.visibleGlobal=false
assert(not m.sync(header) and m.current()==nil,'native hover disappearance hides owned text')
m.destroy();assert(destroys==1)
-- Partial construction failure cleans up its layer and never retries per frame.
package.loaded.hover_overlay=nil;m=require('hover_overlay')
header.visibleGlobal=true
ui.Text.new=function() error('simulated constructor failure') end
assert(not pcall(m.show,header,20,200,80,13,16,'XP'))
local attempts=creates
assert(not m.show(header,20,200,80,13,16,'XP') and creates==attempts)
assert(destroys==2,'partial owned layer cleaned up')
print('PASS: overlay reuse, parent unload/reload, hover disappearance, shutdown and failed creation')
