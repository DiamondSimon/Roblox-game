import unittest
from test_startup import boot
from test_core import runtime,ROOT

class V2Tests(unittest.TestCase):
 def test_fresh_player_and_movement_caps(self):
  lua=boot();lua.execute('''
   local d=require(TestModules.PlayerDataService):Get(TestPlayer)
   assert(d.Cores==0 and d.Scrap==0 and d.SchemaVersion==4)
   for _,level in pairs(d.Upgrades) do assert(level==0) end
   assert(require(TestModules.YardService):Capacity(TestPlayer,d)==8)
   local e=require(game.ReplicatedStorage.Shared.Config.EconomyConfig)
   d.Upgrades.Speed=4;d.Upgrades.Carry=4
   assert(e.speed(d.Upgrades,false)==18 and e.speed(d.Upgrades,true)==14)
  ''')
 def test_claim_duplicate_and_daily_rollover(self):
  lua=boot();lua.execute('''
   local data=require(TestModules.PlayerDataService);local q=require(TestModules.QuestService)
   local d=data:Get(TestPlayer)
   q:Progress(d,"Collected",5)
   assert(q:Claim(TestPlayer,"collect"));assert(data:Get(TestPlayer).Cores==10)
   assert(not q:Claim(TestPlayer,"collect"));assert(data:Get(TestPlayer).Cores==10)
   d=data:Get(TestPlayer);q:Ensure(d,(d.QuestState.Day+1)*86400)
   assert(next(d.QuestState.Claimed)==nil and next(d.QuestState.Progress)==nil)
   assert(d.Cores==10)
  ''')
 def test_inspection_unique_and_distance_checked(self):
  lua=boot();lua.execute('''
   local q=require(TestModules.QuestService);local data=require(TestModules.PlayerDataService)
   local d=data:Get(TestPlayer);local world=require(TestModules.WorldService)
   world.Inspections.Crane.ProximityPrompt.Triggered:Fire(TestPlayer)
   assert((q:Ensure(d).Progress.inspect or 0)==0)
   assert(q:Inspect(d,"Crane"));assert(not q:Inspect(d,"Crane"))
   assert(q:Inspect(d,"Tower"));assert(q:Inspect(d,"Depot"))
   assert(q:Claim(TestPlayer,"inspect"));assert(data:Get(TestPlayer).Cores==10)
  ''')
 def test_cosmetic_exact_cost_and_no_double_charge(self):
  lua=boot();lua.execute('''
   local data=require(TestModules.PlayerDataService);local shop=require(TestModules.CoreShopService)
   assert(not shop:Buy(TestPlayer,"Gold"));assert(data:Get(TestPlayer).Cores==0)
   data:Get(TestPlayer).Cores=30
   assert(shop:Buy(TestPlayer,"Teal"));assert(data:Get(TestPlayer).Cores==0)
   assert(shop:Buy(TestPlayer,"Teal"));assert(data:Get(TestPlayer).Cores==0)
   assert(data:Get(TestPlayer).Cosmetics.Equipped=="Teal")
  ''')
 def test_remote_upgrade_requires_own_terminal(self):
  lua=boot();lua.execute('''
   local data=require(TestModules.PlayerDataService);local gameService=require(TestModules.GameplayService)
   data:Get(TestPlayer).Scrap=10000
   TestPlayer.Character.HumanoidRootPart.Position=Vector3.zero
   gameService:Upgrade(TestPlayer,"Speed");assert(data:Get(TestPlayer).Upgrades.Speed==0)
   Clock=Clock+1;TestPlayer.Character.HumanoidRootPart.Position=require(TestModules.WorldService).Shops.Upgrades.Position
   gameService:Upgrade(TestPlayer,{});assert(data:Get(TestPlayer).Scrap==10000)
  ''')
 def test_contested_pickup_and_distinct_yards(self):
  lua=boot();lua.execute('''
   local second=Instance.new("Player");second.UserId=43;second.DisplayName="Second";second.Parent=TestServices.Players
   second.Character=TestPlayer.Character
   local data=require(TestModules.PlayerDataService);data:Load(second)
   local yards=require(TestModules.YardService);yards:Claim(second)
   assert(yards.Owned[second]~=yards.Owned[TestPlayer])
   local g=require(TestModules.GameplayService);local model=next(g.Salvage)
   TestPlayer.Character.HumanoidRootPart.Position=model.PrimaryPart.Position
   g:Pickup(TestPlayer,model);g:Pickup(second,model)
   assert(g.Carrying[TestPlayer] and not g.Carrying[second])
  ''')
 def test_full_yard_replacement_preserves_starter(self):
  lua=boot();lua.execute('''
   local data=require(TestModules.PlayerDataService);local d=data:Get(TestPlayer)
   table.insert(d.MachineInventory,{Uid="legacy",MachineId="radio",Protected=true})
   for i=2,8 do table.insert(d.MachineInventory,{Uid="extra"..i,MachineId="radio",Protected=false}) end
   local g=require(TestModules.GameplayService);local model=next(g.Salvage)
   TestPlayer.Character.HumanoidRootPart.Position=model.PrimaryPart.Position;g:Pickup(TestPlayer,model)
   Clock=Clock+30;TestPlayer.Character.HumanoidRootPart.Position=require(TestModules.YardService).Owned[TestPlayer].Deposit.Position
   g:Deposit(TestPlayer,d.MachineInventory[1].Uid);assert(g.Carrying[TestPlayer]);assert(#d.MachineInventory==8)
   Clock=Clock+1;g:Deposit(TestPlayer,"extra2");assert(not g.Carrying[TestPlayer]);assert(#d.MachineInventory==8)
   assert(d.MachineInventory[1].Protected)
  ''')
 def test_schema_migration_preserves_old_progress(self):
  lua=runtime();lua.execute('''
   Data:Load(Player);Data:Release(Player)
   local d=Store.records.player_42.Data
   d.SchemaVersion=1;d.Cores=nil;d.QuestState=nil;d.Cosmetics=nil
   d.Upgrades={Income=15,Slots=7};d.Scrap=12345;d.Receipts.old=500
   local migrated=Data:Load(Player)
   assert(migrated.SchemaVersion==4 and migrated.Scrap==12345 and migrated.Cores==0)
   assert(migrated.Upgrades.Income==15 and migrated.Upgrades.Floors==2)
   assert(migrated.Receipts.old.Currency=="Scrap" and migrated.Receipts.old.Amount==500)
  ''')
 def test_core_receipt_ambiguous_failure_and_reload(self):
  lua=runtime();lua.execute('Money.Products={{Id=123,Currency="Cores",Amount=80}}')
  lua.globals().Purchase=lua.execute((ROOT/'src/server/Services/PurchaseService.lua').read_text())
  lua.execute('''
   Data:Load(Player);Purchase:Start();Store.ambiguous=true
   local receipt={PlayerId=42,ProductId=123,PurchaseId="cores-1"}
   assert(Marketplace.ProcessReceipt(receipt)=="pending");assert(Data:Get(Player)==nil)
   assert(Store.records.player_42.Data.Cores==80);assert(not Data:Commit(Player))
   Store.ambiguous=false;Store.failAfterCommit=false
   Data:Load(Player);assert(Data:Get(Player).Cores==80)
   assert(Marketplace.ProcessReceipt(receipt)=="granted");assert(Data:Get(Player).Cores==80)
   assert(Data:Get(Player).Scrap==0)
  ''')
 def test_transaction_failure_prevents_overwrite(self):
  lua=runtime();lua.execute('''
   Data:Load(Player);Data:Get(Player).Cores=40;assert(Data:Commit(Player))
   Store.ambiguous=true
   assert(not Data:Commit(Player,function(d) d.Cores=d.Cores-30;d.Cosmetics.Owned.Teal=true end))
   assert(Data:Get(Player)==nil);assert(not Data:Commit(Player))
   Store.ambiguous=false;Store.failAfterCommit=false
   local d=Data:Load(Player);assert(d.Cores==10 and d.Cosmetics.Owned.Teal)
  ''')
 def test_map_travel_distances(self):
  lua=boot();lua.execute('''
   local world=require(TestModules.WorldService)
   for _,yard in ipairs(world.Yards) do
    local z=math.max(-54,math.min(54,yard.Spawn.Position.Z))
    local distance=(yard.Spawn.Position-Vector3.new(0,0,z)).Magnitude
    assert(distance/16>=15 and distance/16<=25)
   end
  ''')

if __name__=='__main__':unittest.main(verbosity=2)
