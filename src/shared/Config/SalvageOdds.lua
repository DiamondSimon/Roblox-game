local Machines=require(game.ReplicatedStorage.Shared.Config.MachineConfig)
local Odds={}
function Odds.weights(rebirths,personal,server)
 local rows,total={},0
 for _,id in ipairs(Machines.Order) do
  local def=Machines.ById[id];local mult=1
  if def.Rarity~="Common" then mult=server or 1;if Machines.canCollect(id,rebirths) then mult=math.min(2,mult*(personal or 1)) end end
  rows[id]=def.SpawnWeight*mult;total=total+rows[id]
 end
 return rows,total
end
return Odds
