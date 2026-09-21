local Config=require(game.ReplicatedStorage.Shared.Config.PetConfig)
local F={}
function F:Create(id,parent)
 local def=Config.ById[id];if not def then return nil end
 local model=Instance.new("Model");model.Name=def.Name
 local dark=Color3.fromRGB(34,44,58);local light=Color3.fromRGB(237,249,255)
 local function part(name,size,pos,color,ball)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Color=color or def.Color;p.Material=Enum.Material.Metal
  if ball then p.Shape=Enum.PartType.Ball end;p.Parent=model;return p
 end
 local body=part("Body",Vector3.new(2.2,1.7,2.2),Vector3.zero);model.PrimaryPart=body
 part("Face",Vector3.new(1.8,1.4,0.6),Vector3.new(0,0.4,-1),def.Color)
 for _,x in ipairs({-0.48,0.48}) do
  part("Eye",Vector3.new(0.36,0.4,0.18),Vector3.new(x,0.65,-1.36),light,true)
  part("Pupil",Vector3.new(0.14,0.23,0.1),Vector3.new(x,0.65,-1.47),dark,true)
  part("Foot",Vector3.new(0.5,0.5,1),Vector3.new(x,-0.9,0),dark)
 end
 local shape=def.Shape
 if shape=="Mouse" then
  for _,x in ipairs({-0.9,0.9}) do part("Round ear",Vector3.new(1,1,0.35),Vector3.new(x,1.15,-0.3),def.Color,true) end
  part("Wire tail",Vector3.new(0.15,0.15,1.6),Vector3.new(0,0,1.8),dark)
 elseif shape=="Cat" or shape=="Fox" or shape=="Tiger" then
  for _,x in ipairs({-0.8,0.8}) do local ear=part("Pointed ear",Vector3.new(0.6,1.2,0.55),Vector3.new(x,1.1,-0.3));ear.Orientation=Vector3.new(0,0,x*22) end
  part("Tail",Vector3.new(0.6,0.6,1.9),Vector3.new(0,0.3,1.7),shape=="Fox" and light or def.Color)
  if shape=="Tiger" then for z=-0.7,0.7,0.7 do part("Tiger stripe",Vector3.new(2.23,0.2,0.28),Vector3.new(0,0.87,z),dark) end end
 elseif shape=="Dog" then
  for _,x in ipairs({-1.1,1.1}) do part("Floppy ear",Vector3.new(0.5,1.4,0.7),Vector3.new(x,0.3,-0.4),dark) end
  part("Snout",Vector3.new(0.9,0.6,0.7),Vector3.new(0,0,-1.5),light)
 elseif shape=="Serpent" then
  for i=1,5 do part("Segment",Vector3.new(1.5-i*0.12,1.3-i*0.1,1.1),Vector3.new(math.sin(i)*0.5,0,1+i*0.75),def.Color,true) end
  for _,x in ipairs({-0.6,0.6}) do part("Horn",Vector3.new(0.2,1,0.2),Vector3.new(x,1.2,0),light) end
 else
  for _,side in ipairs({-1,1}) do
   for i=1,3 do local wing=part("Wing feather",Vector3.new(0.6,0.25,1.5),Vector3.new(side*(1+i*0.45),0.6,i*0.25),i%2==0 and light or def.Color);wing.Orientation=Vector3.new(0,side*25,side*15) end
  end
  if shape=="Dragon" then for i=1,3 do part("Back spike",Vector3.new(0.3,0.8,0.3),Vector3.new(0,1,i*0.6),light) end end
  part("Beak",Vector3.new(0.5,0.5,0.6),Vector3.new(0,0.2,-1.6),shape=="Owl" and Color3.fromRGB(255,196,65) or dark)
 end
 local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(170,40);gui.StudsOffset=Vector3.new(0,2.4,0);gui.MaxDistance=55;gui.Parent=body
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text=def.Name.." • +"..math.floor(def.Bonus*100).."%";text.TextSize=13;text.Font=Enum.Font.GothamBold;text.TextColor3=def.Color;text.TextStrokeTransparency=0;text.Parent=gui
 model.Parent=parent;return model
end
return F
