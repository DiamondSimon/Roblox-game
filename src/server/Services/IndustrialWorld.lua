-- Fixed, low-part-count landmarks between roads; animated pieces are decorative and noncolliding.
local Tags=game:GetService("CollectionService")
local I={}
function I.Build(W,root)
 local f=Instance.new("Folder");f.Name="IndustrialLandmarks";f.Parent=root
 local steel=Color3.fromRGB(48,61,70);local yellow=Color3.fromRGB(230,164,46);local rust=Color3.fromRGB(143,79,49);local cyan=Color3.fromRGB(78,222,218)
 local function part(name,size,pos,color) return W.part(f,name,size,pos,color or steel) end
 -- Compactor and furnace silhouettes occupy the spaces between Z=70 and Z=210 approaches.
 local center=Vector3.new(-180,0,140)
 part("Compactor foundation",Vector3.new(34,1,32),center+Vector3.new(0,0.5,0),steel)
 for _,x in ipairs({-14,14}) do for _,z in ipairs({-13,13}) do part("Compactor pillar",Vector3.new(2,26,2),center+Vector3.new(x,13,z),yellow) end end
 part("Compactor crown",Vector3.new(34,3,32),center+Vector3.new(0,27,0),yellow)
 local press=part("Hydraulic press",Vector3.new(26,3,24),center+Vector3.new(0,17,0),steel);press.CanCollide=false;Tags:AddTag(press,"ScrapyardPress")
 for _,x in ipairs({-8,8}) do part("Hydraulic ram",Vector3.new(2,13,2),center+Vector3.new(x,21,0),Color3.fromRGB(162,180,184)) end
 part("Crushed vehicle",Vector3.new(15,3,8),center+Vector3.new(0,3,0),rust)
 local panel=part("Compactor screen",Vector3.new(5,4,1),center+Vector3.new(18,5,-14),cyan)
 W.label(panel,"VEHICLE COMPACTOR").Parent.MaxDistance=180
 for _,x in ipairs({-8,8}) do
  local lamp=part("Compactor beacon",Vector3.new(1.5,2,1.5),center+Vector3.new(x,30,0),yellow);lamp.Material=Enum.Material.Neon;Tags:AddTag(lamp,"ScrapyardBeacon")
 end
 local furnace=part("Recycling furnace",Vector3.new(32,23,28),Vector3.new(175,11.5,-140),rust)
 part("Furnace glow",Vector3.new(16,9,0.3),Vector3.new(175,7,-154.2),Color3.fromRGB(255,126,40)).Material=Enum.Material.Neon
 for _,x in ipairs({166,184}) do
  local chimney=part("Furnace smokestack",Vector3.new(7,58,7),Vector3.new(x,36,-140),steel)
  part("Stack hazard band",Vector3.new(7.2,3,7.2),Vector3.new(x,55,-140),yellow)
  local vent=part("Stack steam outlet",Vector3.new(2,1,2),Vector3.new(x,65,-140),steel);vent.Transparency=1;vent.CanCollide=false;Tags:AddTag(vent,"ScrapyardSteam")
 end
 W.label(furnace,"CYAN RECYCLING • FURNACE").Parent.StudsOffsetWorldSpace=Vector3.new(0,60,0)
 -- Scrap mountain, intentionally off the lane and roads.
 for layer=0,3 do for n=1,5-layer do
  local chunk=part("Scrap mountain block",Vector3.new(12-layer,5,10),Vector3.new(112+(n-3)*8,3+layer*5,layer%2*7),n%2==0 and rust or steel)
  chunk.Orientation=Vector3.new(0,n*19+layer*13,0)
 end end
 local cap=part("Mountain cyan core",Vector3.new(7,3,7),Vector3.new(104,22,4),cyan);cap.Material=Enum.Material.Neon
 -- Reusable small industrial dressing, clear of every road corridor.
 for _,x in ipairs({-140,140}) do for _,z in ipairs({-140,0,140}) do
  for n=1,3 do
   local pipe=part("Stored pipe",Vector3.new(7,2,2),Vector3.new(x+n*3,1,z-20),steel);pipe.Shape=Enum.PartType.Cylinder
   local barrel=part("Scrap barrel",Vector3.new(3,4,3),Vector3.new(x+n*4,2,z+20),rust);barrel.Shape=Enum.PartType.Cylinder;barrel.Orientation=Vector3.new(0,0,90)
  end
  part("Utility cabinet",Vector3.new(5,6,3),Vector3.new(x-10,3,z-20),steel)
  part("Utility indicator",Vector3.new(1,1,0.2),Vector3.new(x-10,4,z-21.6),cyan).Material=Enum.Material.Neon
 end end
 -- Hang a visibly substantial electromagnet below the existing animated hoist.
 local hoist=root["Magnet hoist"]
 if hoist then hoist.Size=Vector3.new(18,7,18);hoist.Color=cyan;hoist.Material=Enum.Material.Neon end
 -- Shredder effects use centralized client handling, with no always-emitting particles.
 for _,side in ipairs({-1,1}) do
  local lamp=W.part(root.ConveyorAssembly.ShredderAssembly,"Shredder warning beacon",Vector3.new(1.3,2,1.3),W.Shredder.Position+Vector3.new(side*14,11,4),yellow,Enum.Material.Neon)
  Tags:AddTag(lamp,"ScrapyardBeacon")
 end
 Tags:AddTag(W.Shredder,"ScrapyardMotor")
 local cap=W.part(root.ConveyorAssembly.ShredderAssembly,"Shredder exhaust",Vector3.new(2,4,2),W.Shredder.Position+Vector3.new(19,7,6),steel)
 Tags:AddTag(cap,"ScrapyardSteam")
end
return I
