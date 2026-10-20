package.path='./?.lua;banked-xp/?.lua;'..package.path
-- The client binding rejects extra arguments that stock Lua ignores.
local nativeLower=string.lower
string.lower=function(value,...)
 assert(select('#',...)==0,'client string.lower received extra arguments')
 return nativeLower(value)
end
local e=require('recipe_engine')
local recipe;for _,r in ipairs(e.recipes) do if r.id=='wiki:Extreme ranging:0' then recipe=r end end
local function estimate(counts) return e.estimate({name='Grenwall spikes'},recipe,counts) end
local r=estimate({['grenwall spikes']=10,['super ranging potion (3)']=2})
assert(r.craftable==2 and not r.needsDecanting and not r.note:find('after decanting',1,true),'ready bottles')
r=estimate({['grenwall spikes']=10,['super ranging flask (6)']=1})
assert(r.craftable==2 and r.needsDecanting and r.note:find(', after decanting',1,true),'flask doses need decanting')
r=estimate({['grenwall spikes']=5,['super ranging potion (3)']=1,['super ranging potion (1)']=1})
assert(r.craftable==1 and not r.needsDecanting,'spare partial dose irrelevant when other supply limits')
r=estimate({['grenwall spikes']=15,['super ranging potion (3)']=1,['super ranging potion (1)']=3})
assert(r.craftable==2 and r.needsDecanting,'partial bottles extend craftable amount')
r=estimate({['grenwall spikes']=10,['super ranging flask (3)']=2})
assert(r.craftable==2 and r.needsDecanting,'flask to vial transfer')
r=estimate({['grenwall spikes']=0,['super ranging flask (6)']=1})
assert(r.craftable==0 and not r.needsDecanting,'no decant note with zero crafts')
print('PASS: ready doses, pooled/flask/partial doses, limiting supplies and zero-output decanting qualifiers')
