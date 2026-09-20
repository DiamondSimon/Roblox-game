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
for _, row in ipairs(rows) do
 local id=row[1]
 table.insert(config.Order,id)
 config.ById[id]={MachineId=id, DisplayName=row[2], Rarity=row[3], BaseIncome=row[4],
 SellValue=row[4]*20, SpawnWeight=row[5], Category=row[6], ModelName=id,
 CarrySpeedModifier=0.75, MutationEligibility=true, FusionTier=1,
 UnlockZone=1, Thumbnail="", SoundProfile="Metal"}
end
return config
