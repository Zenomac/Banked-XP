package.path='./?.lua;banked-xp/?.lua;'..package.path
-- Existing potion audit intentionally scopes the recipe provider to Herblore.
package.preload.skill_recipes=function() return {} end
-- The client binding rejects extra arguments that stock Lua ignores.
local nativeLower=string.lower
string.lower=function(value,...)
 assert(select('#',...)==0,'client string.lower received extra arguments')
 return nativeLower(value)
end
-- Exercise existing behavior with unowned recipes explicitly enabled.
package.loaded.settings={showRecipeOnHover=function() return true end,showUnownedIngredients=function() return true end,showUnderlevelRecipes=function() return true end,showBoostableRecipes=function() return false end}
local e=require('recipe_engine')
local function get(name,tableID)
 for _,r in ipairs(e.recipes) do if r.method==name and (not tableID or r.id=='wiki:'..name..':'..tableID) then return r end end
 error('Missing recipe '..name)
end
local function estimate(item,name,counts,id) return e.estimate({name=item},get(name,id),counts) end
local function eq(a,b,label) assert(a==b,(label or '')..': '..tostring(a)..' != '..tostring(b)) end
local r=estimate('Grenwall spikes','Extreme ranging',{['grenwall spikes']=49,['super ranging potion (4)']=9},0)
eq(r.craftable,9,'spikes');eq(r.total,2340,'spikes xp');eq(r.inputPerPotion,5)
r=estimate('Clean ranarr','Prayer potion',{['clean ranarr']=10,['grimy ranarr']=4,['vial of water']=12,['snape grass']=20,['ranarr potion (unf)']=3},0)
eq(r.craftable,15,'pooled herbs and unfinished');eq(r.total,1312.5)
r=estimate('Vial of water','Prayer potion',{['clean ranarr']=10,['vial of water']=3,['snape grass']=20,['ranarr potion (unf)']=50},0)
eq(r.craftable,3,'liquid excludes prepared')
r=estimate('Ranarr potion (unf)','Prayer potion',{['clean ranarr']=10,['vial of water']=10,['snape grass']=20,['ranarr potion (unf)']=2},0)
eq(r.craftable,2,'unfinished only')
r=estimate('Clean ranarr','Prayer potion',{['clean ranarr']=10,['snape grass']=20},0);eq(r.craftable,0,'missing water')
-- Dose matching across vial and flask sizes.
r=estimate('Super ranging flask (6)','Extreme ranging',{['super ranging flask (6)']=2,['super ranging potion (1)']=2,['grenwall spikes']=100},0)
eq(r.craftable,4,'dose pool')
assert(e.key('Antipoison+ (4)')~=e.key('Antipoison++ (4)'),'strength keys')
-- Every recipe works when supplied exactly with its direct ingredients.
for _,recipe in ipairs(e.recipes) do
 local counts={}
 for _,i in ipairs(recipe.inputs) do counts[string.lower(i.name)]=(counts[string.lower(i.name)] or 0)+i.qty end
 local x=e.estimate({name=recipe.inputs[1].name},recipe,counts)
 assert(x.craftable==recipe.output.qty,'direct inputs fail '..recipe.id..' '..tostring(x.craftable))
 assert(x.total==recipe.xp,'XP fail '..recipe.id)
 for k in pairs(recipe.keys) do
  local found=false
  -- Each transitive ingredient is indexed to this exact route.
  for _,candidate in ipairs(e.options({name=k:sub(6)})) do if candidate.id==recipe.id then found=true end end
  -- Dose keys are canonical pools, not literal item names.
  if k:sub(1,5)=='item:' then assert(found,'index '..k..' '..recipe.id) end
 end
