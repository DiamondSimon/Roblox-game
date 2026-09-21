local Tween=game:GetService("TweenService")
local Pets=require(game.ReplicatedStorage.Shared.Config.PetConfig)
local Preview=require(game.ReplicatedStorage.Shared.Config.PetPreview)
local R={}
function R.play(parent,payload,finished)
 local def=Pets.Cases[payload.Case];if not def or not Pets.ById[payload.Pet] then return end
 local gui=Instance.new("ScreenGui");gui.Name="CaseOpening";gui.ResetOnSpawn=false;gui.DisplayOrder=80;gui.Parent=parent
 local shade=Instance.new("Frame");shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.fromRGB(9,17,29);shade.BackgroundTransparency=0.12;shade.BorderSizePixel=0;shade.Parent=gui
 local pane=Instance.new("Frame");pane.AnchorPoint=Vector2.new(0.5,0.5);pane.Position=UDim2.fromScale(0.5,0.5);pane.Size=UDim2.new(0.94,0,0,350);pane.BackgroundColor3=Color3.fromRGB(22,33,49);pane.BorderSizePixel=0;pane.Parent=shade
 local limit=Instance.new("UISizeConstraint");limit.MaxSize=Vector2.new(850,350);limit.Parent=pane
 local function text(value,pos,size,fontSize)
  local t=Instance.new("TextLabel");t.Text=value;t.Position=pos;t.Size=size;t.BackgroundTransparency=1;t.TextColor3=Color3.fromRGB(241,246,255);t.Font=Enum.Font.GothamBold;t.TextSize=fontSize;t.TextWrapped=true;t.Parent=pane;return t
 end
 text(string.upper(def.Name),UDim2.fromOffset(12,12),UDim2.new(1,-24,0,30),22)
 local outcome=text("OPENING…",UDim2.fromOffset(12,256),UDim2.new(1,-24,0,40),18)
 local window=Instance.new("Frame");window.Name="ReelWindow";window.ClipsDescendants=true;window.Size=UDim2.new(1,-24,0,190);window.Position=UDim2.fromOffset(12,58);window.BackgroundColor3=Color3.fromRGB(12,23,37);window.BorderSizePixel=0;window.Parent=pane
 local strip=Instance.new("Frame");strip.Name="ReelStrip";strip.Size=UDim2.fromOffset(18*148,184);strip.Position=UDim2.new(0.5,-70,0,3);strip.BackgroundTransparency=1;strip.Parent=window
 local winner=15;local cosmetic=Random.new()
 for i=1,18 do
  -- Decorative reel, with the saved prize fixed under the center pointer. No reroll or near-miss substitution.
  local id=payload.Pet
  if i~=winner then
   local roll=cosmetic:NextNumber(0,100);id=def.Outcomes[#def.Outcomes].Id
   for _,entry in ipairs(def.Outcomes) do roll=roll-entry.Weight;if roll<=0 then id=entry.Id;break end end
  end
  local pet=Pets.ById[id]
  local tile=Instance.new("Frame");tile.Name="ReelTile_"..i;tile.Size=UDim2.fromOffset(140,184);tile.Position=UDim2.fromOffset((i-1)*148,0);tile.BackgroundColor3=Color3.fromRGB(39,53,70);tile.BorderSizePixel=0;tile:SetAttribute("PetId",id);tile.Parent=strip
  local bar=Instance.new("Frame");bar.Size=UDim2.new(1,0,0,5);bar.BackgroundColor3=pet.Color;bar.BorderSizePixel=0;bar.Parent=tile
  Preview.make(tile,id,UDim2.fromOffset(0,8),UDim2.fromOffset(140,123))
  local name=Instance.new("TextLabel");name.BackgroundTransparency=1;name.Size=UDim2.fromOffset(136,48);name.Position=UDim2.fromOffset(2,134);name.Text=pet.Name.."\n"..pet.Rarity;name.TextColor3=pet.Color;name.TextWrapped=true;name.Font=Enum.Font.GothamBold;name.TextSize=13;name.Parent=tile
 end
 local pointer=Instance.new("Frame");pointer.Name="WinnerPointer";pointer.Size=UDim2.new(0,3,1,0);pointer.Position=UDim2.new(0.5,-1,0,0);pointer.BackgroundColor3=Color3.fromRGB(255,205,82);pointer.BorderSizePixel=0;pointer.ZIndex=4;pointer.Parent=window
 local closed=false
 local function close() if closed then return end;closed=true;gui:Destroy();if finished then finished(payload.Pet) end end
 local button=Instance.new("TextButton");button.Text="SKIP ANIMATION";button.Size=UDim2.fromOffset(180,36);button.Position=UDim2.new(0.5,-90,1,-46);button.BackgroundColor3=Color3.fromRGB(255,199,78);button.TextColor3=Color3.fromRGB(19,29,42);button.Font=Enum.Font.GothamBold;button.TextSize=14;button.Parent=pane;button.Activated:Connect(close)
 local target=UDim2.new(0.5,-((winner-1)*148+70),0,3)
 Tween:Create(strip,TweenInfo.new(4,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=target}):Play()
 task.delay(4,function()
  if closed then return end
  local pet=Pets.ById[payload.Pet];outcome.Text=pet.Name.." • "..pet.Rarity.." • +"..math.floor(pet.Bonus*100).."% INCOME";outcome.TextColor3=pet.Color;button.Text="CONTINUE"
 end)
 return gui
end
return R
