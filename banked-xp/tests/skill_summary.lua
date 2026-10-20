package.path='./?.lua;banked-xp/?.lua;'..package.path
local nativeCoroutine=coroutine
coroutine=setmetatable({}, {__index=function() error('client path must not use coroutines',0) end})
-- The client binding rejects extra arguments that stock Lua ignores.
local nativeLower=string.lower
string.lower=function(value,...)
 assert(select('#',...)==0,'client string.lower received extra arguments')
 return nativeLower(value)
end
PersistentDB={GetStructuredData=function() return {} end,SetStructuredData=function() return true end}
Player={GetLevelGameplay=function() return 104 end,GetLevelCapped=function() return 104 end};SkillType={HERBLORE=15,FIREMAKING=11}
local summary=require('skill_summary');local engine=require('recipe_engine');local methods=require('methods');local settings=require('settings')
assert(summary.line('Herblore'):find('open your bank',1,true))
assert(summary.line('Cooking'):find('open your bank',1,true))
local function bank(records,id)
 return {id=id,GetSlots=function() return records end}
end
local function slot(name,id,n) return {obj={name=name,id=id},count=n} end
local function finish() for _=1,3000 do summary.advance(1) end end
local herb={id=1102,name='Clean bloodweed'}
methods.select(herb.id,'wiki:Aggression potion:0')
local b=bank({slot('Clean bloodweed',1102,10),slot('Bloodweed potion (unfinished)',1103,10),slot('Searing ashes',1104,5)},881)
summary.capture(b);assert(summary.line('Herblore'):find('calculating',1,true));finish()
assert(summary.line('Herblore'):find('925',1,true),summary.line('Herblore')) -- 5*185; recipe deduplicated across both ingredient hovers
local k=engine.key('Test shared ingredient')
local function route(id,xp) return {id=id,xp=xp,keys={[k]=true},inputsNormalized={{key=k,qty=1,name='Test shared ingredient'}}} end
local total,used=engine.portfolio({route('a',100),route('b',200)},{['test shared ingredient']=5})
assert(total==500 and used==1,'shared ingredient must not be spent by second route')
local before=summary.line('Herblore');summary.capture(b);assert(summary.line('Herblore')==before,'unchanged bank reuses finished cache')
summary.clear();assert(summary.line('Prayer'):find('open your bank',1,true))
summary.capture(bank({slot('Maple logs',1517,100)},882));finish()
assert(summary.line('Firemaking'):find('18,200',1,true),summary.line('Firemaking'))
methods.select(1517,'bonfire5');summary.capture(bank({slot('Maple logs',1517,100)},882));finish()
assert(summary.line('Firemaking'):find('18,200',1,true),summary.line('Firemaking'))
summary.clear();summary.capture(bank({},883));finish();assert(summary.line('Prayer'):find('Banked XP: 0',1,true),'known empty bank is zero')
settings.setShowUnderlevelRecipes(true)
local base={skill='Herblore',method='Extreme strength',xp=230}
for _,r in ipairs(engine.recipes) do
 if r.level==106 then
  local obj={id=99999,name=r.inputs[1].name}
  local chosen=methods.summaryMethod(obj,base,{})
  assert(not chosen or chosen.level==nil or chosen.level<=104,'unmet preview excluded from summary')
  break
 end
end
print('PASS: summary bank states, 251-route planner integration, recipe deduplication, shared stock budget, highest Firemaking method independent of saved choice and preview exclusion')

-- A failed asynchronous scan must report its original error, with an explicit
-- numeric stack level for the client's error binding.
local savedLookup=require('catalog').lookup
require('catalog').lookup=function() error('original scan failure',0) end
summary.clear();summary.capture(bank({slot('Clean bloodweed',1102,1)},884))
local ok,err=pcall(summary.advance,1)
assert(not ok and tostring(err):find('original scan failure',1,true),'preserve scan failure')
require('catalog').lookup=savedLookup
-- Skill summaries must choose high-XP methods rather than saved item choices.
SkillType.FLETCHING=9
methods.select(1517,'regular')
local routes=engine.options({name='Maple logs'})
for _,r in ipairs(routes) do if r.method=='Maple shortbow (unstrung)' then methods.select(1517,r.id) end end
summary.clear();require('bank').invalidate()
summary.capture(bank({slot('Maple logs',1517,100),slot('Bowstring',1911,100)},885));finish()
assert(summary.line('Firemaking'):find('18,200',1,true),'highest bonfire method regardless of saved choice')
assert(summary.line('Fletching'):find('10,420',1,true),'higher-XP complete bow route uses bowstrings')
assert(summary.tooltipLine('Firemaking')=='Banked XP: 18,200','compact skill line uses full number')
assert(summary.supports('Archaeology') and not summary.supports('Attack'))
print('PASS: highest-XP method selection, independent skill budgets, no item-choice dependency, full formatted number')
SkillType.CONSTRUCTION=22
local realLookup=require('catalog').lookup
require('catalog').lookup=function() return nil end
summary.clear();require('bank').invalidate()
summary.capture(bank({slot('Oak plank',2111,100)},886));finish()
assert(not summary.line('Construction'):find('Banked XP: 0 ',1,true),'Construction must resolve supplies without catalogue first-skill match')
require('catalog').lookup=realLookup
print('PASS: Construction supply lookup independent of item catalogue')
SkillType.ARCHAEOLOGY=28
local artefact
for _,r in ipairs(engine.recipes) do
 if r.skill=='Archaeology' and r.level<=104 and r.inputs[1].name:lower():match('%(damaged%)$') then artefact=r;break end
end
assert(artefact,'fixture artefact exists')
summary.clear();require('bank').invalidate()
summary.capture(bank({slot(artefact.inputs[1].name,99991,3)},887));finish()
local expected=string.format('%.0f',3*artefact.xp):reverse():gsub('(%d%d%d)','%1,'):reverse():gsub('^,','')
assert(summary.tooltipLine('Archaeology')=='Banked XP: '..expected,summary.tooltipLine('Archaeology'))
assert(summary.tooltipExtra('Archaeology')=='0','missing materials should have zero ready XP, not zero artefact potential')
local all={}
for i,input in ipairs(artefact.inputs) do all[#all+1]=slot(input.name,99990+i,input.qty*3) end
summary.clear();require('bank').invalidate();summary.capture(bank(all,888));finish()
assert(summary.tooltipLine('Archaeology')=='Banked XP: '..expected)
assert(summary.tooltipExtra('Archaeology')==nil,'fully supplied artefacts need no second row')
print('PASS: damaged artefact potential without materials, ready XP remains supply-limited, fully supplied agreement')
summary.clear();require('bank').invalidate()
assert(summary.totalLine()=='Banked XP: Scan bank')
summary.capture(bank({slot('Maple logs',1517,100),slot('Bowstring',1911,100)},901))
assert(summary.totalLine()=='Banked XP: Calculating...');finish()
assert(summary.totalLine()=='Banked XP: 18,200',summary.totalLine())
assert(summary.tooltipLine('Fletching')=='Banked XP: 10,420','individual alternative remains available')
-- Artefact potential is retained in the total even without restoration mats.
summary.clear();require('bank').invalidate()
summary.capture(bank({slot(artefact.inputs[1].name,99991,3)},902));finish()
assert(summary.totalLine()=='Banked XP: '..expected,summary.totalLine())
summary.clear();require('bank').invalidate();summary.capture(bank({},903));finish()
assert(summary.totalLine()=='Banked XP: 0')
print('PASS: combined total shares supplies across skills, bank states, empty bank, and artefact potential')
