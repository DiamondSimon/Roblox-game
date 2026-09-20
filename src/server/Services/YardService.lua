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
 return math.min(Config.MaxSlots,math.max(data.CapacityFloor or 0,Economy.BaseSlots+data.Upgrades.Slots*Economy.SlotsPerLevel+data.Upgrades.Expansion*Economy.ExpansionSlots)+(player:GetAttribute("ExtraSlots") and 5 or 0))
end
function Yard:Refresh(player,data)
 local yard=self.Owned[player];if not yard then return end
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
 if yard.Annex then yard.Annex.Transparency=data.Upgrades.Expansion>0 and 0 or 0.8 end
 if yard.AnnexLabel then yard.AnnexLabel.Text=data.Upgrades.Expansion>0 and ("ANNEX • LEVEL "..data.Upgrades.Expansion) or "FUTURE ANNEX • 9,000 SCRAP" end
end
function Yard:Release(player)
 local yard=self.Owned[player];if not yard then return end
 for _,model in ipairs(yard.Models) do model:Destroy() end
 yard.Models={};yard.Owner=nil;yard.Label.Text="YARD "..yard.Index.." • AVAILABLE";self.Owned[player]=nil
end
return Yard
