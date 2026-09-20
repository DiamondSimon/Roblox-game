local E=require(game.ReplicatedStorage.Shared.Config.EconomyConfig)
local Schema={}
function Schema.migrate(d)
 assert(d.SchemaVersion==1 or d.SchemaVersion==2 or d.SchemaVersion==3,"Unsupported schema")
 if d.SchemaVersion==1 then
  d.Cores=0;d.CapacityFloor=6+d.Upgrades.Slots
  d.Upgrades.Speed=0;d.Upgrades.Carry=0;d.Upgrades.Expansion=0
  d.QuestState={Day=-1,Progress={},Claimed={},Inspected={}}
  d.Cosmetics={Owned={},Equipped="Default"}
  for id,amount in pairs(d.Receipts) do
   if type(amount)=="number" then d.Receipts[id]={Currency="Scrap",Amount=amount} end
  end
  d.SchemaVersion=2
 end
 if d.SchemaVersion==2 then
  local old=math.max(d.CapacityFloor or 0,4+d.Upgrades.Slots*2+d.Upgrades.Expansion*2,#d.MachineInventory)
  d.Upgrades.Floors=math.min(3,math.ceil(old/8)-1)
  d.CapacityFloor=0;d.Rebirths=0;d.RunDelivered=0
  d.TutorialStage=#d.MachineInventory>0 and 4 or 1
  d.SpinState={Day=-1,Reward=0};d.SchemaVersion=3
 end
 return d
end
function Schema.fresh(uid)
 return {SchemaVersion=3,Scrap=E.StartingScrap,LifetimeScrap=0,Cores=E.StartingCores,
 Upgrades={Income=0,Slots=0,Speed=0,Carry=0,Expansion=0,Floors=0},CapacityFloor=0,Rebirths=0,RunDelivered=0,TutorialStage=1,SpinState={Day=-1,Reward=0},
 MachineInventory={},DiscoveredMachines={},
 DiscoveredMutations={},Settings={},DailyRewardState={},Statistics={},Receipts={},
 QuestState={Day=-1,Progress={},Claimed={},Inspected={}},Cosmetics={Owned={},Equipped="Default"}}
end
return Schema
