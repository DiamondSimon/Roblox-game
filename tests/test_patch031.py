import unittest
from test_startup import boot,ROOT
from test_core import runtime
SETUP='''
 local data=require(TestModules.PlayerDataService);local d=data:Get(TestPlayer)
 local g=require(TestModules.GameplayService);local pets=require(TestModules.PetService)
 local config=require(game.ReplicatedStorage.Shared.Config.PetConfig)
 local world=require(TestModules.WorldService);local root=TestPlayer.Character.HumanoidRootPart
 root.Position=world.Shops.Pets.Position
'''
class Patch031Tests(unittest.TestCase):
 def run_lua(self,s):
  lua=boot();lua.execute(SETUP+s);return lua
 def test_case_prices_charge_selected_currency_and_token_replay(self):
  self.run_lua('''
   d.Cores=100;d.Scrap=1000;local token=pets:Token(TestPlayer)
   pets:Buy(TestPlayer,{Case="Salvage",Currency="Cores",Token=token})
   d=data:Get(TestPlayer);assert(d.Cores==75 and d.Scrap==1000 and d.Pets.Owned.bolt_mouse==1)
   Clock=Clock+1;pets:Buy(TestPlayer,{Case="Salvage",Currency="Cores",Token=token});assert(data:Get(TestPlayer).Cores==75)
   Clock=Clock+1;pets:Buy(TestPlayer,{Case="Salvage",Currency="Scrap",Token=pets:Token(TestPlayer)})
   d=data:Get(TestPlayer);assert(d.Scrap==500 and d.Cores==75 and d.Pets.Owned.bolt_mouse==2)
   assert(config.bonus(d.Pets)==0.03)
  ''')
 def test_unknown_case_currency_insufficient_and_distance(self):
  self.run_lua('''
   pets:Buy(TestPlayer,{Case="Salvage",Currency="Cores",Token=pets:Token(TestPlayer)});assert(next(d.Pets.Owned)==nil)
   Clock=Clock+1;d.Cores=1000;pets:Buy(TestPlayer,{Case="invalid",Currency="Cores",Token=pets:Token(TestPlayer)})
   Clock=Clock+1;pets:Buy(TestPlayer,{Case="Salvage",Currency="Robux",Token=pets:Token(TestPlayer)})
   Clock=Clock+1;root.Position=Vector3.zero;pets:Buy(TestPlayer,{Case="Salvage",Currency="Cores",Token=pets:Token(TestPlayer)})
   assert(d.Cores==1000 and next(d.Pets.Owned)==nil)
  ''')
 def test_restricted_and_policy_error_fail_closed_but_direct_allowed(self):
  self.run_lua('''
   d.Cores=100;d.Scrap=5000
   TestServices.PolicyService.GetPolicyInfoForPlayerAsync=function() return {ArePaidRandomItemsRestricted=true} end
   pets:RefreshPolicy(TestPlayer);pets:Buy(TestPlayer,{Case="Salvage",Currency="Cores",Token=pets:Token(TestPlayer)})
   assert(d.Cores==100 and next(d.Pets.Owned)==nil)
   Clock=Clock+1;pets:Direct(TestPlayer,"bolt_mouse");d=data:Get(TestPlayer);assert(d.Scrap==3800 and d.Pets.Owned.bolt_mouse==1)
   TestServices.PolicyService.GetPolicyInfoForPlayerAsync=function() error("unavailable") end
   pets:RefreshPolicy(TestPlayer);assert(not pets:Allowed(TestPlayer))
   Clock=Clock+1;pets:Buy(TestPlayer,{Case="Salvage",Currency="Scrap",Token=pets:Token(TestPlayer)})
   assert(data:Get(TestPlayer).Scrap==3800)
  ''')
 def test_policy_refresh_rechecks_distance_after_yield(self):
  self.run_lua('''
   d.Cores=100;pets.Policies[TestPlayer]=nil
   TestServices.PolicyService.GetPolicyInfoForPlayerAsync=function() root.Position=Vector3.zero;return {ArePaidRandomItemsRestricted=false} end
   pets:Buy(TestPlayer,{Case="Salvage",Currency="Cores",Token=pets:Token(TestPlayer)})
   assert(d.Cores==100 and next(d.Pets.Owned)==nil)
  ''')
 def test_policy_recovery_on_reopening_stand(self):
  self.run_lua('''
   pets.Policies[TestPlayer]={Allowed=false,Checked=Clock-31}
   world.Shops.Pets.ProximityPrompt.Triggered:Fire(TestPlayer);assert(pets:Allowed(TestPlayer))
  ''')
 def test_all_case_outcomes_and_better_tier_expectation(self):
  self.run_lua('''
   local previous=0
   for _,key in ipairs(config.CaseOrder) do
    local def=config.Cases[key];local total,expectation=0,0
    for _,o in ipairs(def.Outcomes) do total=total+o.Weight;expectation=expectation+config.ById[o.Id].Bonus*o.Weight/100 end
    assert(total==100 and expectation>previous);previous=expectation
   end
  ''')
  for roll,pet in [(0,'plasma_dragon'),(60.1,'crane_griffin'),(95.1,'cosmic_serpent'),(100,'cosmic_serpent')]:
   self.run_lua(f'''
    d.Cores=300;g.Random.NextNumber=function() return {roll} end
    pets:Buy(TestPlayer,{{Case="Prototype",Currency="Cores",Token=pets:Token(TestPlayer)}})
    assert(data:Get(TestPlayer).Pets.Owned.{pet}==1 and data:Get(TestPlayer).Cores==0)
   ''')
 def test_one_pet_bonus_equip_ownership_and_rebirth_preservation(self):
  self.run_lua('''
   d.MachineInventory={{Uid="test",MachineId="radio",Protected=false}}
   d.Pets={Owned={bolt_mouse=8,cosmic_serpent=1},Equipped="cosmic_serpent"}
   assert(math.abs(g:Income(TestPlayer,d)-0.36)<0.00001)
   pets:Equip(TestPlayer,"steel_tiger");assert(d.Pets.Equipped=="cosmic_serpent")
   Clock=Clock+1;pets:Equip(TestPlayer,"bolt_mouse");d=data:Get(TestPlayer);assert(math.abs(g:Income(TestPlayer,d)-0.309)<0.00001)
   Clock=Clock+1;d.Scrap=25000;root.Position=world.Shops.Rebirth.Position
   require(TestModules.ProgressionService):Rebirth(TestPlayer,true)
   d=data:Get(TestPlayer);assert(d.Pets.Owned.bolt_mouse==8 and d.Pets.Owned.cosmic_serpent==1 and d.Pets.Equipped=="bolt_mouse")
  ''')
 def test_schema3_migration_preserves_everything_and_adds_empty_pets(self):
  self.run_lua('''
   d.SchemaVersion=3;d.Pets=nil;d.Scrap=777;d.Cores=51;d.Rebirths=2
   d=require(TestModules.ProfileSchema).migrate(d)
   assert(d.SchemaVersion==4 and d.Scrap==777 and d.Cores==51 and d.Rebirths==2 and next(d.Pets.Owned)==nil and d.Pets.Equipped=="")
  ''')
 def test_all_pet_models_and_scrap_rarity_budgets(self):
  self.run_lua('''
   local factory=require(game.ReplicatedStorage.Shared.Config.PetModelFactory)
   for _,id in ipairs(config.Order) do local model=factory:Create(id,workspace);assert(model.PrimaryPart and #model:GetDescendants()>8);model:Destroy() end
   local machines=require(game.ReplicatedStorage.Shared.Config.MachineConfig)
   assert(#machines.Order==30)
   local sums={};for _,id in ipairs(machines.Order) do local m=machines.ById[id];sums[m.Rarity]=(sums[m.Rarity] or 0)+m.SpawnWeight end
   for key,value in pairs({Common=295,Uncommon=93,Rare=43,Epic=12,Legendary=4,Mythic=0.9,Secret=0.1}) do assert(math.abs(sums[key]-value)<0.00001) end
  ''')
 def test_shredder_rotors_and_pet_stand_safe(self):
  self.run_lua('''
   local rotors,teeth,motors=0,0,0
   for _,obj in ipairs(world.Root:GetDescendants()) do
    if obj.Name=="CuttingRotor" then rotors=rotors+1;assert(obj.PrimaryPart) end
    if obj.Name=="Hook tooth" then teeth=teeth+1;assert(not obj.CanCollide) end
    if obj.Name=="Shredder drive motor" then motors=motors+1 end
   end
   assert(rotors==2 and teeth==84 and motors==2)
   assert(require(TestModules.ProgressionService):Safe(TestPlayer))
  ''')
 def test_client_companion_equipping_distance_and_cleanup(self):
  lua=boot();lua.execute((ROOT/'tests/client_stub.lua').read_text())
  lua.execute('workspace.CurrentCamera.CFrame=CFrame.new(TestPlayer.Character.HumanoidRootPart.Position)')
  lua.execute((ROOT/'src/client/Pets.client.lua').read_text())
  lua.execute(''' 
   TestPlayer:SetAttribute("EquippedPet","bolt_mouse");TestServices.RunService.Heartbeat:Fire(0.1)
   assert(workspace:FindFirstChild("Bolt Mouse"))
   TestPlayer:SetAttribute("EquippedPet","cosmic_serpent");TestServices.RunService.Heartbeat:Fire(0.1)
   assert(not workspace:FindFirstChild("Bolt Mouse") and workspace:FindFirstChild("Cosmic Serpent"))
   workspace.CurrentCamera.CFrame=CFrame.new(9999,0,0);TestServices.RunService.Heartbeat:Fire(0.1)
   assert(not workspace:FindFirstChild("Cosmic Serpent"))
  ''')
 def test_ambiguous_pet_transaction_preserves_spend_and_award(self):
  lua=runtime();lua.execute('''
   Data:Load(Player);Data:Get(Player).Cores=100;Data:Commit(Player)
   Store.ambiguous=true
   assert(not Data:Commit(Player,function(d) d.Cores=d.Cores-25;d.Pets.Owned.bolt_mouse=1;d.Pets.Equipped="bolt_mouse" end))
   assert(Data:Get(Player)==nil and not Data:Commit(Player))
   Store.ambiguous=false;Store.failAfterCommit=false
   local d=Data:Load(Player);assert(d.Cores==75 and d.Pets.Owned.bolt_mouse==1 and d.Pets.Equipped=="bolt_mouse")
  ''')
if __name__=='__main__':unittest.main(verbosity=2)
