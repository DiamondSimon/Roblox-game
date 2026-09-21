local Policy=game:GetService("PolicyService")
local Config=require(game.ReplicatedStorage.Shared.Config.PetConfig)
local Data=require(script.Parent.PlayerDataService)
local World=require(script.Parent.WorldService)
local Http=game:GetService("HttpService")
local Pets={Policies={},Checking={},Tokens={}}
function Pets:Token(player)
 if not self.Tokens[player] then self.Tokens[player]=Http:GenerateGUID(false) end
 return self.Tokens[player]
end
function Pets:RefreshPolicy(player)
 if self.Checking[player] then return end
 self.Checking[player]=true
 local ok,result=pcall(function() return Policy:GetPolicyInfoForPlayerAsync(player) end)
 if player.Parent then
  self.Policies[player]={Allowed=ok and type(result)=="table" and result.ArePaidRandomItemsRestricted==false,Checked=os.clock()}
 end
 self.Checking[player]=nil
end
function Pets:Allowed(player)
 local record=self.Policies[player]
 if not record or os.clock()-record.Checked>300 then return false end
 return record.Allowed
end
function Pets:Publish(player,d)
 player:SetAttribute("EquippedPet",d.Pets.Equipped)
end
function Pets:Award(d,id)
 d.Pets.Owned[id]=(d.Pets.Owned[id] or 0)+1
 if Config.ById[id].Bonus>Config.bonus(d.Pets) then d.Pets.Equipped=id end
end
function Pets:Buy(player,arg)
 local g=self.Game
 if type(arg)~="table" or not Data:Get(player) or not g:Near(player,World.Shops.Pets,15) or not g:Allow(player) then return end
 local def=type(arg.Case)=="string" and Config.Cases[arg.Case]
 local currency=arg.Currency
 if not def or (currency~="Scrap" and currency~="Cores") or arg.Token~=self:Token(player) then return end
 local record=self.Policies[player]
 if not record or os.clock()-record.Checked>300 then self:RefreshPolicy(player) end
 -- Recheck after yielding to PolicyService: the player may have moved or data may now be busy.
 local d=Data:Get(player)
 if not d or not g:Near(player,World.Shops.Pets,15) then return end
 if not self:Allowed(player) then g:Notify(player,"RANDOM CASES UNAVAILABLE • Guaranteed pets are available in the Pets tab");g:State(player);return end
 local cost=def[currency]
 if d[currency]<cost then g:Notify(player,"NEED "..math.ceil(cost-d[currency]).." MORE "..string.upper(currency));return end
 for _,outcome in ipairs(def.Outcomes) do if (d.Pets.Owned[outcome.Id] or 0)>=10000 then g:Notify(player,"CASE COLLECTION LIMIT REACHED");return end end
 -- Draw once before the durable transaction; retries never change the chosen pet.
 local roll=g.Random:NextNumber(0,100);local id=def.Outcomes[#def.Outcomes].Id
 for _,outcome in ipairs(def.Outcomes) do roll=roll-outcome.Weight;if roll<=0 then id=outcome.Id;break end end
 self.Tokens[player]=Http:GenerateGUID(false)
 local ok=Data:Commit(player,function(candidate)
  assert(candidate[currency]>=cost)
  candidate[currency]=candidate[currency]-cost;self:Award(candidate,id)
 end)
 if ok then
  d=Data:Get(player);if not d then return end
  self:Publish(player,d);g:State(player);g.Remote:FireClient(player,"PetResult",id)
 else g:Notify(player,"CASE SAVE COULD NOT BE CONFIRMED • Rejoin to restore the saved result") end
end
function Pets:Direct(player,id)
 local g=self.Game;local def=type(id)=="string" and Config.ById[id];local d=Data:Get(player)
 if not def or not d or not g:Near(player,World.Shops.Pets,15) or not g:Allow(player) then return end
 if (d.Pets.Owned[id] or 0)>0 then g:Notify(player,"ALREADY OWNED • Equip it from Pets");return end
 if d.Scrap<def.DirectScrap then g:Notify(player,"NEED "..math.ceil(def.DirectScrap-d.Scrap).." MORE SCRAP");return end
 local ok=Data:Commit(player,function(candidate)
  assert(not candidate.Pets.Owned[id] and candidate.Scrap>=def.DirectScrap)
  candidate.Scrap=candidate.Scrap-def.DirectScrap;self:Award(candidate,id)
 end)
 if ok then d=Data:Get(player);if not d then return end;self:Publish(player,d);g:State(player);g.Remote:FireClient(player,"PetResult",id) end
end
function Pets:Equip(player,id)
 local g=self.Game;local d=Data:Get(player)
 if not d or type(id)~="string" or not g:Allow(player) then return end
 if id~="" and not d.Pets.Owned[id] then return end
 if d.Pets.Equipped==id then return end
 local ok=Data:Commit(player,function(candidate) assert(id=="" or candidate.Pets.Owned[id]);candidate.Pets.Equipped=id end)
 if ok then d=Data:Get(player);if not d then return end;self:Publish(player,d);g:State(player) end
end
return Pets
