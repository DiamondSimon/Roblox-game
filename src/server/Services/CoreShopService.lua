local Config=require(game.ReplicatedStorage.Shared.Config.CoreShopConfig)
local Data=require(script.Parent.PlayerDataService)
local Shop={}
function Shop:Buy(player,id)
 local item=type(id)=="string" and Config.Items[id]
 local d=Data:Get(player)
 if not item or not d then return false,"Unavailable" end
 if not d.Cosmetics.Owned[id] and d.Cores<item.Cost then return false,"Earn more Cores through quests" end
 local ok=Data:Commit(player,function(candidate)
  if not candidate.Cosmetics.Owned[id] then
   assert(candidate.Cores>=item.Cost,"Insufficient Cores")
   candidate.Cores=candidate.Cores-item.Cost;candidate.Cosmetics.Owned[id]=true
  end
  candidate.Cosmetics.Equipped=id
 end)
 return ok,ok and (item.Name.." EQUIPPED") or "Could not confirm purchase"
end
return Shop
