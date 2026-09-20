local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local Marketplace=game:GetService("MarketplaceService")
local player=Players.LocalPlayer
local remoteFolder=game.ReplicatedStorage:WaitForChild("Remotes",30)
local remote=remoteFolder and remoteFolder:WaitForChild("Game",10)
if not remote then
 warn("SCRAPYARD: server did not initialize. Check the server Output for SCRAPYARD startup failed.")
 return
end
local Config=require(game.ReplicatedStorage.Shared.Config.MonetizationConfig)
local Machines=require(game.ReplicatedStorage.Shared.Config.MachineConfig)
local amber=Color3.fromRGB(255,184,55)
local ink=Color3.fromRGB(19,27,34)
local muted=Color3.fromRGB(155,175,183)
local white=Color3.fromRGB(240,245,241)
local state=nil
local gui=Instance.new("ScreenGui");gui.Name="ScrapyardHUD";gui.ResetOnSpawn=false;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=player:WaitForChild("PlayerGui")
local function round(obj,r)
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=obj
end
local function text(parent,content,size,pos,dim,color)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=content;l.TextSize=size;l.TextColor3=color or white;l.Font=Enum.Font.GothamBold;l.TextXAlignment=Enum.TextXAlignment.Left;l.Position=pos;l.Size=dim;l.Parent=parent;return l
end
local function panel(parent,pos,size)
 local p=Instance.new("Frame");p.Position=pos;p.Size=size;p.BackgroundColor3=ink;p.BackgroundTransparency=0.06;p.BorderSizePixel=0;p.Parent=parent;round(p)
 local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(67,83,87);stroke.Thickness=1;stroke.Parent=p;return p
end
local function button(parent,label,pos,size,fn)
 local b=Instance.new("TextButton");b.Text=label;b.Position=pos;b.Size=size;b.TextSize=15;b.Font=Enum.Font.GothamBold;b.TextColor3=ink;b.BackgroundColor3=amber;b.BorderSizePixel=0;b.Parent=parent;round(b,8)
 b.Activated:Connect(fn)
 b.MouseEnter:Connect(function() Tween:Create(b,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(255,209,113)}):Play() end)
 b.MouseLeave:Connect(function() Tween:Create(b,TweenInfo.new(0.12),{BackgroundColor3=amber}):Play() end)
 return b
end
local hud=panel(gui,UDim2.fromOffset(14,12),UDim2.fromOffset(300,126))
text(hud,"SCRAPYARD  /  SALVAGE CO.",13,UDim2.fromOffset(16,10),UDim2.fromOffset(275,22),amber)
local balance=text(hud,"0 SCRAP",29,UDim2.fromOffset(16,37),UDim2.fromOffset(275,38))
local income=text(hud,"+1 / SEC",15,UDim2.fromOffset(16,83),UDim2.fromOffset(135,26),Color3.fromRGB(115,240,195))
local capacity=text(hud,"1 / 6 SLOTS",14,UDim2.fromOffset(170,83),UDim2.fromOffset(120,26),muted)
local hint=panel(gui,UDim2.new(0.5,0,0,150),UDim2.new(0.85,0,0,54));hint.AnchorPoint=Vector2.new(0.5,0)
local hintLimit=Instance.new("UISizeConstraint");hintLimit.MaxSize=Vector2.new(620,54);hintLimit.Parent=hint
local instruction=text(hint,"HEAD TO CENTRAL SALVAGE • Hold E or tap a machine",14,UDim2.fromOffset(12,4),UDim2.new(1,-24,1,-8));instruction.TextWrapped=true;instruction.TextXAlignment=Enum.TextXAlignment.Center
local shopButton=button(gui,"SHOP",UDim2.new(1,-124,0,12),UDim2.fromOffset(110,48),function() end)
local indexButton=button(gui,"INDEX",UDim2.new(1,-124,0,68),UDim2.fromOffset(110,48),function() end)
local drop=button(gui,"DROP",UDim2.new(1,-124,0,124),UDim2.fromOffset(110,48),function() remote:FireServer("DiscardCarry") end);drop.Visible=false
local notice=panel(gui,UDim2.new(0.5,0,0,216),UDim2.new(0.85,0,0,60));notice.AnchorPoint=Vector2.new(0.5,0);notice.Visible=false
local noticeLimit=Instance.new("UISizeConstraint");noticeLimit.MaxSize=Vector2.new(620,60);noticeLimit.Parent=notice
local noticeText=text(notice,"",17,UDim2.fromOffset(12,4),UDim2.new(1,-24,1,-8),amber);noticeText.TextWrapped=true;noticeText.TextXAlignment=Enum.TextXAlignment.Center
local noticeToken=0
local function notify(message)
 noticeToken=noticeToken+1;local n=noticeToken;notice.Visible=true;noticeText.Text=message
 task.delay(4,function() if noticeToken==n then notice.Visible=false end end)
