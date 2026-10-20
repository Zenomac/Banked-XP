package.path='./?.lua;banked-xp/?.lua;'..package.path
local current={staticID=896,visibleGlobal=true,xyGlobal={x=0,y=0}}
local creates,destroys=0,0
ui={Interfaces={GetComponent=function() return current end},AlignMode={CENTRE=1,TOPLEFT=0},Layer={},Text={}}
local function object(parent)
 return {parent=parent,hidden=true,SetPos=function(self,x,y) self.x=x;self.y=y end,
 SetSize=function(self,w,h) self.w=w;self.h=h end,MoveToFront=function() end,
 Destroy=function() destroys=destroys+1 end}
end
ui.Layer.new=function(parent) creates=creates+1;return object(parent) end
ui.Text.new=function(parent) return object(parent) end
local m=require('hover_overlay')
local header={visibleGlobal=true,xyGlobal={x=20,y=40}}
assert(m.show(header,20,200,80,13,16,'XP'))
local body=m.current()
for i=1,100 do header.xyGlobal.x=i;assert(m.sync(header)) end
assert(creates==1,'cursor movement does not allocate')
current=nil
assert(not m.sync(header) and m.current()==nil)
assert(destroys==0,'do not call Destroy on proxies from unloaded interfaces')
current={staticID=896,visibleGlobal=true,xyGlobal={x=0,y=0}}
assert(m.show(header,20,200,80,13,16,'XP'))
assert(creates==2 and m.current()~=body,'new interface receives new owned components')
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
