package.path='./?.lua;banked-xp/?.lua;'..package.path
local probe=require('anima_probe')
local messages={};local oldPrint=print
print=function(s) messages[#messages+1]=s end
local row={content='(tradeable)',hidden=true,visibleGlobal=false,type=2}
local rows={[0]={content='Withdraw-All Resonant anima of Jas',type=2},[1]=row}
for i=1,100 do probe.report('Resonant anima of Jas (tradeable)','unavailable',rows) end
assert(#messages==1,'repeated snapshots rate limited')
for i=1,10 do probe.report('Resonant anima of Jas (tradeable)','state'..i,rows) end
assert(#messages==3,'hard per-item limit')
probe.report('Resonant anima of Jas','unavailable',rows);assert(#messages==3)
assert(row.content=='(tradeable)' and row.hidden and not row.visibleGlobal,'probe is read only')
print=oldPrint
print('PASS: bounded read-only anima diagnostics')
