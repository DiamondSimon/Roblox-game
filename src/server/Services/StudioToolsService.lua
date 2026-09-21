-- Deliberate local test controls. Never accessible in published servers or persistent Studio sessions.
local Run=game:GetService("RunService")
local Data=require(script.Parent.PlayerDataService)
local Yard=require(script.Parent.YardService)
local World=require(script.Parent.WorldService)
local Pets=require(script.Parent.PetService)
local Purchase=require(script.Parent.PurchaseService)
local Money=require(game.ReplicatedStorage.Shared.Config.MonetizationConfig)
local Machines=require(game.ReplicatedStorage.Shared.Config.MachineConfig)
local Http=game:GetService("HttpService")
local T={}
function T:Allowed(player) return Run:IsStudio() and not Data:IsPersistent() and Data:Get(player)~=nil end
function T:Action(player,arg)
 if not self:Allowed(player) or type(arg)~="table" or not self.Game:Allow(player) then return end
 local d=Data:Get(player);local kind=arg.Kind
 if kind=="Scrap" then d.Scrap=math.min(1e12,d.Scrap+100000)
 elseif kind=="Cores" then d.Cores=d.Cores+1000
 elseif kind=="Pass" and (arg.Key=="DoubleScrap" or arg.Key=="ExtraSlots") then player:SetAttribute(arg.Key,not player:GetAttribute(arg.Key));Yard:Refresh(player,d)
 elseif kind=="Product" then
  for _,list in ipairs({Money.Products,Money.LegacyProducts}) do for _,item in ipairs(list) do
   if item.Key==arg.Key then Purchase:Grant(player,"studio:"..Http:GenerateGUID(false),item) end
  end end
 elseif kind=="Policy" and (arg.Value=="Allowed" or arg.Value=="Restricted" or arg.Value=="Actual") then
  Pets.PracticePolicy[player]=arg.Value=="Actual" and nil or arg.Value
 elseif kind=="Daily" then d.SpinState={Day=-1,Reward=0};d.QuestState={Day=-1,Progress={},Claimed={},Inspected={}}
 elseif kind=="Tutorial" then d.TutorialStage=4
 elseif kind=="Loadout" then
  d.Upgrades.Floors=3;d.MachineInventory={}
  for i=1,8 do local id=Machines.Order[i];table.insert(d.MachineInventory,{Uid=Http:GenerateGUID(false),MachineId=id,Protected=false});d.DiscoveredMachines[id]=true end
  Yard:Refresh(player,d)
 elseif kind=="Stand" and type(arg.Key)=="string" and World.Shops[arg.Key] then
  if self.Game.Carrying[player] then self.Game:Notify(player,"PLACE / DROP CARRIED JUNK FIRST");return end
  player.Character:PivotTo(CFrame.new(World.Shops[arg.Key].Position+Vector3.new(0,3,-7)))
 else return end
 self.Game:Notify(player,"STUDIO TEST APPLIED • No Robux charged; resets on Stop")
 self.Game:State(player)
end
return T
