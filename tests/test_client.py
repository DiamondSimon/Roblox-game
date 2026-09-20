import unittest
from test_startup import boot,ROOT

class ClientSmokeTests(unittest.TestCase):
 def test_hud_and_all_menu_callbacks(self):
  lua=boot();lua.execute((ROOT/'tests/client_stub.lua').read_text())
  lua.execute((ROOT/'src/client/ClientMain.client.lua').read_text())
  lua.execute((ROOT/'src/client/Waypoints.client.lua').read_text())
  lua.execute('''
   require(TestModules.GameplayService):State(TestPlayer)
   assert(TestPlayer.PlayerGui.ScrapyardHUD)
   assert(workspace.TutorialWaypoint.Beam.Enabled)
   TestPlayer:SetAttribute("TutorialTarget",nil);assert(not workspace.TutorialWaypoint.Beam.Enabled)
   TestPlayer:SetAttribute("TutorialTarget",Vector3.new(1,2,3));assert(workspace.TutorialWaypoint.Position.X==1)
   local remote=game.ReplicatedStorage.Remotes.Game
   click("SHOP →");Clock=Clock+6;click("HOME →")
   remote:FireClient(TestPlayer,"Open","Shop");click("CORES");click("STYLES");click("X")
   remote:FireClient(TestPlayer,"Open","Upgrades");click("X");click("QUESTS");click("X");click("COLLECTION");click("X")
   for _,menu in ipairs({"Sell","Spin","Rebirth"}) do remote:FireClient(TestPlayer,"Open",menu);click("X") end
   remote:FireClient(TestPlayer,"SpinResult",10)
   click("X")
   local data=require(TestModules.PlayerDataService)
   require(TestModules.QuestService):Progress(data:Get(TestPlayer),"Collected",5)
   require(TestModules.GameplayService):State(TestPlayer)
   click("QUESTS •");Clock=Clock+1;click("CLAIM CORES")
   assert(data:Get(TestPlayer).Cores==10)
  ''')

if __name__=='__main__':unittest.main(verbosity=2)
