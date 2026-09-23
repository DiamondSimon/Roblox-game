import unittest
from test_startup import boot,ROOT
from test_core import runtime
from test_v3 import SETUP,SECOND
class Patch035Tests(unittest.TestCase):
 def run_lua(self,code):
  lua=boot();lua.execute(SETUP+'local boosts=require(TestModules.BoostService)\n'+code);return lua
 def test_shredder_endpoint_and_unchanged_conveyor_yards(self):
  self.run_lua('''
   local c=require(game.ReplicatedStorage.Shared.Config.GameConfig)
   local belt=w.Root.ConveyorAssembly["CENTRAL SALVAGE"]
   assert(belt.Position.Z==1 and belt.Size.Z==450 and belt.Position.Z+belt.Size.Z/2==c.BeltDeckEnd)
   assert(w.Shredder.Position.Z-w.Shredder.Size.Z/2==c.BeltDeckEnd and w.Shredder.Position.Z==c.ShredderCenterZ)
   assert((c.ShredderCenterZ-c.BeltStart)/c.BeltSpeed==42)
   for i,y in ipairs(w.Yards) do assert(math.abs(y.Center.X)==330 and y.Center.Z==-210+((i-1)%4)*140) end
  ''')
 def test_vip_income_theme_daily_once(self):
  self.run_lua('''
   d.MachineInventory={{Uid="r",MachineId="radio",Protected=false}}
   TestPlayer:SetAttribute("VIP",true);yards:Refresh(TestPlayer,d)
   assert(yards.Owned[TestPlayer].Label.Text:find("VIP"))
   assert(math.abs(g:Income(TestPlayer,d)-345)<0.001)
   boosts:Daily(TestPlayer);assert(data:Get(TestPlayer).Cores==5)
   Clock=Clock+1;boosts:Daily(TestPlayer);assert(data:Get(TestPlayer).Cores==5)
  ''')
 def test_personal_boost_atomic_charge_expiry_and_no_duration_stack(self):
  self.run_lua('''
   local now=100000;os.time=function() return now end
   root.Position=w.Shops.Shop.Position;d.Cores=100
   boosts:Buy(TestPlayer,"Income");d=data:Get(TestPlayer)
   assert(d.Cores==70 and d.Boosts.Income==100900)
   Clock=Clock+1;boosts:Buy(TestPlayer,"Income");assert(data:Get(TestPlayer).Cores==70)
   d.MachineInventory={{Uid="r",MachineId="radio",Protected=false}}
   assert(g:Income(TestPlayer,d)==600)
   now=100900;assert(g:Income(TestPlayer,d)==300)
  ''')
 def test_server_boost_does_not_multiply_scrap_rush(self):
  self.run_lua('''
   root.Position=w.Shops.Shop.Position;d.Cores=100
   boosts:Buy(TestPlayer,"ServerIncome");d=data:Get(TestPlayer);assert(d.Cores==0)
   d.MachineInventory={{Uid="r",MachineId="radio",Protected=false}}
   assert(g:Income(TestPlayer,d)==375)
   require(TestModules.RewardsService).Started=Clock-480
   assert(g:Income(TestPlayer,d)==375)
   TestPlayer:SetAttribute("DoubleScrap",true);TestPlayer:SetAttribute("VIP",true)
   d.Pets={Owned={cosmic_serpent=1},Equipped="cosmic_serpent"};d.Rebirths=10;d.Boosts.Income=os.time()+900
   assert(math.abs(g:Income(TestPlayer,d)-3105)<0.001)
  ''')
 def test_boost_invalid_remote_distance_and_insufficient_funds(self):
  self.run_lua('''
   boosts:Buy(TestPlayer,{});assert(d.Cores==0)
   Clock=Clock+1;root.Position=w.Shops.Shop.Position;boosts:Buy(TestPlayer,"Income");assert(next(d.Boosts)==nil)
   Clock=Clock+1;d.Cores=100;root.Position=Vector3.zero;boosts:Buy(TestPlayer,"Income");assert(d.Cores==100)
  ''')
 def test_migration_and_boost_persistence_ambiguous_commit(self):
  lua=runtime();lua.execute('''
   Data:Load(Player);Data:Release(Player);local d=Store.records.player_42.Data
   d.SchemaVersion=6;d.Boosts=nil;d.VIPDay=nil;d.Scrap=500;d.Cores=100
   d=Data:Load(Player);assert(d.SchemaVersion==7 and d.Scrap==500 and d.VIPDay==-1)
   Store.ambiguous=true
   assert(not Data:Commit(Player,function(c) c.Cores=c.Cores-30;c.Boosts.Income=os.time()+900 end))
   assert(Data:Get(Player)==nil);Store.ambiguous=false;Store.failAfterCommit=false
   d=Data:Load(Player);assert(d.Cores==70 and d.Boosts.Income>os.time())
  ''')
 def test_luck_odds_sum_and_gate_weight_cap(self):
  self.run_lua('''
   local odds=require(game.ReplicatedStorage.Shared.Config.SalvageOdds)
   local base,bt=odds.weights(0,1,1);local plus,pt=odds.weights(0,1.5,1);local max,mt=odds.weights(8,1.5,1.5)
   assert(plus.radio==base.radio and plus.mower==base.mower*1.5 and plus.ufo==base.ufo)
   assert(max.ufo==base.ufo*2)
   local sum=0;for _,v in pairs(max) do sum=sum+v/mt end;assert(math.abs(sum-1)<0.000001)
  ''')
 def test_paid_luck_pickup_drop_and_slap_fail_closed(self):
  self.run_lua(SECOND+'''
   local pets=require(TestModules.PetService);pets.PracticePolicy[TestPlayer]="Restricted"
   g:Spawn("radio",nil,root.Position,true);local target
   for model,e in pairs(g.Salvage) do if e.PaidLuck then target=model end end
   g:Pickup(TestPlayer,target);assert(not g.Carrying[TestPlayer] and g.Salvage[target])
   pets.PracticePolicy[other]="Allowed";assert(g:GiveCarry(other,"radio",true))
   p:Slap(TestPlayer);assert(g.Carrying[other] and not g.Carrying[TestPlayer])
   Clock=Clock+2;root.Position=w.Shops.Shop.Position;d.Cores=100
   boosts:Buy(TestPlayer,"Luck");assert(data:Get(TestPlayer).Cores==100)
  ''')
 def test_paid_drop_cannot_bypass_transfer_policy(self):
  self.run_lua(SECOND+'''
   local pets=require(TestModules.PetService);pets.PracticePolicy[other]="Allowed"
   assert(g:GiveCarry(other,"radio",true));g:Drop(other)
   local target;for model,entry in pairs(g.Salvage) do if entry.PaidLuck then target=model;assert(entry.PaidOwner==other.UserId) end end
   pets.PracticePolicy[TestPlayer]=nil;pets.Policies[TestPlayer]={Allowed=true,TradingAllowed=false,Checked=Clock}
   root.Position=target.PrimaryPart.Position;g:Pickup(TestPlayer,target)
   assert(not g.Carrying[TestPlayer] and g.Salvage[target])
  ''')
 def test_new_ui_boosts_vip_rebirth_and_odds(self):
  lua=boot();lua.execute((ROOT/'tests/client_stub.lua').read_text());lua.execute((ROOT/'src/client/ClientMain.client.lua').read_text())
  lua.execute('''
   local data=require(TestModules.PlayerDataService);local g=require(TestModules.GameplayService)
   TestPlayer:SetAttribute("VIP",true);g:State(TestPlayer)
   local remote=game.ReplicatedStorage.Remotes.Game
   remote:FireClient(TestPlayer,"Open","Shop");click("BOOSTS")
   click("25 CORES • ACTIVATE HERE");click("VIEW NEXT REBIRTH TIER")
   click("X");click("REWARDS");Clock=Clock+1;click("CLAIM VIP CORES");assert(data:Get(TestPlayer).Cores==5)
   click("X");remote:FireClient(TestPlayer,"Open","Rebirth")
   local n=0;for _,o in ipairs(TestPlayer.PlayerGui:GetDescendants()) do if o:IsA("ViewportFrame") then n=n+1 end end;assert(n==1)
  ''')
 def test_environment_scheduler_culls_effects_and_animates_press(self):
  lua=boot();lua.execute((ROOT/'tests/client_stub.lua').read_text())
  lua.execute('''
   TestServices.Debris={AddItem=function(_,o,seconds) task.delay(seconds,function() o:Destroy() end) end}
   local map={ScrapyardPress="Hydraulic press",ScrapyardBeacon="Shredder warning beacon",ScrapyardSteam="Stack steam outlet",ScrapyardMotor="SHREDDER"}
   local tags=TestServices.CollectionService
   function tags:GetTagged(tag) local t={};for _,p in ipairs(workspace.Map:GetDescendants()) do if p.Name==map[tag] then table.insert(t,p) end end;return t end
   function tags:GetInstanceAddedSignal() return {Connect=function() end} end
   function tags:GetInstanceRemovedSignal() return {Connect=function() end} end
   workspace.CurrentCamera.CFrame=CFrame.new(-180,15,140)
  ''');lua.execute((ROOT/'src/client/IndustrialEffects.client.lua').read_text());lua.execute('''
   local press=workspace.Map.IndustrialLandmarks["Hydraulic press"];local y=press.Position.Y
   TestServices.RunService.Heartbeat:Fire(1);assert(press.Position.Y<y and not press.CanCollide)
   workspace.CurrentCamera.CFrame=CFrame.new(10000,0,0);y=press.Position.Y
   TestServices.RunService.Heartbeat:Fire(1);assert(press.Position.Y==y)
  ''')
