-- Local-only tutorial guide, recreated on respawn and compatible with streaming.
local Players=game:GetService("Players")
local Audio=require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("AudioConfig"))
local Tween=game:GetService("TweenService")
local player=Players.LocalPlayer
local Motion=require(game.ReplicatedStorage.Shared.Config.ConveyorMotion)
local tracked=nil
local marker=Instance.new("Part");marker.Name="TutorialWaypoint";marker.Anchored=true;marker.CanCollide=false;marker.CanTouch=false;marker.CanQuery=false;marker.Transparency=1;marker.Size=Vector3.new(1,1,1);marker.Parent=workspace
local target=Instance.new("Attachment");target.Parent=marker
local beam=Instance.new("Beam");beam.Attachment1=target;beam.FaceCamera=true;beam.Width0=0.6;beam.Width1=0.6;beam.Color=ColorSequence.new(Color3.fromRGB(255,222,51));beam.LightEmission=1;beam.Segments=1;beam.Parent=marker
local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(90,90);gui.StudsOffset=Vector3.new(0,5,0);gui.AlwaysOnTop=true;gui.MaxDistance=1200;gui.Parent=marker
local arrow=Instance.new("TextLabel");arrow.Size=UDim2.fromScale(1,1);arrow.BackgroundTransparency=1;arrow.Text="▼";arrow.TextSize=64;arrow.TextColor3=Color3.fromRGB(255,222,51);arrow.TextStrokeTransparency=0;arrow.Parent=gui
Tween:Create(gui,TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{StudsOffset=Vector3.new(0,7,0)}):Play()
local function update()
 local pos=player:GetAttribute("TutorialTarget");
 if tracked then pos=tracked.Parent and Motion.partPosition(tracked,workspace:GetServerTimeNow()) or nil end;local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 beam.Enabled=pos~=nil and root~=nil;gui.Enabled=beam.Enabled
 if pos then marker.Position=pos end
 if root then
  local origin=root:FindFirstChild("TutorialOrigin")
  if not origin then origin=Instance.new("Attachment");origin.Name="TutorialOrigin";origin.Parent=root end
  beam.Attachment0=origin
 end
end
player:GetAttributeChangedSignal("TutorialTarget"):Connect(update)
player.CharacterAdded:Connect(function(character) character:WaitForChild("HumanoidRootPart");update() end)
update()
game:GetService("RunService").RenderStepped:Connect(update)
local remote=game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
remote.OnClientEvent:Connect(function(kind,pos)
 if kind=="State" then tracked=pos.WaypointObject;update();return end
 if kind~="SlapFX" then return end
 local flash=Instance.new("Part");flash.Anchored=true;flash.CanCollide=false;flash.CanQuery=false;flash.CanTouch=false;flash.Shape=Enum.PartType.Ball;flash.Size=Vector3.new(2,2,2);flash.Position=pos+Vector3.new(0,3,0);flash.Material=Enum.Material.Neon;flash.Color=kind=="SlapFX" and Color3.fromRGB(255,255,225) or Color3.fromRGB(255,157,45);flash.Parent=workspace
 if kind=="SlapFX" then
  local sound=Instance.new("Sound");sound.Name="SlapImpact";sound.SoundId=Audio.Slap.SoundId;sound.Volume=Audio.Slap.Volume;sound.PlaybackSpeed=Audio.Slap.PlaybackSpeed;sound.RollOffMaxDistance=Audio.Slap.MaxDistance;sound.RollOffMinDistance=8;sound.Parent=flash;sound:Play()
  task.delay(Audio.Slap.Duration,function() if sound.Parent then sound:Stop() end end)
 end
 Tween:Create(flash,TweenInfo.new(0.35),{Size=Vector3.new(8,8,8),Transparency=1}):Play();task.delay(0.4,function() flash:Destroy() end)
end)
