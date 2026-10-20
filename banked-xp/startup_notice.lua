-- Local chat only. Errors must be visible rather than silently swallowed.
local M={}
local registered,shown,ticks=false,false,0
local state,readyTicks,lastError=nil,0,nil
local message='<col=00ffff>BXP</col>: Outfits stored with Diango are not detected. Reclaim them into your backpack so Banked XP can recognize them for this session.'
local function report(reason)
 if reason==lastError then return end
 lastError=reason
 print('[banked-xp] Diango notice: '..reason)
end
local function available()
 if state~=nil then return state==30 end
 local ok,value=pcall(function() return Player.IsAvailable() end)
 if ok then return value end
 -- Older beta builds may expose the player entity but not IsAvailable.
 local success,entity=pcall(function() return Player.GetEntity() end)
 if success and entity then return true end
 report('waiting for player availability; '..tostring(value))
 return false
end
function M.check()
 if shown or not available() then return end
 if Plugin and Plugin.HasPermission and PluginPermissions then
  local ok,allowed=pcall(function() return Plugin.HasPermission(PluginPermissions.chatAccess) end)
  if not ok or not allowed then
   report('chatAccess is not granted. Optional chat access is disabled; XP tooltips remain available.')
   return
  end
 end
 local ok,result=pcall(function() return Chat.AddMessage(message) end)
 if not ok or result==false then
  report('Chat.AddMessage failed: '..tostring(result));return
 end
 shown=true;lastError=nil
 print('[banked-xp] Diango notice queued to local chat. If hidden, check the chat tab/filter for plugin messages.')
end
function M.stateChanged(event)
 if not event then return end
 state=event.newState;readyTicks=0
 if state==10 or state==20 then shown=false;lastError=nil end
end
function M.register()
 if registered then return end;registered=true
 print('[banked-xp] Diango chat notice enabled (v0.108).')
 if Event and Event.GameStateChanged then Event.GameStateChanged.Subscribe('bankedXpDiangoNotice',M.stateChanged) end
 if Event and Event.Logic then
  Event.Logic.Subscribe('bankedXpDiangoNotice',function()
   ticks=ticks+1
   if shown then return end
   -- Let login chat/interface initialization finish before enqueueing.
   if ticks%25==1 then
    if available() then readyTicks=readyTicks+1 else readyTicks=0 end
    if readyTicks>=3 then M.check() end
   end
  end)
 end
end
return M
