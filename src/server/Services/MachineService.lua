local Config=require(game.ReplicatedStorage.Shared.Config.MachineConfig)
local Factory=require(game.ReplicatedStorage.Shared.Config.MachineModelFactory)
local World=require(script.Parent.WorldService)
local Machines={}
function Machines:Create(id,position,parent)
 local model=Factory:Create(id,position,parent);local def=Config.ById[id];local color=Config.Rarities[def.Rarity].Color
 local gate=def.RequiredRebirths>0 and (" • RB "..def.RequiredRebirths) or ""
 local label=World.label(model.PrimaryPart,def.DisplayName.."\n"..def.Rarity..gate.." • +"..def.BaseIncome.." /s",color)
 label.Parent.StudsOffsetWorldSpace=Vector3.new(0,7,0)
 if Config.Rarities[def.Rarity].Announce then local h=Instance.new("Highlight");h.FillColor=color;h.FillTransparency=0.85;h.OutlineColor=color;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=model end
 return model
end
return Machines
