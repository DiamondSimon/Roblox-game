local Data=require(script.Parent.PlayerDataService)
local Config=require(game.ReplicatedStorage.Shared.Config.RewardsConfig)
local R={Started=os.clock()}
function R:Event()
 local phase=(os.clock()-self.Started)%Config.RushPeriod
 local active=phase>=Config.RushPeriod-Config.RushDuration
 return {Active=active,Remaining=math.ceil((active and Config.RushPeriod or Config.RushPeriod-Config.RushDuration)-phase),Multiplier=active and Config.RushMultiplier or 1}
end
function R:View(d)
 local count=0;for _,found in pairs(d.DiscoveredMachines) do if found then count=count+1 end end
 local rows={};for _,m in ipairs(Config.Milestones) do table.insert(rows,{Id=m.Id,Count=m.Count,Cores=m.Cores,Progress=count,Claimed=d.Rewards.Milestones[m.Id]==true}) end
 return rows
end
function R:Claim(player,kind,id)
 local g=self.Game;local d=Data:Get(player)
 if not d or not g:Allow(player) or type(id)~="string" or #id>40 then return end
 local amount,marker=nil,nil
 if kind=="Code" then
  id=string.upper(id):gsub("%s+","");local def=Config.Codes[id]
  if def and not d.Rewards.Codes[id] then amount=def.Cores;marker="Codes" end
 elseif kind=="Milestone" then
  for _,m in ipairs(self:View(d)) do if m.Id==id and m.Progress>=m.Count and not m.Claimed then amount=m.Cores;marker="Milestones" end end
 end
 if not amount then g:Notify(player,"NOT AVAILABLE • Check progress or already redeemed code");return end
 local ok=Data:Commit(player,function(candidate)
  assert(not candidate.Rewards[marker][id]);candidate.Rewards[marker][id]=true;candidate.Cores=candidate.Cores+amount
 end)
 if ok then g:Notify(player,"REWARD CLAIMED • +"..amount.." CORES");g:State(player) end
end
return R
