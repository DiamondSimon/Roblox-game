local World=require(script.Parent.WorldService)
local Machine=require(script.Parent.MachineService)
local Config=require(game.ReplicatedStorage.Shared.Config.GameConfig)
local Economy=require(game.ReplicatedStorage.Shared.Config.EconomyConfig)
local Themes=require(game.ReplicatedStorage.Shared.Config.CoreShopConfig)
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
 return math.min(Config.MaxSlots,8*(1+data.Upgrades.Floors+(player:GetAttribute("ExtraSlots") and 1 or 0)))
end
function Yard:Refresh(player,data)
 local yard=self.Owned[player];if not yard then return end
 World:SetFloors(yard,self:Capacity(player,data)/8)
 self:Style(player,data)
 for _,model in ipairs(yard.Models) do model:Destroy() end;yard.Models={}
 for i,item in ipairs(data.MachineInventory) do
  if yard.Slots[i] then table.insert(yard.Models,Machine:Create(item.MachineId,yard.Slots[i],yard.Folder)) end
 end
end
function Yard:Style(player,data)
 local yard=self.Owned[player];if not yard then return end
 local theme=Themes.Items[data.Cosmetics.Equipped]
 local color=theme and theme.Color or Color3.fromRGB(255,184,55)
 yard.Label.TextColor3=color;yard.Deposit.Color=theme and color or Color3.fromRGB(61,170,154)

end
function Yard:Release(player)
 local yard=self.Owned[player];if not yard then return end
 for _,model in ipairs(yard.Models) do model:Destroy() end
 World:SetFloors(yard,1)
 yard.Models={};yard.Owner=nil;yard.Label.Text="YARD "..yard.Index.." • AVAILABLE";self.Owned[player]=nil
end
return Yard
