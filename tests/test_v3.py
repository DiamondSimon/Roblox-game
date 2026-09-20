import unittest
from test_startup import boot,ROOT

SETUP='''
 local data=require(TestModules.PlayerDataService)
 local g=require(TestModules.GameplayService)
 local p=require(TestModules.ProgressionService)
 local w=require(TestModules.WorldService)
 local yards=require(TestModules.YardService)
 local d=data:Get(TestPlayer)
 local root=TestPlayer.Character.HumanoidRootPart
'''
SECOND='''
 local other=Instance.new("Player");other.Name="Other";other.DisplayName="Other";other.UserId=43;other.Parent=TestServices.Players
 other.Character=Instance.new("Model");other.Character.Parent=workspace
 local r=Instance.new("Part");r.Name="HumanoidRootPart";r.Parent=other.Character;r.Position=Vector3.new(0,3,-4)
 local h=Instance.new("Humanoid");h.Health=100;h.Parent=other.Character
 data:Load(other);yards:Claim(other);data:Get(other).TutorialStage=4
 d.TutorialStage=4;root.Position=Vector3.new(0,3,0);Clock=100
'''
class V3Tests(unittest.TestCase):
 def run_lua(self,code):
  lua=boot();lua.execute(SETUP+code);return lua
 def test_conveyor_moves_expires_and_cannot_pickup_expired(self):
  self.run_lua('''
   local model,entry=next(g.Salvage);local before=model.PrimaryPart.Position.Z
   g:MoveSalvage(entry.Started+2);assert(model.PrimaryPart.Position.Z==before+6)
   Clock=entry.Expires;root.Position=model.PrimaryPart.Position;g:Pickup(TestPlayer,model)
   assert(not g.Carrying[TestPlayer]);g:MoveSalvage(Clock)
   assert(model.Destroyed and not g.Salvage[model]);assert(g.Remote.LastBroadcast[1]=="ShredFX")
  ''')
 def test_floor_capacity_and_geometry_increase_in_eights(self):
  self.run_lua('''
   local yard=yards.Owned[TestPlayer];assert(#yard.Slots==8 and yard.FloorCount==1)
   assert(not yard.Folder:FindFirstChild("Upgrade terminal"))
   root.Position=w.Shops.Upgrades.Position;d.Scrap=3500;g:Upgrade(TestPlayer,"Floors")
   assert(yards:Capacity(TestPlayer,d)==16 and #yard.Slots==16 and yard.FloorCount==2)
   assert(math.abs(yard.Slots[9].Y-yard.Slots[1].Y-16)<0.001)
   TestPlayer:SetAttribute("ExtraSlots",true);yards:Refresh(TestPlayer,d);assert(#yard.Slots==24)
   d.Upgrades.Floors=3;yards:Refresh(TestPlayer,d);assert(#yard.Slots==40)
  ''')
 def test_tutorial_without_starter_then_shop(self):
  self.run_lua('''
   assert(#d.MachineInventory==0 and g:Income(TestPlayer,d)==0 and d.TutorialStage==1)
   local model=next(g.Salvage);root.Position=model.PrimaryPart.Position;g:Pickup(TestPlayer,model);assert(d.TutorialStage==2)
   Clock=Clock+40;root.Position=yards.Owned[TestPlayer].Deposit.Position;g:Deposit(TestPlayer)
   assert(d.TutorialStage==3 and #d.MachineInventory==1 and g:Income(TestPlayer,d)>0)
   root.Position=w.Shops.Upgrades.Position;w.Shops.Upgrades.ProximityPrompt.Triggered:Fire(TestPlayer)
   assert(d.TutorialStage==4)
  ''')
 def test_teleports_carry_combat_and_cooldown(self):
  self.run_lua('''
   p:Teleport(TestPlayer,"Shop");assert((root.Position-w.ShopSpawn).Magnitude==0)
   p:Teleport(TestPlayer,"Home");assert((root.Position-w.ShopSpawn).Magnitude==0)
   Clock=Clock+6;p:Teleport(TestPlayer,"Home");assert((root.Position-w.ShopSpawn).Magnitude>100)
   g:GiveCarry(TestPlayer,"radio");Clock=Clock+6;local before=root.Position
   p:Teleport(TestPlayer,"Shop");assert(root.Position==before)
   g:ClearCarry(TestPlayer);p.Combat[TestPlayer]=Clock+5;p:Teleport(TestPlayer,"Shop");assert(root.Position==before)
  ''')
 def test_spin_once_per_day_and_distance(self):
  self.run_lua('''
   p:Spin(TestPlayer);assert(d.Cores==0)
   root.Position=w.Shops.Spin.Position;p:Spin(TestPlayer)
   d=data:Get(TestPlayer);assert(d.Cores==5 and d.SpinState.Reward==5)
   Clock=Clock+1;p:Spin(TestPlayer);assert(data:Get(TestPlayer).Cores==5)
   d.SpinState.Day=d.SpinState.Day-1;Clock=Clock+1;p:Spin(TestPlayer);assert(data:Get(TestPlayer).Cores==10)
  ''')
 def test_spin_weight_boundaries(self):
  for roll,reward in [(0,5),(59,5),(61,10),(89,10),(91,20),(100,20)]:
   self.run_lua(f'''
    root.Position=w.Shops.Spin.Position;g.Random.NextNumber=function() return {roll} end
    p:Spin(TestPlayer);assert(data:Get(TestPlayer).Cores=={reward})
   ''')
 def test_sale_cannot_duplicate_or_sell_protected(self):
  self.run_lua('''
   d.MachineInventory={{Uid="a",MachineId="radio",Protected=false},{Uid="b",MachineId="radio",Protected=true}}
   p:Sell(TestPlayer,"a");assert(#data:Get(TestPlayer).MachineInventory==2)
   root.Position=w.Shops.Sell.Position;Clock=Clock+1;p:Sell(TestPlayer,"a")
   d=data:Get(TestPlayer);assert(#d.MachineInventory==1 and d.Scrap==6)
   Clock=Clock+1;p:Sell(TestPlayer,"a");Clock=Clock+1;p:Sell(TestPlayer,"b");assert(data:Get(TestPlayer).Scrap==6)
  ''')
 def test_rebirth_reset_preserves_permanent_progress(self):
  self.run_lua('''
   root.Position=w.Shops.Rebirth.Position;d.Scrap=25000;d.Cores=87;d.Upgrades.Floors=2;d.Upgrades.Income=4
   d.MachineInventory={{Uid="a",MachineId="radio",Protected=false},{Uid="b",MachineId="radio",Protected=true}}
   d.SpinState.Day=123;d.Cosmetics.Owned.Teal=true;d.DiscoveredMachines.radio=true
   p:Rebirth(TestPlayer,false);assert(d.Scrap==25000)
   p:Rebirth(TestPlayer,true);d=data:Get(TestPlayer)
   assert(d.Scrap==0 and d.Rebirths==1 and d.Upgrades.Income==0 and d.Upgrades.Floors==0)
   assert(d.Cores==87 and d.SpinState.Day==123 and d.Cosmetics.Owned.Teal and d.DiscoveredMachines.radio)
   assert(#d.MachineInventory==1 and d.MachineInventory[1].Protected)
   assert(yards.Owned[TestPlayer].FloorCount==1)
   local e=require(game.ReplicatedStorage.Shared.Config.EconomyConfig);assert(math.abs(e.income(100,0,false,1)-105)<0.001)
   Clock=Clock+1;p:Rebirth(TestPlayer,true);assert(data:Get(TestPlayer).Rebirths==1)
  ''')
 def test_slap_steals_exactly_one_and_recovers(self):
  self.run_lua(SECOND+'''
   g:GiveCarry(other,"radio");p:Slap(TestPlayer)
   assert(g.Carrying[TestPlayer] and not g.Carrying[other]);assert(h.PlatformStand)
   assert(#data:Get(other).MachineInventory==0)
   p:Teleport(other,"Home");assert(r.Position.Z==-4)
   Clock=Clock+2;advance();assert(h.PlatformStand==false)
   assert(h.LastState=="GettingUp")
  ''')
 def test_slap_range_los_safezones_and_tutorial_protection(self):
  self.run_lua(SECOND+'''
   g:GiveCarry(other,"radio")
   r.Position=Vector3.new(0,3,-20);p:Slap(TestPlayer);assert(g.Carrying[other])
   Clock=Clock+4;r.Position=Vector3.new(0,3,-4);workspace.RaycastHit={Instance=w.Shredder};p:Slap(TestPlayer);assert(g.Carrying[other])
   Clock=Clock+4;workspace.RaycastHit=nil;data:Get(other).TutorialStage=2;p:Slap(TestPlayer);assert(g.Carrying[other])
   Clock=Clock+4;data:Get(other).TutorialStage=4;root.Position=w.ShopSpawn;r.Position=w.ShopSpawn+Vector3.new(0,0,-4);p:Slap(TestPlayer);assert(g.Carrying[other])
  ''')
 def test_drop_creates_reclaimable_expiring_junk(self):
  self.run_lua('''
   g:GiveCarry(TestPlayer,"radio");g:Drop(TestPlayer);assert(not g.Carrying[TestPlayer])
   local dropped=nil;for model,entry in pairs(g.Salvage) do if entry.Dropped then dropped=model;assert(entry.Expires==Clock+25) end end
   assert(dropped);root.Position=dropped.PrimaryPart.Position;g:Pickup(TestPlayer,dropped);assert(g.Carrying[TestPlayer])
  ''')
 def test_schema2_inventory_and_receipts_preserved(self):
  self.run_lua('''
   d.SchemaVersion=2;d.Upgrades.Slots=4;d.Upgrades.Expansion=3;d.Upgrades.Floors=nil
   d.MachineInventory={{Uid="legacy",MachineId="radio",Protected=true}};d.Cores=37;d.Receipts.x={Currency="Cores",Amount=80}
   local migrated=require(TestModules.ProfileSchema).migrate(d)
   assert(migrated.SchemaVersion==3 and migrated.Upgrades.Floors==2 and migrated.Cores==37)
   assert(migrated.MachineInventory[1].Uid=="legacy" and migrated.Receipts.x.Amount==80 and migrated.TutorialStage==4)
  ''')
if __name__=='__main__':unittest.main(verbosity=2)
