local E=require(game.ReplicatedStorage.Shared.Config.EconomyConfig)
local Schema={}
function Schema.migrate(d)
 assert(d.SchemaVersion==1 or d.SchemaVersion==2,"Unsupported schema")
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
 return d
end
function Schema.fresh(uid)
 return {SchemaVersion=2,Scrap=E.StartingScrap,LifetimeScrap=0,Cores=E.StartingCores,
 Upgrades={Income=0,Slots=0,Speed=0,Carry=0,Expansion=0},CapacityFloor=0,
 MachineInventory={{Uid=uid,MachineId="radio",Protected=true}},DiscoveredMachines={radio=true},
 DiscoveredMutations={},Settings={},DailyRewardState={},Statistics={},Receipts={},
 QuestState={Day=-1,Progress={},Claimed={},Inspected={}},Cosmetics={Owned={},Equipped="Default"}}
end
return Schema
