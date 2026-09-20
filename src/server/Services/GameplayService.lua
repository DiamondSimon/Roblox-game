local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local Shared=game.ReplicatedStorage.Shared.Config
local Config=require(Shared.GameConfig)
local Definitions=require(Shared.MachineConfig)
local Economy=require(Shared.EconomyConfig)
local Data=require(script.Parent.PlayerDataService)
local World=require(script.Parent.WorldService)
local Yard=require(script.Parent.YardService)
local Machine=require(script.Parent.MachineService)
local Game={Carrying={},Salvage={},LastAction={},Random=Random.new()}
function Game:Notify(player,text) self.Remote:FireClient(player,"Notice",text) end
function Game:Near(player,part,distance)
 local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart")
 local hum=char and char:FindFirstChildOfClass("Humanoid")
 return root and hum and hum.Health>0 and (root.Position-part.Position).Magnitude<=(distance or Config.PickupDistance)
end
function Game:Allow(player)
 local now=os.clock()
 if now-(self.LastAction[player] or 0)<0.35 then return false end
 self.LastAction[player]=now;return true
end
function Game:Income(player,d)
 local total=0
 for _,item in ipairs(d.MachineInventory) do total=total+Definitions.ById[item.MachineId].BaseIncome end
 return Economy.income(total,d.Upgrades.Income,player:GetAttribute("DoubleScrap")==true)
end
function Game:State(player)
 local d=Data:Get(player);if not d then return end
 self.Remote:FireClient(player,"State",{Scrap=d.Scrap,Income=self:Income(player,d),Count=#d.MachineInventory,
 Capacity=Yard:Capacity(player,d),IncomeLevel=d.Upgrades.Income,SlotLevel=d.Upgrades.Slots,
 UpgradeCost=Economy.upgradeCost(d.Upgrades.Income),SlotCost=Economy.slotCost(d.Upgrades.Slots),
 Carrying=self.Carrying[player] and Definitions.ById[self.Carrying[player].Id].DisplayName or false,
 Discovered=d.DiscoveredMachines, Persistent=Data:IsPersistent()})
end
function Game:ClearCarry(player)
 local carry=self.Carrying[player];if not carry then return end
 carry.Model:Destroy();self.Carrying[player]=nil
 local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if hum then hum.WalkSpeed=Config.WalkSpeed end
end
function Game:Pickup(player,model)
 if not self:Allow(player) then return end
 local entry=self.Salvage[model];local d=Data:Get(player)
 if not entry or not d or self.Carrying[player] or not self:Near(player,model.PrimaryPart) then return end
 if #d.MachineInventory>=Yard:Capacity(player,d) then self:Notify(player,"YARD FULL • Expand at your terminal");return end
 local root=player.Character:FindFirstChild("HumanoidRootPart");if not root then return end
 self.Salvage[model]=nil
 local id=entry.Id;model:Destroy()
 local carry=Machine:Create(id,Vector3.zero,workspace)
 carry:PivotTo(root.CFrame*CFrame.new(0,1,-3.5))
 for _,p in ipairs(carry:GetDescendants()) do
  if p:IsA("BasePart") then
   p.Anchored=false;p.Massless=true
   local weld=Instance.new("WeldConstraint");weld.Part0=root;weld.Part1=p;weld.Parent=p
  end
 end
 self.Carrying[player]={Id=id,Model=carry,PickedAt=os.clock(),Origin=root.Position}
 player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed=Config.CarrySpeed
 self:Notify(player,"BRING IT HOME • Use your green intake pad");self:State(player)
end
function Game:Deposit(player)
 local yard=Yard.Owned[player];local carry=self.Carrying[player];local d=Data:Get(player)
 if not self:Allow(player) or not yard or not carry or not d or not self:Near(player,yard.Deposit) then return end
 if #d.MachineInventory>=Yard:Capacity(player,d) then self:Notify(player,"YARD FULL");return end
 -- Reject implausibly fast direct teleports; full movement auditing remains a release gate.
 local root=player.Character.HumanoidRootPart
 if (root.Position-carry.Origin).Magnitude>Config.WalkSpeed*(os.clock()-carry.PickedAt)+15 then return end
 table.insert(d.MachineInventory,{Uid=Http:GenerateGUID(false),MachineId=carry.Id,Protected=false})
 d.DiscoveredMachines[carry.Id]=true
 self:ClearCarry(player);Yard:Refresh(player,d)
 self:Notify(player,"MACHINE ADDED • +"..self:Income(player,d).." SCRAP / SECOND");self:State(player)
