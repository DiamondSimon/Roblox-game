local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local Marketplace=game:GetService("MarketplaceService")
local player=Players.LocalPlayer
local folder=game.ReplicatedStorage:WaitForChild("Remotes",30)
local remote=folder and folder:WaitForChild("Game",10)
if not remote then warn("SCRAPYARD server did not initialize. Check server Output.");return end
local Shared=game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local Monetization=require(Shared.MonetizationConfig)
local Machines=require(Shared.MachineConfig)
local Economy=require(Shared.EconomyConfig)
local Styles=require(Shared.CoreShopConfig)
local amber=Color3.fromRGB(255,187,68);local ink=Color3.fromRGB(19,28,36)
local white=Color3.fromRGB(238,245,242);local muted=Color3.fromRGB(153,175,183);local teal=Color3.fromRGB(105,238,214)
local state=nil;local page=nil;local shopTab="PASSES";local updaters={}
local gui=Instance.new("ScreenGui");gui.Name="ScrapyardHUD";gui.ResetOnSpawn=false;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=player:WaitForChild("PlayerGui")
local function round(o,n) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,n or 10);c.Parent=o end
local function label(parent,content,size,pos,dim,color)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=content;l.TextSize=size;l.TextColor3=color or white;l.Font=Enum.Font.GothamBold;l.TextXAlignment=Enum.TextXAlignment.Left;l.Position=pos;l.Size=dim;l.Parent=parent;return l
end
local function panel(parent,pos,size)
 local f=Instance.new("Frame");f.Position=pos;f.Size=size;f.BackgroundColor3=ink;f.BackgroundTransparency=0.08;f.BorderSizePixel=0;f.Parent=parent;round(f);return f
end
local function button(parent,content,pos,size,fn,secondary)
 local b=Instance.new("TextButton");b.Position=pos;b.Size=size;b.Text=content;b.TextSize=14;b.Font=Enum.Font.GothamBold;b.TextColor3=secondary and white or ink;b.BackgroundColor3=secondary and Color3.fromRGB(42,58,68) or amber;b.BorderSizePixel=0;b.Parent=parent;round(b,8)
 local scale=Instance.new("UIScale");scale.Parent=b
 b.MouseEnter:Connect(function() Tween:Create(scale,TweenInfo.new(0.1),{Scale=1.025}):Play() end)
 b.MouseLeave:Connect(function() Tween:Create(scale,TweenInfo.new(0.1),{Scale=1}):Play() end)
 b.Activated:Connect(fn);return b
end
local function fmt(n)
 if n>=1e6 then return string.format("%.2fM",n/1e6) elseif n>=1e3 then return string.format("%.1fK",n/1e3) end
 return tostring(math.floor(n))
