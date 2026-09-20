local DSS=game:GetService("DataStoreService")
local Http=game:GetService("HttpService")
local Run=game:GetService("RunService")
local Config=require(game.ReplicatedStorage.Shared.Config.GameConfig)
local Machines=require(game.ReplicatedStorage.Shared.Config.MachineConfig)
local Schema=require(script.Parent.ProfileSchema)
local Store=nil -- Open lazily inside the protected persistent-write path.
local Data={Sessions={}, Closing=false}
local memoryMode=Run:IsStudio() and not Config.StudioPersistence
local token=(game.JobId~="" and game.JobId or "studio")..Http:GenerateGUID(false)
local function clone(t)
 local n={} for k,v in pairs(t) do n[k]=type(v)=="table" and clone(v) or v end return n
end
local function fresh() return Schema.fresh(Http:GenerateGUID(false)) end
local function validate(d)
 assert(d.SchemaVersion==3,"Unsupported schema; never overwrite a newer save")
 assert(type(d.Scrap)=="number" and d.Scrap==d.Scrap and d.Scrap>=0 and d.Scrap<math.huge,"Bad balance")
 assert(type(d.MachineInventory)=="table" and #d.MachineInventory<=40,"Bad inventory")
 local ids={}
 for _,item in ipairs(d.MachineInventory) do
  assert(type(item.Uid)=="string" and not ids[item.Uid] and Machines.ById[item.MachineId],"Bad item")
  ids[item.Uid]=true
 end
 assert(type(d.Upgrades)=="table" and type(d.Receipts)=="table","Bad schema")
 assert(type(d.Upgrades.Income)=="number" and d.Upgrades.Income%1==0 and d.Upgrades.Income>=0 and d.Upgrades.Income<=20,"Bad upgrade")
 assert(type(d.Upgrades.Slots)=="number" and d.Upgrades.Slots%1==0 and d.Upgrades.Slots>=0 and d.Upgrades.Slots<=7,"Bad slots")
 assert(type(d.Cores)=="number" and d.Cores==d.Cores and d.Cores>=0 and d.Cores<math.huge,"Bad Cores")
 for _,key in ipairs({"Speed","Carry","Expansion"}) do
  assert(type(d.Upgrades[key])=="number" and d.Upgrades[key]>=0 and d.Upgrades[key]%1==0 and d.Upgrades[key]<=4,"Bad utility upgrade")
 end
 assert(type(d.QuestState)=="table" and type(d.Cosmetics)=="table","Bad v2 state")
 assert(type(d.Upgrades.Floors)=="number" and d.Upgrades.Floors%1==0 and d.Upgrades.Floors>=0 and d.Upgrades.Floors<=3,"Bad floors")
 assert(type(d.Rebirths)=="number" and d.Rebirths%1==0 and d.Rebirths>=0 and d.Rebirths<=10,"Bad rebirths")
 assert(type(d.TutorialStage)=="number" and d.TutorialStage>=1 and d.TutorialStage<=4,"Bad tutorial")
 assert(type(d.SpinState)=="table" and type(d.SpinState.Day)=="number","Bad spin")
 return d
end
local function update(key, transform)
 for attempt=1,3 do
  local ok,result=pcall(function()
   if not Store then Store=DSS:GetDataStore(Config.DataStoreName) end
   return Store:UpdateAsync(key,transform)
  end)
  if ok then return true,result end
  warn("SCRAPYARD save attempt failed",attempt)
  task.wait(attempt)
 end
 return false,nil
end
function Data:Load(player)
 if self.Closing then return nil end
 local session={Busy=true,Active=true,Key="player_"..player.UserId,LeaseUntil=0}
 self.Sessions[player]=session
 if memoryMode then session.Data=fresh();session.Busy=false;return session.Data end
 local ok,record=update(session.Key,function(old)
  if old and old.Lease and old.Lease.Token~=token and old.Lease.Expires>os.time() then return nil end
  local d=old and validate(Schema.migrate(old.Data)) or fresh()
  return {Data=d,Lease={Token=token,Expires=os.time()+Config.LeaseSeconds}}
 end)
 if not ok or not record or record.Lease.Token~=token then
  self.Sessions[player]=nil
  player:Kick("Your save is unavailable or open on another server. Please rejoin shortly.")
  return nil
 end
 session.Data=record.Data;session.LeaseUntil=record.Lease.Expires;session.Busy=false
 return session.Data
end
function Data:Get(player)
 local s=self.Sessions[player]
 if not s or not s.Active or s.Busy then return nil end
 if not memoryMode and os.time()>=s.LeaseUntil-10 then
  s.Active=false;player:Kick("Save connection interrupted. Please rejoin to protect your progress.");return nil
 end
 return s.Data
end
-- Mutations supplied here must not yield. Saving and receipts serialize on Busy.
function Data:Mutate(player,fn)
 local d=self:Get(player);if not d then return false end
 fn(d);return true
end
function Data:Commit(player,transform,release)
 local s=self.Sessions[player]
 if not s or s.Busy or not s.Active or not s.Data then return false end
 s.Busy=true
 local candidate=clone(s.Data)
 local transformOK=pcall(function() if transform then transform(candidate) end;validate(candidate) end)
 if not transformOK then s.Busy=false;return false end
 if memoryMode then
  s.Data=candidate;s.Busy=false;return true
 end
 local ok,record=update(s.Key,function(old)
  if not old or not old.Lease or old.Lease.Token~=token or old.Lease.Expires<=os.time() then return nil end
  -- An UpdateAsync error can be ambiguous: a previous attempt may have committed.
  -- Merge durable receipts missing from memory before any subsequent profile save.
  local merged=clone(candidate)
  for purchaseId,amount in pairs(old.Data.Receipts) do
   if not merged.Receipts[purchaseId] then
    merged.Receipts[purchaseId]=amount
    local currency=type(amount)=="number" and "Scrap" or amount.Currency
    local value=type(amount)=="number" and amount or amount.Amount
    merged[currency]=merged[currency]+value
   end
  end
  local lease=nil
  if not release then lease={Token=token,Expires=os.time()+Config.LeaseSeconds} end
  return {Data=merged,Lease=lease}
 end)
 if ok and record then
  s.Data=record.Data;s.LeaseUntil=record.Lease and record.Lease.Expires or 0
 end
 s.Busy=false
 if transform and not (ok and record) then
  -- A failed response may hide a successful spend/claim. Freeze until durable reload.
  s.Active=false
  player:Kick("Could not confirm this transaction. Rejoin shortly to restore the saved result.")
 end
 return ok and record~=nil
end
function Data:Release(player)
 local s=self.Sessions[player];if not s then return end
 local deadline=os.clock()+20
 while s.Busy and os.clock()<deadline do task.wait(0.1) end
 if s.Data and not s.Busy then self:Commit(player,nil,true) end
 s.Active=false;self.Sessions[player]=nil
end
function Data:IsPersistent() return not memoryMode end
function Data:Start()
 task.spawn(function()
  while not self.Closing do
   task.wait(Config.AutosaveSeconds)
   for player in pairs(self.Sessions) do task.spawn(function() self:Commit(player) end) end
  end
 end)
 game:BindToClose(function()
  self.Closing=true
  local pending=0
  for player in pairs(self.Sessions) do
   pending=pending+1
   task.spawn(function() self:Release(player);pending=pending-1 end)
  end
  local deadline=os.clock()+25
  while pending>0 and os.clock()<deadline do task.wait(0.1) end
 end)
end
return Data
