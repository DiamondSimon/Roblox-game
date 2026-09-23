import unittest
from test_startup import boot,ROOT
from test_core import runtime
SETUP='''
 local data=require(TestModules.PlayerDataService);local d=data:Get(TestPlayer)
 local g=require(TestModules.GameplayService);local world=require(TestModules.WorldService)
 local lab=require(TestModules.StudioToolsService);local pets=require(TestModules.PetService)
 local rewards=require(TestModules.RewardsService)
'''
class Patch032Tests(unittest.TestCase):
 def run_lua(self,s):
  lua=boot();lua.execute(SETUP+s);return lua
 def test_shredder_whole_assembly_at_endpoint_no_overhead_text(self):
  self.run_lua('''
   local c=require(game.ReplicatedStorage.Shared.Config.GameConfig)
   assert(world.Shredder.Position.Z==c.ShredderCenterZ and c.ShredderCenterZ==238)
   local assembly=world.Root.ConveyorAssembly.ShredderAssembly;assert(assembly)
   for _,p in ipairs(assembly:GetDescendants()) do
    assert(not p:IsA("BillboardGui"))
    if p:IsA("BasePart") then assert(p.Position.Z>=222 and p.Position.Z<=252) end
   end
   local belt=world.Root.ConveyorAssembly["CENTRAL SALVAGE"]
   assert(belt.Position.Z+belt.Size.Z/2==226)
   assert(math.abs((c.ShredderCenterZ-c.BeltStart)/c.BeltSpeed-42)<0.001)
  ''')
 def test_studio_controls_fail_closed_on_live_and_persistent(self):
  self.run_lua('''
   assert(lab:Allowed(TestPlayer))
   TestServices.RunService.IsStudio=function() return false end
   lab:Action(TestPlayer,{Kind="Cores"});assert(d.Cores==0)
   lab:Action(TestPlayer,{Kind="Pass",Key="DoubleScrap"});assert(not TestPlayer:GetAttribute("DoubleScrap"))
   TestServices.RunService.IsStudio=function() return true end
   data.IsPersistent=function() return true end
   lab:Action(TestPlayer,{Kind="Scrap"});assert(d.Scrap==0)
   pets.PracticePolicy[TestPlayer]="Allowed";pets.Policies[TestPlayer]={Allowed=false,Checked=Clock}
   assert(not pets:Allowed(TestPlayer))
  ''')
 def test_studio_currencies_passes_all_products(self):
  self.run_lua('''
   lab:Action(TestPlayer,{Kind="Scrap"});assert(d.Scrap==100000000)
   Clock=Clock+1;lab:Action(TestPlayer,{Kind="Cores"});assert(d.Cores==1000)
   Clock=Clock+1;lab:Action(TestPlayer,{Kind="Pass",Key="DoubleScrap"});assert(TestPlayer:GetAttribute("DoubleScrap"))
   Clock=Clock+1;lab:Action(TestPlayer,{Kind="Pass",Key="ExtraSlots"});assert(#require(TestModules.YardService).Owned[TestPlayer].Slots==16)
   local config=require(game.ReplicatedStorage.Shared.Config.MonetizationConfig)
   local total=d.Cores
   for _,product in ipairs(config.Products) do Clock=Clock+1;lab:Action(TestPlayer,{Kind="Product",Key=product.Key});total=total+product.Amount end
   assert(data:Get(TestPlayer).Cores==total)
   local purchase=require(TestModules.PurchaseService)
   local before=data:Get(TestPlayer).Cores;assert(purchase:Grant(TestPlayer,"same-test",config.Products[1]));assert(purchase:Grant(TestPlayer,"same-test",config.Products[1]))
   assert(data:Get(TestPlayer).Cores==before+80)
  ''')
 def test_studio_policy_simulation_and_case_fulfillment(self):
  self.run_lua('''
   d.Cores=100;TestPlayer.Character.HumanoidRootPart.Position=world.Shops.Pets.Position
   lab:Action(TestPlayer,{Kind="Policy",Value="Restricted"});assert(not pets:Allowed(TestPlayer))
   Clock=Clock+1;lab:Action(TestPlayer,{Kind="Policy",Value="Allowed"});assert(pets:Allowed(TestPlayer))
   Clock=Clock+1;pets:Buy(TestPlayer,{Case="Salvage",Currency="Cores",Token=pets:Token(TestPlayer)})
   assert(data:Get(TestPlayer).Cores==75 and data:Get(TestPlayer).Pets.Owned.bolt_mouse==1)
   assert(g.Remote.LastMessage[2]=="CaseResult" and g.Remote.LastMessage[3].Pet=="bolt_mouse")
  ''')
 def test_studio_daily_reset_tutorial_and_stands(self):
  self.run_lua('''
   d.SpinState.Day=123;lab:Action(TestPlayer,{Kind="Daily"});assert(d.SpinState.Day==-1)
   Clock=Clock+1;lab:Action(TestPlayer,{Kind="Tutorial"});assert(d.TutorialStage==4)
   Clock=Clock+1;lab:Action(TestPlayer,{Kind="Stand",Key="Pets"});assert(g:Near(TestPlayer,world.Shops.Pets,15))
   Clock=Clock+1;lab:Action(TestPlayer,{Kind="Loadout"});assert(#d.MachineInventory==8 and #require(TestModules.YardService).Owned[TestPlayer].Slots==32)
  ''')
 def test_codes_and_collection_rewards_once_through_rebirth(self):
  self.run_lua('''
   rewards:Claim(TestPlayer,"Code"," foundry ");assert(data:Get(TestPlayer).Cores==20)
   Clock=Clock+1;rewards:Claim(TestPlayer,"Code","FOUNDRY");assert(data:Get(TestPlayer).Cores==20)
   Clock=Clock+1;rewards:Claim(TestPlayer,"Milestone","discover5");assert(data:Get(TestPlayer).Cores==20)
   d=data:Get(TestPlayer);local m=require(game.ReplicatedStorage.Shared.Config.MachineConfig)
   for i=1,5 do d.DiscoveredMachines[m.Order[i]]=true end
   Clock=Clock+1;rewards:Claim(TestPlayer,"Milestone","discover5");assert(data:Get(TestPlayer).Cores==30)
   d=data:Get(TestPlayer);d.Scrap=25000000;TestPlayer.Character.HumanoidRootPart.Position=world.Shops.Rebirth.Position
   Clock=Clock+1;require(TestModules.ProgressionService):Rebirth(TestPlayer,true)
   Clock=Clock+1;rewards:Claim(TestPlayer,"Milestone","discover5");assert(data:Get(TestPlayer).Cores==30)
   assert(data:Get(TestPlayer).Rewards.Codes.FOUNDRY)
  ''')
 def test_rush_boundaries_and_income(self):
  self.run_lua('''
   d.MachineInventory={{Uid="a",MachineId="radio",Protected=false}}
   rewards.Started=Clock;assert(not rewards:Event().Active);assert(math.abs(g:Income(TestPlayer,d)-300)<0.00001)
   Clock=Clock+480;assert(rewards:Event().Active and rewards:Event().Remaining==120)
   assert(math.abs(g:Income(TestPlayer,d)-375)<0.00001)
   Clock=Clock+120;assert(not rewards:Event().Active and rewards:Event().Remaining==480)
  ''')
 def test_equip_best_only_owned_strongest(self):
  self.run_lua('''
   d.Pets.Owned={bolt_mouse=500,steel_tiger=1,welding_owl=2};pets:EquipBest(TestPlayer)
   assert(data:Get(TestPlayer).Pets.Equipped=="steel_tiger")
  ''')
 def test_schema4_migration_adds_rewards_preserves_pet(self):
  self.run_lua('''
   d.SchemaVersion=4;d.Rewards=nil;d.Pets.Owned.bolt_mouse=1;d.Pets.Equipped="bolt_mouse";d.Cores=38
   d=require(TestModules.ProfileSchema).migrate(d)
   assert(d.SchemaVersion==7 and next(d.Rewards.Codes)==nil and d.Pets.Equipped=="bolt_mouse" and d.Cores==38)
  ''')
 def test_case_reel_preview_winner_and_skip_no_additional_reward(self):
  lua=boot();lua.execute((ROOT/'tests/client_stub.lua').read_text())
  lua.execute('''
   local reel=require(game.ReplicatedStorage.Shared.Config.CaseReel)
   local result=nil;local before=require(TestModules.PlayerDataService):Get(TestPlayer).Cores
   local gui=reel.play(TestPlayer.PlayerGui,{Pet="steel_tiger",Case="Industrial"},function(id) result=id end)
   local winner,views=0,0
   for _,o in ipairs(gui:GetDescendants()) do
    if o.Name=="ReelTile_15" then assert(o:GetAttribute("PetId")=="steel_tiger");winner=winner+1 end
    if o:IsA("ViewportFrame") then assert(o.CurrentCamera);views=views+1 end
    if o.Name=="ReelStrip" then assert(o.Position[1]==0.5 and o.Position[2]==-2142) end
   end
   assert(winner==1 and views==18)
   click("SKIP ANIMATION");assert(result=="steel_tiger" and gui.Destroyed)
   assert(require(TestModules.PlayerDataService):Get(TestPlayer).Cores==before)
  ''')
 def test_ui_test_lab_previews_and_reward_input(self):
  lua=boot();lua.execute((ROOT/'tests/client_stub.lua').read_text());lua.execute((ROOT/'src/client/ClientMain.client.lua').read_text())
  lua.execute('''
   require(TestModules.GameplayService):State(TestPlayer)
   click("TEST LAB");Clock=Clock+1;click("APPLY");assert(require(TestModules.PlayerDataService):Get(TestPlayer).Scrap==100000000)
   click("X");click("PETS");local views=0
   for _,o in ipairs(TestPlayer.PlayerGui:GetDescendants()) do if o:IsA("ViewportFrame") then views=views+1 end end;assert(views==9)
   click("X");click("REWARDS")
   for _,o in ipairs(TestPlayer.PlayerGui:GetDescendants()) do if o.Name=="RewardCode" then o.Text="SCRAP032" end end
   Clock=Clock+1;click("REDEEM");assert(require(TestModules.PlayerDataService):Get(TestPlayer).Cores==15)
  ''')
if __name__=='__main__':unittest.main(verbosity=2)
