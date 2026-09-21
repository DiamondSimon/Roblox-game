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
local Quests=require(script.Parent.QuestService)
local CoreShop=require(script.Parent.CoreShopService)
local Telemetry=require(script.Parent.TelemetryService)
local Pets=require(script.Parent.PetService)
local PetConfig=require(Shared.PetConfig)
local Progression=require(script.Parent.ProgressionService)
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
 return Economy.income(total,d.Upgrades.Income,player:GetAttribute("DoubleScrap")==true,d.Rebirths)*(1+PetConfig.bonus(d.Pets))
end
function Game:State(player)
 local d=Data:Get(player);if not d then return end
 local state={Scrap=d.Scrap,Cores=d.Cores,Upgrades=d.Upgrades,Quests=Quests:View(d),Cosmetics=d.Cosmetics,Inventory=d.MachineInventory,Income=self:Income(player,d),Count=#d.MachineInventory,
 Capacity=Yard:Capacity(player,d),IncomeLevel=d.Upgrades.Income,SlotLevel=d.Upgrades.Slots,
 UpgradeCost=Economy.upgradeCost(d.Upgrades.Income),SlotCost=Economy.slotCost(d.Upgrades.Slots),
 Carrying=self.Carrying[player] and Definitions.ById[self.Carrying[player].Id].DisplayName or false,
 Discovered=d.DiscoveredMachines, Persistent=Data:IsPersistent()}
 state.Pets=d.Pets;state.PetBonus=PetConfig.bonus(d.Pets);state.CasesAllowed=Pets:Allowed(player);state.PetOfferToken=Pets:Token(player)
 Progression:State(player,d,state);self.Remote:FireClient(player,"State",state)
end
function Game:ClearCarry(player)
 local carry=self.Carrying[player];if not carry then return end
 carry.Model:Destroy();self.Carrying[player]=nil
 local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if hum then local d=Data:Get(player);hum.WalkSpeed=d and Economy.speed(d.Upgrades,false) or Config.WalkSpeed end
end
function Game:Pickup(player,model)
 if not self:Allow(player) then return end
 local entry=self.Salvage[model];local d=Data:Get(player)
 if not entry or entry.Expires<=os.clock() or Progression:Blocked(player) or not d or self.Carrying[player] or not self:Near(player,model.PrimaryPart) then return end
 
 self.Salvage[model]=nil
 local id=entry.Id;model:Destroy();self:GiveCarry(player,id)
 if d.TutorialStage==1 then d.TutorialStage=2 end
 Telemetry:Event(player,"FirstMachinePickedUp",1,true)
 self:Notify(player,"BRING IT HOME • Use your green intake pad");self:State(player)
end
function Game:GiveCarry(player,id)
 local root=player.Character:FindFirstChild("HumanoidRootPart");local d=Data:Get(player)
 if not root or not d or self.Carrying[player] then return false end
 local carry=Machine:Create(id,Vector3.zero,workspace)
 carry:PivotTo(root.CFrame*CFrame.new(0,1,-3.5))
 for _,p in ipairs(carry:GetDescendants()) do
  if p:IsA("BasePart") then p.Anchored=false;p.Massless=true
   local weld=Instance.new("WeldConstraint");weld.Part0=root;weld.Part1=p;weld.Parent=p
  end
 end
 self.Carrying[player]={Id=id,Model=carry,PickedAt=os.clock(),Origin=root.Position}
 player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed=Economy.speed(d.Upgrades,true)
 return true
end
function Game:Drop(player)
 local carry=self.Carrying[player];local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not carry or not root then return end
 local id=carry.Id;local pos=root.Position+Vector3.new(0,0,-5);self:ClearCarry(player)
 self:Spawn(id,nil,pos);self:State(player)
