package.path='./?.lua;banked-xp/?.lua;'..package.path
-- The client binding rejects extra arguments that stock Lua ignores.
local nativeLower=string.lower
string.lower=function(value,...)
 assert(select('#',...)==0,'client string.lower received extra arguments')
 return nativeLower(value)
end
local logic
Event={Logic={Subscribe=function(_,fn) logic=fn end}}
local b=require('bank');local reads=0;local count=1
local function proxy(id)
 return {id=id,isValid=true,GetSlots=function() reads=reads+1;return {{obj={name='Clean guam'},count=count},{obj={name='Place holder'},count=0}} end}
end
assert(b.snapshot(proxy(95))['clean guam']==1)
count=2
assert(b.snapshot(proxy(95))['clean guam']==1 and reads==1,'fresh wrapper invalidated cache')
for _=1,25 do logic() end
assert(b.snapshot(proxy(95))['clean guam']==2 and reads==2,'refresh after logic ticks')
b.invalidate();assert(b.snapshot(proxy(95))['clean guam']==2 and reads==3,'explicit invalidation')
assert(b.snapshot(proxy(96)) and reads==4,'different inventory cannot share snapshot')
assert(not b.snapshot({id=96,isValid=false}),'invalid inventory ignored')
assert(b.snapshot(proxy(96)) and reads==5,'invalid inventory clears cache')
print('PASS: stable inventory-ID cache, new wrappers, tick refresh, explicit invalidation and invalid containers')

local bankData=require('bank')
assert(select('#',bankData.normalize('Clean ranarr'))==1,'normalizer returns only the string')
assert(bankData.normalize("<col=fff>Rogue’s purse</col>")=="rogue's purse")
print('PASS: single-value normalization and formatted names')
