-- Bounded local diagnostic: one sample per anima name per plugin load.
-- Frame counts are always available; optional os.clock measures CPU, not wall time.
local M={}
local done,active={},nil
local function clock()
    local ok,t=pcall(function() return os.clock() end)
    return ok and type(t)=='number' and t or nil
end
local function emit(reason)
    local a=active
    if not a then return end
    done[a.name]=true;active=nil
    local cpu=a.cpu and string.format(' prepareCPU=%.2fms',a.cpu*1000) or ' prepareCPU=unavailable'
    print('[BXP timing] '..a.name..' end='..reason..' frames='..a.frames
        ..' ready='..tostring(a.ready)..' layout='..tostring(a.layout)
        ..' visible='..tostring(a.visible)..' builds='..a.builds..' detects='..a.detects
        ..' lastGate='..(a.gate or 'none')..(a.render or '')..cpu)
end
function M.begin(name)
    name=require('bank').normalize(name)
    if active and active.name~=name then emit('switched') end
    if done[name] or not name:match('^resonant anima of .+ %(tradeable%)$') then return end
    if not active then active={name=name,frames=0,builds=0,detects=0} end
    active.detects=active.detects+1;active.started=clock()
end
function M.ready()
    if not active then return end
    active.ready=active.ready or active.frames
    local now=clock()
    if now and active.started then active.cpu=(active.cpu or 0)+math.max(0,now-active.started) end
end
function M.gate(reason) if active then active.gate=reason end end
function M.layout()
    if active then active.layout=active.layout or active.frames;active.builds=active.builds+1 end
end
function M.draw() if active then active.frames=active.frames+1 end end
function M.finish(body)
    if not active then return end
    local ok,visible=pcall(function() return body and body.visibleGlobal end)
    if ok and visible and active.layout then active.visible=active.visible or active.frames end
    if body then
        pcall(function()
            local xy=body.xyGlobal
            active.render=' textLength='..tostring(#(body.content or ''))
                ..' rgba='..tostring(body.rgba)..' alpha='..tostring(body.alpha)
                ..' bounds='..tostring(xy.x)..','..tostring(xy.y)..','..tostring(body.width)..','..tostring(body.height)
        end)
    end
    if active.frames>=120 or (active.visible and active.frames-active.visible>=30) then emit('sampled') end
end
return M
