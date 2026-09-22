local Config=require(game.ReplicatedStorage.Shared.Config.BoostConfig)
local Data=require(script.Parent.PlayerDataService)
local World=require(script.Parent.WorldService)
local B={Server={ServerLuck=0,ServerIncome=0},Busy={}}
function B:Restore(d)
 for _,key in ipairs({"ServerLuck","ServerIncome"}) do self.Server[key]=math.max(self.Server[key],d.Boosts[key] or 0) end
end
function B:Multiplier(key) return (self.Server[key] or 0)>os.time() and Config.Items[key].Multiplier or 1 end
function B:View(d)
 self:Restore(d);local out={}
 for _,key in ipairs(Config.Order) do local def=Config.Items[key];out[key]=math.max(0,(def.Scope=="Server" and self.Server[key] or d.Boosts[key] or 0)-os.time()) end
 return out
end
function B:Buy(player,key)
 local g=self.Game;local d=Data:Get(player);local def=type(key)=="string" and Config.Items[key]
 if not def or not d or not g:Allow(player) or not g:Near(player,World.Shops.Shop,18) then return end
 if key=="Luck" or key=="ServerLuck" then
  local pets=require(script.Parent.PetService);pets:RefreshPolicy(player)
  d=Data:Get(player);if not d or not g:Near(player,World.Shops.Shop,18) or not pets:Allowed(player) then g:Notify(player,"LUCK UNAVAILABLE • Choose income boosts or styles");return end
 end
 self:Restore(d)
 if self.Busy[key] or (def.Scope=="Server" and self.Server[key] or d.Boosts[key] or 0)>os.time() then g:Notify(player,"BOOST ALREADY ACTIVE • No Cores spent");return end
 if d.Cores<def.Cost then g:Notify(player,"NEED "..def.Cost.." CORES • Try daily contracts");return end
 self.Busy[key]=true;local untilTime=os.time()+def.Seconds
 local ok=Data:Commit(player,function(c) assert(c.Cores>=def.Cost and not Config.active(c,key));c.Cores=c.Cores-def.Cost;c.Boosts[key]=untilTime end)
 self.Busy[key]=nil
 if ok then
  if def.Scope=="Server" then self.Server[key]=untilTime;g.Remote:FireAllClients("Notice",player.DisplayName.." activated "..def.Name) end
  g:Notify(player,"BOOST ACTIVE • "..def.Name);g:State(player)
 end
end
function B:Daily(player)
 local g=self.Game;local d=Data:Get(player);local day=math.floor(os.time()/86400)
 if not d or not g:Allow(player) or not player:GetAttribute("VIP") or d.VIPDay>=day then return end
 local ok=Data:Commit(player,function(c) assert(c.VIPDay<day);c.VIPDay=day;c.Cores=c.Cores+Config.VIPDailyCores end)
 if ok then g:Notify(player,"VIP DAILY • +5 CORES");g:State(player) end
end
return B