end
function Game:Deposit(player,replacementUid)
 local yard=Yard.Owned[player];local carry=self.Carrying[player];local d=Data:Get(player)
 if Progression:Blocked(player) or not self:Allow(player) or not yard or not carry or not d or not self:Near(player,yard.Deposit) then return end
 local replaceIndex=nil
 if #d.MachineInventory>=Yard:Capacity(player,d) then
  if type(replacementUid)=="string" then
   for i,item in ipairs(d.MachineInventory) do if item.Uid==replacementUid and not item.Protected then replaceIndex=i end end
  end
  if not replaceIndex then self.Remote:FireClient(player,"Replace");return end
 end
 -- Reject implausibly fast direct teleports; full movement auditing remains a release gate.
 local root=player.Character.HumanoidRootPart
 if (root.Position-carry.Origin).Magnitude>Economy.MaxWalkSpeed*(os.clock()-carry.PickedAt)+15 then return end
 if replaceIndex then table.remove(d.MachineInventory,replaceIndex) end
 table.insert(d.MachineInventory,{Uid=Http:GenerateGUID(false),MachineId=carry.Id,Protected=false})
 if not d.DiscoveredMachines[carry.Id] then self:Notify(player,"COLLECTION DISCOVERY • "..Definitions.ById[carry.Id].DisplayName) end
 d.DiscoveredMachines[carry.Id]=true
 d.RunDelivered=d.RunDelivered+1;if d.TutorialStage<3 then d.TutorialStage=3 end
 Quests:Progress(d,"Collected",1)
 local rarity=Definitions.ById[carry.Id].Rarity
 if rarity~="Common" and rarity~="Uncommon" then Quests:Progress(d,"RareCollected",1) end
 local added=Economy.income(Definitions.ById[carry.Id].BaseIncome,d.Upgrades.Income,player:GetAttribute("DoubleScrap")==true,d.Rebirths)*(1+PetConfig.bonus(d.Pets))
 Telemetry:Event(player,"FirstMachinePlaced",1,true)
 self:ClearCarry(player);Yard:Refresh(player,d)
 self:Notify(player,"MACHINE ADDED • +"..string.format("%.2f",added).." SCRAP / SECOND");self:State(player)
end
function Game:Upgrade(player,kind)
 local yard=Yard.Owned[player];local d=Data:Get(player)
 if not self:Allow(player) or not yard or not d or not self:Near(player,World.Shops.Upgrades,15) then return end
 local def=type(kind)=="string" and Economy.Upgrades[kind]
 if not def then return end
 local level=d.Upgrades[kind];local cost=Economy.cost(kind,level);local cap=def.Max
 if level>=cap then self:Notify(player,"UPGRADE MAXED");return end
 if d.Scrap<cost then self:Notify(player,"NEED "..math.ceil(cost-d.Scrap).." MORE SCRAP");return end
 d.Scrap=d.Scrap-cost;d.Upgrades[kind]=level+1
 Quests:Progress(d,"Upgrade",1)
 local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if hum then hum.WalkSpeed=Economy.speed(d.Upgrades,self.Carrying[player]~=nil) end
 Yard:Refresh(player,d);Telemetry:Event(player,"FirstUpgradePurchased",1,true)
 self:Notify(player,"UPGRADE INSTALLED");self:State(player)
end
function Game:Spawn(forcedId,startZ,droppedPosition)
 local count=0;for _ in pairs(self.Salvage) do count=count+1 end
 if count>=Config.MaxSalvage and not droppedPosition then return end
 local total=0;for _,id in ipairs(Definitions.Order) do total=total+Definitions.ById[id].SpawnWeight end
 local roll=self.Random:NextNumber(0,total);local selected=Definitions.Order[1]
 for _,id in ipairs(Definitions.Order) do roll=roll-Definitions.ById[id].SpawnWeight;if roll<=0 then selected=id;break end end
 selected=forcedId or selected
 local model=Machine:Create(selected,droppedPosition or Vector3.new(0,3,startZ or Config.BeltStart),World.Root)
 game:GetService("CollectionService"):AddTag(model.PrimaryPart,"ScrapyardSalvage")
 local now=os.clock();local z=startZ or Config.BeltStart
 self.Salvage[model]={Id=selected,Started=now,StartZ=z,Dropped=droppedPosition~=nil,Expires=now+(droppedPosition and 25 or (Config.BeltEnd-z)/Config.BeltSpeed)}
 for _,obj in ipairs(model:GetDescendants()) do if obj:IsA("BillboardGui") then obj.MaxDistance=48;obj.Size=UDim2.fromOffset(175,50) end end
 World.prompt(model.PrimaryPart,"Carry machine",0.4,function(player) self:Pickup(player,model) end)
 if Definitions.Rarities[Definitions.ById[selected].Rarity].Announce then self.Remote:FireAllClients("Notice",string.upper(Definitions.ById[selected].Rarity).." SALVAGE DETECTED") end