end
-- Master cape outputs use batch XP divided by actual output count.
r=estimate('Clean torstol','Overload',{['clean torstol']=4,['extreme attack (3)']=4,['extreme strength (3)']=4,['extreme defence (3)']=4,['extreme ranging (3)']=4,['extreme magic (3)']=4,['extreme necromancy (3)']=4},1)
eq(r.craftable,5);eq(r.total,4000);eq(r.xp,800)
Player={GetLevelGameplay=function() return 120 end};SkillType={HERBLORE=15};local methods=require('methods');local catalog=require('catalog')
local obj={id=100,name='Grenwall spikes'};assert(catalog.lookup(obj));assert(#methods.options(obj,catalog.lookup(obj))>0)
local menu={entries={{verbText='Withdraw-All'}}}
function menu:Add(label,callback) self.entries[#self.entries+1]={verbText=label,callback=callback} end
function menu:Swap(a,b) self.entries[a],self.entries[b]=self.entries[b],self.entries[a] end
methods.addMenu(menu,obj,methods.options(obj,catalog.lookup(obj)))
eq(menu.entries[#menu.entries].verbText,'Withdraw-All','native priority')
print('PASS: 251 direct recipes, ingredient index, supply limits, doses, unfinished, cape batches and menu priority')
-- All virtual unfinished preparations resolve to their exact bank ingredients.
local producers={}
for _,p in ipairs(require('wiki_preparations')) do producers[e.key(p.output.name)]=p end
local function expand(name,n,counts,seen)
 local k=e.key(name);local p=producers[k]
 if p and not seen[k] then
  seen[k]=true
  for _,i in ipairs(p.inputs) do expand(i.name,n*i.qty/p.output.qty,counts,seen) end
  seen[k]=nil
 else
  local norm=string.lower(name);counts[norm]=(counts[norm] or 0)+n
 end
end
for _,recipe in ipairs(e.recipes) do
 local counts={}
 for _,i in ipairs(recipe.inputs) do expand(i.name,i.qty,counts,{}) end
 -- Use a non-uf source to permit virtual preparation.
 local item=recipe.inputs[1].name
 for name in pairs(counts) do if not name:find('(unfinished)',1,true) and name~='vial of water' and name~='juju vial of water' and name~='coconut milk' then item=name;break end end
 local r=e.estimate({name=item},recipe,counts)
 assert(r.craftable==recipe.output.qty,'prepared inputs '..recipe.id..' '..r.craftable)
end
local water={id=200,name='Vial of water'}
local options=methods.options(water,catalog.lookup(water));assert(#options>10)
local seen={}
for page=1,math.ceil(#options/10) do
 local m={entries={{verbText='Withdraw-All'}},Add=menu.Add,Swap=menu.Swap}
 methods.addMenu(m,water,options)
 assert(#m.entries<=13,'menu bounded')
 eq(m.entries[#m.entries].verbText,'Withdraw-All','paged menu priority')
 local nextPage
 for _,entry in ipairs(m.entries) do
  if entry.verbText:find('Next methods',1,true) then nextPage=entry.callback
  elseif not entry.verbText:find('Previous methods',1,true) then seen[entry.verbText]=true end
 end
 if nextPage then nextPage() end
end
local n=0;for _ in pairs(seen) do n=n+1 end
eq(n,#options+1,'all method pages reachable')
print('PASS: all 251 recipes from raw unfinished-preparation inputs and complete paginated menus')
-- Native API lists menu entries in reverse screen order.
local ordered={entries={{verbText='Cancel'},{verbText='Examine'},{verbText='Withdraw-All',subjectText='<col=ffff00>Extreme necromancy (4)</col>'}},Add=menu.Add,Swap=menu.Swap}
local many={}
for i=1,25 do many[i]={id='color:'..i,engine=true,method=i==1 and 'Overload' or 'Extreme necromancy',shortLabel=i==1 and 'Overload' or 'Extreme necromancy',skill='Herblore',level=1} end
methods.addMenu(ordered,obj,many,{skill='Herblore'})
eq(ordered.entries[1].verbText,'Cancel','Cancel below all plugin entries')
eq(ordered.entries[#ordered.entries].verbText,'Withdraw-All','default native action retained')
eq(ordered.entries[#ordered.entries-1].verbText,'Examine','native Examine retained above plugin block')
local seen=0
for i,entry in ipairs(ordered.entries) do
 if entry.verbText:find('<col=00ffff>BXP</col>:',1,true) then
  assert(i>1 and i<#ordered.entries-1,'all plugin actions including pagination above Cancel and below native actions')
  if entry.verbText:find('<col=ffff00>',1,true) then seen=seen+1 end
 end
end
eq(seen,10,'all potion names colored on first menu page')
print('PASS: colored recipe menu and pagination above Cancel, native actions unchanged')
