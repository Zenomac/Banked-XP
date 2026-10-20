package.path='./?.lua;banked-xp/?.lua;'..package.path
-- The client binding rejects extra arguments that stock Lua ignores.
local nativeLower=string.lower
string.lower=function(value,...)
 assert(select('#',...)==0,'client string.lower received extra arguments')
 return nativeLower(value)
end
local function copy(t) local c={};for k,v in pairs(t) do c[k]=v end;return c end
local stored={}
PersistentDB={GetStructuredData=function(_,key) return stored[key] and copy(stored[key]) end,
 SetStructuredData=function(_,key,data) stored[key]=copy(data);return true end}
Player={GetLevelGameplay=function() return 104 end,GetLevelCapped=function() return 104 end}
SkillType={HERBLORE=15}
local callbacks={}
Event={SettingsLayerReady={Subscribe=function(id,fn) callbacks[id]=fn end}}
local settings=require('settings');local engine=require('recipe_engine');local methods=require('methods');local catalog=require('catalog')
assert(settings.showUnownedIngredients()==false,'default off')
local function countsBank(counts)
 return {GetSlots=function() local t={};for name,n in pairs(counts) do t[#t+1]={obj={name=name},count=n} end;return t end}
end
local herb={id=801,name='Clean avantoe'};local base=catalog.lookup(herb)
local counts={['clean avantoe']=10,['vial of water']=10,['ancient gravel']=5}
local options=methods.options(herb,base,counts)
local n=0;for _,o in ipairs(options) do if o.method=='Archaeology potion' then n=n+1;assert(o.id=='wiki:Archaeology potion:0') end end
assert(n==1,'only owned soil option')
assert(settings.setShowUnownedIngredients(true))
options=methods.options(herb,base,counts);n=0
for _,o in ipairs(options) do if o.method=='Archaeology potion' then n=n+1 end end
assert(n==7,'enabled shows all soil options')
assert(settings.setShowUnownedIngredients(false))
local spikes={id=802,name='Grenwall spikes'}
local recipe;for _,r in ipairs(engine.recipes) do if r.id=='wiki:Extreme ranging:0' then recipe=r end end
local one={['grenwall spikes']=1,['super ranging potion (1)']=1}
assert(not engine.inputsOwned(spikes,recipe,one),'insufficient batch hidden')
assert(engine.estimate(spikes,recipe,one).craftable==0,'exact quantity still enforced')
assert(not engine.inputsOwned(spikes,recipe,{['grenwall spikes']=10}),'missing other input')
local water={id=803,name='Vial of water'}
local prayer;for _,r in ipairs(engine.recipes) do if r.id=='wiki:Prayer potion:0' then prayer=r end end
assert(engine.inputsOwned({name='Clean ranarr'},prayer,{['grimy ranarr']=1,['vial of water']=1,['snape grass']=1}),'preparation graph')
assert(engine.inputsOwned({name='Ranarr potion (unf)'},prayer,{['ranarr potion (unf)']=1,['snape grass']=1}),'existing unfinished')
assert(not engine.inputsOwned(water,prayer,{['vial of water']=1,['ranarr potion (unf)']=1,['snape grass']=1}),'liquid excludes prepared')
assert(not engine.inputsOwned(spikes,recipe,nil),'unknown bank')
local result,opts=methods.estimate(spikes,catalog.lookup(spikes),countsBank({['grenwall spikes']=5}),5)
assert(#opts==0 and result.total==0 and result.note:find('Missing or insufficient bank ingredients',1,true),'accurate no options reason')
methods.select(herb.id,'wiki:Archaeology potion:6')
result=methods.estimate(herb,base,countsBank(counts),10)
assert(result.method:find('Ancient gravel',1,true),'hidden shared choice skipped')
-- Preferences survive a module reload; settings UI restores and changes them.
package.loaded.settings=nil;settings=require('settings');assert(not settings.showUnownedIngredients())
local constructors={}
local function make(kind,parent)
 local c={kind=kind,parent=parent,children={},text={}}
 if parent then parent.children[#parent.children+1]=c end
 function c:SetPos(...) self.pos={...} end
 function c:SetSize(...) self.size={...} end
 function c:AlignTo(...) self.align={...} end
 function c:Subscribe(hook,id,fn) self.callback=fn end
 constructors[#constructors+1]=c
 return c
end
ui={Panel={new=function(p) return make('panel',p) end},Text={new=function(p) return make('text',p) end},Check={new=function(p) return make('check',p) end},AlignMode={TOPLEFT=0},CheckAlignMode={LEFT=1},Hook={ONBUTTONPRESSED=2}}
id={StyleSheet={DEFAULT=1,CHECKBOX_DEFAULT=2}}
local settingsUI=require('settings_ui');settingsUI.register();assert(callbacks.bankedXpSettings)
local root={children={}};callbacks.bankedXpSettings({component=root})
local check,status
for _,c in ipairs(constructors) do if c.kind=='check' and c.label=='Show recipes with missing ingredients.' then check=c end;status=c end
assert(check.label=='Show recipes with missing ingredients.' and check.value==false)
check.callback(check,true);assert(settings.showUnownedIngredients())
check.callback(check,0);assert(not settings.showUnownedIngredients())
check.value=true;check.callback(check,nil);assert(settings.showUnownedIngredients())
for _,c in ipairs(constructors) do
 if c.kind=='check' and c.label=='Show recipes above my level.' then
  assert(c.value==false);c.callback(c,true);assert(settings.showUnderlevelRecipes(),'second checkbox saves independently')
 end
end
for _,c in ipairs(constructors) do
 if c.kind=='check' and c.label=='Show recipes within boosting range.' then
  assert(c.value==false);c.callback(c,true);assert(settings.showBoostableRecipes(),'boost checkbox saves independently')
 end
end
package.loaded.settings=nil;assert(require('settings').showUnownedIngredients(),'UI change persisted')
print('PASS: default and saved setting, UI build/callbacks, owned alternatives, doses/preparations, full batch quantities, empty bank and hidden shared choices')

assert(settings.showRecipeOnHover(),'new preference defaults on for existing settings')
local checks=0
for _,c in ipairs(constructors) do
 if c.kind=='check' then checks=checks+1;assert(c.size[2]==34) end
 if c.kind=='text' then assert(c.content and c.content:find('Diango',1,true),'only Diango note added') end
 if c.label=='Show ingredients on hover.' then
  assert(c.value==true);c.callback(c,false);assert(not settings.showRecipeOnHover())
 end
end
assert(checks==7 and root.children[1].spacing==4)
assert(checks*34+(checks-1)*4+22+32<=340,'all settings fit compact window')
package.loaded.settings=nil;assert(not require('settings').showRecipeOnHover(),'recipe choice persists')

local note
for _,c in ipairs(constructors) do
 if c.kind=='text' then note=c;assert(not c.content:find('by Zenomac',1,true),'author credit removed') end
end
assert(note and note.maxLines==1 and note.content:find('Diango',1,true),'Diango ownership note')
local children=root.children[1].children
local outfitIndex,noteIndex,handIndex
for i,c in ipairs(children) do
 if c.label=='Apply worn outfit XP bonuses.' then outfitIndex=i end
 if c==note then noteIndex=i end
 if c.label=='Include equipped skilling tools.' then handIndex=i end
end
assert(noteIndex==outfitIndex+1 and handIndex==noteIndex+1,'note directly below outfit setting')

assert(settings.includeOutfitBonuses(),'outfit bonus default on')
local outfitCheck
for _,c in ipairs(constructors) do if c.label=='Apply worn outfit XP bonuses.' then outfitCheck=c end end
assert(outfitCheck and outfitCheck.value==true)
outfitCheck.callback(outfitCheck,false)
assert(not settings.includeOutfitBonuses(),'outfit setting toggles independently')
package.loaded.settings=nil;assert(not require('settings').includeOutfitBonuses(),'outfit setting persists')