end
local currency=panel(gui,UDim2.fromOffset(14,12),UDim2.fromOffset(228,102))
label(currency,"SCRAP",10,UDim2.fromOffset(12,7),UDim2.fromOffset(90,16),muted)
local scrap=label(currency,"0",27,UDim2.fromOffset(12,23),UDim2.new(1,-24,0,31))
local rate=label(currency,"+0.30 / sec",12,UDim2.fromOffset(12,57),UDim2.new(1,-24,0,18),teal)
local cores=label(currency,"CORES  0",13,UDim2.fromOffset(12,80),UDim2.new(1,-24,0,18),amber)
local goal=label(gui,"Walk to CENTRAL SALVAGE",12,UDim2.fromOffset(16,122),UDim2.new(1,-148,0,44),white);goal.TextWrapped=true
local nav=Instance.new("Frame");nav.Position=UDim2.new(1,-120,0,14);nav.Size=UDim2.fromOffset(106,258);nav.BackgroundTransparency=1;nav.Parent=gui
local modal=panel(gui,UDim2.fromScale(0.5,0.51),UDim2.fromScale(0.9,0.82));modal.AnchorPoint=Vector2.new(0.5,0.5);modal.Visible=false;modal.ZIndex=5
local limit=Instance.new("UISizeConstraint");limit.MaxSize=Vector2.new(640,620);limit.Parent=modal
local title=label(modal,"",21,UDim2.fromOffset(18,10),UDim2.new(1,-92,0,38))
button(modal,"X",UDim2.new(1,-60,0,8),UDim2.fromOffset(44,44),function() modal.Visible=false;page=nil end,true)
local tabs=Instance.new("Frame");tabs.Position=UDim2.fromOffset(16,58);tabs.Size=UDim2.new(1,-32,0,44);tabs.BackgroundTransparency=1;tabs.Parent=modal
local scroll=Instance.new("ScrollingFrame");scroll.Position=UDim2.fromOffset(16,112);scroll.Size=UDim2.new(1,-32,1,-128);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=4;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=modal
local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,10);list.SortOrder=Enum.SortOrder.LayoutOrder;list.Parent=scroll
local function card(name,description,action,fn,color)
 local f=panel(scroll,UDim2.new(),UDim2.new(1,-6,0,154));f.BackgroundColor3=Color3.fromRGB(30,43,52)
 local heading=label(f,name,16,UDim2.fromOffset(12,8),UDim2.new(1,-24,0,34),color);heading.TextWrapped=true
 local desc=label(f,description,12,UDim2.fromOffset(12,43),UDim2.new(1,-24,0,49),muted);desc.TextWrapped=true;desc.Font=Enum.Font.Gotham
 local b=button(f,action,UDim2.fromOffset(12,102),UDim2.new(1,-24,0,44),fn)
 return b,desc,f
end
local notice=panel(gui,UDim2.new(0.5,0,0,175),UDim2.new(0.8,0,0,48));notice.AnchorPoint=Vector2.new(0.5,0);notice.Visible=false;notice.ZIndex=9
local cap=Instance.new("UISizeConstraint");cap.MaxSize=Vector2.new(560,48);cap.Parent=notice
local noticeText=label(notice,"",14,UDim2.fromOffset(10,3),UDim2.new(1,-20,1,-6),amber);noticeText.TextWrapped=true;noticeText.TextXAlignment=Enum.TextXAlignment.Center
local noticeToken=0
local function notify(message)
 noticeToken=noticeToken+1;local n=noticeToken;notice.Visible=true;noticeText.Text=message
 task.delay(3,function() if noticeToken==n then notice.Visible=false end end)
end
local renderMenu
local function open(name)
 page=name;modal.Visible=true;renderMenu();scroll.CanvasPosition=Vector2.new(0,0)
 modal.Position=UDim2.fromScale(0.5,0.54);Tween:Create(modal,TweenInfo.new(0.13),{Position=UDim2.fromScale(0.5,0.51)}):Play()
end
local function marketplaceCard(item,isPass)
 local ready=false
 local b=card(item.Name,item.Description,"NOT CONFIGURED",function()
  if not ready then return end
  remote:FireServer("Telemetry",isPass and "PassPrompted" or "CorePurchasePrompted")
  local ok=pcall(function() if isPass then Marketplace:PromptGamePassPurchase(player,item.Id) else Marketplace:PromptProductPurchase(player,item.Id) end end)
  if not ok then notify("Shop unavailable • Try again later") end
 end)
 if Monetization.Enabled and item.Id>0 and state and state.Persistent then
  b.Text="CHECKING PRICE…"
  task.spawn(function()
   local ok,info=pcall(function() return Marketplace:GetProductInfo(item.Id,isPass and Enum.InfoType.GamePass or Enum.InfoType.Product) end)
   if not b.Parent then return end
   if isPass and player:GetAttribute(item.Key) then b.Text="OWNED"
   elseif ok and info.IsForSale and type(info.PriceInRobux)=="number" then b.Text=info.PriceInRobux.." ROBUX";ready=true
   else b.Text="UNAVAILABLE" end
  end)
 end
