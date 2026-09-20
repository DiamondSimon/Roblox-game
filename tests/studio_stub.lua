-- Narrow server startup harness. This is NOT a Roblox engine replacement.
local vmt={}
vmt.__index=function(v,k) if k=="Magnitude" then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z) end end
vmt.__add=function(a,b) return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
vmt.__sub=function(a,b) return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
Vector3={new=function(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},vmt) end};Vector3.zero=Vector3.new()
Vector2={new=function(x,y) return {X=x,Y=y} end}
local cmt={__mul=function(a,b) return CFrame.new(a.Position.X+b.Position.X,a.Position.Y+b.Position.Y,a.Position.Z+b.Position.Z) end}
CFrame={new=function(x,y,z) return setmetatable({Position=Vector3.new(x,y,z)},cmt) end}
Color3={fromRGB=function(r,g,b) return {R=r/255,G=g/255,B=b/255} end}
UDim2={new=function(...) return {...} end,fromOffset=function(...) return {...} end,fromScale=function(...) return {...} end}
local function enumeration(names)
 local result={} for word in string.gmatch(names,"%S+") do result[word]=word end
 return setmetatable(result,{__index=function(_,k) error("Invalid enum: "..k) end})
end
Enum={Material=enumeration("Metal Asphalt Concrete DiamondPlate Neon CorrodedMetal Rubber Glass"),SurfaceType=enumeration("Smooth"),Font=enumeration("GothamBold"),PartType=enumeration("Cylinder Ball"),HighlightDepthMode=enumeration("Occluded"),ProductPurchaseDecision=enumeration("PurchaseGranted NotProcessedYet")}
local function signal()
 return {callbacks={},Connect=function(self,fn) table.insert(self.callbacks,fn);return {Disconnect=function() end} end,
 Fire=function(self,...) for _,fn in ipairs(self.callbacks) do fn(...) end end}
end
local methods={}
function methods:GetChildren() local a={} for _,c in ipairs(self._children) do table.insert(a,c) end return a end
function methods:GetDescendants() local a={} for _,c in ipairs(self._children) do table.insert(a,c);for _,d in ipairs(c:GetDescendants()) do table.insert(a,d) end end return a end
function methods:FindFirstChild(name) for _,c in ipairs(self._children) do if c.Name==name then return c end end end
function methods:WaitForChild(name) return assert(self:FindFirstChild(name),"Missing child "..name) end
function methods:FindFirstChildOfClass(cls) for _,c in ipairs(self._children) do if c.ClassName==cls then return c end end end
function methods:IsA(cls) return self.ClassName==cls or cls=="BasePart" and (self.ClassName=="Part" or self.ClassName=="SpawnLocation") end
function methods:SetAttribute(k,v) self._attributes[k]=v end
function methods:GetAttribute(k) return self._attributes[k] end
function methods:Destroy() self.Parent=nil;self.Destroyed=true end
function methods:PivotTo(cf)
 local base=self.PrimaryPart or self:FindFirstChild("HumanoidRootPart")
 local delta=cf.Position-base.Position
 for _,p in ipairs(self:GetDescendants()) do if p:IsA("BasePart") then p.Position=p.Position+delta end end
