local Factory=require(game.ReplicatedStorage.Shared.Config.PetModelFactory)
local P={}
function P.make(parent,id,position,size)
 local viewport=Instance.new("ViewportFrame");viewport.Name="PetPreview_"..id;viewport.Position=position;viewport.Size=size;viewport.BackgroundTransparency=1;viewport.Ambient=Color3.fromRGB(210,220,237);viewport.LightColor=Color3.fromRGB(255,243,224);viewport.LightDirection=Vector3.new(-1,-1,-1);viewport.Parent=parent
 local world=Instance.new("WorldModel");world.Parent=viewport
 local model=Factory:Create(id,world)
 for _,child in ipairs(model:GetDescendants()) do if child:IsA("BillboardGui") then child:Destroy() end end
 local camera=Instance.new("Camera");camera.CFrame=CFrame.lookAt(Vector3.new(5,3.2,-9),Vector3.new(0,0.3,0.6));camera.FieldOfView=40;camera.Parent=viewport;viewport.CurrentCamera=camera
 return viewport
end
return P
