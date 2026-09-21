-- Cosmetic companions. Bonuses and pet ownership are authoritative on the server.
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Factory=require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("PetModelFactory"))
local models={};local elapsed=0;local tick=0
local function remove(player) local entry=models[player];if entry then entry.Model:Destroy();models[player]=nil end end
Players.PlayerRemoving:Connect(remove)
Run.Heartbeat:Connect(function(dt)
 elapsed=elapsed+dt;tick=tick+dt;if tick<0.05 then return end;local step=tick;tick=0
 local camera=workspace.CurrentCamera
 for _,player in ipairs(Players:GetPlayers()) do
  local id=player:GetAttribute("EquippedPet");local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if not id or id=="" or not root or not camera or (root.Position-camera.CFrame.Position).Magnitude>180 then remove(player)
  else
   if models[player] and models[player].Id~=id then remove(player) end
   local target=root.CFrame*CFrame.new(3,0.4+math.sin(elapsed*3)*0.3,4)
   if not models[player] then local model=Factory:Create(id,workspace);if model then model:PivotTo(target);models[player]={Id=id,Model=model} end end
   local entry=models[player];if entry then entry.Model:PivotTo(entry.Model:GetPivot():Lerp(target,math.min(1,step*8))) end
  end
 end
end)
