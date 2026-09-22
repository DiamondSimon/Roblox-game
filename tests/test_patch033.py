import unittest
from test_startup import boot
from test_core import runtime

class Patch033Tests(unittest.TestCase):
 def test_entire_conveyor_and_spawn_path_relocated(self):
  lua=boot();lua.execute('''
   local w=require(TestModules.WorldService);local g=require(TestModules.GameplayService)
   local c=require(game.ReplicatedStorage.Shared.Config.GameConfig)
   local belt=w.Root.ConveyorAssembly["CENTRAL SALVAGE"]
   assert(belt.Position.Z==1 and belt.Position.Z-belt.Size.Z/2==-224)
   assert(w.Root.ConveyorAssembly["Salvage hopper"].Position.Z==-246)
   assert(w.Shredder.Position.Z==238)
   for model,entry in pairs(g.Salvage) do
    assert(model.PrimaryPart.Position.Z>=-224 and model.PrimaryPart.Position.Z<=-149)
   end
   g:MoveSalvage(Clock+1)
   for model,entry in pairs(g.Salvage) do
    assert(math.abs(model.PrimaryPart.Position.Z-(entry.StartZ+c.BeltSpeed))<0.0001)
   end
   assert(not w.Root:FindFirstChild("CENTRAL SALVAGE"))
  ''')
 def test_poi_labels_above_roofs_world_space_and_unoccluded(self):
  lua=boot();lua.execute('''
   local w=require(TestModules.WorldService)
   for _,part in ipairs(w.Root:GetDescendants()) do
    if part.Name=="Warehouse" or part.Name=="Water tower" or part.Name=="Restricted gate" then
     local gui=part:FindFirstChild("BillboardGui")
     assert(gui and gui.AlwaysOnTop and gui.StudsOffsetWorldSpace.Y>=part.Size.Y/2+7)
    end
   end
   for _,stand in pairs(w.Shops) do
    local gui=stand:FindFirstChild("BillboardGui")
    assert(stand.Position.Y+gui.StudsOffsetWorldSpace.Y>=22)
   end
  ''')
 def test_schema5_conversion_once_including_old_receipts(self):
  lua=runtime();lua.execute('''
   Data:Load(Player);Data:Release(Player)
   local old=Store.records.player_42.Data
   old.SchemaVersion=5;old.Scrap=1234.5;old.LifetimeScrap=9000;old.Cores=81
   old.Receipts.paid={Currency="Scrap",Amount=500};old.Receipts.core={Currency="Cores",Amount=80}
   local d=Data:Load(Player)
   assert(d.SchemaVersion==7 and d.Scrap==1234500 and d.LifetimeScrap==9000000 and d.Cores==81)
   assert(d.Receipts.paid.Amount==500000 and d.Receipts.core.Amount==80)
   Data:Release(Player);d=Data:Load(Player)
   assert(d.Scrap==1234500 and d.Receipts.paid.Amount==500000)
  ''')
 def test_large_income_and_price_ladder(self):
  lua=boot();lua.execute('''
   local m=require(game.ReplicatedStorage.Shared.Config.MachineConfig)
   local e=require(game.ReplicatedStorage.Shared.Config.EconomyConfig)
   assert(m.ById.radio.BaseIncome==300 and m.ById.singularity.BaseIncome==3500000)
   assert(m.ById.radio.SellValue==6000 and e.cost("Income",0)==180000)
   assert(e.cost("Floors",0)==3500000 and e.rebirthCost(0)==25000000)
   local previous=0
   for _,id in ipairs({"radio","mower","motorcycle","compressor","excavator","reactor","ufo"}) do
    assert(m.ById[id].BaseIncome>previous);previous=m.ById[id].BaseIncome
   end
  ''')
 def test_durable_receipt_merge_converts_legacy_units_once(self):
  lua=runtime();lua.execute('''
   Data:Load(Player)
   local old=Store.records.player_42.Data;old.SchemaVersion=5
   old.Receipts.late={Currency="Scrap",Amount=500}
   assert(Data:Commit(Player));assert(Data:Get(Player).Scrap==500000)
   assert(Data:Commit(Player));assert(Data:Get(Player).Scrap==500000)
  ''')
