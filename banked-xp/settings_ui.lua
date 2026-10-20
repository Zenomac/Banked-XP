local settings=require('settings')
local M={}
local function check(parent,label,value,hook,setter)
    local c=ui.Check.new(parent)
    c.stylesheetID=id.StyleSheet.CHECKBOX_DEFAULT
    c:SetSize(0,34,1,0)
    c.alignment=ui.CheckAlignMode.LEFT;c.buttonSize=20
    c.label=label;c.text.maxLines=0;c.value=value
    c:Subscribe(ui.Hook.ONBUTTONPRESSED,hook,function(component,newValue)
        local selected
        if type(newValue)=='boolean' then selected=newValue
        elseif type(newValue)=='number' then selected=newValue~=0
        else selected=component.value end
        if type(selected)~='boolean' then return end
        local saved=setter(selected)
        if not saved then print('Banked XP: applied for this session; preference could not be saved.') end
    end)
    return c
end
function M.build(event)
    local panel=ui.Panel.new(event.component)
    panel:SetPos(16,16);panel:SetSize(-32,-32,1,1)
    -- The native window already supplies its title. Native checkbox styling
    -- supplies visible fonts; standalone DEFAULT text rows were blank spacers.
    panel.isVertical=true;panel.spacing=4
    local first=check(panel,'Show recipes with missing ingredients.',settings.showUnownedIngredients(),
        'bankedXpOwnedIngredients',settings.setShowUnownedIngredients)
    local second=check(panel,'Show recipes above my level.',settings.showUnderlevelRecipes(),
        'bankedXpUnderlevelRecipes',settings.setShowUnderlevelRecipes)
    local third=check(panel,'Show recipes within boosting range.',settings.showBoostableRecipes(),
        'bankedXpBoostableRecipes',settings.setShowBoostableRecipes)
    local fourth=check(panel,'Show ingredients on hover.',settings.showRecipeOnHover(),
        'bankedXpRecipeOnHover',settings.setShowRecipeOnHover)
    local fifth=check(panel,'Apply worn outfit XP bonuses.',settings.includeOutfitBonuses(),
        'bankedXpOutfitBonuses',settings.setIncludeOutfitBonuses)
    local note=ui.Text.new(panel)
    note:SetSize(0,22,1,0)
    note.font=first.text.font
    -- Use an actual native italic font when this beta build exposes one.
    -- Unsupported HTML <i> tags can disappear or render literally in RS text.
    for _,name in ipairs({'MUSEO_SANS_12PT_ITALIC','MUSEO_SANS_11PT_ITALIC','MUSEO_SANS_13PT_ITALIC','MUSEO_SANS_15PT_ITALIC'}) do
        local ok,font=pcall(function() return config.Font[name] end)
        if ok and font then
            local found,fontID=pcall(function() return font.id end)
            if found and fontID then note.font=fontID;break end
        end
    end
    note.content="<col=b8ad98>(Outfits stored with Diango are not detected.)</col>"
    note.maxLines=1;note.clickthrough=true
    local sixth=check(panel,'Include equipped skilling tools.',settings.includeHandEquipment(),
        'bankedXpHandEquipment',settings.setIncludeHandEquipment)
    -- This checkbox is a momentary action, reset immediately after activation.
    local erase
    erase=check(panel,'Clear saved preferences (resets settings).',false,'bankedXpErase',function(value)
        if not value then return true end
        local ok=require('privacy').erasePreferences()
        first.value=settings.showUnownedIngredients()
        second.value=settings.showUnderlevelRecipes()
        third.value=settings.showBoostableRecipes()
        fourth.value=settings.showRecipeOnHover()
        fifth.value=settings.includeOutfitBonuses()
        sixth.value=settings.includeHandEquipment()
        erase.value=false
        if ok then
            print('Banked XP: saved preferences cleared. Disable the plugin to release session observations; clear before uninstalling.')
        else
            print('Banked XP: some saved preferences could not be deleted. Retry before uninstalling.')
        end
        return ok
    end)
    return first,second,third,fourth,fifth,sixth
end
function M.register()
    if Event and Event.SettingsLayerReady then Event.SettingsLayerReady.Subscribe('bankedXpSettings',M.build) end
end
return M
