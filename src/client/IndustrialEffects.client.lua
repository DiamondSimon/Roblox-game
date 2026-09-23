-- One client scheduler, distance-culling, bounded transient effects. No physical moving obstacles.
local Tags=game:GetService("CollectionService")
local Run=game:GetService("RunService")
local Debris=game:GetService("Debris")
local Rep=game.ReplicatedStorage
local Audio=require(Rep.Shared.Config.AudioConfig)
local rareUntil=0;local rareColor=nil
local tracked={};local elapsed=0;local accumulator=0;local activeBursts=0
local function register(tag)
 local function add(p) if p:IsA("BasePart") then tracked[p]={Tag=tag,Position=p.Position,Color=p.Color} end end
 for _,p in ipairs(Tags:GetTagged(tag)) do add(p) end
 Tags:GetInstanceAddedSignal(tag):Connect(add)
 Tags:GetInstanceRemovedSignal(tag):Connect(function(p) local state=tracked[p];if state and state.Sound then state.Sound:Destroy() end;if state and state.Smoke then state.Smoke:Destroy() end;tracked[p]=nil end)
end
for _,tag in ipairs({"ScrapyardPress","ScrapyardBeacon","ScrapyardSteam","ScrapyardMotor"}) do register(tag) end
local function sound(parent,id,volume,pitch,loop)
 local s=Instance.new("Sound");s.SoundId=id;s.Volume=volume;s.PlaybackSpeed=pitch;s.Looped=loop;s.RollOffMinDistance=8;s.RollOffMaxDistance=100;s.Parent=parent;s:Play();return s
end
local function burst(position,color,count)
 local camera=workspace.CurrentCamera
 if not camera or (position-camera.CFrame.Position).Magnitude>150 or activeBursts>=3 then return end
 activeBursts=activeBursts+1
 for i=1,count do
  local p=Instance.new("Part");p.Name="IndustrialSpark";p.Size=Vector3.new(0.2,0.2,0.7);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Material=Enum.Material.Neon;p.Color=color;p.Position=position+Vector3.new((i%3-1)*1.5,1+i%4,(i%2-0.5)*2);p.Parent=workspace
  local tween=game:GetService("TweenService"):Create(p,TweenInfo.new(0.4),{Position=p.Position+Vector3.new((i%3-1)*3,2,-2),Transparency=1});tween:Play();Debris:AddItem(p,0.5)
 end
 task.delay(0.55,function() activeBursts=math.max(0,activeBursts-1) end)
end
Run.Heartbeat:Connect(function(dt)
 elapsed=elapsed+dt;accumulator=accumulator+dt;if accumulator<0.1 then return end;accumulator=0
 local camera=workspace.CurrentCamera;if not camera then return end
 local rush=Rep:GetAttribute("ScrapRushActive")==true
 for p,s in pairs(tracked) do
  if p.Parent then
   local near=(s.Position-camera.CFrame.Position).Magnitude<170
   if s.Tag=="ScrapyardPress" and near then p.Position=s.Position+Vector3.new(0,-(1-math.cos(elapsed*0.65))*5,0)
   elseif s.Tag=="ScrapyardBeacon" and near and elapsed<rareUntil then p.Color=math.sin(elapsed*7)>0 and rareColor or s.Color
   elseif s.Tag=="ScrapyardBeacon" then p.Color=near and math.sin(elapsed*(rush and 8 or 4))>0 and Color3.fromRGB(255,104,35) or s.Color
   elseif s.Tag=="ScrapyardMotor" then
    if near and not s.Sound then s.Sound=sound(p,Audio.Motor.SoundId,Audio.Motor.Volume,Audio.Motor.PlaybackSpeed,true) end
    if s.Sound then s.Sound.Volume=near and Audio.Motor.Volume or 0 end
   elseif s.Tag=="ScrapyardSteam" then
    if near and not s.Smoke then local smoke=Instance.new("Smoke");smoke.Color=Color3.fromRGB(174,185,193);smoke.Opacity=0.08;smoke.Size=3;smoke.RiseVelocity=2;smoke.Parent=p;s.Smoke=smoke end
    if s.Smoke then s.Smoke.Enabled=near end
   end
  end
 end
end)
local remote=Rep:WaitForChild("Remotes",30);remote=remote and remote:WaitForChild("Game",10)
if remote then remote.OnClientEvent:Connect(function(kind,payload)
 if kind=="ShredFX" then
  burst(payload,Color3.fromRGB(255,175,55),8)
  local camera=workspace.CurrentCamera;if camera and (payload-camera.CFrame.Position).Magnitude<120 then
   local anchor=Instance.new("Part");anchor.Name="GrindingAudio";anchor.Anchored=true;anchor.Transparency=1;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false;anchor.Position=payload;anchor.Parent=workspace
   sound(anchor,Audio.Grind.SoundId,Audio.Grind.Volume,Audio.Grind.PlaybackSpeed,false);Debris:AddItem(anchor,1.5)
  end
 elseif kind=="RushFX" then burst(payload,Color3.fromRGB(75,235,220),10)
 elseif kind=="RareFX" and type(payload)=="table" then
  if payload.Tier>=3 then rareUntil=elapsed+(payload.Tier>=8 and 6 or 3);rareColor=payload.Color end
  burst(payload.Position,payload.Color,payload.Major and 10 or 4)
  local camera=workspace.CurrentCamera
  if payload.Tier>=2 and camera and (payload.Position-camera.CFrame.Position).Magnitude<150 then
   local anchor=Instance.new("Part");anchor.Anchored=true;anchor.Transparency=1;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false;anchor.Position=payload.Position;anchor.Parent=workspace
   sound(anchor,Audio.Rare.SoundId,Audio.Rare.Volume,payload.Tier>=8 and 0.7 or payload.Tier>=5 and 0.9 or 1.3,false);Debris:AddItem(anchor,2)
  end
 end
end) end
