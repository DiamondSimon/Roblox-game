-- UI execution smoke test; no rasterization or layout engine.
UDim={new=function(...) return {...} end}
TweenInfo={new=function(...) return {...} end}
local function sig() return {callbacks={},Connect=function(self,fn) table.insert(self.callbacks,fn) end,Fire=function(self,...) for _,fn in ipairs(self.callbacks) do fn(...) end end} end
local create=Instance.new
Instance.new=function(cls)
 local obj=create(cls)
 if cls=="TextButton" then obj.MouseEnter=sig();obj.MouseLeave=sig();obj.Activated=sig() end
 if cls=="NumberValue" then obj.Value=0;obj.Changed=sig() end
 if cls=="RemoteEvent" then obj.OnClientEvent=sig() end
 local inherited=obj.IsA
 function obj:IsA(kind)
  if kind=="GuiObject" then return self.ClassName=="TextLabel" or self.ClassName=="TextButton" or self.ClassName=="Frame" or self.ClassName=="ScrollingFrame" end
  return inherited(self,kind)
 end
 return obj
end
local function enums(names) local t={} for name in names:gmatch('%S+') do t[name]=name end return t end
Enum.ZIndexBehavior=enums("Sibling");Enum.TextXAlignment=enums("Left Center");Enum.AutomaticSize=enums("Y");Enum.SortOrder=enums("LayoutOrder");Enum.Font.Gotham="Gotham"
TestServices.TweenService={Create=function(_,obj,info,props) return {Play=function() for k,v in pairs(props) do obj[k]=v;if obj.ClassName=="NumberValue" then obj.Changed:Fire(v) end end end,Cancel=function() end} end}
TestServices.Players.LocalPlayer=TestPlayer
local pg=Instance.new("PlayerGui");pg.Name="PlayerGui";pg.Parent=TestPlayer
workspace.CurrentCamera={ViewportSize=Vector2.new(390,844),GetPropertyChangedSignal=function() return sig() end}
function workspace:GetPropertyChangedSignal() return sig() end
local remote=game.ReplicatedStorage.Remotes.Game
remote.OnClientEvent=sig()
function remote:FireServer(action,arg) self.OnServerEvent:Fire(TestPlayer,action,arg) end
function remote:FireClient(player,kind,payload) self.LastMessage={player,kind,payload};self.OnClientEvent:Fire(kind,payload) end
function click(text)
 for _,obj in ipairs(pg:GetDescendants()) do if obj.ClassName=="TextButton" and obj.Text==text then obj.Activated:Fire();return end end
 error("Button not found: "..text)
end

TestServices.UserInputService={InputBegan=sig()}
Enum.KeyCode={F="F"};Enum.EasingStyle={Quint="Quint",Sine="Sine"};Enum.EasingDirection={Out="Out",InOut="InOut"}

ColorSequence={new=function(value) return value end}
local attributeSignals={}
function TestPlayer:GetAttributeChangedSignal(key) attributeSignals[key]=attributeSignals[key] or sig();return attributeSignals[key] end
local setAttribute=TestPlayer.SetAttribute
function TestPlayer:SetAttribute(key,value) setAttribute(self,key,value);if attributeSignals[key] then attributeSignals[key]:Fire() end end
TestServices.RunService.Heartbeat=sig()
local frameMeta=getmetatable(CFrame.new())
frameMeta.__index={Lerp=function(a,b,t) return CFrame.new(a.Position+(b.Position-a.Position)*t) end}
