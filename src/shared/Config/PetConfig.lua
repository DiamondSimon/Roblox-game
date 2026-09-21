local P={Order={"bolt_mouse","tin_cat","spring_dog","magnet_fox","welding_owl","steel_tiger","plasma_dragon","crane_griffin","cosmic_serpent"},ById={},CaseOrder={"Salvage","Industrial","Prototype"}}
local rows={
 {"bolt_mouse","Bolt Mouse","Common",0.03,1200,149,172,185,"Mouse"},
 {"tin_cat","Tin Cat","Uncommon",0.05,1800,102,210,145,"Cat"},
 {"spring_dog","Spring Dog","Rare",0.08,3000,90,173,247,"Dog"},
 {"magnet_fox","Magnet Fox","Rare",0.08,7000,67,179,240,"Fox"},
 {"welding_owl","Welding Owl","Epic",0.12,9000,176,108,245,"Owl"},
 {"steel_tiger","Steel Tiger","Legendary",0.16,35000,255,181,45,"Tiger"},
 {"plasma_dragon","Plasma Dragon","Epic",0.12,14000,194,105,252,"Dragon"},
 {"crane_griffin","Crane Griffin","Legendary",0.16,65000,255,204,70,"Griffin"},
 {"cosmic_serpent","Cosmic Serpent","Mythic",0.20,140000,255,85,148,"Serpent"},
}
for _,r in ipairs(rows) do P.ById[r[1]]={Name=r[2],Rarity=r[3],Bonus=r[4],DirectScrap=r[5]*1000,Color=Color3.fromRGB(r[6],r[7],r[8]),Shape=r[9]} end
P.Cases={
 Salvage={Name="Salvage Case",Scrap=500,Cores=25,Outcomes={{Id="bolt_mouse",Weight=60},{Id="tin_cat",Weight=30},{Id="spring_dog",Weight=10}}},
 Industrial={Name="Industrial Case",Scrap=3500,Cores=100,Outcomes={{Id="magnet_fox",Weight=60},{Id="welding_owl",Weight=30},{Id="steel_tiger",Weight=10}}},
 Prototype={Name="Prototype Case",Scrap=15000,Cores=300,Outcomes={{Id="plasma_dragon",Weight=60},{Id="crane_griffin",Weight=35},{Id="cosmic_serpent",Weight=5}}},
}
for _,case in pairs(P.Cases) do case.Scrap=case.Scrap*1000 end
-- One equipped pet. Copies are collected, never stacked, traded or converted to currency.
function P.bonus(pets) local pet=pets and P.ById[pets.Equipped];return pet and (pets.Owned[pets.Equipped] or 0)>0 and pet.Bonus or 0 end
return P
