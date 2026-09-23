local P={}
function P.Build(W,root)
 local f=Instance.new("Folder");f.Name="FocalDetail";f.Parent=root
 local steel=Color3.fromRGB(43,56,63);local pale=Color3.fromRGB(196,198,182)
 local yellow=Color3.fromRGB(227,165,47);local cyan=Color3.fromRGB(83,218,211)
 local function part(name,size,pos,color)
  local p=W.part(f,name,size,pos,color or steel);p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;return p
 end
 -- Six distinct shop backs, inset service windows, angled awnings and displays.
 for i,key in ipairs({"Upgrades","Sell","Spin","Rebirth","Shop","Pets"}) do
  local pos=W.Shops[key].Position;local x,z=pos.X,pos.Z
  local height=14+(i%3)*2
  part(key.." rear wall",Vector3.new(26,height,2),Vector3.new(x,height/2,z-13),i%2==0 and pale or steel)
  for _,side in ipairs({-1,1}) do
   part(key.." frame",Vector3.new(1.2,13,12),Vector3.new(x+side*12,6.5,z-7),steel)
   part(key.." awning brace",Vector3.new(0.5,4,0.5),Vector3.new(x+side*10,11,z-1),yellow).Orientation=Vector3.new(28,0,0)
  end
  part(key.." service recess",Vector3.new(17,5,0.3),Vector3.new(x,8,z-11.8),Color3.fromRGB(22,34,39))
  part(key.." service shelf",Vector3.new(18,0.5,3),Vector3.new(x,5.3,z-10),pale)
  local hood=part(key.." sloped fascia",Vector3.new(27,1,5),Vector3.new(x,13,z+1),W.Shops[key].Color);hood.Orientation=Vector3.new(12,0,0)
  part(key.." light strip",Vector3.new(16,0.2,0.3),Vector3.new(x,12,z-1),cyan).Material=Enum.Material.Neon
  local sign=part(key.." brand plate",Vector3.new(12,2.4,0.25),Vector3.new(x,height-1,z-11.7),yellow)
  local surface=Instance.new("SurfaceGui");surface.Face=Enum.NormalId.Front;surface.CanvasSize=Vector2.new(480,96);surface.Parent=sign
  local title=Instance.new("TextLabel");title.Size=UDim2.fromScale(1,1);title.BackgroundTransparency=1;title.Text="CYAN / "..string.upper(key);title.Font=Enum.Font.GothamBold;title.TextSize=32;title.TextColor3=steel;title.Parent=surface
  for n=1,3 do
   local display=part(key.." display",Vector3.new(1.5,1+n%2,1.5),Vector3.new(x-4+n*2,6+n%2/2,z-9),W.Shops[key].Color)
   if key=="Spin" or key=="Pets" then display.Shape=Enum.PartType.Ball end
  end
 end
 -- Side-only shredder pipe runs connect motors to rear return headers.
 local center=W.Shredder.Position.Z
 for _,side in ipairs({-1,1}) do
  local pipe=part("Shredder coolant return",Vector3.new(13,0.9,0.9),Vector3.new(side*20,7,center),cyan);pipe.Shape=Enum.PartType.Cylinder;pipe.Orientation=Vector3.new(0,90,0)
  local elbow=part("Shredder return riser",Vector3.new(4,1,1),Vector3.new(side*20,9,center+6),steel);elbow.Shape=Enum.PartType.Cylinder;elbow.Orientation=Vector3.new(0,0,90)
  part("Shredder motor coupler",Vector3.new(7,1.4,1.4),Vector3.new(side*14,5.8,center+7),pale).Shape=Enum.PartType.Cylinder
  if side==1 then for z=-200,200,40 do
   part("Conveyor roller axle",Vector3.new(22,0.5,0.5),Vector3.new(0,0.65,z),pale).Shape=Enum.PartType.Cylinder
  end end
 end
 -- Crane truss bracing above head clearance; hoist cable attaches to moving magnet.
 for x=-70,70,20 do
  local brace=part("Crane diagonal truss",Vector3.new(1,14,1),Vector3.new(x,56,-100),yellow);brace.Orientation=Vector3.new(0,0,55)
 end
 local hoist=root["Magnet hoist"]
 if hoist then
  local anchor=part("Crane cable anchor",Vector3.new(1,1,1),Vector3.new(0,59,-100),steel)
  local a=Instance.new("Attachment");a.Parent=anchor
  local b=Instance.new("Attachment");b.Position=Vector3.new(0,3,0);b.Parent=hoist
  local cable=Instance.new("Beam");cable.Attachment0=a;cable.Attachment1=b;cable.Width0=0.35;cable.Width1=0.35;cable.FaceCamera=true;cable.Color=ColorSequence.new(steel);cable.Parent=anchor
 end
 for _,side in ipairs({-1,1}) do
  local pipe=part("Compactor hydraulic line",Vector3.new(22,0.65,0.65),Vector3.new(-180+side*12,15,152),cyan);pipe.Shape=Enum.PartType.Cylinder;pipe.Orientation=Vector3.new(0,0,90)
  part("Compactor pump manifold",Vector3.new(6,3,4),Vector3.new(-180+side*12,3,152),steel)
 end
end
return P