end
renderMenu=function()
 updaters={}
 for _,child in ipairs(scroll:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 for _,child in ipairs(tabs:GetChildren()) do child:Destroy() end
 if not state then title.Text="LOADING…";return end
 if page=="Shop" then
  title.Text="SUPPLY DEPOT"
  for i,name in ipairs({"PASSES","CORES","STYLES"}) do
   button(tabs,name,UDim2.new((i-1)/3,0,0,0),UDim2.new(1/3,-6,1,0),function() shopTab=name;renderMenu() end,shopTab~=name)
  end
  if shopTab=="PASSES" then for _,item in ipairs(Monetization.Passes) do marketplaceCard(item,true) end
  elseif shopTab=="CORES" then
   label(tabs,"",12,UDim2.new(),UDim2.new())
   for _,item in ipairs(Monetization.Products) do if not item.Hidden then marketplaceCard(item,false) end end
  else
   for _,id in ipairs(Styles.Order) do
    local item=Styles.Items[id]
    local b=card(item.Name,item.Description,item.Cost.." CORES",function() remote:FireServer("CoreShop",id) end,item.Color)
    table.insert(updaters,function() b.Text=state.Cosmetics.Equipped==id and "EQUIPPED" or state.Cosmetics.Owned[id] and "EQUIP" or item.Cost.." CORES" end)
   end
  end
 elseif page=="Upgrades" then
  title.Text="YARD WORKSHOP"
  label(tabs,"Purchase at your yard's amber terminal.",12,UDim2.new(),UDim2.fromScale(1,1),muted)
  for _,key in ipairs(Economy.UpgradeOrder) do
   local def=Economy.Upgrades[key]
   local b,desc,f=card(def.Name,def.Description,"",function() remote:FireServer("Upgrade",key) end)
   table.insert(updaters,function()
    local level=state.Upgrades[key];local cost=Economy.cost(key,level)
    desc.Text=def.Branch.." • Level "..level.." / "..def.Max.."\n"..def.Description
    b.Text=level>=def.Max and "MAX LEVEL" or fmt(cost).." SCRAP  •  "..math.min(100,math.floor(state.Scrap/cost*100)).."% FUNDED"
   end)
  end
 elseif page=="Quests" then
  title.Text="DAILY CONTRACTS"
  label(tabs,"Earn Cores • Refreshes at 00:00 UTC",12,UDim2.new(),UDim2.fromScale(1,1),teal)
  for i,q in ipairs(state.Quests) do
   local b,desc=card(q.Name,"","",function() remote:FireServer("ClaimQuest",q.Id) end)
   table.insert(updaters,function()
    local current=state.Quests[i];desc.Text=current.Progress.." / "..current.Target.."  •  Reward: "..current.Cores.." Cores"
    b.Text=current.Claimed and "CLAIMED" or current.Progress>=current.Target and "CLAIM CORES" or "IN PROGRESS"
   end)
  end
 elseif page=="Collection" then
  title.Text="COLLECTION"
  label(tabs,"Find machines. Bring them home to discover them.",12,UDim2.new(),UDim2.fromScale(1,1),muted)
  for _,id in ipairs(Machines.Order) do
   local m=Machines.ById[id];local b=card(m.DisplayName,m.Rarity.." • +"..m.BaseIncome.." base Scrap/sec","",function() end,Machines.Rarities[m.Rarity].Color)
   table.insert(updaters,function() b.Text=state.Discovered[id] and "DISCOVERED" or "UNDISCOVERED" end)
  end
 elseif page=="Replace" then
  title.Text="MAKE ROOM"
  label(tabs,"Your yard is full. Choose a machine to replace.",12,UDim2.new(),UDim2.fromScale(1,1),muted)
  for _,item in ipairs(state.Inventory) do
   if not item.Protected then
    local def=Machines.ById[item.MachineId]
    card(def.DisplayName,"Replace with your carried machine. This removes the old machine permanently.","SELECT TO REPLACE",function()
     updaters={};for _,child in ipairs(scroll:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
     card("Confirm replacement",def.DisplayName.." will be removed. No Scrap is awarded.","CONFIRM REPLACEMENT",function() remote:FireServer("Replace",item.Uid);modal.Visible=false;page=nil end)
     card("Keep your machine","Cancel and return to your inventory.","CANCEL",function() renderMenu() end)
    end)
   end
  end
 end
 for _,update in ipairs(updaters) do update() end
end
local shop=button(nav,"SHOP",UDim2.fromOffset(0,0),UDim2.fromOffset(106,46),function() remote:FireServer("Telemetry","ShopOpened");open("Shop") end,true)
local upgrades=button(nav,"UPGRADES",UDim2.fromOffset(0,54),UDim2.fromOffset(106,46),function() open("Upgrades") end,true)
local quests=button(nav,"QUESTS",UDim2.fromOffset(0,108),UDim2.fromOffset(106,46),function() open("Quests") end,true)
button(nav,"COLLECTION",UDim2.fromOffset(0,162),UDim2.fromOffset(106,46),function() open("Collection") end,true)
local drop=button(nav,"DROP",UDim2.fromOffset(0,216),UDim2.fromOffset(106,44),function() remote:FireServer("DiscardCarry") end,true);drop.Visible=false
local counter=Instance.new("NumberValue");local counterTween=nil
counter.Changed:Connect(function(v) scrap.Text=fmt(v) end)
local function render()
 if counterTween then counterTween:Cancel() end
 counterTween=Tween:Create(counter,TweenInfo.new(0.35),{Value=state.Scrap});counterTween:Play()
 cores.Text="CORES  "..fmt(state.Cores);rate.Text=string.format("+%.2f / sec  •  %d/%d slots",state.Income,state.Count,state.Capacity)
 drop.Visible=state.Carrying~=false
 local ready=false
 for _,q in ipairs(state.Quests) do if not q.Claimed and q.Progress>=q.Target then ready=true end end
 quests.Text=ready and "QUESTS •" or "QUESTS"
 local affordable=false
 for _,key in ipairs(Economy.UpgradeOrder) do if state.Upgrades[key]<Economy.Upgrades[key].Max and state.Scrap>=Economy.cost(key,state.Upgrades[key]) then affordable=true end end
 upgrades.Text=affordable and "UPGRADES •" or "UPGRADES"
 if state.Carrying then goal.Text="HAULING "..state.Carrying.." → Yard "..tostring(player:GetAttribute("YardIndex"))
 elseif state.Count<=1 then goal.Text="Follow the road to CENTRAL SALVAGE. Hold E or tap to carry."
 elseif ready then goal.Text="Contract complete • Claim your Cores in QUESTS"
 else goal.Text="YOUR YARD "..tostring(player:GetAttribute("YardIndex")).."  •  Inspect landmarks for daily Cores" end
 for _,update in ipairs(updaters) do update() end
end
local mode=label(gui,"V0.2 • PRACTICE MODE",10,UDim2.new(0.5,0,1,-22),UDim2.new(0.7,0,0,18),muted);mode.AnchorPoint=Vector2.new(0.5,0);mode.TextXAlignment=Enum.TextXAlignment.Center
remote.OnClientEvent:Connect(function(kind,payload)
 if kind=="State" then local first=state==nil;state=payload;render();mode.Text=state.Persistent and "V0.2 • PRIVATE TEST" or "V0.2 • PRACTICE — PROGRESS RESETS";if first and page then renderMenu() end
 elseif kind=="Notice" then notify(payload)
 elseif kind=="Upgrades" then open("Upgrades")
 elseif kind=="Replace" then open("Replace") end
end)
local function resize()
 local camera=workspace.CurrentCamera;if not camera then return end
 currency.Size=UDim2.fromOffset(camera.ViewportSize.X<480 and 178 or 228,102)
 rate.TextSize=camera.ViewportSize.X<480 and 10 or 12
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(resize)
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
resize();remote:FireServer("Sync")
