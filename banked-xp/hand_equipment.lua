-- Cached WORN equipment only. No inventory/API work from tooltip rendering.
local M={}
local rows={}
local function add(names,skills,note,percent)
 for _,name in ipairs(names) do rows[name]={skills=skills,note=note,percent=percent or 0} end
end
add({'sculpting chisel (bandos)','sculpting chisel (guthix)','sculpting chisel (saradomin)','sculpting chisel (zamorak)','sculpting chisel (seren)'}, {Construction=true},'Sculpting chisel: <col=00ff00>+1%</col> Construction XP',1)
add({"artificer's measure"},{Crafting=true,Construction=true},"Artificer's measure: conditional XP stacks up to +5%; active stacks unverified and excluded. Resource-saving and duplication effects excluded")
add({'orthen furnace core'},{Firemaking=true,Smithing=true},'Orthen furnace core: conditional +5% XP requires Furnace Core buff; active buff unverified and excluded')
add({"balarak's sash brush"},{Archaeology=true},"Balarak's sash brush: excavation benefits; restoration XP unchanged")
add({'crystal chisel'},{Crafting=true},'Crystal chisel: 2% extra eligible gem chance; charges and extra output not included')
add({'crystal knife'},{Fletching=true},'Crystal knife: 5% extra shafts or strung-bow chance; charges and proc XP not included')
add({'fenshell knife'},{Fletching=true},'Fenshell knife: 7% resource-saving chance; saved supplies not included. Faster actions apply only to Fenmoor totems')
add({'crystal hammer'},{Smithing=true},'Crystal hammer: 1% double-progress chance; no flat Smithing XP bonus')
add({'hammer-tron','enhanced hammer-tron'},{Smithing=true},'Hammer-tron: Invention training tool; perks and item XP excluded')
add({'pyro-matic','enhanced pyro-matic'},{Firemaking=true},'Pyro-matic: Invention training tool; perks and item XP excluded')
add({'crystal tinderbox'},{Firemaking=true},'Crystal tinderbox: increased fire-spirit chance; spirit rewards excluded')
add({'dragon mattock','crystal mattock','imcando mattock','mattock of time and space',"guildmaster tony's mattock"},{Archaeology=true},'Mattock: excavation benefits; restoration XP unchanged')
add({"farmer's catalyst fragment",'combined catalyst fragment'},{Farming=true},'Catalyst fragment: herb-patch benefits; no flat Farming XP bonus')
function M.evaluate(skill,equipment)
 local percent,notes=0,{}
 for name in pairs(equipment or {}) do
  local key=string.lower(name):gsub('<[^>]*>',''):gsub('’',"'")
  local augmented=key:match('^augmented ')~=nil
  key=key:gsub('^augmented ','')
  local row=rows[key]
  if row and row.skills[skill] then
   percent=percent+row.percent
   notes[#notes+1]=row.note..(augmented and '; augmentation perks and charges unverified' or '')
  end
 end
 table.sort(notes)
 return percent,notes
end
function M.percent(skill)
 local settings=require('settings')
 if not settings.includeHandEquipment or not settings.includeHandEquipment() then return 0 end
 return (M.evaluate(skill,require('outfits').equipment()))
end
function M.decorate(result)
 local settings=require('settings')
 if not result or not settings.includeHandEquipment or not settings.includeHandEquipment() then return result end
 local percent,notes=M.evaluate(result.skill,require('outfits').equipment())
 if #notes==0 then return result end
 local out={};for k,v in pairs(result) do out[k]=v end
 out.handPercent=percent
 if percent>0 and out.total then
  -- Construction's chisel bonus stacks additively with its outfit.
  out.equipmentTotal=out.total*(1+((out.outfitPercent or 0)+percent)/100)
 end
 for _,note in ipairs(notes) do out.note=(out.note and out.note..' | ' or '')..note end
 return out
end
return M
