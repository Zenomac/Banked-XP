package.path='./?.lua;banked-xp/?.lua;'..package.path
local stored={}
PersistentDB={GetStructuredData=function(_,k) return stored[k] end,SetStructuredData=function(_,k,v) stored[k]=v;return true end}
local support=require('skill_support');SkillType={}
for i,s in ipairs(support.names) do SkillType[s:upper()]=i end
local real,live=99,99
Player={GetLevelGameplay=function() return live end,GetLevelCapped=function() return real end}
local settings=require('settings');settings.setShowUnownedIngredients(true)
local engine=require('recipe_engine');local methods=require('methods');local catalog=require('catalog');local bankData=require('bank')
local function route(name)
 for _,r in ipairs(engine.recipes) do if r.skill=='Summoning' and r.method==name then return r end end
 error(name)
end
local potato={id=987001,name='Potato cactus'}
local kalphite=route('Spirit kalphite pouch')
local stock={['potato cactus']=10,pouch=10,['blue charm']=3,['spirit shards']=102}
assert(engine.estimate(potato,kalphite,stock).total==440,'shards cap two pouches')
local missing={['potato cactus']=10,pouch=10,['spirit shards']=1000}
assert(engine.estimate(potato,kalphite,missing).total==0,'charms required')
local muspah=route('Nightmare muspah pouch')
assert(engine.estimate({name='Muspah spine'},muspah,{['muspah spine']=2,pouch=2,['elder charm']=2,['elder energy']=150}).total==145.3,'elder energy replaces shards')
local wolf=route('Wolpertinger pouch')
assert(#wolf.inputs==5 and wolf.inputs[4].name=='Raw rabbit' and wolf.inputs[5].name=='Wolf bones','both tertiaries required')
local slots={}
for name,n in pairs(stock) do slots[#slots+1]={obj={name=name,id=#slots+1},count=n} end
local bank={GetSlots=function() return slots end}
local base=catalog.lookup(potato)
local function estimate() return methods.estimate(potato,base,bank,10) end
local result=estimate()
assert(result.note:find('Dual-use:',1,true) and result.note:find('Summoning',1,true),'dual-use note')
local function menuFor()
 local _,options=estimate()
 local menu={entries={{verbText='Cancel'},{verbText='Withdraw-All'}}}
 function menu:Add(label,fn) self.entries[#self.entries+1]={verbText=label,callback=fn} end
 function menu:Swap(a,b) self.entries[a],self.entries[b]=self.entries[b],self.entries[a] end
 methods.addMenu(menu,potato,options,base)
 return menu
end
methods.selectSkill(potato.id,'Herblore')
local menu=menuFor();local switched=false
for _,e in ipairs(menu.entries) do if e.verbText=='<col=00ffff>BXP</col>: Use Summoning' then e.callback();switched=true end end
assert(switched,'skill switch provided')
result=estimate();assert(result.skill=='Summoning' and result.total==440,'skill choice drives hover')
methods.select(500,'wiki:Super magic:0')
assert(estimate().skill=='Summoning','shared recipe cannot override skill choice')
menu=menuFor()
assert(menu.entries[1].verbText=='Cancel','Cancel stays lowest in native reverse order')
for _,e in ipairs(menu.entries) do assert(not e.verbText:find('Super magic',1,true),'other-skill recipes hidden') end
package.loaded.methods=nil;methods=require('methods')
assert(estimate().skill=='Summoning','saved skill survives reload')
local candidates=methods.summaryCandidates(potato,base,stock);local seen={}
for _,r in ipairs(candidates) do seen[r.skill]=true end
assert(seen.Herblore and seen.Summoning,'summary retains all uses')
settings.setShowUnownedIngredients(false)
slots={};bankData.invalidate()
result=estimate();assert(result.total==0,'no fabricated XP without ingredients')
settings.setShowUnownedIngredients(true)
real=20;live=99
local options=methods.options(potato,base,stock)
for _,r in ipairs(options) do assert(r.id~=kalphite.id,'temporary boost cannot unlock pouches') end
real=99;live=99
methods.selectSkill(potato.id,'Herblore');assert(estimate().skill=='Herblore','switch back')
methods.resetMemory();assert(stored.xpMethodsV1,'uses existing privacy-reset storage key')
print('PASS: Summoning supplies, elder energy, dual use, menu skill switch, persistence, boost restriction and independent summary candidates')

-- Alternate granite is a direct recipe, not an assumed automatic split.
local granites={}
for _,r in ipairs(engine.recipes) do
 if r.skill=='Summoning' and r.method=='Granite lobster pouch' then
  local name=r.inputs[4].name;granites[name]=true
  local n=engine.estimate({name=name},r,{[name:lower()]=1,pouch=20,['crimson charm']=20,['spirit shards']=3320})
  assert(n.craftable==1 and n.total==325.6,'one direct granite input consumes one piece')
 end
end
assert(granites['Granite (500g)'] and granites['Granite (2kg)'] and granites['Granite (5kg)'])
local scroll
for _,r in ipairs(engine.options({name='Steel titan pouch'})) do if r.category=='Scroll conversion' then scroll=r end end
assert(scroll and scroll.xp==4.9 and scroll.output.qty==10,'XP is per pouch, not per scroll')
local conversion=engine.estimate({name='Steel titan pouch'},scroll,{['steel titan pouch']=10})
assert(conversion.craftable==100 and math.abs(conversion.total-49)<0.000001,'finished pouches award conversion XP only')
assert(engine.estimate({name='Steel titan pouch'},scroll,{}).total==0,'conversion requires owned finished pouches')
assert(#engine.options({name='Steel Titan scroll (Steel of Legends)'})==0,'no repeated conversion of scroll output')
print('PASS: all granite sizes; finished pouch conversion, per-batch XP and no output recycling')