end
function Game:Upgrade(player,kind)
 local yard=Yard.Owned[player];local d=Data:Get(player)
 if not self:Allow(player) or not yard or not d or not self:Near(player,yard.Terminal,15) then return end
 local level,cost,cap
 if kind=="Income" then level=d.Upgrades.Income;cost=Economy.upgradeCost(level);cap=Economy.MaxIncomeLevel
 elseif kind=="Slots" then level=d.Upgrades.Slots;cost=Economy.slotCost(level);cap=Economy.MaxSlotLevel
 else return end
 if level>=cap then self:Notify(player,"UPGRADE MAXED");return end
 if d.Scrap<cost then self:Notify(player,"NEED "..math.ceil(cost-d.Scrap).." MORE SCRAP");return end
 d.Scrap=d.Scrap-cost;d.Upgrades[kind]=level+1
 self:Notify(player,"UPGRADE INSTALLED");self:State(player)
end
function Game:Spawn(forcedId)
 local count=0;for _ in pairs(self.Salvage) do count=count+1 end
 if count>=Config.MaxSalvage then return end
 local total=0;for _,id in ipairs(Definitions.Order) do total=total+Definitions.ById[id].SpawnWeight end
 local roll=self.Random:NextNumber(0,total);local selected=Definitions.Order[1]
 for _,id in ipairs(Definitions.Order) do roll=roll-Definitions.ById[id].SpawnWeight;if roll<=0 then selected=id;break end end
 selected=forcedId or selected
 local model=Machine:Create(selected,Vector3.new(self.Random:NextNumber(-6,6),3,self.Random:NextNumber(-54,54)),World.Root)
 self.Salvage[model]={Id=selected,Expires=os.clock()+Config.SalvageLifetime}
 World.prompt(model.PrimaryPart,"Carry machine",0.4,function(player) self:Pickup(player,model) end)
 if Definitions.Rarities[Definitions.ById[selected].Rarity].Announce then self.Remote:FireAllClients("Notice",string.upper(Definitions.ById[selected].Rarity).." SALVAGE DETECTED") end
end
function Game:Start(remote)
 self.Remote=remote
 for _,yard in ipairs(World.Yards) do
  World.prompt(yard.Deposit,"Place machine",0,function(player) if yard.Owner==player then self:Deposit(player) end end)
  World.prompt(yard.Terminal,"Open upgrades",0,function(player)
   if yard.Owner==player and self:Near(player,yard.Terminal) then self:State(player);self.Remote:FireClient(player,"Upgrades") end
  end)
 end
 remote.OnServerEvent:Connect(function(player,action,arg)
  if action=="Upgrade" then self:Upgrade(player,arg)
  elseif action=="DiscardCarry" and self:Allow(player) then self:ClearCarry(player);self:State(player)
  elseif action=="Sync" and self:Allow(player) then self:State(player) end
 end)
 for _,id in ipairs({"microwave","television","mower","generator","motorcycle","radio"}) do self:Spawn(id) end
 task.spawn(function()
  while true do
   task.wait(Config.SpawnInterval)
   for model,entry in pairs(self.Salvage) do if os.clock()>entry.Expires then self.Salvage[model]=nil;model:Destroy() end end
   self:Spawn()
  end
 end)
 task.spawn(function()
  while true do
   local dt=task.wait(1);dt=math.min(dt,5)
   for _,player in ipairs(Players:GetPlayers()) do
    Data:Mutate(player,function(d)
     local gain=self:Income(player,d)*dt
     d.Scrap=math.max(d.Scrap,math.min(Economy.CurrencyLimit,d.Scrap+gain));d.LifetimeScrap=d.LifetimeScrap+gain
    end)
    self:State(player)
   end
  end
 end)
end
return Game