end
local modal=panel(gui,UDim2.fromScale(0.5,0.52),UDim2.fromScale(0.9,0.78));modal.AnchorPoint=Vector2.new(0.5,0.5);modal.Visible=false;modal.ZIndex=5
local limit=Instance.new("UISizeConstraint");limit.MaxSize=Vector2.new(580,590);limit.Parent=modal
local title=text(modal,"SHOP",22,UDim2.fromOffset(20,12),UDim2.new(1,-100,0,40))
button(modal,"X",UDim2.new(1,-62,0,10),UDim2.fromOffset(48,44),function() modal.Visible=false end)
local scroll=Instance.new("ScrollingFrame");scroll.Position=UDim2.fromOffset(16,70);scroll.Size=UDim2.new(1,-32,1,-85);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=5;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=modal
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,10);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=scroll
local function open(name)
 title.Text=name;for _,child in ipairs(scroll:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 modal.Visible=true
end
local function card(name,description,label,fn)
 local row=panel(scroll,UDim2.new(),UDim2.new(1,-7,0,142))
 local nameLabel=text(row,name,17,UDim2.fromOffset(14,10),UDim2.new(1,-28,0,25))
 local desc=text(row,description,13,UDim2.fromOffset(14,38),UDim2.new(1,-28,0,43),muted);desc.TextWrapped=true;desc.Font=Enum.Font.Gotham
 local b=button(row,label,UDim2.fromOffset(14,88),UDim2.new(1,-28,0,44),fn)
 return b,nameLabel
end
local function openShop()
 open("THE SUPPLY DEPOT")
 for _,group in ipairs({{Items=Config.Passes,Pass=true},{Items=Config.Products,Pass=false}}) do
  for _,item in ipairs(group.Items) do
   local isPass=group.Pass;local configured=Config.Enabled and item.Id>0 and state and state.Persistent
   local canBuy=false
   local b=card(item.Name,item.Description,configured and "LOADING PRICE…" or "NOT AVAILABLE IN THIS BUILD",function()
    if not canBuy then return end
    local ok=pcall(function()
     if isPass then Marketplace:PromptGamePassPurchase(player,item.Id) else Marketplace:PromptProductPurchase(player,item.Id) end
    end)
    if not ok then notify("SHOP UNAVAILABLE • Please try again later") end
   end)
   if configured then
    task.spawn(function()
     local ok,info=pcall(function() return Marketplace:GetProductInfo(item.Id,isPass and Enum.InfoType.GamePass or Enum.InfoType.Product) end)
     if not b.Parent then return end
     if isPass and player:GetAttribute(item.Key) then b.Text="OWNED"
     elseif ok and info.IsForSale and type(info.PriceInRobux)=="number" then b.Text=tostring(info.PriceInRobux).." ROBUX";canBuy=true
     else b.Text="UNAVAILABLE" end
    end)
   end
  end
 end
end
local function openIndex()
 open("COLLECTION INDEX")
 for _,id in ipairs(Machines.Order) do
  local def=Machines.ById[id];local found=state and state.Discovered[id]
  local b,name=card(def.DisplayName,def.Rarity.." • "..def.BaseIncome.." Scrap / sec",found and "DISCOVERED" or "FIND IN CENTRAL SALVAGE",function() end)
  name.TextColor3=Machines.Rarities[def.Rarity].Color;b.BackgroundColor3=found and Color3.fromRGB(112,223,180) or muted
 end
end
local function openUpgrades()
 if not state then return end
 open("YARD WORKSHOP")
 local b1,b2
 b1=card("INCOME TUNING • LV "..state.IncomeLevel,"+15% of base machine income per level.",tostring(state.UpgradeCost).." SCRAP",function() remote:FireServer("Upgrade","Income") end)
 b2=card("EXPAND STORAGE • LV "..state.SlotLevel,"Add one machine slot to your yard.",tostring(state.SlotCost).." SCRAP",function() remote:FireServer("Upgrade","Slots") end)
end
shopButton.Activated:Connect(openShop);indexButton.Activated:Connect(openIndex)
local function fmt(n)
 if n>=1e6 then return string.format("%.2fM",n/1e6) end
 if n>=1e3 then return string.format("%.1fK",n/1e3) end
 return tostring(math.floor(n))
end
local function render()
 balance.Text=fmt(state.Scrap).." SCRAP";income.Text="+"..string.format("%.1f",state.Income).." / SEC"
 capacity.Text=state.Count.." / "..state.Capacity.." SLOTS";drop.Visible=state.Carrying~=false
 if state.Carrying then instruction.Text="CARRYING "..string.upper(state.Carrying).." • Return to YOUR green intake"
 elseif state.Count<=1 then instruction.Text="HEAD TO CENTRAL SALVAGE • Hold E or tap a machine"
 elseif state.Scrap>=state.UpgradeCost then instruction.Text="UPGRADE READY • Use the amber terminal in YOUR yard"
 else instruction.Text="COLLECT • EARN • UPGRADE  |  YOUR YARD: "..tostring(player:GetAttribute("YardIndex") or "…") end
end
remote.OnClientEvent:Connect(function(kind,payload)
 if kind=="State" then
  local old=state;state=payload;render()
  if modal.Visible and title.Text=="YARD WORKSHOP" and old and (old.IncomeLevel~=state.IncomeLevel or old.SlotLevel~=state.SlotLevel) then openUpgrades() end
 elseif kind=="Notice" then notify(payload)
 elseif kind=="Upgrades" then openUpgrades() end
end)
local mode=text(gui,"ALPHA 0.1.1 • STUDIO PRACTICE DOES NOT SAVE",10,UDim2.new(0.5,0,1,-23),UDim2.new(0.75,0,0,18),muted);mode.AnchorPoint=Vector2.new(0.5,0);mode.TextXAlignment=Enum.TextXAlignment.Center
local function resize()
 local camera=workspace.CurrentCamera;if not camera then return end
 local small=camera.ViewportSize.X<520
 hud.Size=UDim2.fromOffset(small and 220 or 300,126)
 capacity.Position=UDim2.fromOffset(small and 116 or 170,83);capacity.TextSize=small and 11 or 14
 balance.TextSize=small and 25 or 29
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(resize)
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
resize()
task.spawn(function()
 while true do
  if state then mode.Text=state.Persistent and "ALPHA 0.1.1 • PRIVATE TEST BUILD" or "ALPHA 0.1.1 • PRACTICE MODE — PROGRESS RESETS" end
  task.wait(3)
 end
end)
remote:FireServer("Sync")
