"""Execute the actual server entrypoint and world generation with limited API fakes."""
from pathlib import Path
import unittest
from lupa import LuaRuntime
ROOT=Path(__file__).resolve().parents[1]

def boot():
 lua=LuaRuntime(unpack_returned_tuples=True)
 lua.execute((ROOT/'tests/studio_stub.lua').read_text())
 for p in sorted((ROOT/'src/shared/Config').glob('*.lua')):
  lua.globals().addSource(str(p.relative_to(ROOT)),p.read_text())
 for p in sorted((ROOT/'src/server').rglob('*.lua')):
  lua.globals().addSource(str(p.relative_to(ROOT)),p.read_text())
 lua.execute('startServer();assert(#Warnings==0,table.concat(Warnings,"\\n"));assert(not TestPlayer.Kicked,TestPlayer.Kicked)')
 return lua

class StartupTests(unittest.TestCase):
 def test_unpublished_boot_map_character_and_income(self):
  lua=boot()
  lua.execute('''
   assert(DataStoreOpenCalls==0)
   assert(game.ReplicatedStorage:GetAttribute("BootStatus")=="Ready")
   local world=require(TestModules.WorldService)
   assert(#world.Yards==8);assert(workspace.Map);assert(workspace.Map["District ground"])
   assert(#workspace.Map:GetDescendants()>500)
   assert(TestPlayer.Character);assert(TestPlayer.RespawnLocation)
   assert(TestPlayer:GetAttribute("YardIndex")==1)
   local root=TestPlayer.Character.HumanoidRootPart
   assert((root.Position-TestPlayer.RespawnLocation.Position).Magnitude==4)
   local data=require(TestModules.PlayerDataService)
   assert(#data:Get(TestPlayer).MachineInventory==1)
   local gameplay=require(TestModules.GameplayService)
   local count=0;for _ in pairs(gameplay.Salvage) do count=count+1 end;assert(count==6)
   local before=data:Get(TestPlayer).Scrap;advance();assert(data:Get(TestPlayer).Scrap>before)
  ''')
 def test_every_machine_model_builds(self):
  lua=boot()
  lua.execute('''
   local definitions=require(game.ReplicatedStorage.Shared.Config.MachineConfig)
   local factory=require(TestModules.MachineService)
   for _,id in ipairs(definitions.Order) do
    local model=factory:Create(id,Vector3.zero,workspace)
    assert(model.PrimaryPart);assert(#model:GetDescendants()>3);model:Destroy()
   end
  ''')
 def test_pickup_deposit_upgrade(self):
  lua=boot()
  lua.execute('''
   local gameplay=require(TestModules.GameplayService)
   local yard=require(TestModules.YardService).Owned[TestPlayer]
   local data=require(TestModules.PlayerDataService)
   local model=next(gameplay.Salvage)
   TestPlayer.Character.HumanoidRootPart.Position=model.PrimaryPart.Position
   gameplay:Pickup(TestPlayer,model);assert(gameplay.Carrying[TestPlayer])
   Clock=Clock+30
   TestPlayer.Character.HumanoidRootPart.Position=yard.Deposit.Position
   gameplay:Deposit(TestPlayer);assert(not gameplay.Carrying[TestPlayer])
   assert(#data:Get(TestPlayer).MachineInventory==2)
   Clock=Clock+1;data:Get(TestPlayer).Scrap=240
   TestPlayer.Character.HumanoidRootPart.Position=yard.Terminal.Position
   gameplay:Upgrade(TestPlayer,"Income")
   assert(data:Get(TestPlayer).Upgrades.Income==1);assert(data:Get(TestPlayer).Scrap==0)
  ''')

if __name__=='__main__': unittest.main(verbosity=2)
