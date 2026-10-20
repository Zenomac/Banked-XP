package.path='./?.lua;banked-xp/?.lua;'..package.path
package.loaded.bank={normalize=function(s) return s:lower() end}
local originalPrint,originalOS=print,os
local logs={}
print=function(s) logs[#logs+1]=s end
os=nil
local timing=require('hover_timing')
local name='Resonant anima of Wen (tradeable)'
timing.begin(name);timing.ready()
timing.draw();timing.layout()
for i=1,119 do timing.finish({visibleGlobal=false});timing.draw() end
timing.finish({visibleGlobal=false})
assert(#logs==1 and logs[1]:find('visible=nil',1,true) and logs[1]:find('prepareCPU=unavailable',1,true))
timing.begin(name)
for i=1,200 do timing.draw();timing.finish({visibleGlobal=true}) end
assert(#logs==1,'sample budget stops further output')
timing.begin('Resonant anima of Jas (tradeable)');timing.ready();timing.draw();timing.layout()
for i=1,31 do timing.finish({visibleGlobal=true});timing.draw() end
assert(#logs==2 and logs[2]:find('visible=1',1,true),'visible stage distinguished from missing body')
os=originalOS;print=originalPrint
print('PASS: bounded timing samples, delayed/visible body and absent clock API')
