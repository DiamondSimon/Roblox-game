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
function World:SetFloors(yard,count)
 if yard.FloorCount==count then return end
 if yard.FloorFolder then yard.FloorFolder:Destroy() end
 local folder=Instance.new("Folder");folder.Name="MachineFloors";folder.Parent=yard.Folder
 yard.FloorFolder=folder;yard.FloorCount=count;yard.Slots={}
 local steel=Color3.fromRGB(77,98,110)
 for floor=0,count-1 do
  local height=floor*16
  if floor>0 then
   self.part(folder,"Floor_"..(floor+1),Vector3.new(44,1,70),yard.Center+Vector3.new(0,height,0),Color3.fromRGB(179,189,190),Enum.Material.Concrete)
   for _,x in ipairs({-22,22}) do
    for _,z in ipairs({-33,33}) do self.part(folder,"Floor pillar",Vector3.new(1,16,1),yard.Center+Vector3.new(x,height-8,z),steel) end
   end
   -- Alternating side stairs reach every floor, with clear landings at either end.
   local side=floor%2==1 and 1 or -1
   for step=1,16 do
    self.part(folder,"Stair",Vector3.new(9,1,2.5),yard.Center+Vector3.new(side*27,(floor-1)*16+step,side*(-17+step*2)),steel)
   end
   self.part(folder,"Landing",Vector3.new(10,1,12),yard.Center+Vector3.new(side*26,height,side*23),steel)
   for _,z in ipairs({-34,34}) do self.part(folder,"Safety rail",Vector3.new(44,3,0.4),yard.Center+Vector3.new(0,height+2,z),steel) end
  end
  for n=1,8 do
   local pos=yard.Center+Vector3.new(((n-1)%2==0 and -1 or 1)*10,height+0.7,(math.floor((n-1)/2)-1.5)*16)
   yard.Slots[floor*8+n]=pos+Vector3.new(0,1.7,0)
   self.part(folder,"Slot_"..(floor*8+n),Vector3.new(8,0.2,11),pos,steel,Enum.Material.DiamondPlate)
  end
 end
