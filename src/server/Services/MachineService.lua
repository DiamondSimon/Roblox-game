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
 if id=="toaster" then
  part("Toaster shell",Vector3.new(2.7,1.7,2),Vector3.new(0,1,0))
  for _,z in ipairs({-0.5,0.5}) do part("Toast slot",Vector3.new(2,0.15,0.25),Vector3.new(0,1.9,z),Color3.fromRGB(22,27,32)) end
  part("Lever",Vector3.new(0.3,0.4,0.5),Vector3.new(1.55,1,0))
 elseif id=="washer" then
  part("Cabinet",Vector3.new(3,3,2.5),Vector3.new(0,1.5,0))
  local door=part("Round drum",Vector3.new(0.35,2,2),Vector3.new(0,1.4,-1.4),Color3.fromRGB(45,85,105),Enum.Material.Glass);door.Shape=Enum.PartType.Cylinder;door.Orientation=Vector3.new(0,90,0)
  part("Controls",Vector3.new(2.5,0.4,0.2),Vector3.new(0,2.7,-1.4),Color3.fromRGB(45,57,65))
 elseif id=="fridge" then
  part("Tall cabinet",Vector3.new(2.8,4.4,2.4),Vector3.new(0,2,0))
  part("Door seam",Vector3.new(2.85,0.12,0.1),Vector3.new(0,2.7,-1.25),Color3.fromRGB(35,45,52))
  part("Handle",Vector3.new(0.18,1.2,0.25),Vector3.new(1,1.6,-1.4),Color3.fromRGB(220,228,225))
 elseif id=="fan" then
  part("Stand",Vector3.new(0.4,2.8,0.4),Vector3.new(0,1.4,0))
  local cage=part("Fan housing",Vector3.new(0.5,2.8,2.8),Vector3.new(0,2.8,0));cage.Shape=Enum.PartType.Cylinder;cage.Orientation=Vector3.new(0,90,0)
  for i=0,3 do local blade=part("Fan blade",Vector3.new(0.35,2.1,0.15),Vector3.new(0,2.8,-0.4),Color3.fromRGB(52,66,77));blade.Orientation=Vector3.new(0,0,i*45) end
 elseif id=="toolbox" then
  part("Toolbox body",Vector3.new(3.2,1.7,2),Vector3.new(0,1,0))
  part("Lid",Vector3.new(3.4,0.4,2.2),Vector3.new(0,2,0),Color3.fromRGB(183,78,49))
  part("Handle",Vector3.new(1.5,0.25,0.3),Vector3.new(0,2.5,0),Color3.fromRGB(45,52,61))
  for _,x in ipairs({-1,1}) do part("Latch",Vector3.new(0.3,0.6,0.2),Vector3.new(x,1.7,-1.15)) end
 elseif id=="tires" then
  for i=1,3 do local tire=part("Tire",Vector3.new(0.65,2.7,2.7),Vector3.new(0,i*0.65,0),Color3.fromRGB(32,36,40),Enum.Material.Rubber);tire.Shape=Enum.PartType.Cylinder;tire.Orientation=Vector3.new(0,0,90) end
  local hole=part("Top hub",Vector3.new(0.1,1.25,1.25),Vector3.new(0,2.32,0),Color3.fromRGB(12,17,20));hole.Shape=Enum.PartType.Cylinder;hole.Orientation=Vector3.new(0,0,90)
 elseif id=="barrel" then
  local drum=part("Drum",Vector3.new(3,2.2,2.2),Vector3.new(0,1.6,0));drum.Shape=Enum.PartType.Cylinder;drum.Orientation=Vector3.new(0,0,90)
  for _,y in ipairs({0.6,2.6}) do local band=part("Drum band",Vector3.new(0.15,2.35,2.35),Vector3.new(0,y,0),Color3.fromRGB(42,50,55));band.Shape=Enum.PartType.Cylinder;band.Orientation=Vector3.new(0,0,90) end
 elseif id=="engine" then
  part("Block",Vector3.new(2.8,2.1,2.5),Vector3.new(0,1.3,0))
  for _,x in ipairs({-1,1}) do for z=-0.9,0.9,0.6 do local piston=part("Cylinder head",Vector3.new(0.6,1.2,0.5),Vector3.new(x,2.3,z),Color3.fromRGB(180,192,200));piston.Orientation=Vector3.new(0,0,x*25) end end
  part("Intake",Vector3.new(1.2,0.8,1.8),Vector3.new(0,2.8,0),Color3.fromRGB(48,60,68))
 elseif id=="satellite" then
  part("Tripod mast",Vector3.new(0.4,2.8,0.4),Vector3.new(0,1.4,0))
  local dish=part("Dish",Vector3.new(0.35,3.7,3.7),Vector3.new(0,3,0),Color3.fromRGB(174,194,202));dish.Shape=Enum.PartType.Cylinder;dish.Orientation=Vector3.new(0,60,0)
  part("Receiver arm",Vector3.new(0.2,0.2,2),Vector3.new(0,2.8,-1.1));part("Receiver",Vector3.new(0.5,0.5,0.5),Vector3.new(0,2.8,-2))
 elseif id=="arcade" then
  part("Cabinet",Vector3.new(2.8,3.8,2.5),Vector3.new(0,1.9,0))
  part("Screen",Vector3.new(2.1,1.5,0.15),Vector3.new(0,2.5,-1.3),Color3.fromRGB(93,240,202),Enum.Material.Neon)
  part("Marquee",Vector3.new(2.6,0.55,0.2),Vector3.new(0,4,-1.3),color,Enum.Material.Neon)
  part("Control shelf",Vector3.new(2.8,0.3,0.9),Vector3.new(0,1.5,-1.5));part("Joystick",Vector3.new(0.2,0.6,0.2),Vector3.new(-0.5,1.9,-1.6))
 elseif id=="drone" then
  part("Cargo pod",Vector3.new(2.5,1.7,2),Vector3.new(0,1.2,0))
  for _,x in ipairs({-2,2}) do for _,z in ipairs({-1.7,1.7}) do
   part("Rotor arm",Vector3.new(2.6,0.3,0.3),Vector3.new(x/2,2,z));part("Rotor",Vector3.new(1.8,0.15,0.3),Vector3.new(x,2.4,z),Color3.fromRGB(34,48,55))
  end end
 elseif id=="turbine" then
  local shell=part("Turbine shell",Vector3.new(3.8,2.8,2.8),Vector3.new(0,1.5,0));shell.Shape=Enum.PartType.Cylinder;shell.Orientation=Vector3.new(0,90,0)
  local core=part("Turbine core",Vector3.new(0.2,2.3,2.3),Vector3.new(0,1.5,-2),Color3.fromRGB(33,51,66));core.Shape=Enum.PartType.Cylinder;core.Orientation=Vector3.new(0,90,0)
  for i=1,8 do local blade=part("Turbine blade",Vector3.new(0.2,2,0.1),Vector3.new(0,1.5,-2.2),color);blade.Orientation=Vector3.new(0,0,i*22.5) end
 elseif category=="Vehicles" or category=="Military" or id=="forklift" or id=="mower" then
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
