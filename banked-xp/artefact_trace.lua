-- Bounded, one-time diagnostics; no inventory work on Draw.
local M={}
local seen,n={},0
function M.log(name,reason)
 name=name or ''
 if not name:lower():find('damaged',1,true) then return end
 local key=name..':'..reason
 if seen[key] or n>=80 then return end
 seen[key]=true;n=n+1
 print('[BXP artefact] '..name..': '..reason)
end
function M.selection(obj,base,result,options,count)
 local name=obj.name or ''
 if not name:lower():find('damaged',1,true) then return end
 local level=require('skill_support').level('Archaeology','GetLevelGameplay')
 local recipes=require('recipe_engine').options(obj)
 local required=recipes[1] and recipes[1].level
 M.log(name,'id='..tostring(obj.id)..', skill='..tostring(base.skill)..', level='..tostring(level)..', required='..tostring(required)..', bank='..tostring(count)..', recipes='..#recipes..', options='..#(options or {})..', preview='..tostring(result and result.artefactPreview)..', method='..tostring(result and result.method))
end
return M