end
function World:Build()
 local Tags=game:GetService("CollectionService")
 local root=Instance.new("Folder");root.Name="Map";root.Parent=workspace;self.Root=root;self.Inspections={}
 local steel=Color3.fromRGB(43,57,65);local teal=Color3.fromRGB(40,111,121)
 self.part(root,"District ground",Vector3.new(1000,2,880),Vector3.new(0,-1,0),Color3.fromRGB(129,154,98),Enum.Material.Ground)
 local function road(size,pos)
  self.part(root,"Scrap road",size,pos,Color3.fromRGB(38,44,48),Enum.Material.Asphalt)
 end
 for _,x in ipairs({-242,242}) do
  road(Vector3.new(28,0.3,610),Vector3.new(x,0.2,0))
  for z=-285,285,30 do self.part(root,"Road marking",Vector3.new(0.6,0.1,10),Vector3.new(x,0.4,z),amber) end
 end
 for _,z in ipairs({-210,-70,70,210}) do
  road(Vector3.new(720,0.3,24),Vector3.new(0,0.2,z))
  for x=-260,260,30 do self.part(root,"Lane marking",Vector3.new(10,0.1,0.6),Vector3.new(x,0.4,z),amber) end
 end
 for _,side in ipairs({-1,1}) do
  for _,z in ipairs({-210,-70,70,210}) do
   local start=Vector3.new(side*276,0.45,z)
   local finish=Vector3.new(side*20,0.45,math.max(-54,math.min(54,z)))
   local midpoint=Vector3.new((start.X+finish.X)/2,0.45,(start.Z+finish.Z)/2)
   local path=self.part(root,"Direct haul path",Vector3.new(14,0.25,(finish-start).Magnitude),midpoint,Color3.fromRGB(66,76,79),Enum.Material.Concrete)
   path.CFrame=CFrame.lookAt(midpoint,finish)
  end
 end
 self.part(root,"Salvage plaza",Vector3.new(120,0.6,210),Vector3.new(0,0.3,0),Color3.fromRGB(71,82,84),Enum.Material.Concrete)
 local belt=self.part(root,"CENTRAL SALVAGE",Vector3.new(20,1,132),Vector3.new(0,1,0),steel,Enum.Material.DiamondPlate)
 local title=self.label(belt,"CENTRAL SALVAGE\nGRAB IT BEFORE IT SHREDS",amber);title.Parent.MaxDistance=400;title.Parent.StudsOffset=Vector3.new(0,16,0)
 for z=-62,62,8 do self.part(root,"Conveyor roller",Vector3.new(19,0.2,0.35),Vector3.new(0,1.6,z),Color3.fromRGB(115,137,140)) end
 for _,x in ipairs({-11,11}) do self.part(root,"Conveyor rail",Vector3.new(0.5,1.2,134),Vector3.new(x,1,0),amber) end
 local hopper=self.part(root,"Salvage hopper",Vector3.new(28,12,18),Vector3.new(0,6,-82),teal)
 self.part(root,"Hopper intake",Vector3.new(18,8,1),Vector3.new(0,5,-72),Color3.fromRGB(15,23,27))
 self.label(hopper,"SALVAGE IN",amber).Parent.MaxDistance=150
 self.Shredder=self.part(root,"SHREDDER",Vector3.new(28,2,24),Vector3.new(0,1,76),steel)
 for _,x in ipairs({-14,14}) do self.part(root,"Shredder wall",Vector3.new(2,10,26),Vector3.new(x,5,76),amber) end
 self.part(root,"Shredder rear",Vector3.new(28,10,2),Vector3.new(0,5,89),amber)
 self.part(root,"Shredder mouth",Vector3.new(24,0.5,22),Vector3.new(0,2.2,76),Color3.fromRGB(17,24,30))
 for _,x in ipairs({-6,6}) do
  local rotor=self.part(root,"Shredder rotor",Vector3.new(9,1,20),Vector3.new(x,3,76),Color3.fromRGB(180,193,199));rotor.CanCollide=false
  Tags:AddTag(rotor,"ScrapyardShredder")
 end
 self.label(self.Shredder,"SHREDDER • UNCLAIMED JUNK LOST",Color3.fromRGB(255,100,78))
 self.ShopSpawn=Vector3.new(0,4,-196);self.Shops={}
 self.part(root,"Shop plaza",Vector3.new(180,0.6,88),Vector3.new(0,0.3,-229),Color3.fromRGB(188,183,161),Enum.Material.Concrete)
 for i,key in ipairs({"Upgrades","Sell","Spin","Rebirth","Shop"}) do
  local x=(i-3)*34
  local colors={Color3.fromRGB(100,193,255),Color3.fromRGB(93,224,131),Color3.fromRGB(255,202,67),Color3.fromRGB(201,130,255),Color3.fromRGB(255,143,83)}
  local stand=self.part(root,key.." stand",Vector3.new(22,4,8),Vector3.new(x,2,-234),colors[i])
  self.part(root,key.." canopy",Vector3.new(27,2,18),Vector3.new(x,13,-239),colors[i])
  for _,dx in ipairs({-11,11}) do self.part(root,"Stall post",Vector3.new(1,13,1),Vector3.new(x+dx,6.5,-245),steel) end
  self.Shops[key]=stand;self.label(stand,string.upper(key=="Shop" and "SUPPLIES" or key),colors[i]).Parent.StudsOffset=Vector3.new(0,13,0)
 end
 local wheel=self.part(root,"Daily wheel",Vector3.new(12,12,1),Vector3.new(0,8,-244),amber)
 for i=1,6 do local a=i*math.pi/3;self.part(root,"Wheel segment",Vector3.new(3,3,1.2),Vector3.new(math.cos(a)*4,8+math.sin(a)*4,-243),i%2==0 and teal or Color3.fromRGB(243,237,205)) end
 self.label(wheel,"FREE DAILY SPIN",amber).Parent.MaxDistance=60
 for i=1,8 do
  local side=i<=4 and -1 or 1;local index=(i-1)%4
  local center=Vector3.new(side*330,0,-210+index*140)
  local folder=Instance.new("Folder");folder.Name="Yard_"..i;folder.Parent=root
  self.part(folder,"Yard foundation",Vector3.new(64,0.6,76),center+Vector3.new(0,0.3,0),Color3.fromRGB(178,181,160),Enum.Material.Concrete)
  for _,z in ipairs({-37,37}) do
   for _,y in ipairs({2,5}) do self.part(folder,"Fence rail",Vector3.new(64,0.3,0.3),center+Vector3.new(0,y,z),steel) end
   for x=-30,30,10 do self.part(folder,"Fence post",Vector3.new(0.5,6,0.5),center+Vector3.new(x,3,z),steel) end
  end
  self.part(folder,"Rear fence",Vector3.new(0.6,5,76),center+Vector3.new(side*32,2.5,0),steel)
  local spawn=Instance.new("SpawnLocation");spawn.Name="YardSpawn";spawn.Size=Vector3.new(6,0.5,6);spawn.Position=center+Vector3.new(-side*26,0.8,20);spawn.Anchored=true;spawn.Neutral=true;spawn.Transparency=1;spawn.Parent=folder
  local sign=self.part(folder,"Yard sign",Vector3.new(1,8,1),center+Vector3.new(-side*30,4,-28),amber)
  local name=self.label(sign,"YARD "..i.." • AVAILABLE");name.Parent.MaxDistance=180
  local deposit=self.part(folder,"Machine intake",Vector3.new(9,1,9),center+Vector3.new(-side*26,0.8,0),Color3.fromRGB(61,170,154),Enum.Material.Neon)
  self.label(deposit,"PLACE / REPLACE",Color3.fromRGB(119,255,217))
  self.Yards[i]={Index=i,Folder=folder,Center=center,Spawn=spawn,Label=name,Deposit=deposit,Slots={},Models={}}
  self:SetFloors(self.Yards[i],1)

 end
 -- Off-road landmarks: main roads remain unobstructed.
 for _,x in ipairs({-120,-175,130,185}) do
  local offset=math.abs(x)<=140 and 170 or 105
  for _,z in ipairs({-offset,offset}) do
   local color=x<0 and Color3.fromRGB(176,95,49) or teal
   self.part(root,"Freight container",Vector3.new(26,14,38),Vector3.new(x,7,z),color,Enum.Material.CorrodedMetal)
   for dz=-16,16,5 do self.part(root,"Container rib",Vector3.new(26.3,13,0.4),Vector3.new(x,7,z+dz),color) end
  end
 end
 for _,x in ipairs({-160,160}) do
  local warehouse=self.part(root,"Warehouse",Vector3.new(80,38,62),Vector3.new(x,19,-285),teal)
  self.part(root,"Warehouse door",Vector3.new(35,24,0.5),Vector3.new(x,12,-253),steel)
  self.label(warehouse,"WAREHOUSE • FUTURE DISTRICT",amber).Parent.MaxDistance=350
 end
 for _,x in ipairs({-83,83}) do self.part(root,"Crane leg",Vector3.new(5,60,5),Vector3.new(x,30,-100),amber) end
 self.part(root,"Magnetic gantry",Vector3.new(172,5,7),Vector3.new(0,61,-100),amber)
 local hoist=self.part(root,"Magnet hoist",Vector3.new(12,4,12),Vector3.new(0,34,-100),steel);Tags:AddTag(hoist,"ScrapyardHoist")
 local inspect=self.part(root,"Crane inspection",Vector3.new(4,3,4),Vector3.new(-86,1.5,-88),teal,Enum.Material.Neon);self.Inspections.Crane=inspect;self.label(inspect,"INSPECT • MAGNET CRANE")
 for _,x in ipairs({120,150}) do for _,z in ipairs({250,280}) do self.part(root,"Tower support",Vector3.new(3,62,3),Vector3.new(x,31,z),steel) end end
 local tank=self.part(root,"Water tower",Vector3.new(42,26,42),Vector3.new(135,68,265),teal);self.label(tank,"DISTRICT 08",amber).Parent.MaxDistance=500
 inspect=self.part(root,"Tower inspection",Vector3.new(4,3,4),Vector3.new(108,1.5,240),teal,Enum.Material.Neon);self.Inspections.Tower=inspect;self.label(inspect,"INSPECT • WATER TOWER")
 for _,z in ipairs({325,333}) do self.part(root,"Rail",Vector3.new(760,0.5,0.8),Vector3.new(0,0.5,z),steel) end
 for x=-370,370,15 do self.part(root,"Sleeper",Vector3.new(3,0.3,14),Vector3.new(x,0.3,329),Color3.fromRGB(78,66,50),Enum.Material.Wood) end
 for x=-90,30,40 do self.part(root,"Freight wagon",Vector3.new(34,16,18),Vector3.new(x,10,329),Color3.fromRGB(135,66,47)) end
 inspect=self.part(root,"Depot inspection",Vector3.new(4,3,4),Vector3.new(-45,1.5,280),teal,Enum.Material.Neon);self.Inspections.Depot=inspect;self.label(inspect,"INSPECT • TRAIN DEPOT")
 for _,pos in ipairs({Vector3.new(-190,1,-210),Vector3.new(190,1,70),Vector3.new(-190,1,70),Vector3.new(190,1,-210)}) do
  local sign=self.part(root,"Road wayfinder",Vector3.new(1,8,1),pos+Vector3.new(0,4,14),amber)
  self.label(sign,"CENTRAL SALVAGE →",amber)
 end
 for _,x in ipairs({-225,225}) do for _,z in ipairs({-230,-90,90,230}) do
  self.part(root,"Worklight mast",Vector3.new(0.8,25,0.8),Vector3.new(x,12.5,z),steel)
  local lamp=self.part(root,"Worklight",Vector3.new(5,0.6,3),Vector3.new(x,25,z),Color3.fromRGB(255,225,166),Enum.Material.Neon)
  local light=Instance.new("PointLight");light.Brightness=1;light.Range=28;light.Color=lamp.Color;light.Shadows=false;light.Parent=lamp
 end end
 for _,x in ipairs({-40,40}) do
  local vent=self.part(root,"Steam vent",Vector3.new(3,3,3),Vector3.new(x,2,86),steel)
  local smoke=Instance.new("Smoke");smoke.Color=Color3.fromRGB(173,192,194);smoke.Opacity=0.15;smoke.RiseVelocity=3;smoke.Size=5;smoke.Parent=vent
  local fan=self.part(root,"Vent fan",Vector3.new(9,0.3,1),Vector3.new(x,5,86),amber);fan.CanCollide=false;Tags:AddTag(fan,"ScrapyardFan")
 end
 local gate=self.part(root,"Restricted gate",Vector3.new(85,12,2),Vector3.new(0,6,-360),steel)
 self.label(gate,"RESTRICTED SECTOR • FUTURE UPDATE",Color3.fromRGB(145,236,103)).Parent.MaxDistance=400
 Lighting.ClockTime=13.5;Lighting.Brightness=3;Lighting.Ambient=Color3.fromRGB(138,145,153);Lighting.OutdoorAmbient=Color3.fromRGB(165,172,177)
 local atmosphere=Instance.new("Atmosphere");atmosphere.Density=0.16;atmosphere.Offset=0.1;atmosphere.Color=Color3.fromRGB(196,211,222);atmosphere.Parent=Lighting
 local bloom=Instance.new("BloomEffect");bloom.Intensity=0.14;bloom.Size=20;bloom.Threshold=1.8;bloom.Parent=Lighting
 local cc=Instance.new("ColorCorrectionEffect");cc.Contrast=0.12;cc.Saturation=0.12;cc.Parent=Lighting
end
return World
