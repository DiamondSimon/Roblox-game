local Players=game:GetService("Players")
Players.CharacterAutoLoads=false
local ReplicatedStorage=game:GetService("ReplicatedStorage")
ReplicatedStorage:SetAttribute("BootStatus","Starting")
local function boot()
local services=script.Parent.Services
local Data=require(services.PlayerDataService)
local World=require(services.WorldService)
local Yard=require(services.YardService)
local Game=require(services.GameplayService)
local Pets=require(services.PetService)
local Progression=require(services.ProgressionService)
local Purchase=require(services.PurchaseService)
local Telemetry=require(services.TelemetryService)
local Economy=require(game.ReplicatedStorage.Shared.Config.EconomyConfig)
local folder=Instance.new("Folder");folder.Name="Remotes";folder.Parent=game.ReplicatedStorage
local remote=Instance.new("RemoteEvent");remote.Name="Game";remote.Parent=folder
ReplicatedStorage:SetAttribute("BootStatus","Building map")
World:Build();Data:Start();Game:Start(remote);Purchase:Start()
local joining={}
local function join(player)
 if joining[player] then return end;joining[player]=true
 Telemetry:Join(player)
 local d=Data:Load(player)
 if not d then joining[player]=nil;return end
 if not player.Parent then Data:Release(player);joining[player]=nil;return end
 local yard=Yard:Claim(player)
 if not yard then player:Kick("All eight yards are occupied. Please join another server.");return end
 Yard:Refresh(player,d);Pets:Publish(player,d);task.spawn(function() Pets:RefreshPolicy(player);Game:State(player) end);Telemetry:Event(player,"YardClaimed",1,true)
 player.CharacterAdded:Connect(function(character)
  local humanoid=character:WaitForChild("Humanoid")
  character:WaitForChild("HumanoidRootPart")
  Progression.Immune[player]=os.clock()+10
  character:PivotTo(yard.Spawn.CFrame*CFrame.new(0,4,0))
  local current=Data:Get(player);if current then humanoid.WalkSpeed=Economy.speed(current.Upgrades,false) end
  humanoid.Died:Connect(function()
   Game:Drop(player)
   task.delay(3,function() if player.Parent then player:LoadCharacterAsync() end end)
  end)
 end)
 player:LoadCharacterAsync()
 task.spawn(function() Purchase:RefreshPasses(player) end)
 Game:State(player)
end
local function safeJoin(player)
 local ok,err=xpcall(function() join(player) end,debug.traceback)
 if not ok then
  warn("SCRAPYARD player startup failed: "..tostring(err))
  Game:ClearCarry(player);Yard:Release(player);Data:Release(player)
  joining[player]=nil
  player:Kick("SCRAPYARD could not start your session. Check Studio Output for the startup error.")
 end
end
Players.PlayerAdded:Connect(safeJoin)
Players.PlayerRemoving:Connect(function(player)
 Telemetry:Leave(player)
 Game:Drop(player);Progression:Cleanup(player);Pets.Policies[player]=nil;Pets.Tokens[player]=nil;Pets.PracticePolicy[player]=nil;Game.LastAction[player]=nil;Yard:Release(player)
 -- Load() owns cleanup if the player departed while its request was in flight.
 local s=Data.Sessions[player]
 if s and s.Data then Data:Release(player) end
 joining[player]=nil
end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(safeJoin,player) end
ReplicatedStorage:SetAttribute("BootStatus","Ready")
print("SCRAPYARD 0.3.3 • First playable loop loaded")
end
local ok,err=xpcall(boot,debug.traceback)
if not ok then
 ReplicatedStorage:SetAttribute("BootStatus","Failed")
 warn("SCRAPYARD startup failed: "..tostring(err))
 local function reject(player)
  player:Kick("SCRAPYARD startup failed. Open Studio Output and send the first startup error.")
 end
 Players.PlayerAdded:Connect(reject)
 for _,player in ipairs(Players:GetPlayers()) do reject(player) end
end