end
function methods:FireClient(player,kind,payload) self.LastMessage={player,kind,payload} end
function methods:FireAllClients(kind,payload) self.LastBroadcast={kind,payload} end
local mt={__index=function(o,k)
 if methods[k] then return methods[k] end
 if k=="CFrame" and o._props.Position then local p=o._props.Position;return CFrame.new(p.X,p.Y,p.Z) end
 if o._props[k]~=nil then return o._props[k] end
 return methods.FindFirstChild(o,k)
end,__newindex=function(o,k,v)
 if k=="Parent" then
  local old=o._props.Parent
  if old then for i,c in ipairs(old._children) do if c==o then table.remove(old._children,i);break end end end
  if v then table.insert(v._children,o) end
 end
 o._props[k]=v
end}
Instance={new=function(cls)
 local o=setmetatable({_props={ClassName=cls,Name=cls},_children={},_attributes={}},mt)
 if cls=="Part" or cls=="SpawnLocation" then o.Position=Vector3.zero end
 if cls=="ProximityPrompt" then o.Triggered=signal() end
 if cls=="RemoteEvent" then o.OnServerEvent=signal() end
 return o
end}
Scheduled={};Clock=10
os.clock=function() return Clock end
function advance()
 Clock=Clock+1
 local pending=Scheduled;Scheduled={}
 for _,co in ipairs(pending) do local ok,err=coroutine.resume(co,1);assert(ok,err);if coroutine.status(co)~="dead" then table.insert(Scheduled,co) end end
end
task={wait=function() return coroutine.yield() end,spawn=function(fn,...)
 local co=coroutine.create(fn);local ok,err=coroutine.resume(co,...);assert(ok,err)
 if coroutine.status(co)~="dead" then table.insert(Scheduled,co) end
end,delay=function(_,fn) table.insert(Scheduled,coroutine.create(fn)) end}
Random={new=function() return {NextNumber=function(_,a,b) return (a+b)/2 end} end}
Warnings={};warn=function(s) table.insert(Warnings,s) end
workspace=Instance.new("Workspace")
local rep=Instance.new("ReplicatedStorage")
local server=Instance.new("ServerScriptService")
local players=Instance.new("Players");players.PlayerAdded=signal();players.PlayerRemoving=signal()
local player=Instance.new("Player");player.Name="TestPlayer";player.DisplayName="Tester";player.UserId=42;player.Parent=players;player.CharacterAdded=signal()
function player:Kick(reason) self.Kicked=reason end
function player:LoadCharacterAsync()
 local character=Instance.new("Model");character.Parent=workspace
 local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Parent=character
 local humanoid=Instance.new("Humanoid");humanoid.Health=100;humanoid.Died=signal();humanoid.Parent=character
 self.Character=character;self.CharacterAdded:Fire(character)
end
function players:GetPlayers() return {player} end
function players:GetPlayerByUserId(id) if id==42 then return player end end
local guid=0;DataStoreOpenCalls=0
local services={ReplicatedStorage=rep,ServerScriptService=server,Players=players,Lighting=Instance.new("Lighting"),
 RunService={IsStudio=function() return true end},
 HttpService={GenerateGUID=function() guid=guid+1;return "guid-"..guid end},
 DataStoreService={GetDataStore=function() DataStoreOpenCalls=DataStoreOpenCalls+1;error("Publish this place to access DataStore") end},
 MarketplaceService={PromptGamePassPurchaseFinished=signal()}}
game={ReplicatedStorage=rep,JobId="",GetService=function(_,name) return assert(services[name],name) end,BindToClose=function(_,fn) CloseCallback=fn end}
local function folder(parent,name) local f=Instance.new("Folder");f.Name=name;f.Parent=parent;return f end
local shared=folder(rep,"Shared");local config=folder(shared,"Config");local modules=folder(server,"Services")
ModuleCache={}
function require(module)
 if ModuleCache[module] then return ModuleCache[module] end
 local env=setmetatable({script=module},{__index=_G})
 local fn=assert(load(module.Source,module.Name,"t",env));local value=fn();ModuleCache[module]=value;return value
end
function addSource(name,source)
 local parent=config
 if string.find(name,"src/server/Services/",1,true) then parent=modules end
 if string.find(name,"ServerMain.server",1,true) then parent=server end
 local module=Instance.new("ModuleScript");module.Name=string.match(name,"([^/]+)%.lua$"):gsub("%.server$","");module.Source=source;module.Parent=parent
 return module
end
function startServer() require(server.ServerMain) end
TestPlayer=player;TestServices=services;TestModules=modules
