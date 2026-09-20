local Marketplace=game:GetService("MarketplaceService")
local Players=game:GetService("Players")
local Config=require(game.ReplicatedStorage.Shared.Config.MonetizationConfig)
local Data=require(script.Parent.PlayerDataService)
local Purchase={}
function Purchase:RefreshPasses(player)
 for _,pass in ipairs(Config.Passes) do
  if pass.Id>0 then
   local ok,owned=pcall(function() return Marketplace:UserOwnsGamePassAsync(player.UserId,pass.Id) end)
   if ok then player:SetAttribute(pass.Key,owned) end
  end
 end
end
function Purchase:Start()
 local products={};local ids={}
 for _,p in ipairs(Config.Products) do
  if p.Id>0 then assert(not ids[p.Id],"Duplicate product ID");ids[p.Id]=true;products[p.Id]=p end
 end
 Marketplace.ProcessReceipt=function(receipt)
  local product=products[receipt.ProductId]
  local player=Players:GetPlayerByUserId(receipt.PlayerId)
  if not product or not player or not Data:IsPersistent() then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local d=Data:Get(player)
  if not d then return Enum.ProductPurchaseDecision.NotProcessedYet end
  -- Receipt marker and reward share ONE atomic profile write, never separate keys.
  if d.Receipts[receipt.PurchaseId] then return Enum.ProductPurchaseDecision.PurchaseGranted end
  local committed=Data:Commit(player,function(candidate)
   if candidate.Receipts[receipt.PurchaseId] then return end
   candidate.Scrap=candidate.Scrap+product.Scrap
   candidate.Receipts[receipt.PurchaseId]=product.Scrap
  end)
  if committed then return Enum.ProductPurchaseDecision.PurchaseGranted end
  return Enum.ProductPurchaseDecision.NotProcessedYet
 end
 Marketplace.PromptGamePassPurchaseFinished:Connect(function(player,id,purchased)
  if purchased then
   -- Verify entitlement with Roblox before activating it.
   task.spawn(function() self:RefreshPasses(player) end)
  end
 end)
end
return Purchase
