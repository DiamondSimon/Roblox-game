import unittest
from test_startup import boot,ROOT

class ClientSmokeTests(unittest.TestCase):
 def test_hud_and_all_menu_callbacks(self):
  lua=boot();lua.execute((ROOT/'tests/client_stub.lua').read_text())
  lua.execute((ROOT/'src/client/ClientMain.client.lua').read_text())
  lua.execute('''
   require(TestModules.GameplayService):State(TestPlayer)
   assert(TestPlayer.PlayerGui.ScrapyardHUD)
   click("SHOP");click("CORES");click("STYLES");click("X")
   click("UPGRADES");click("X");click("QUESTS");click("X");click("COLLECTION");click("X")
   local data=require(TestModules.PlayerDataService)
   require(TestModules.QuestService):Progress(data:Get(TestPlayer),"Collected",5)
   require(TestModules.GameplayService):State(TestPlayer)
   click("QUESTS •");Clock=Clock+1;click("CLAIM CORES")
   assert(data:Get(TestPlayer).Cores==10)
  ''')

if __name__=='__main__':unittest.main(verbosity=2)
