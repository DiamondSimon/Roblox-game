local Factory=require(game.ReplicatedStorage.Shared.Config.MachineModelFactory)
local P={}
function P.make(parent,id)
 local viewport=Instance.new("ViewportFrame");viewport.Name="JunkPreview_"..id;viewport.Position=UDim2.fromOffset(12,39);viewport.Size=UDim2.new(1,-24,0,120);viewport.BackgroundTransparency=1;viewport.Ambient=Color3.fromRGB(210,220,237);viewport.LightColor=Color3.fromRGB(255,243,224);viewport.Parent=parent
 local world=Instance.new("WorldModel");world.Parent=viewport;Factory:Create(id,Vector3.zero,world)
 local camera=Instance.new("Camera");camera.CFrame=CFrame.lookAt(Vector3.new(10,7,-13),Vector3.new(0,1,0));camera.FieldOfView=40;camera.Parent=viewport;viewport.CurrentCamera=camera
 return viewport
end
return P