end
function Game:MoveSalvage(now)
 for model,entry in pairs(self.Salvage) do
  if now>=entry.Expires then
   self.Salvage[model]=nil;model:Destroy()
   if not entry.Dropped then self.Remote:FireAllClients("ShredFX",World.Shredder.Position) end
  elseif not entry.Dropped then
   model:PivotTo(CFrame.new(0,3,entry.StartZ+(now-entry.Started)*Config.BeltSpeed))
  end
 end
end
function Game:Start(remote)
 self.Remote=remote
 for _,yard in ipairs(World.Yards) do
  World.prompt(yard.Deposit,"Place machine",0,function(player) if yard.Owner==player then self:Deposit(player) end end)

 end
 Pets.Game=self
 Progression:Start(self)
 remote.OnServerEvent:Connect(function(player,action,arg)
  if action=="BuyCase" then Pets:Buy(player,arg)
  elseif action=="BuyPet" then Pets:Direct(player,arg)
  elseif action=="EquipPet" then Pets:Equip(player,arg)
  elseif action=="Teleport" then Progression:Teleport(player,arg)
  elseif action=="Slap" then Progression:Slap(player)
  elseif action=="Spin" then Progression:Spin(player)
  elseif action=="Sell" then Progression:Sell(player,arg)
  elseif action=="Rebirth" then Progression:Rebirth(player,arg)
  elseif action=="Upgrade" then self:Upgrade(player,arg)
  elseif action=="Replace" then self:Deposit(player,arg)
  elseif action=="ClaimQuest" and self:Allow(player) then local _,message=Quests:Claim(player,arg);self:Notify(player,message);self:State(player)
  elseif action=="CoreShop" and self:Near(player,World.Shops.Shop,15) and self:Allow(player) then
   local ok,message=CoreShop:Buy(player,arg);local d=Data:Get(player)
   if ok and d then Yard:Style(player,d) end;self:Notify(player,message);self:State(player)
  elseif action=="Telemetry" and self:Allow(player) then
   if arg=="ShopOpened" or arg=="PassPrompted" or arg=="CorePurchasePrompted" then Telemetry:Event(player,arg,1,true) end
  elseif action=="DiscardCarry" and not Progression:Blocked(player) and self:Allow(player) then self:Drop(player)
  elseif action=="Sync" and self:Allow(player) then self:State(player) end
 end)
 for id,station in pairs(World.Inspections or {}) do
  World.prompt(station,"Inspect landmark",0.5,function(player)
   if not self:Allow(player) or not self:Near(player,station) then return end
   local d=Data:Get(player);if d and Quests:Inspect(d,id) then self:Notify(player,"LANDMARK INSPECTED • Quest progress");self:State(player) end
  end)
 end
 for i,id in ipairs({"microwave","television","mower","radio"}) do self:Spawn(id,Config.BeltStart+(i-1)*25) end
 task.spawn(function()
  while true do task.wait(Config.SpawnInterval);self:Spawn() end
 end)
 task.spawn(function()
  while true do task.wait(0.1);self:MoveSalvage(os.clock()) end
 end)
 task.spawn(function()
  while true do
   local dt=task.wait(1);dt=math.min(dt,5)
   for _,player in ipairs(Players:GetPlayers()) do
    Data:Mutate(player,function(d)
     local gain=self:Income(player,d)*dt
     d.Scrap=math.max(d.Scrap,math.min(Economy.CurrencyLimit,d.Scrap+gain));d.LifetimeScrap=d.LifetimeScrap+gain
    end)
    self:State(player);Telemetry:Tick(player)
   end
  end
 end)
end
return Game
