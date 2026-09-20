local rows = {
 {"radio", "Broken Radio", "Common", 1, 100, "Electronics"},
 {"microwave", "Microwave", "Common", 2, 80, "Electronics"},
 {"television", "Old Television", "Common", 3, 65, "Electronics"},
 {"cart", "Shopping Cart", "Common", 4, 50, "Tools"},
 {"mower", "Lawnmower", "Uncommon", 6, 38, "Tools"},
 {"generator", "Scrap Generator", "Uncommon", 8, 30, "Industrial"},
 {"scooter", "Scooter", "Uncommon", 10, 25, "Vehicles"},
 {"motorcycle", "Motorcycle", "Rare", 14, 18, "Vehicles"},
 {"forklift", "Forklift", "Rare", 18, 14, "Industrial"},
 {"compact", "Compact Car", "Rare", 22, 11, "Vehicles"},
 {"compressor", "Air Compressor", "Epic", 30, 7, "Industrial"},
 {"sports", "Vortex Coupe", "Epic", 40, 5, "Vehicles"},
 {"excavator", "Excavator", "Legendary", 60, 2.5, "Industrial"},
 {"armored", "Armored Salvager", "Legendary", 75, 1.5, "Military"},
 {"reactor", "Prototype Reactor", "Mythic", 110, 0.6, "Experimental"},
 {"pod", "Alien Pod", "Mythic", 140, 0.3, "Alien"},
 {"ufo", "UFO", "Secret", 220, 0.08, "Alien"},
 {"singularity", "Singularity Engine", "Secret", 300, 0.02, "Secret"},
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
for _, row in ipairs(rows) do
 local id=row[1]
 table.insert(config.Order,id)
 config.ById[id]={MachineId=id, DisplayName=row[2], Rarity=row[3], BaseIncome=row[4],
 SellValue=row[4]*20, SpawnWeight=row[5], Category=row[6], ModelName=id,
 CarrySpeedModifier=0.75, MutationEligibility=true, FusionTier=1,
 UnlockZone=1, Thumbnail="", SoundProfile="Metal"}
end
return config
