local Tags=game:GetService("CollectionService")
local Run=game:GetService("RunService")
local Tween=game:GetService("TweenService")
local fans={};local hoists={};local shredders={}
local function fan(part) if part:IsA("BasePart") then fans[part]=part.CFrame end end
local function hoist(part)
 if not part:IsA("BasePart") or hoists[part] then return end
 local tween=Tween:Create(part,TweenInfo.new(7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Position=part.Position+Vector3.new(32,8,0)})
 hoists[part]=tween;tween:Play()
end
for _,p in ipairs(Tags:GetTagged("ScrapyardFan")) do fan(p) end
for _,p in ipairs(Tags:GetTagged("ScrapyardHoist")) do hoist(p) end
Tags:GetInstanceAddedSignal("ScrapyardFan"):Connect(fan)
Tags:GetInstanceAddedSignal("ScrapyardHoist"):Connect(hoist)
Tags:GetInstanceRemovedSignal("ScrapyardFan"):Connect(function(p) fans[p]=nil end)
Tags:GetInstanceRemovedSignal("ScrapyardHoist"):Connect(function(p) if hoists[p] then hoists[p]:Cancel();hoists[p]=nil end end)
local function shredder(model) if model:IsA("Model") then shredders[model]=model:GetPivot() end end
for _,p in ipairs(Tags:GetTagged("ScrapyardShredder")) do shredder(p) end
Tags:GetInstanceAddedSignal("ScrapyardShredder"):Connect(shredder)
Tags:GetInstanceRemovedSignal("ScrapyardShredder"):Connect(function(p) shredders[p]=nil end)
local elapsed=0;local step=0
Run.Heartbeat:Connect(function(dt)
 elapsed=elapsed+dt;step=step+dt;if step<0.05 then return end;step=0
 local camera=workspace.CurrentCamera
 for part,cf in pairs(shredders) do
  if part.Parent and camera and (cf.Position-camera.CFrame.Position).Magnitude<180 then part:PivotTo(cf*CFrame.Angles(0,0,elapsed*5*(part:GetAttribute("Direction") or 1))) end
 end
 for part,cf in pairs(fans) do
  if part.Parent and camera and (part.Position-camera.CFrame.Position).Magnitude<180 then part.CFrame=cf*CFrame.Angles(0,elapsed*2,0) end
 end
end)

local function reveal(part)
 local billboard=part:FindFirstChildOfClass("BillboardGui")
 if billboard then
  billboard.StudsOffset=Vector3.new(0,8,0)
  Tween:Create(billboard,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{StudsOffset=Vector3.new(0,5,0)}):Play()
 end
end
Tags:GetInstanceAddedSignal("ScrapyardSalvage"):Connect(reveal)
