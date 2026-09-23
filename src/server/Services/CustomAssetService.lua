-- Asynchronous template cache: failures never block map boot or remove fallback art.
local Rep=game.ReplicatedStorage
local Config=require(Rep.Shared.Config.AssetConfig)
local A={}
function A:Load(id,def,folder)
 if type(def.ModelId)~="number" or def.ModelId<=0 then return false end
 local container,template
 local ok,err=pcall(function()
  container=game:GetService("InsertService"):LoadAsset(def.ModelId)
  template=Instance.new("Model");template.Name=id
  -- Copy geometry/appearance only; never execute scripts from an imported asset.
  for _,source in ipairs(container:GetDescendants()) do
   if source:IsA("BasePart") then
    local copy=source:Clone()
    for _,child in ipairs(copy:GetChildren()) do
     if not child:IsA("SurfaceAppearance") and not child:IsA("SpecialMesh") then child:Destroy() end
    end
    for _,child in ipairs(copy:GetDescendants()) do
     if child:IsA("LuaSourceContainer") then child:Destroy() end
    end
    copy.Anchored=true;copy.CanCollide=false;copy.CanTouch=false;copy.CanQuery=false;copy.Parent=template
   end
  end
  local _,size=template:GetBoundingBox();local max=math.max(size.X,size.Y,size.Z)
  assert(max>0 and #template:GetChildren()>0,"Empty custom model")
  template:ScaleTo(def.MaxDimension/max)
  local cf,scaled=template:GetBoundingBox()
  -- Floor center origin; visual chassis sits 0.6 studs below gameplay anchor.
  template.WorldPivot=CFrame.new(cf.Position.X,cf.Position.Y-scaled.Y/2,cf.Position.Z)
  template:PivotTo(CFrame.new(0,-0.6,0))
  local anchor=Instance.new("Part");anchor.Name="CustomChassis";anchor.Size=Vector3.new(3.5,1.2,2.6)
  anchor.CFrame=CFrame.new();anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanTouch=false;anchor.CanQuery=false;anchor.Parent=template;template.PrimaryPart=anchor
  local loaded=true
  game:GetService("ContentProvider"):PreloadAsync(template:GetDescendants(),function(_,status)
   if status~=Enum.AssetFetchStatus.Success then loaded=false end
  end)
  assert(loaded,"Custom mesh content failed to load")
  template.Parent=folder
 end)
 if container then container:Destroy() end
 if not ok then if template then template:Destroy() end;warn("Custom asset fallback: "..id.." • "..tostring(err));return false end
 return true
end
function A:Start()
 local folder=Instance.new("Folder");folder.Name="CustomAssetTemplates";folder.Parent=Rep
 for id,def in pairs(Config) do
  if def.ModelId>0 then task.spawn(function()
   if self:Load(id,def,folder) and id=="compactor" then
    local visual=folder[id]:Clone();visual.Name="CustomVehicleCompactor";visual:PivotTo(CFrame.new(-180,1.1,140));visual.Parent=workspace.Map
    -- Retain invisible simplified collision; remove duplicate decorative motion/effects.
    local tags=game:GetService("CollectionService")
    for _,p in ipairs(workspace.Map.IndustrialLandmarks:GetDescendants()) do
     if p:IsA("BasePart") and (p.Name:find("Compactor") or p.Name=="Hydraulic press" or p.Name=="Hydraulic ram" or p.Name=="Crushed vehicle") then
      p.Transparency=1
      for _,tag in ipairs({"ScrapyardPress","ScrapyardBeacon"}) do tags:RemoveTag(p,tag) end
     end
    end
   end
  end) end
 end
end
return A
