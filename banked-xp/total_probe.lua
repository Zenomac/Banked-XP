-- Temporary, read-only total-XP discovery. Never changes native UI.
local M={}
local scopes={{1477,923},{1477,924},{1477,904},{1477,902},{1477,901},{1477,900},{1477,899},{1477,897},{1477,898},{320,16},{320,17},{320,13},{320,11},{320,0}}
local ticks,passes,genericCount,totalCount=0,0,0,0
local seen={}
local function read(c,k) local ok,v=pcall(function() return c[k] end);if ok then return v end end
local function get(...) local args={...};local ok,c=pcall(function() return ui.Interfaces:GetComponent(table.unpack(args)) end);if ok then return c end end
local function clean(s) return (s:gsub('<[^>]*>','')) end
function M.scan(phase)
 phase=phase or 'Logic'
 local visible,texts,nodes=0,0,0
 for _,scope in ipairs(scopes) do
  local budget,childLookups=96,160
  local visited={}
  local function inspect(c,depth,label)
   if not c or depth>4 or budget<=0 or visited[c] or not read(c,'visibleGlobal') then return end
   visited[c]=true;budget=budget-1;nodes=nodes+1
   if depth==0 then visible=visible+1 end
   local content=read(c,'content')
   if type(content)=='string' and content~='' then
    texts=texts+1
    local text=clean(content):gsub('[\r\n]',' ')
    local isTotal=text:lower():find('total',1,true) and text:lower():find('xp',1,true)
    local key=scope[1]..':'..scope[2]..':'..label..':'..text
    if not seen[key] and ((isTotal and totalCount<12) or (not isTotal and genericCount<18)) then
     seen[key]=true
     if isTotal then totalCount=totalCount+1 else genericCount=genericCount+1 end
     local xy=read(c,'xyGlobal') or {}
     print('[BXP total probe] '..(isTotal and 'TOTAL MATCH ' or 'visible text ')..scope[1]..':'..scope[2]..' phase='..phase..' path='..label..' component='..tostring(read(c,'interfaceID'))..':'..tostring(read(c,'staticID'))..':'..tostring(read(c,'categoryID'))..':'..tostring(read(c,'dynamicID'))..' pos='..tostring(xy.x)..','..tostring(xy.y)..' size='..tostring(read(c,'width'))..'x'..tostring(read(c,'height'))..' font='..tostring(read(c,'font'))..' text='..text:sub(1,220))
    end
   end
   -- Some native collections iterate; others expose children only by ID.
   for _,method in ipairs({'IterateStaticComponents','IterateDynamicComponents'}) do
    pcall(function() c[method](c,function(child,shown)
     if shown~=false then inspect(child,depth+1,label..'/'..method) end
     return budget<=0
    end) end)
   end
   -- Direct collection lookup is a separate API path from Interfaces lookup.
   -- Native iteration can return no children even when GetChild succeeds.
   if depth<=1 then
    for category=0,3 do
     for id=0,31 do
      if childLookups<=0 or budget<=0 then break end
      childLookups=childLookups-1
      local ok,child=pcall(function() return c:GetChild(category,id) end)
      if ok then inspect(child,depth+1,label..'/child/'..category..'/'..id) end
     end
    end
   end
  end
  inspect(get(scope[1],scope[2]),0,'static')
  for id=0,64 do
   if budget<=0 then break end
   inspect(get(scope[1],scope[2],0,id),1,'dynamic/'..id)
  end
 end
 passes=passes+1
 if passes<=6 then print('[BXP total probe] '..phase..' read-only pass '..passes..': visible roots='..visible..'; nodes='..nodes..'; text nodes='..texts..'. Hover total XP for at least one second.') end
end
function M.register()
 if not Event.Logic then return end
 Event.Logic.Subscribe('bankedXpTotalDiscovery',function()
  ticks=ticks+1;if ticks%25~=1 then return end
  local ok,err=pcall(M.scan,'Logic')
  if not ok and not M.warned then print('[BXP total probe] Read error: '..tostring(err));M.warned=true end
 end)
 if Event.Draw then
  local draws=0
  Event.Draw.Subscribe('bankedXpTotalDiscovery',function()
   draws=draws+1;if draws%25~=1 then return end
   local ok,err=pcall(M.scan,'Draw')
   if not ok and not M.drawWarned then print('[BXP total probe] Draw read error: '..tostring(err));M.drawWarned=true end
  end)
 end
 print('[BXP total probe] v0.107 read-only child/Logic/Draw discovery enabled; existing hovers remain active.')
end
return M
