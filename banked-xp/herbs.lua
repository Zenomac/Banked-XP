-- RuneScape 3 base XP. Potion routes are examples, not rate rankings.
local data={
    ["guam"]={clean=2.5},
    ["tarromin"]={clean=3.8},
    ["marrentill"]={clean=5},
    ["harralander"]={clean=6.3},
    ["ranarr"]={clean=7.5},
    ["toadflax"]={clean=8},
    ["spirit weed"]={clean=7.8},
    ["irit"]={clean=8.8},
    ["wergali"]={clean=9.5},
    ["avantoe"]={clean=10},
    ["kwuarm"]={clean=11.3},
    ["bloodweed"]={clean=11.5},
    ["snapdragon"]={clean=11.8},
    ["cadantine"]={clean=12.5},
    ["lantadyme"]={clean=13.1},
    ["dwarf weed"]={clean=13.8},
    ["torstol"]={clean=15},
    ["arbuck"]={clean=13.5},
    ["fellstalk"]={clean=16.8},
    ["erzille"]={clean=10},
    ["ugune"]={clean=11.5},
    ["argway"]={clean=11.6},
    ["shengo"]={clean=11.7},
    ["samaden"]={clean=11.7},
    ["ardrigal"]={clean=2.5},
    ["rogue's purse"]={clean=2.5},
    ["sito foil"]={clean=2.5},
    ["snake weed"]={clean=2.5},
    ["volencia moss"]={clean=2.5},
    ["sagewort"]={clean=2.1},
    ["valerian"]={clean=3.2},
    ["aloe"]={clean=4},
    ["wormwood leaf"]={clean=7.2},
    ["magebane"]={clean=7.7},
    ["featherfoil"]={clean=8.6},
    ["winter's grip"]={clean=12.7},
    ["lycopus"]={clean=13.1},
    ["buckthorn"]={clean=13.8},
}
local M={}
function M.lookup(obj)
    local plain=string.gsub(obj.name or '', '<[^>]*>', '')
    local name=string.lower(plain)
    local grimy=name:match('^grimy (.+)$')
    local clean=name:match('^clean (.+)$')
    -- Only exact herb names; seeds, tar, completed potions and unrelated
    -- names never match. The unprefixed alias supports legacy display names.
    local herb=grimy or clean or name
    local row=data[herb]
    if not row then return nil end
    if grimy then
        return {skill='Herblore',method='Clean herb',xp=row.clean,unit='herbs'}
    end
end
M.data=data
return M
