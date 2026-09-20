local Players=game:GetService("Players")
Players.CharacterAutoLoads=false
local services=script.Parent.Services
local Data=require(services.PlayerDataService)
local World=require(services.WorldService)
local Yard=require(services.YardService)
local Game=require(services.GameplayService)
local Purchase=require(services.PurchaseService)
local folder=Instance.new("Folder");folder.Name="Remotes";folder.Parent=game.ReplicatedStorage
local remote=Instance.new("RemoteEvent");remote.Name="Game";remote.Parent=folder
World:Build();Data:Start();Game:Start(remote);Purchase:Start()
local joining={}
local function join(player)
 if joining[player] then return end;joining[player]=true
 local d=Data:Load(player)
 if not d then joining[player]=nil;return end
 if not player.Parent then Data:Release(player);joining[player]=nil;return end
 local yard=Yard:Claim(player)
 if not yard then player:Kick("All eight yards are occupied. Please join another server.");return end
 Yard:Refresh(player,d)
 player.CharacterAdded:Connect(function(character)
  local humanoid=character:WaitForChild("Humanoid")
  character:WaitForChild("HumanoidRootPart")
  character:PivotTo(yard.Spawn.CFrame*CFrame.new(0,4,0))
  humanoid.Died:Connect(function()
   Game:ClearCarry(player)
   task.delay(3,function() if player.Parent then player:LoadCharacterAsync() end end)
  end)
 end)
 player:LoadCharacterAsync()
 task.spawn(function() Purchase:RefreshPasses(player) end)
 Game:State(player)
end
Players.PlayerAdded:Connect(join)
Players.PlayerRemoving:Connect(function(player)
 Game:ClearCarry(player);Game.LastAction[player]=nil;Yard:Release(player)
 -- Load() owns cleanup if the player departed while its request was in flight.
 local s=Data.Sessions[player]
 if s and s.Data then Data:Release(player) end
 joining[player]=nil
end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(join,player) end
print("SCRAPYARD 0.1.0 • First playable loop loaded")
