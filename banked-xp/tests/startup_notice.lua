package.path='./?.lua;banked-xp/?.lua;'..package.path
local logic,state,available,count=nil,nil,false,0
Event={Logic={Subscribe=function(_,fn) logic=fn end},GameStateChanged={Subscribe=function(_,fn) state=fn end}}
Player={IsAvailable=function() return available end}
Chat={AddMessage=function(message) assert(message:find('Diango',1,true) and message:find('for this session',1,true));count=count+1 end}
PluginPermissions={chatAccess=1}
Plugin={HasPermission=function() return true end}
local m=require('startup_notice');m.register();m.register()
for i=1,50 do logic() end;assert(count==0,'no chat before login')
available=true
for i=1,100 do logic() end;assert(count==1,'one notice after login')
for _,s in ipairs({40,30,35,30,37,40,30}) do state({newState=s});m.check() end
assert(count==1,'no loading/hop/reconnect spam')
available=false;state({newState=20});m.check();assert(count==1)
available=true;state({newState=30});m.check();assert(count==2,'new login notice')
package.loaded.startup_notice=nil
m=require('startup_notice');m.register()
for i=1,100 do logic() end;assert(count==3,'activation while logged in')
print('PASS: delayed login, activation, duplicate guard, no hop spam and subsequent login')

state({newState=20});state({newState=30})
PluginPermissions={chatAccess=1};local granted=false
Plugin={HasPermission=function() return granted end}
m.check();assert(count==3,'denied permission must not mark sent')
granted=true
local add=Chat.AddMessage
Chat.AddMessage=function() error('simulated chat failure') end
m.check();assert(count==3)
Chat.AddMessage=add;m.check();assert(count==4,'retry after permission/error recovery')
print('PASS: permission denial, chat failure and successful recovery')

Plugin=nil;m.stateChanged({newState=20});m.stateChanged({newState=30});m.check();assert(count==4,'missing permission API fails closed')
