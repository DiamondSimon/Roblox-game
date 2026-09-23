-- Server-owned models, presentation only. No pickup/ownership/expiry remotes are sent.
local Tags=game:GetService("CollectionService")
local Run=game:GetService("RunService")
local Motion=require(game.ReplicatedStorage.Shared.Config.ConveyorMotion)
local parts={}
local lights={}
local function add(p) if p:IsA("BasePart") then parts[p]=true end end
for _,p in ipairs(Tags:GetTagged("ScrapyardSalvage")) do add(p) end
Tags:GetInstanceAddedSignal("ScrapyardSalvage"):Connect(add)
Tags:GetInstanceRemovedSignal("ScrapyardSalvage"):Connect(function(p) parts[p]=nil;if lights[p] then lights[p]:Destroy();lights[p]=nil end end)
Run.RenderStepped:Connect(function()
 local now=workspace:GetServerTimeNow();local camera=workspace.CurrentCamera;local lightCount=0
 for part in pairs(parts) do
  if not part.Parent then parts[part]=nil
  elseif part:GetAttribute("StartServerTime")~=nil then
   part.Parent:PivotTo(CFrame.new(Motion.partPosition(part,now)))
   local rarity=part:GetAttribute("Rarity")
   if rarity=="Legendary" or rarity=="Mythic" or rarity=="Secret" then
    local near=camera~=nil and (part.Position-camera.CFrame.Position).Magnitude<100 and lightCount<3
    if near then
     lightCount=lightCount+1
     if not lights[part] then local light=Instance.new("PointLight");light.Name="RarityAura";light.Shadows=false;light.Color=require(game.ReplicatedStorage.Shared.Config.MachineConfig).Rarities[rarity].Color;light.Range=rarity=="Secret" and 12 or 8;light.Parent=part;lights[part]=light end
    end
    if lights[part] then lights[part].Enabled=near;lights[part].Brightness=0.6+0.2*math.sin(now*2) end
   end
  end
 end
end)
