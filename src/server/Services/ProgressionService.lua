local Players=game:GetService("Players")
local Config=require(game.ReplicatedStorage.Shared.Config.GameConfig)
local Economy=require(game.ReplicatedStorage.Shared.Config.EconomyConfig)
local Spin=require(game.ReplicatedStorage.Shared.Config.SpinConfig)
local Machines=require(game.ReplicatedStorage.Shared.Config.MachineConfig)
local Data=require(script.Parent.PlayerDataService)
local World=require(script.Parent.WorldService)
local Yard=require(script.Parent.YardService)
local P={LastSlap={},LastTeleport={},Stunned={},Immune={},Combat={}}
function P:Safe(player)
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not root then return true end
 if (root.Position-World.ShopSpawn).Magnitude<100 then return true end
 for _,yard in ipairs(World.Yards) do
  local offset=root.Position-yard.Center
  if math.abs(offset.X)<40 and math.abs(offset.Z)<43 then return true end
 end
 return false
end
function P:Blocked(player) return (self.Stunned[player] or 0)>os.clock() end
function P:State(player,d,state)
 state.Rebirths=d.Rebirths;state.RebirthCost=Economy.rebirthCost(d.Rebirths)
 state.SpinReady=d.SpinState.Day<math.floor(os.time()/86400);state.SpinReward=d.SpinState.Reward
 state.TutorialStage=d.TutorialStage
 local carry=self.Game.Carrying[player]
 if carry then state.Waypoint=Yard.Owned[player].Deposit.Position;state.Objective="BRING YOUR JUNK HOME • USE THE GREEN PAD"
 elseif d.TutorialStage<3 then
  local nearest,dist=nil,math.huge
  local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  for model in pairs(self.Game.Salvage) do
   local delta=root and (root.Position-model.PrimaryPart.Position).Magnitude or 0
   if delta<dist then dist=delta;nearest=model.PrimaryPart.Position end
  end
  state.Waypoint=nearest or Vector3.new(0,3,-50);state.Objective="GRAB YOUR FIRST JUNK • HOLD E / TAP AT THE CONVEYOR"
 elseif d.TutorialStage==3 then state.Waypoint=World.Shops.Upgrades.Position;state.Objective="VISIT THE UPGRADE STAND • TAP SHOP TO TELEPORT"
 else state.Objective=state.SpinReady and "FREE DAILY SPIN READY • VISIT THE SHOP DISTRICT" or "GRAB • HAUL • BUILD YOUR YARD" end
 state.Stunned=self:Blocked(player)
end
function P:Teleport(player,where)
 local g=self.Game;local d=Data:Get(player);local yard=Yard.Owned[player]
 if not d or not yard or (where~="Home" and where~="Shop") then return end
 if g.Carrying[player] then g:Notify(player,"HAUL YOUR JUNK HOME FIRST • No teleport while carrying");return end
 if self:Blocked(player) or (self.Combat[player] or 0)>os.clock() then return end
 if os.clock()-(self.LastTeleport[player] or -100)<Config.TeleportCooldown then return end
 local char=player.Character;local hum=char and char:FindFirstChildOfClass("Humanoid")
 if not hum or hum.Health<=0 then return end
 self.LastTeleport[player]=os.clock();self.Immune[player]=os.clock()+5
 char:PivotTo(CFrame.new(where=="Home" and yard.Spawn.Position+Vector3.new(0,4,0) or World.ShopSpawn))
 g:Notify(player,where=="Home" and "WELCOME HOME" or "SHOP DISTRICT • Walk up to a stand");g:State(player)
end
function P:Slap(player)
 local g=self.Game;local d=Data:Get(player)
 if not d or d.TutorialStage<4 or self:Blocked(player) or self:Safe(player) or g.Carrying[player] then return end
 if os.clock()-(self.LastSlap[player] or -100)<Config.SlapCooldown then return end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if not root or not hum or hum.Health<=0 then return end
 self.LastSlap[player]=os.clock()
 local victim,best=nil,Config.SlapRange+1
 for _,other in ipairs(Players:GetPlayers()) do
  local od=Data:Get(other);local oroot=other.Character and other.Character:FindFirstChild("HumanoidRootPart")
  local oh=other.Character and other.Character:FindFirstChildOfClass("Humanoid")
  if other~=player and od and od.TutorialStage>=4 and oroot and oh and oh.Health>0 and not self:Safe(other) and not self:Blocked(other) and (self.Immune[other] or 0)<=os.clock() then
   local delta=oroot.Position-root.Position;local distance=delta.Magnitude
   if distance<=Config.SlapRange and distance<best and distance>0.01 and root.CFrame.LookVector:Dot(delta.Unit)>0.1 then
    local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={player.Character}
    local hit=workspace:Raycast(root.Position,delta,params)
    if not hit or hit.Instance:IsDescendantOf(other.Character) then victim=other;best=distance end
   end
  end
 end
 if not victim then g:Notify(player,"SLAP MISSED • Get close and face another player");return end
 local vroot=victim.Character.HumanoidRootPart;local vh=victim.Character:FindFirstChildOfClass("Humanoid")
 self.Stunned[victim]=os.clock()+Config.KnockdownSeconds;self.Immune[victim]=os.clock()+Config.SlapImmunity
 self.Combat[player]=os.clock()+5;self.Combat[victim]=os.clock()+5
 local carried=g.Carrying[victim]
 if carried then local id=carried.Id;g:ClearCarry(victim);g:GiveCarry(player,id);g:Notify(player,"SNATCHED • "..Machines.ById[id].DisplayName) end
 vh.PlatformStand=true
 pcall(function() vroot:SetNetworkOwner(nil);vroot:ApplyImpulse(((vroot.Position-root.Position).Unit*23+Vector3.new(0,12,0))*vroot.AssemblyMass) end)
 g.Remote:FireAllClients("SlapFX",vroot.Position)
 g:Notify(victim,carried and "SLAPPED! YOUR CARRIED JUNK WAS STOLEN" or "SLAPPED! BACK ON YOUR FEET IN A MOMENT")
 task.delay(Config.KnockdownSeconds,function()
  if vh.Parent and vh.Health>0 then vh.PlatformStand=false;vh:ChangeState(Enum.HumanoidStateType.GettingUp) end
  if vroot.Parent then pcall(function() vroot:SetNetworkOwnershipAuto() end) end
 end)
 g:State(player);g:State(victim)
