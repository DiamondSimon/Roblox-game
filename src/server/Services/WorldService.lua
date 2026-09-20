local Lighting=game:GetService("Lighting")
local World={Yards={}}
local amber=Color3.fromRGB(255,184,55)
function World.part(parent,name,size,pos,color,material)
 local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.Size=size;p.Position=pos
 p.Color=color;p.Material=material or Enum.Material.Metal;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
 return p
end
function World.label(part,text,color)
 local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(240,65);gui.StudsOffset=Vector3.new(0,4,0);gui.MaxDistance=110;gui.AlwaysOnTop=false;gui.Parent=part
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextColor3=color or amber;t.TextStrokeTransparency=0.4;t.Font=Enum.Font.GothamBold;t.TextSize=17;t.Parent=gui
 return t
end
function World.prompt(part,text,hold,fn)
 local p=Instance.new("ProximityPrompt");p.ActionText=text;p.ObjectText=part.Name;p.HoldDuration=hold or 0;p.MaxActivationDistance=10;p.RequiresLineOfSight=false;p.Parent=part
 p.Triggered:Connect(fn);return p
end
function World:Build()
 local root=Instance.new("Folder");root.Name="Map";root.Parent=workspace;self.Root=root
 self.part(root,"Ground",Vector3.new(350,2,350),Vector3.new(0,-1,0),Color3.fromRGB(42,49,52),Enum.Material.Asphalt)
 self.part(root,"Salvage floor",Vector3.new(58,0.5,150),Vector3.new(0,0.25,0),Color3.fromRGB(64,73,77),Enum.Material.Concrete)
 local belt=self.part(root,"CENTRAL SALVAGE",Vector3.new(18,1,122),Vector3.new(0,0.8,0),Color3.fromRGB(27,33,39),Enum.Material.DiamondPlate)
 self.label(belt,"CENTRAL SALVAGE\nFIND IT. HAUL IT. OWN IT.")
 for z=-58,58,8 do self.part(root,"Conveyor roller",Vector3.new(17,0.2,0.3),Vector3.new(0,1.4,z),Color3.fromRGB(99,109,111)) end
 for _,x in ipairs({-10,10}) do self.part(root,"Belt trim",Vector3.new(0.5,1,124),Vector3.new(x,1,0),amber) end
 for i=1,8 do
  local side=i<=4 and -1 or 1;local index=(i-1)%4
  local center=Vector3.new(side*68,0,-66+index*44)
  local folder=Instance.new("Folder");folder.Name="Yard_"..i;folder.Parent=root
  self.part(folder,"Yard foundation",Vector3.new(62,0.6,39),center+Vector3.new(0,0.3,0),Color3.fromRGB(84,83,77),Enum.Material.Concrete)
  for _,z in ipairs({-19,19}) do
   self.part(folder,"Safety rail",Vector3.new(62,0.25,0.25),center+Vector3.new(0,3,z),amber)
   for x=-30,30,10 do self.part(folder,"Fence post",Vector3.new(0.4,5,0.4),center+Vector3.new(x,2.5,z),Color3.fromRGB(39,46,50)) end
  end
  local spawn=Instance.new("SpawnLocation");spawn.Name="YardSpawn";spawn.Size=Vector3.new(6,0.5,6);spawn.Position=center+Vector3.new(-side*20,0.8,10);spawn.Anchored=true;spawn.Neutral=true;spawn.Transparency=0.5;spawn.Color=amber;spawn.Parent=folder
  local sign=self.part(folder,"Yard sign",Vector3.new(1,5,1),center+Vector3.new(-side*25,2.5,-14),amber)
  local name=self.label(sign,"YARD "..i.." • AVAILABLE")
  local deposit=self.part(folder,"Machine intake",Vector3.new(7,1,7),center+Vector3.new(-side*20,0.8,0),Color3.fromRGB(61,170,154),Enum.Material.Neon)
  self.label(deposit,"PLACE MACHINE",Color3.fromRGB(119,255,217))
  local terminal=self.part(folder,"Upgrade terminal",Vector3.new(3,4,3),center+Vector3.new(-side*20,2,-10),Color3.fromRGB(33,42,51))
  self.part(folder,"Terminal screen",Vector3.new(3.1,2,0.15),terminal.Position+Vector3.new(0,0.4,1.55),amber,Enum.Material.Neon)
  self.label(terminal,"UPGRADES")
  local slots={}
  for n=1,18 do
   local row=math.floor((n-1)/6);local col=(n-1)%6
   local pos=center+Vector3.new(side*4+(col-2.5)*6,0.7,(row-1)*10)
   slots[n]=pos+Vector3.new(0,1.7,0)
   self.part(folder,"Slot_"..n,Vector3.new(5,0.2,7),pos,Color3.fromRGB(54,61,62),Enum.Material.DiamondPlate)
  end
  self.Yards[i]={Index=i,Folder=folder,Center=center,Spawn=spawn,Label=name,Deposit=deposit,Terminal=terminal,Slots=slots,Models={}}
 end
 for i=1,16 do
  local x=(i%2==0 and 1 or -1)*(115+(i%3)*8);local z=-140+math.floor((i-1)/2)*39
  local color=i%2==0 and Color3.fromRGB(37,93,104) or Color3.fromRGB(162,86,49)
  self.part(root,"Freight container",Vector3.new(18,12,30),Vector3.new(x,6,z),color,Enum.Material.CorrodedMetal)
  for dz=-12,12,4 do self.part(root,"Container rib",Vector3.new(18.3,11,0.4),Vector3.new(x,6,z+dz),color) end
 end
 for _,x in ipairs({-26,26}) do
  for _,z in ipairs({-77,0,77}) do
   self.part(root,"Worklight mast",Vector3.new(0.7,20,0.7),Vector3.new(x,10,z),Color3.fromRGB(49,56,60))
   local lamp=self.part(root,"Worklight",Vector3.new(4,0.5,2),Vector3.new(x,20,z),Color3.fromRGB(255,227,165),Enum.Material.Neon)
   local light=Instance.new("PointLight");light.Brightness=1;light.Range=30;light.Color=lamp.Color;light.Shadows=false;light.Parent=lamp
  end
 end
 for _,z in ipairs({-130,130}) do
  self.part(root,"Gantry beam",Vector3.new(110,4,4),Vector3.new(0,42,z),amber)
  for _,x in ipairs({-52,52}) do self.part(root,"Gantry leg",Vector3.new(4,42,4),Vector3.new(x,21,z),amber) end
  self.part(root,"Hoist cable",Vector3.new(0.35,23,0.35),Vector3.new(0,29,z),Color3.fromRGB(30,34,37))
 end
 Lighting.ClockTime=16.8;Lighting.Brightness=2;Lighting.Ambient=Color3.fromRGB(80,88,105);Lighting.OutdoorAmbient=Color3.fromRGB(110,115,125)
 local atmosphere=Instance.new("Atmosphere");atmosphere.Density=0.28;atmosphere.Offset=0.15;atmosphere.Color=Color3.fromRGB(190,205,215);atmosphere.Parent=Lighting
 local bloom=Instance.new("BloomEffect");bloom.Intensity=0.15;bloom.Size=20;bloom.Threshold=1.8;bloom.Parent=Lighting
 local cc=Instance.new("ColorCorrectionEffect");cc.Contrast=0.12;cc.Saturation=0.08;cc.Parent=Lighting
end
return World
