local Analytics=game:GetService("AnalyticsService")
local Run=game:GetService("RunService")
local T={Seen={},Joined={}}
function T:Event(player,name,value,once)
 self.Seen[player]=self.Seen[player] or {}
 if once and self.Seen[player][name] then return end
 self.Seen[player][name]=true
 if not Run:IsStudio() then
  task.spawn(function() local ok=pcall(function() Analytics:LogCustomEvent(player,name,value or 1) end)
   if not ok then warn("SCRAPYARD analytics event unavailable: "..name) end
  end)
 end
end
function T:Join(player) self.Joined[player]=os.clock();self:Event(player,"PlayerJoined",1,true) end
function T:Tick(player)
 local elapsed=os.clock()-(self.Joined[player] or os.clock())
 for _,m in ipairs({5,10,20}) do if elapsed>=m*60 then self:Event(player,"Played"..m.."Minutes",1,true) end end
end
function T:Leave(player)
 self:Event(player,"PlayerLeft",os.clock()-(self.Joined[player] or os.clock()))
 self.Seen[player]=nil;self.Joined[player]=nil
end
return T
