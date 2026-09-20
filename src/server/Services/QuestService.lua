local Config=require(game.ReplicatedStorage.Shared.Config.QuestConfig)
local Data=require(script.Parent.PlayerDataService)
local T=require(script.Parent.TelemetryService)
local Q={}
function Q:Ensure(d,now)
 local day=math.floor((now or os.time())/86400)
 if d.QuestState.Day~=day then d.QuestState={Day=day,Progress={},Claimed={},Inspected={}} end
 return d.QuestState
end
function Q:Progress(d,event,amount)
 local q=self:Ensure(d)
 for _,def in ipairs(Config.Daily) do
  if def.Event==event then q.Progress[def.Id]=math.min(def.Target,(q.Progress[def.Id] or 0)+(amount or 1)) end
 end
end
function Q:Inspect(d,id)
 local q=self:Ensure(d)
 if q.Inspected[id] then return false end
 q.Inspected[id]=true;self:Progress(d,"Inspect",1);return true
end
function Q:View(d)
 local q=self:Ensure(d);local rows={}
 for _,def in ipairs(Config.Daily) do
  table.insert(rows,{Id=def.Id,Name=def.Name,Progress=q.Progress[def.Id] or 0,Target=def.Target,Cores=def.Cores,Claimed=q.Claimed[def.Id]==true})
 end
 return rows
end
function Q:Claim(player,id)
 if type(id)~="string" then return false,"Invalid quest" end
 local d=Data:Get(player);if not d then return false,"Save busy • Try again" end
 local def=nil;for _,item in ipairs(Config.Daily) do if item.Id==id then def=item end end
 if not def then return false,"Unknown quest" end
 local q=self:Ensure(d)
 if q.Claimed[id] or (q.Progress[id] or 0)<def.Target then return false,"Quest not ready" end
 local day=q.Day
 local ok=Data:Commit(player,function(candidate)
  local state=self:Ensure(candidate)
  assert(state.Day==day and not state.Claimed[id] and (state.Progress[id] or 0)>=def.Target,"Quest changed")
  state.Claimed[id]=true;candidate.Cores=candidate.Cores+def.Cores
 end)
 if ok then T:Event(player,"FirstQuestCompleted",1,true);T:Event(player,"FirstCoresEarned",def.Cores,true) end
 return ok,ok and ("QUEST CLAIMED • +"..def.Cores.." CORES") or "Could not confirm claim"
end
return Q
