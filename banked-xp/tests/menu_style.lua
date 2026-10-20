package.path='./?.lua;banked-xp/?.lua;'..package.path
local style=require('menu_style')
local recipes=require('wiki_recipes')
local count=0
for _,r in ipairs(recipes) do
 local label=r.shortLabel or r.method
 r.engine=true
 local colored=style.label(r,label,'ffff00')
 assert(colored:find('<col=ffff00>'..r.method..'</col>',1,true),'every recipe output name is yellow: '..r.method)
 assert(colored:gsub('<[^>]*>','')==label,'recipe text unchanged')
 count=count+1
end
assert(style.label({engine=true,method='Overload'},'Overload [Base potions] [Lv 96]','ffff00')=='<col=ffff00>Overload</col> [Base potions] [Lv 96]')
assert(style.label({method='Ectofuntus'},'Ectofuntus','ffff00')=='Ectofuntus','non-item methods retain text')
assert(style.color({entries={{subjectText='<col=123456>Item</col>'}}})=='123456','native color preferred')
assert(style.color({entries={}})=='ffff00','standard yellow fallback')
local menu={entries={{verbText='Examine'},{verbText='Cancel'},{verbText='Withdraw-All'}}}
function menu:Swap(a,b) self.entries[a],self.entries[b]=self.entries[b],self.entries[a] end
style.prepare(menu)
assert(menu.entries[1].verbText=='Cancel' and menu.entries[2].verbText=='Examine' and menu.entries[3].verbText=='Withdraw-All','Cancel lowest, native actions ordered')
print('PASS: '..count..' recipe color labels, native color inheritance and Cancel placement')
local proxy={entries={{verbText='Examine'},{verbText='',fullText='',actionType=1006},{verbText='Withdraw-All'}}}
function proxy:Swap(a,b) self.entries[a],self.entries[b]=self.entries[b],self.entries[a] end
for _,name in ipairs({'Overload','Extreme necromancy','Next methods'}) do
 local before=#proxy.entries
 local colored='<col=00ffff>BXP</col>: <col=ffff00>'..name..'</col>'
 -- Client exposes the visible string, not Add() markup.
 proxy.entries[#proxy.entries+1]={overrideText=colored:gsub('<[^>]*>','')}
 style.placeAdded(proxy,colored,before)
end
style.prepare(proxy)
assert(proxy.entries[1].actionType==1006,'action-only Cancel is last on screen after all additions')
assert(proxy.entries[#proxy.entries].verbText=='Withdraw-All','default action unchanged')
assert(proxy.entries[#proxy.entries-1].verbText=='Examine','native action ordering preserved')
for i=2,4 do assert(proxy.entries[i].overrideText:find('BXP:',1,true),'colored-label plugin block above Cancel') end
print('PASS: action-only Cancel, stripped client color tags and final menu ordering')
