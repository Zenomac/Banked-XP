package.path='./?.lua;banked-xp/?.lua;'..package.path
local data={xpSettingsV1={},xpMethodsV1={},xpSharedMethodsV2={},unrelated=true}
local resets=0
package.loaded.settings={resetMemory=function() resets=resets+1 end}
package.loaded.methods={resetMemory=function() resets=resets+1 end}
PersistentDB={CheckExists=function(_,k) return data[k]~=nil end,Delete=function(_,k) data[k]=nil;return true end}
local p=require('privacy')
assert(p.erasePreferences());assert(data.unrelated and not data.xpSettingsV1 and not data.xpMethodsV1 and not data.xpSharedMethodsV2)
assert(p.erasePreferences(),'already deleted succeeds');assert(resets==4)
data.xpMethodsV1={};PersistentDB.Delete=function() return false end
local ok,failed=p.erasePreferences();assert(not ok and #failed==1,'failed deletion is reported')
PersistentDB=nil;assert(not p.erasePreferences(),'missing API does not claim deletion')
print('PASS: targeted preference deletion, repeat deletion, memory reset and failure reporting')