end
function P:Spin(player)
 local g=self.Game;local d=Data:Get(player);local day=math.floor(os.time()/86400)
 if not d or not g:Near(player,World.Shops.Spin,15) or not g:Allow(player) then return end
 if d.SpinState.Day>=day then g:Notify(player,"SPIN CLAIMED • Next spin at 00:00 UTC");return end
 -- Roll outside UpdateAsync: retries persist the same reward, never reroll.
 local roll=g.Random:NextNumber(0,100);local amount=Spin.Rewards[#Spin.Rewards].Cores
 for _,reward in ipairs(Spin.Rewards) do roll=roll-reward.Weight;if roll<=0 then amount=reward.Cores;break end end
 local ok=Data:Commit(player,function(candidate)
  assert(candidate.SpinState.Day<day,"Already spun")
  candidate.SpinState={Day=day,Reward=amount};candidate.Cores=candidate.Cores+amount
 end)
 if ok then g:State(player);g.Remote:FireClient(player,"SpinResult",amount) else g:Notify(player,"SPIN COULD NOT BE CONFIRMED • Rejoin to check your reward") end
end
function P:Sell(player,uid)
 local g=self.Game
 if type(uid)~="string" or not Data:Get(player) or not g:Near(player,World.Shops.Sell,15) or not g:Allow(player) then return end
 local found=nil
 for _,item in ipairs(Data:Get(player).MachineInventory) do if item.Uid==uid and not item.Protected then found=item end end
 if not found then return end
 local value=Machines.ById[found.MachineId].SellValue
 local ok=Data:Commit(player,function(d)
  local index=nil;for i,item in ipairs(d.MachineInventory) do if item.Uid==uid and not item.Protected then index=i end end
  assert(index,"Machine no longer owned");table.remove(d.MachineInventory,index);d.Scrap=math.min(Economy.CurrencyLimit,d.Scrap+value)
 end)
 if ok then Yard:Refresh(player,Data:Get(player));g:Notify(player,"SOLD • +"..value.." SCRAP");g:State(player);g.Remote:FireClient(player,"Open","Sell") end
end
function P:Rebirth(player,confirmed)
 local g=self.Game;local d=Data:Get(player)
 if confirmed~=true or not d or not g:Near(player,World.Shops.Rebirth,15) or not g:Allow(player) then return end
 if g.Carrying[player] or d.Rebirths>=10 then g:Notify(player,"REBIRTH UNAVAILABLE • Put down carried junk / check max level");return end
 local cost=Economy.rebirthCost(d.Rebirths)
 if d.Scrap<cost then g:Notify(player,"NEED "..math.ceil(cost-d.Scrap).." MORE SCRAP");return end
 local ok=Data:Commit(player,function(candidate)
  assert(candidate.Scrap>=cost and candidate.Rebirths==d.Rebirths)
  candidate.Scrap=0;candidate.Rebirths=candidate.Rebirths+1;candidate.RunDelivered=0
  candidate.Upgrades={Income=0,Speed=0,Carry=0,Floors=0,Slots=0,Expansion=0};candidate.CapacityFloor=0
  local keep={};for _,item in ipairs(candidate.MachineInventory) do if item.Protected then table.insert(keep,item) end end
  candidate.MachineInventory=keep;candidate.Upgrades.Floors=math.max(0,math.ceil(#keep/8)-1)
 end)
 if ok then
  local current=Data:Get(player);if not current then return end;Yard:Refresh(player,current)
  local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid");if hum then hum.WalkSpeed=Economy.speed(current.Upgrades,false) end
  g:State(player);g:Notify(player,"REBIRTH COMPLETE • Permanent income bonus +5 percentage points")
 end
end
function P:Start(g)
 self.Game=g
 for key,stand in pairs(World.Shops) do
  World.prompt(stand,"Open "..key,0,function(player)
   local d=Data:Get(player);if not d or not g:Near(player,stand,15) then return end
   if key=="Upgrades" and d.TutorialStage==3 then d.TutorialStage=4;g:Notify(player,"TUTORIAL COMPLETE • Collect, upgrade, and compete!") end
   g:State(player);g.Remote:FireClient(player,"Open",key)
  end)
 end
end
function P:Cleanup(player)
 self.LastSlap[player]=nil;self.LastTeleport[player]=nil;self.Stunned[player]=nil;self.Immune[player]=nil;self.Combat[player]=nil
end
return P
