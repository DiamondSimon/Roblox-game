local Config=require(game.ReplicatedStorage.Shared.Config.MachineConfig)
local World=require(script.Parent.WorldService)
local Machines={}
function Machines:Create(id,position,parent)
 local def=Config.ById[id];local color=Config.Rarities[def.Rarity].Color
 local model=Instance.new("Model");model.Name=def.DisplayName
 local function part(name,size,offset,tint,material)
  local p=World.part(model,name,size,position+offset,tint or color,material)
  p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;return p
 end
 local base=part("Chassis",Vector3.new(3.5,1.2,2.6),Vector3.zero,Color3.fromRGB(55,65,70));model.PrimaryPart=base
 local category=def.Category
 if category=="Vehicles" or category=="Military" or id=="forklift" or id=="mower" then
  part("Body",Vector3.new(3.8,0.9,2.3),Vector3.new(0,0.8,0))
  part("Cab",Vector3.new(1.8,1.2,2),Vector3.new(-0.35,1.6,0),Color3.fromRGB(53,102,118),Enum.Material.Glass)
  for _,x in ipairs({-1.2,1.2}) do for _,z in ipairs({-1.4,1.4}) do
   local wheel=part("Wheel",Vector3.new(1.2,0.5,1.2),Vector3.new(x,-0.2,z),Color3.fromRGB(21,26,28),Enum.Material.Rubber)
   wheel.Shape=Enum.PartType.Cylinder;wheel.Orientation=Vector3.new(0,90,90)
  end end
  if id=="forklift" then part("Fork mast",Vector3.new(0.4,3.5,2.8),Vector3.new(2,1.2,0)) end
 elseif category=="Alien" or category=="Secret" or category=="Experimental" then
  local core=part("Energy core",Vector3.new(2.4,2.4,2.4),Vector3.new(0,1.5,0),color,Enum.Material.Neon);core.Shape=Enum.PartType.Ball
  for _,y in ipairs({0.7,2.3}) do
   local ring=part("Containment ring",Vector3.new(0.25,4.2,4.2),Vector3.new(0,y,0));ring.Shape=Enum.PartType.Cylinder;ring.Orientation=Vector3.new(0,0,90)
  end
 elseif category=="Industrial" then
  part("Housing",Vector3.new(3,2.3,2.2),Vector3.new(0,1.5,0))
  for x=-1,1,0.5 do part("Cooling fin",Vector3.new(0.12,1.6,2.4),Vector3.new(x,1.5,0),Color3.fromRGB(32,40,44)) end
  part("Exhaust",Vector3.new(0.5,1.5,0.5),Vector3.new(1,3,0),Color3.fromRGB(67,74,79))
 else
  part("Housing",Vector3.new(3.2,2.1,2.2),Vector3.new(0,1.2,0))
  part("Display",Vector3.new(2.2,1.3,0.15),Vector3.new(-0.2,1.2,-1.2),Color3.fromRGB(25,41,46),Enum.Material.Glass)
  for y=0.7,1.7,0.5 do part("Dial",Vector3.new(0.3,0.3,0.2),Vector3.new(1.2,y,-1.25),color) end
 end
 local label=World.label(base,def.DisplayName.."\n"..def.Rarity.."  •  +"..def.BaseIncome.." /s",color)
 label.Parent.StudsOffset=Vector3.new(0,5,0)
 if Config.Rarities[def.Rarity].Announce then
  local h=Instance.new("Highlight");h.FillColor=color;h.FillTransparency=0.85;h.OutlineColor=color;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=model
 end
 model.Parent=parent
 return model
end
return Machines
