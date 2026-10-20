local M={}
local defaults={showUnownedIngredients=false,showUnderlevelRecipes=false,showBoostableRecipes=false,showRecipeOnHover=true,includeOutfitBonuses=true,includeHandEquipment=true}
local values={}
for key,value in pairs(defaults) do values[key]=value end
local ok,stored=pcall(function() return PersistentDB:GetStructuredData('xpSettingsV1') end)
if ok and type(stored)=='table' then
    for key in pairs(values) do if type(stored[key])=='boolean' then values[key]=stored[key] end end
end
local function set(key,value)
    if type(value)~='boolean' then return false end
    values[key]=value
    local ok,saved=pcall(function() return PersistentDB:SetStructuredData('xpSettingsV1',values) end)
    require('bank').invalidate()
    return ok and saved==true
end
function M.showUnownedIngredients() return values.showUnownedIngredients end
function M.setShowUnownedIngredients(v) return set('showUnownedIngredients',v) end
function M.showUnderlevelRecipes() return values.showUnderlevelRecipes end
function M.setShowUnderlevelRecipes(v) return set('showUnderlevelRecipes',v) end
function M.showBoostableRecipes() return values.showBoostableRecipes end
function M.setShowBoostableRecipes(v) return set('showBoostableRecipes',v) end
function M.showRecipeOnHover() return values.showRecipeOnHover end
function M.setShowRecipeOnHover(v) return set('showRecipeOnHover',v) end
function M.includeOutfitBonuses() return values.includeOutfitBonuses end
function M.setIncludeOutfitBonuses(v) return set('includeOutfitBonuses',v) end
function M.includeHandEquipment() return values.includeHandEquipment end
function M.setIncludeHandEquipment(v) return set('includeHandEquipment',v) end
-- Memory reset does not write preferences back after an erasure.
function M.resetMemory()
    for key,value in pairs(defaults) do values[key]=value end
    require('bank').invalidate()
end
return M
