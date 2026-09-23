import unittest
from test_startup import boot,ROOT
from test_v3 import SETUP,SECOND
class Patch034Tests(unittest.TestCase):
 def test_later_cost_growth_is_bounded(self):
  lua=boot();lua.execute("local e=require(game.ReplicatedStorage.Shared.Config.EconomyConfig);assert(e.rebirthCost(0)==25000000);assert(e.rebirthCost(3)==390625000);assert(math.abs(e.rebirthCost(4)/e.rebirthCost(3)-1.65)<0.00001);assert(e.rebirthCost(9)<8000000000)")
 def test_equal_yard_approaches_and_clear_corridors(self):
  lua=boot();lua.execute(SETUP+'''
   local belt=w.Root.ConveyorAssembly["CENTRAL SALVAGE"]
   for _,yard in ipairs(w.Yards) do
    assert(math.abs(yard.Deposit.Position.X)==304)
    assert(yard.Center.Z>=belt.Position.Z-belt.Size.Z/2 and yard.Center.Z<=belt.Position.Z+belt.Size.Z/2)
    for _,part in ipairs(w.Root:GetDescendants()) do
     if part:IsA("BasePart") and part.Size and part.Position and part.Position.Y-part.Size.Y/2<6 and part.Position.Y+part.Size.Y/2>1 then
      local overlapZ=math.abs(part.Position.Z-yard.Center.Z)<part.Size.Z/2+7
      local toward=yard.Center.X<0 and -1 or 1
      local x=part.Position.X*toward
      -- Interior walk corridor: exclude endpoint conveyor and the player's own yard.
      if overlapZ and x+part.Size.X/2>25 and x-part.Size.X/2<276 then
       assert(part.Name=="Direct haul path",part.Name.." obstructs approach")
      end
     end
    end
   end
   assert(#w.Root.OffRoadScenery:GetChildren()==132)
  ''')
 def test_pickup_drop_and_direct_carry_rarity_gates(self):
  lua=boot();lua.execute(SETUP+'''
   local m=require(game.ReplicatedStorage.Shared.Config.MachineConfig)
   for _,pair in ipairs({{"motorcycle",1},{"sports",2},{"excavator",3},{"reactor",5},{"ufo",8}}) do
    assert(not m.canCollect(pair[1],pair[2]-1) and m.canCollect(pair[1],pair[2]))
   end
   assert(not g:GiveCarry(TestPlayer,"ufo"))
   g:Spawn("ufo",nil,root.Position)
   local target;for model,entry in pairs(g.Salvage) do if entry.Id=="ufo" then target=model end end
   g:Pickup(TestPlayer,target);assert(not g.Carrying[TestPlayer] and g.Salvage[target])
   Clock=Clock+1;d.Rebirths=8;g:Pickup(TestPlayer,target);assert(g.Carrying[TestPlayer].Id=="ufo")
  ''')
 def test_locked_slap_does_not_delete_or_transfer_item(self):
  lua=boot();lua.execute(SETUP+SECOND+'''
   data:Get(other).Rebirths=8;assert(g:GiveCarry(other,"ufo"))
   p:Slap(TestPlayer);assert(not g.Carrying[TestPlayer] and g.Carrying[other].Id=="ufo")
  ''')
 def test_junk_previews_sell_confirm_replace_and_collection(self):
  lua=boot();lua.execute((ROOT/'tests/client_stub.lua').read_text());lua.execute((ROOT/'src/client/ClientMain.client.lua').read_text())
  lua.execute('''
   local data=require(TestModules.PlayerDataService);local g=require(TestModules.GameplayService)
   data:Get(TestPlayer).MachineInventory={{Uid="preview",MachineId="radio",Protected=false}};g:State(TestPlayer)
   local remote=game.ReplicatedStorage.Remotes.Game
   local function count()
    local n=0;for _,o in ipairs(TestPlayer.PlayerGui:GetDescendants()) do if o.Name=="JunkPreview_radio" then assert(o.CurrentCamera);n=n+1 end end;assert(n==1)
   end
   remote:FireClient(TestPlayer,"Open","Sell");count();click("SELL…");count()
   click("X");remote:FireClient(TestPlayer,"Replace");count();click("SELECT TO REPLACE");count()
   click("X");click("COLLECTION");local n=0
   for _,o in ipairs(TestPlayer.PlayerGui:GetDescendants()) do if o:IsA("ViewportFrame") then n=n+1 end end;assert(n==30)
  ''')
 def test_belt_tread_motion_and_streaming_cleanup(self):
  lua=boot();lua.execute((ROOT/'tests/client_stub.lua').read_text())
  lua.execute('''
   Enum.EasingStyle.Quad="Quad"
   local tags=TestServices.CollectionService;local added,removed={},{}
   local function signal() return {Connect=function(self,f) self.fn=f end} end
   function tags:GetTagged(tag)
    local t={};if tag=="ScrapyardBelt" then for _,v in ipairs(workspace.Map.ConveyorAssembly:GetChildren()) do if v.Name=="Moving belt tread" then table.insert(t,v) end end end;return t
   end
   function tags:GetInstanceAddedSignal(tag) added[tag]=signal();return added[tag] end
   function tags:GetInstanceRemovedSignal(tag) removed[tag]=signal();return removed[tag] end
   TestRemoved=removed
   workspace.CurrentCamera.CFrame=CFrame.new(0,5,0)
  ''');lua.execute((ROOT/'src/client/Environment.client.lua').read_text());lua.execute('''
   local tread=workspace.Map.ConveyorAssembly["Moving belt tread"];local before=tread.Position.Z
   TestServices.RunService.RenderStepped:Fire(0.5);assert(math.abs(tread.Position.Z-before-5.5)<0.001)
   TestRemoved.ScrapyardBelt.fn(tread);before=tread.Position.Z
   TestServices.RunService.RenderStepped:Fire(0.5);assert(tread.Position.Z==before)
  ''')
