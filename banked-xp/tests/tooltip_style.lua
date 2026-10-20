package.path='./?.lua;banked-xp/?.lua;'..package.path
local style=require('tooltip_style')
for _,text in ipairs({'Temporarily increases <col=00ff00>Necromancy +20</col>','Temporarily increases Defence +6','Temporarily boosts Herblore by 3','Boosts your Mining level','Attack +17 Strength +17 Defence +17'}) do
 assert(style.statBoost('Herblore',{text}),text)
end
for _,text in ipairs({'Restores 317 prayer points.','Restores 1300 health.','Temporarily reduces Attack -4','More recipes unlocked in 16 levels','Protects against dragonfire'}) do
 assert(not style.statBoost('Herblore',{text}),text)
end
assert(not style.statBoost('Prayer',{'Temporarily increases Defence +6'}))
print('PASS: boost effects, colored text, skill boosts, restorations and other items')
