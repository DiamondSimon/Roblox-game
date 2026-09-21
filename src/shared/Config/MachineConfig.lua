local rows = {
 {"radio", "Broken Radio", "Common", 0.3, 100, "Electronics"},
 {"microwave", "Microwave", "Common", 0.6, 80, "Electronics"},
 {"television", "Old Television", "Common", 0.8, 65, "Electronics"},
 {"cart", "Shopping Cart", "Common", 1, 50, "Tools"},
 {"mower", "Lawnmower", "Uncommon", 1.2, 38, "Tools"},
 {"generator", "Scrap Generator", "Uncommon", 1.5, 30, "Industrial"},
 {"scooter", "Scooter", "Uncommon", 1.8, 25, "Vehicles"},
 {"motorcycle", "Motorcycle", "Rare", 2.2, 18, "Vehicles"},
 {"forklift", "Forklift", "Rare", 2.6, 14, "Industrial"},
 {"compact", "Compact Car", "Rare", 3, 11, "Vehicles"},
 {"compressor", "Air Compressor", "Epic", 3.5, 7, "Industrial"},
 {"sports", "Vortex Coupe", "Epic", 4, 5, "Vehicles"},
 {"excavator", "Excavator", "Legendary", 5, 2.5, "Industrial"},
 {"armored", "Armored Salvager", "Legendary", 6, 1.5, "Military"},
 {"reactor", "Prototype Reactor", "Mythic", 7.5, 0.6, "Experimental"},
 {"pod", "Alien Pod", "Mythic", 9, 0.3, "Alien"},
 {"ufo", "UFO", "Secret", 11, 0.08, "Alien"},
 {"toaster","Burnt Toaster","Common",0.4,35,"Appliances"},
 {"washer","Washing Machine","Common",0.75,30,"Appliances"},
 {"fridge","Rusty Refrigerator","Uncommon",1.3,18,"Appliances"},
 {"fan","Desk Fan","Common",0.5,30,"Appliances"},
 {"toolbox","Mechanic Toolbox","Common",0.7,25,"Tools"},
 {"tires","Tire Stack","Common",0.45,30,"Parts"},
 {"barrel","Chemical Drum","Uncommon",1.4,15,"Parts"},
 {"engine","V8 Engine Block","Rare",2.8,10,"Parts"},
 {"satellite","Satellite Dish","Rare",2.4,10,"Electronics"},
 {"arcade","Arcade Cabinet","Epic",3.8,5,"Electronics"},
 {"drone","Cargo Drone","Legendary",5.5,2,"Experimental"},
 {"turbine","Jet Turbine","Mythic",8.2,0.3,"Experimental"},
 {"singularity", "Singularity Engine", "Secret", 14, 0.02, "Secret"},
}
local config = {Order={}, ById={}, Rarities={
 Common={Color=Color3.fromRGB(174,189,190)},
 Uncommon={Color=Color3.fromRGB(120,223,138)},
 Rare={Color=Color3.fromRGB(85,184,255)},
 Epic={Color=Color3.fromRGB(191,120,255)},
 Legendary={Color=Color3.fromRGB(255,184,55), Announce=true},
 Mythic={Color=Color3.fromRGB(255,83,118), Announce=true},
 Secret={Color=Color3.fromRGB(99,255,238), Announce=true},
}}
local rarityBudget={Common=295,Uncommon=93,Rare=43,Epic=12,Legendary=4,Mythic=0.9,Secret=0.1}
local rawTotals={};for _,row in ipairs(rows) do rawTotals[row[3]]=(rawTotals[row[3]] or 0)+row[5] end
local incomeScale={Common=1000,Uncommon=1500,Rare=2500,Epic=5000,Legendary=10000,Mythic=40000,Secret=250000}
for _, row in ipairs(rows) do
 row[4]=row[4]*incomeScale[row[3]]
 local id=row[1]
 table.insert(config.Order,id)
 config.ById[id]={MachineId=id, DisplayName=row[2], Rarity=row[3], BaseIncome=row[4],
 SellValue=row[4]*20, SpawnWeight=row[5]*rarityBudget[row[3]]/rawTotals[row[3]], Category=row[6], ModelName=id,
 CarrySpeedModifier=0.75, MutationEligibility=true, FusionTier=1,
 UnlockZone=1, Thumbnail="", SoundProfile="Metal"}
end
return config
