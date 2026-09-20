local World=require(script.Parent.WorldService)
local Machine=require(script.Parent.MachineService)
local Config=require(game.ReplicatedStorage.Shared.Config.GameConfig)
local Yard={Owned={}}
function Yard:Claim(player)
 for _,yard in ipairs(World.Yards) do
  if not yard.Owner then
   yard.Owner=player;yard.Label.Text=player.DisplayName.."'S YARD";self.Owned[player]=yard
   player.RespawnLocation=yard.Spawn
   player:SetAttribute("YardIndex",yard.Index)
   return yard
  end
 end
 return nil
end
function Yard:Capacity(player,data)
 return math.min(Config.MaxSlots,Config.BaseSlots+data.Upgrades.Slots+(player:GetAttribute("ExtraSlots") and 5 or 0))
end
function Yard:Refresh(player,data)
 local yard=self.Owned[player];if not yard then return end
 for _,model in ipairs(yard.Models) do model:Destroy() end;yard.Models={}
 for i,item in ipairs(data.MachineInventory) do
  if yard.Slots[i] then table.insert(yard.Models,Machine:Create(item.MachineId,yard.Slots[i],yard.Folder)) end
 end
end
function Yard:Release(player)
 local yard=self.Owned[player];if not yard then return end
 for _,model in ipairs(yard.Models) do model:Destroy() end
 yard.Models={};yard.Owner=nil;yard.Label.Text="YARD "..yard.Index.." • AVAILABLE";self.Owned[player]=nil
end
return Yard
