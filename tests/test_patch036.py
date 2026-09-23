import math
import unittest
from test_startup import boot, ROOT
from test_v3 import SETUP

class Patch036Tests(unittest.TestCase):
 def run_lua(self, code):
  lua=boot();lua.execute(SETUP+code);return lua
 def test_actual_cutter_sweep_and_feed_geometry(self):
  lua=self.run_lua('''
   local c=require(game.ReplicatedStorage.Shared.Config.GameConfig)
   local a=w.Root.ConveyorAssembly.ShredderAssembly
   local belt=w.Root.ConveyorAssembly["CENTRAL SALVAGE"]
   local endZ=belt.Position.Z+belt.Size.Z/2
   assert(endZ==226 and belt.Position.Z-belt.Size.Z/2==-224)
   local firstDisc,firstTooth,firstShaft=math.huge,math.huge,math.huge
   for _,p in ipairs(a:GetDescendants()) do
    if p.Name=="Cutter disc" then
     assert(p.Orientation.Y==90) -- Roblox cylinders have local X axis, rotated onto Z.
     firstDisc=math.min(firstDisc,p.Position.Z-p.Size.X/2)
     assert(p.Position.Y-p.Size.Y/2>a["Shredder mouth"].Position.Y+a["Shredder mouth"].Size.Y/2)
    elseif p.Name=="Hook tooth" then
     firstTooth=math.min(firstTooth,p.Position.Z-p.Size.Z/2)
     local shaft=p.Parent.PrimaryPart
     local radius=math.sqrt((p.Position.X-shaft.Position.X)^2+(p.Position.Y-shaft.Position.Y)^2)
     -- Conservative swept circle of a rotating square tooth, tested through all phases.
     local swept=radius+math.sqrt((p.Size.X/2)^2+(p.Size.Y/2)^2)
     assert(shaft.Position.Y-swept>a["Shredder mouth"].Position.Y+a["Shredder mouth"].Size.Y/2)
     local innerWall=12-(math.cos(math.rad(18))*0.5+math.sin(math.rad(18))*3.5)
     assert(math.abs(shaft.Position.X)+swept<innerWall)
     assert(p.Position.Z-p.Size.Z/2>endZ)
    elseif p.Name=="Shaft" then firstShaft=math.min(firstShaft,p.Position.Z-p.Size.Z/2)
    elseif p.Name=="Flared feed wall" then assert(p.Position.Z-p.Size.Z/2==225.5 and math.abs(p.Position.X)==12) end
   end
   assert(firstDisc==228.45 and firstTooth==228.25 and firstShaft==227)
   assert(w.ShredderContact.Position.Z==firstTooth and firstTooth-endZ==2.25)
   assert(a["Shredder mouth"].Position.Z-a["Shredder mouth"].Size.Z/2==227)
   assert(w.Shredder.Position.Z==c.ShredderCenterZ and c.BeltEnd==nil)
   for _,t in ipairs(w.Root.ConveyorAssembly:GetChildren()) do
    if t.Name=="Moving belt tread" then assert(t.Position.Z-t.Size.Z/2>=c.BeltStart and t.Position.Z+t.Size.Z/2<=endZ) end
   end
  ''')
 def test_destruction_and_fx_share_contact_not_base(self):
  self.run_lua('''
   for model in pairs(g.Salvage) do model:Destroy();g.Salvage[model]=nil end
   g:Spawn("radio",228)
   local model,e=next(g.Salvage);local endpoint
   local pivot=model.PivotTo;model.PivotTo=function(self,cf) endpoint=cf.Position;pivot(self,cf) end
   Clock=e.Expires;g:MoveSalvage(Clock)
   assert(model.Destroyed and not g.Salvage[model])
   assert(endpoint.Z==w.ShredderContact.Position.Z)
   local fx=g.Remote.LastBroadcast;assert(fx[1]=="ShredFX" and fx[2]==w.ShredderContact.Position)
   root.Position=endpoint;g:Pickup(TestPlayer,model);assert(not g.Carrying[TestPlayer])
  ''')
 def test_pickup_near_contact_and_exact_expiry(self):
  self.run_lua('''
   for model in pairs(g.Salvage) do model:Destroy();g.Salvage[model]=nil end
   g:Spawn("radio",227);local model,e=next(g.Salvage)
   Clock=e.Expires-0.001;root.Position=w.ShredderContact.Position
   g:Pickup(TestPlayer,model);assert(g.Carrying[TestPlayer])
   g:ClearCarry(TestPlayer);Clock=Clock+1;g:Spawn("radio",227);model,e=next(g.Salvage)
   Clock=e.Expires;g:Pickup(TestPlayer,model);assert(not g.Carrying[TestPlayer])
  ''')
 def test_pickup_uses_math_not_stale_or_forged_proxy(self):
  self.run_lua('''
   local model,e=next(g.Salvage)
   Clock=Clock+2;root.Position=Vector3.new(0,3,-224)
   model:PivotTo(root.CFrame)
   g:Pickup(TestPlayer,model);assert(not g.Carrying[TestPlayer])
   Clock=Clock+1;root.Position=g:SalvagePosition(model,e,Clock)
   model:PivotTo(CFrame.new(900,3,900))
   g:Pickup(TestPlayer,model);assert(g.Carrying[TestPlayer])
  ''')
 def test_dropped_junk_remains_static_and_has_separate_lifetime(self):
  self.run_lua('''
   g:Spawn("radio",nil,Vector3.new(10,3,10))
   local model,entry
   for m,e in pairs(g.Salvage) do if e.Dropped then model,entry=m,e end end
   assert(model.PrimaryPart:GetAttribute("StartServerTime")==nil)
   Clock=Clock+2;g:MoveSalvage(Clock);assert(model.PrimaryPart.Position.Z==10)
   assert(entry.Expires-entry.Started==25)
  ''')
 def test_render_frames_advance_without_server_steps(self):
  lua=boot();lua.execute((ROOT/'tests/client_stub.lua').read_text())
  lua.execute('''
   local tags=TestServices.CollectionService;local g=require(TestModules.GameplayService)
   function tags:GetTagged() local t={};for m in pairs(g.Salvage) do table.insert(t,m.PrimaryPart) end;return t end
   function tags:GetInstanceAddedSignal() return {Connect=function() end} end
   function tags:GetInstanceRemovedSignal() return {Connect=function() end} end
   workspace.CurrentCamera.CFrame=CFrame.new(0,5,-200)
  ''')
  lua.execute((ROOT/'src/client/Conveyor.client.lua').read_text())
  lua.execute('''
   local g=require(TestModules.GameplayService);local m,e=next(g.Salvage)
   local before=m.PrimaryPart.Position.Z
   for i=1,12 do Clock=Clock+1/120;TestServices.RunService.RenderStepped:Fire(1/120)
    local z=m.PrimaryPart.Position.Z;assert(math.abs(z-before-11/120)<0.00001);before=z
   end
   Clock=e.Expires+1;TestServices.RunService.RenderStepped:Fire(1/60)
   assert(math.abs(m.PrimaryPart.Position.Z-e.DestroyZ)<0.00001 and g.Salvage[m]) -- Client never owns expiry.
  ''')
 def test_fresh_tutorial_tracks_every_frame_then_home_and_upgrade(self):
  lua=boot();lua.execute((ROOT/'tests/client_stub.lua').read_text())
  lua.execute((ROOT/'src/client/ClientMain.client.lua').read_text())
  lua.execute((ROOT/'src/client/Waypoints.client.lua').read_text())
  lua.execute(SETUP+'''
   assert(d.TutorialStage==1 and #d.MachineInventory==0)
   g:State(TestPlayer);local state=g.Remote.LastMessage[3];local target=state.WaypointObject
   assert(target and state.Waypoint==nil)
   local before=workspace.TutorialWaypoint.Position.Z
   Clock=Clock+1/60;TestServices.RunService.RenderStepped:Fire(1/60)
   assert(math.abs(workspace.TutorialWaypoint.Position.Z-before-11/60)<0.00001)
   Clock=Clock+0.5;root.Position=g:SalvagePosition(target.Parent,g.Salvage[target.Parent],Clock)
   g:Pickup(TestPlayer,target.Parent)
   assert(workspace.TutorialWaypoint.Position==yards.Owned[TestPlayer].Deposit.Position)
   Clock=Clock+60;root.Position=yards.Owned[TestPlayer].Deposit.Position;g:Deposit(TestPlayer)
   assert(workspace.TutorialWaypoint.Position==w.Shops.Upgrades.Position)
  ''')
 def test_tutorial_retargets_expiry_without_waiting_for_state_timer(self):
  self.run_lua('''
   for model in pairs(g.Salvage) do model:Destroy();g.Salvage[model]=nil end
   g:Spawn("radio",228);g:Spawn("microwave",210);root.Position=Vector3.new(0,3,228)
   g:State(TestPlayer);local first=g.Remote.LastMessage[3].WaypointObject
   local e=g.Salvage[first.Parent];Clock=e.Expires;g:MoveSalvage(Clock)
   local nextTarget=g.Remote.LastMessage[3].WaypointObject
   assert(nextTarget and nextTarget~=first and nextTarget.Parent.Parent)
  ''')
 def test_custom_asset_zero_and_load_failure_preserve_fallback(self):
  self.run_lua('''
   local assets=require(TestModules.CustomAssetService)
   local folder=game.ReplicatedStorage.CustomAssetTemplates
   local calls=0;TestServices.InsertService={LoadAsset=function() calls=calls+1;error("moderated") end}
   assert(not assets:Load("reactor",{ModelId=0},folder) and calls==0)
   assert(not assets:Load("reactor",{ModelId=123},folder) and calls==1)
   assert(not folder:FindFirstChild("reactor"))
   local m=require(TestModules.MachineService):Create("reactor",Vector3.zero,workspace)
   assert(m.PrimaryPart.Name=="Chassis" and #m:GetDescendants()>3)
  ''')
 def test_treads_stay_inside_deck_at_many_frame_times(self):
  start,end=-224,226
  for t in range(1000):
   for z in range(57):
    center=start+0.3+((z*8+t/120*11)%(end-start-0.6))
    self.assertGreaterEqual(center-0.3,start-1e-9)
    self.assertLessEqual(center+0.3,end+1e-9)

 def test_custom_template_clone_failure_preserves_playable_model(self):
  self.run_lua('''
   local folder=game.ReplicatedStorage.CustomAssetTemplates
   local template=Instance.new("Model");template.Name="pod";template.Parent=folder
   function template:Clone() error("Unavailable asset") end
   local model=require(TestModules.MachineService):Create("pod",Vector3.zero,workspace)
   assert(model.PrimaryPart.Name=="Chassis")
  ''')
 def test_partial_replication_does_not_break_visual_motion(self):
  self.run_lua('''
   local motion=require(game.ReplicatedStorage.Shared.Config.ConveyorMotion)
   local part=Instance.new("Part");part.Position=Vector3.new(1,2,3)
   part:SetAttribute("StartServerTime",Clock)
   assert(motion.partPosition(part,Clock)==part.Position)
  ''')

 def test_rarity_lights_cap_and_camera_removal(self):
  lua=boot();lua.execute((ROOT/'tests/client_stub.lua').read_text())
  lua.execute('''
   local g=require(TestModules.GameplayService)
   for model in pairs(g.Salvage) do model:Destroy();g.Salvage[model]=nil end
   for i=1,4 do g:Spawn("reactor",i*5) end
   local tags=TestServices.CollectionService
   function tags:GetTagged() local t={};for model in pairs(g.Salvage) do table.insert(t,model.PrimaryPart) end;return t end
   function tags:GetInstanceAddedSignal() return {Connect=function() end} end
   function tags:GetInstanceRemovedSignal() return {Connect=function() end} end
   workspace.CurrentCamera.CFrame=CFrame.new(0,5,10)
  ''')
  lua.execute((ROOT/'src/client/Conveyor.client.lua').read_text())
  lua.execute('''
   TestServices.RunService.RenderStepped:Fire(1/60)
   local count=0
   for _,o in ipairs(workspace.Map:GetDescendants()) do if o.Name=="RarityAura" and o.Enabled then count=count+1 end end
   assert(count==3)
   workspace.CurrentCamera=nil;TestServices.RunService.RenderStepped:Fire(1/60)
   for _,o in ipairs(workspace.Map:GetDescendants()) do if o.Name=="RarityAura" then assert(o.Enabled==false) end end
  ''')
