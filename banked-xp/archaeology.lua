-- A damaged artefact is useful to inspect even with no restoration supplies.
-- Keep the recipe menu filtered and zero-supply XP distinct from potential XP.
local M={}
local engine=require('recipe_engine')
local policy=require('recipe_policy')
local function copy(r) local o={};for k,v in pairs(r) do o[k]=v end;return o end
function M.decorate(result,options,obj,base,bank,count)
 local name=(obj.name or ''):lower()
 if not result or result.skill~='Archaeology' or not (name:match('%(damaged%)$') or name:match('^damaged soul beacon')) then return result end
 local counts=require('bank').snapshot(bank)
 local eligible=policy.filter(engine.options(obj),policy.state(counts,'Archaeology'))
 if #eligible==0 then return result end
 local out=copy(result)
 if not options or #options==0 then
  out=copy(engine.estimate(obj,eligible[1],counts))
  out.artefactPreview=true
  out.method=eligible[1].method
  if not require('settings').showRecipeOnHover() then out.note='Limited by: '..(out.limitingIngredient or 'restoration materials') end
 end
 local potential=(count or 0)*(out.xp or eligible[1].xp)
 out.note=(out.note and out.note..' | ' or '')..string.format('Potential base XP from all damaged artefacts: %.1f (requires restoration materials)',potential)
 out.note=out.note..' | '..require('storage').status()
 return out
end
return M
