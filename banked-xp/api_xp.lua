-- API-first provider. Never treats arbitrary XP parameters as a selected
-- method's XP. Recipe references are learned only from hovered objects.
local M={}
local recipes={}
local function param(obj,name)
    local ok,value=pcall(function()
        local p=config.Param[name]
        if p and obj:HasParam(p) then return obj:GetParamValue(p) end
    end)
    if ok then return value end
end
local function normalized(name)
    local value=string.lower(name or '')
    value=string.gsub(value,'<[^>]*>','')
    value=string.gsub(value,'%s*%(%d+%)','')
    value=string.gsub(value,'potion','')
    value=string.gsub(value,'[^%a%d+]','')
    return value
end
local function herbName(obj)
    local name=string.lower(obj.name or '')
    name=string.gsub(name,' potion %(unfinished%)$','')
    name=string.gsub(name,' potion %(unf%)$','')
    name=string.gsub(name,'^clean ','')
    name=string.gsub(name,'^grimy ','')
    return name
end
local function key(obj,method) return herbName(obj)..':'..normalized(method) end
local function readRecipe(obj)
    -- Herblore is skill ID 9 in the exported client recipe data. XP tenths
    -- are calibrated per recipe before that recipe is allowed to override.
    if param(obj,'RECIPE_XP_TYPE_1')~=9 then return nil end
    for _,field in ipairs({'RECIPE_MAKE_STACK_SIZE','RECIPE_BATCH_SIZE'}) do
        local n=param(obj,field)
        if type(n)=='number' and n>1 then return nil end
    end
    if param(obj,'RECIPE_XP_SCALE_STACK_1')==true then return nil end
    local second=param(obj,'RECIPE_XP_VALUE_2')
    if type(second)=='number' and second>0 then return nil end
    if param(obj,'RECIPE_XP_GIVE_NO_XP')==1 then return nil end
    local raw=param(obj,'RECIPE_XP_VALUE_1')
    if type(raw)=='number' and raw>0 and raw<100000000 then return raw end
end
function M.observe(obj,fallbackLookup)
    local raw=readRecipe(obj)
    if not raw then return end
    for i=1,15 do
        local ingredient=param(obj,'RECIPE_INGREDIENT_TYPE_'..i)
        local count=param(obj,'RECIPE_INGREDIENT_NUMBER_'..i)
        if ingredient and count==1 then
            local ok,name=pcall(function() return ingredient.name end)
            if ok and name then
                local fallback=fallbackLookup(ingredient)
                if fallback and fallback.skill=='Herblore' then
                    local cleanMethod=fallback.method=='Clean herb'
                    local correctOutput=cleanMethod
                        and string.lower(obj.name or '')=='clean '..herbName(ingredient)
                        or not cleanMethod and normalized(obj.name)==normalized(fallback.method)
                    -- Verify method, input quantity, output identity AND scale.
                    -- Unknown scaling or a different use leaves fallback intact.
                    if correctOutput and math.abs(raw/10-fallback.xp)<0.00001 then
                        local k=key(ingredient,fallback.method)
                        if not recipes[k] then
                            recipes[k]={obj=obj,output=normalized(obj.name)}

                        end
                    end
                end
            end
        end
    end
end
function M.lookup(obj,fallback)
    local raw=param(obj,'PRAYER_XP')
    if type(raw)=='number' and raw>0 then
        for _,op in pairs(obj.interfaceOpNames or {}) do
            local name=string.lower(op)
            if name=='bury' or name=='scatter' then
                return {skill='Prayer',method=name=='bury' and 'Bury bones' or 'Scatter ashes',
                    xp=raw/10,source='api'}
            end
        end
    end
    if not fallback or fallback.skill~='Herblore' then return nil end
    local recipe=recipes[key(obj,fallback.method)]
    if not recipe then return nil end
    local value=readRecipe(recipe.obj)
    if not value or normalized(recipe.obj.name)~=recipe.output then return nil end
    local result={}
    for k,v in pairs(fallback) do result[k]=v end
    result.xp=value/10;result.source='api'
    return result
end
return M
