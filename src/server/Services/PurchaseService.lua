local Marketplace=game:GetService("MarketplaceService")
local Players=game:GetService("Players")
local Config=require(game.ReplicatedStorage.Shared.Config.MonetizationConfig)
local Data=require(script.Parent.PlayerDataService)
local T=require(script.Parent.TelemetryService)
local Purchase={}
function Purchase:RefreshPasses(player)
 for _,pass in ipairs(Config.Passes) do
  if pass.Id>0 then
   local ok,owned=pcall(function() return Marketplace:UserOwnsGamePassAsync(player.UserId,pass.Id) end)
   if ok then player:SetAttribute(pass.Key,owned) end
  end
 end
 local d=Data:Get(player)
 if d then require(script.Parent.YardService):Refresh(player,d) end
end
-- Shared fulfillment used by verified receipts and isolated Studio test products.
function Purchase:Grant(player,purchaseId,product)
 local d=Data:Get(player);if not d then return false end
 if d.Receipts[purchaseId] then return true end
 return Data:Commit(player,function(candidate)
  if candidate.Receipts[purchaseId] then return end
  local currency=product.Currency or "Scrap";local amount=product.Amount or product.Scrap
  assert(currency=="Cores" or currency=="Scrap","Unsupported currency")
  candidate[currency]=candidate[currency]+amount
  candidate.Receipts[purchaseId]={Currency=currency,Amount=amount}
 end)
end
function Purchase:Start()
 local products={};local ids={}
 local catalog={}
 for _,list in ipairs({Config.Products,Config.LegacyProducts or {}}) do for _,p in ipairs(list) do table.insert(catalog,p) end end
 for _,p in ipairs(catalog) do
  if p.Id>0 then assert(not ids[p.Id],"Duplicate product ID");ids[p.Id]=true;products[p.Id]=p end
 end
 Marketplace.ProcessReceipt=function(receipt)
  local product=products[receipt.ProductId]
  local player=Players:GetPlayerByUserId(receipt.PlayerId)
  if not product or not player or not Data:IsPersistent() then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local d=Data:Get(player)
  if not d then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local committed=self:Grant(player,receipt.PurchaseId,product)
  if committed then
   T:Event(player,product.Currency=="Cores" and "CorePurchaseCompleted" or "LegacyPurchaseCompleted",product.Amount or product.Scrap)
   return Enum.ProductPurchaseDecision.PurchaseGranted
  end
  return Enum.ProductPurchaseDecision.NotProcessedYet
 end
 Marketplace.PromptGamePassPurchaseFinished:Connect(function(player,id,purchased)
  if purchased then
   -- Verify entitlement with Roblox before activating it.
   task.spawn(function() self:RefreshPasses(player);T:Event(player,"PassPurchased") end)
  end
 end)
end
return Purchase
