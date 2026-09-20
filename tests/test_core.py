"""Run with python -m pip install lupa, then python tests/test_core.py.
Executes actual Lua modules with service fakes, not the Roblox engine.
"""
from pathlib import Path
import unittest
from lupa import LuaRuntime
ROOT=Path(__file__).resolve().parents[1]

def runtime(studio=False, datastore_unavailable=False, source=None):
 lua=LuaRuntime(unpack_returned_tuples=True)
 lua.execute('''
 Color3={fromRGB=function(r,g,b) return {r=r,g=g,b=b} end}
 Config={DataStoreName="test",LeaseSeconds=180,AutosaveSeconds=30,StudioPersistence=false}
 Definitions={ById={radio={}}}
 game={ReplicatedStorage={Shared={Config={GameConfig="config",MachineConfig="machines",MonetizationConfig="money",EconomyConfig="economy"}}},JobId="test-server"}
 script={Parent={PlayerDataService="data",ProfileSchema="schema",TelemetryService="telemetry"}}
 task={wait=function() end,spawn=function() end}
 warn=function() end
 Enum={ProductPurchaseDecision={NotProcessedYet="pending",PurchaseGranted="granted"}}
 Store={records={},fail=false,ambiguous=false,failAfterCommit=false}
 function copy(t) if type(t)~="table" then return t end local n={} for k,v in pairs(t) do n[k]=copy(v) end return n end
 function Store:UpdateAsync(key,fn)
  if self.fail then error("offline") end
  if self.failAfterCommit then error("response lost") end
  local result=fn(copy(self.records[key]))
  if result then self.records[key]=copy(result) end
  if self.ambiguous then self.failAfterCommit=true;error("committed but response lost") end
  return copy(result)
 end
 Player={UserId=42,Parent=true,attributes={}}
 function Player:Kick(message) self.Kicked=message end
 function Player:SetAttribute(k,v) self.attributes[k]=v end
 Players={GetPlayerByUserId=function(_,id) if id==42 then return Player end end}
 Marketplace={PromptGamePassPurchaseFinished={Connect=function() end},UserOwnsGamePassAsync=function() return true end}
 Money={Products={{Id=123,Scrap=500}},Passes={}}
 Services={DataStoreService={GetDataStore=function() return Store end},
 HttpService={GenerateGUID=function() return tostring(math.random()) end},RunService={IsStudio=function() return false end},MarketplaceService=Marketplace,Players=Players}
 function game:GetService(name) return Services[name] end
 function require(key) if key=="economy" then return Economy elseif key=="schema" then return Schema elseif key=="telemetry" then return {Event=function() end} elseif key=="config" then return Config elseif key=="machines" then return Definitions elseif key=="money" then return Money elseif key=="data" then return Data end end
 ''')
 lua.globals().Economy=lua.execute((ROOT/"src/shared/Config/EconomyConfig.lua").read_text())
 lua.globals().Schema=lua.execute((ROOT/"src/server/Services/ProfileSchema.lua").read_text())
 if studio: lua.execute('Services.RunService.IsStudio=function() return true end')
 if datastore_unavailable: lua.execute('Store.openCalls=0;Services.DataStoreService.GetDataStore=function() Store.openCalls=Store.openCalls+1;error("Publish this place to access DataStore") end')
 lua.globals().Data=lua.execute(source or (ROOT/'src/server/Services/PlayerDataService.lua').read_text())
 return lua

class CoreTests(unittest.TestCase):
 def test_unpublished_studio_never_opens_datastore(self):
  lua=runtime(studio=True,datastore_unavailable=True)
  lua.execute('Data:Load(Player);assert(Data:Get(Player));Data:Commit(Player);Data:Release(Player);assert(Store.openCalls==0)')
 def test_persistent_datastore_open_failure_fails_closed(self):
  lua=runtime(datastore_unavailable=True)
  lua.execute('assert(Data:Load(Player)==nil);assert(Player.Kicked);assert(Store.openCalls==3)')
 def test_original_version_reproduces_unpublished_failure(self):
  import xml.etree.ElementTree as ET
  old=ET.parse(ROOT/'build/SCRAPYARD-0.1.0.rbxlx')
  source=next(n.find('Properties/ProtectedString').text for n in old.iter('Item') if n.findtext('Properties/string')=='PlayerDataService')
  with self.assertRaisesRegex(Exception,'Publish this place'):
   runtime(studio=True,datastore_unavailable=True,source=source)
 def test_all_sources_parse(self):
  lua=LuaRuntime(unpack_returned_tuples=True)
  compile=lua.eval('function(s) local f,e=load(s); return f~=nil,e end')
  for p in (ROOT/'src').rglob('*.lua'):
   ok,error=compile(p.read_text());self.assertTrue(ok,f'{p}: {error}')
 def test_economy_and_catalog(self):
  lua=runtime();e=lua.execute((ROOT/'src/shared/Config/EconomyConfig.lua').read_text())
  self.assertEqual(e.upgradeCost(0),240)
  self.assertEqual(e.income(3,0,False),3)
  self.assertAlmostEqual(e.income(3,1,True),6.36)
  self.assertTrue(all(e.upgradeCost(i+1)>e.upgradeCost(i) for i in range(19)))
  catalog=lua.execute((ROOT/'src/shared/Config/MachineConfig.lua').read_text())
  self.assertEqual(len(catalog.Order),18)
  self.assertEqual(len(set(catalog.Order.values())),18)
 def test_load_failure_does_not_create_default_session(self):
  lua=runtime();lua.execute('Store.fail=true; assert(Data:Load(Player)==nil);assert(Data.Sessions[Player]==nil);assert(Player.Kicked)')
 def test_competing_server_cannot_load(self):
  lua=runtime();lua.execute('Data:Load(Player);Store.records.player_42.Lease.Token="other";Data.Sessions[Player]=nil;assert(Data:Load(Player)==nil)')
 def test_release_and_rejoin_preserves_progress(self):
  lua=runtime();lua.execute('Data:Load(Player);Data:Get(Player).Scrap=321;Data:Release(Player);assert(Store.records.player_42.Lease==nil);assert(Data:Load(Player).Scrap==321)')
 def test_expired_lease_cannot_overwrite(self):
  lua=runtime();lua.execute('Data:Load(Player);Store.records.player_42.Lease.Expires=0;assert(not Data:Commit(Player));assert(Store.records.player_42.Data.Scrap==0)')
 def test_failed_write_preserves_in_memory_progress(self):
  lua=runtime();lua.execute('Data:Load(Player);Data:Get(Player).Scrap=100;Store.fail=true;assert(not Data:Commit(Player));assert(Data:Get(Player).Scrap==100);Store.fail=false;assert(Data:Commit(Player));assert(Store.records.player_42.Data.Scrap==100)')
 def test_receipt_duplicate_and_rejoin(self):
  lua=runtime();lua.globals().Purchase=lua.execute((ROOT/'src/server/Services/PurchaseService.lua').read_text())
  lua.execute('''Data:Load(Player);Purchase:Start()
   local r={PlayerId=42,ProductId=123,PurchaseId="receipt-A"}
   assert(Marketplace.ProcessReceipt(r)=="granted");assert(Data:Get(Player).Scrap==500)
   assert(Marketplace.ProcessReceipt(r)=="granted");assert(Data:Get(Player).Scrap==500)
   Data:Release(Player);Data:Load(Player)
   assert(Marketplace.ProcessReceipt(r)=="granted");assert(Data:Get(Player).Scrap==500)
   assert(Marketplace.ProcessReceipt({PlayerId=42,ProductId=999,PurchaseId="bad"})=="pending")''')
 def test_receipt_failure_then_retry(self):
  lua=runtime();lua.globals().Purchase=lua.execute((ROOT/'src/server/Services/PurchaseService.lua').read_text())
  lua.execute('''Data:Load(Player);Purchase:Start();Store.fail=true
   local r={PlayerId=42,ProductId=123,PurchaseId="receipt-B"}
   assert(Marketplace.ProcessReceipt(r)=="pending");assert(Data:Get(Player)==nil)
   Store.fail=false;Data:Load(Player);assert(Marketplace.ProcessReceipt(r)=="granted");assert(Data:Get(Player).Scrap==500)''')
 def test_ambiguous_receipt_survives_autosave(self):
  lua=runtime();lua.globals().Purchase=lua.execute((ROOT/'src/server/Services/PurchaseService.lua').read_text())
  lua.execute('''Data:Load(Player);Purchase:Start();Store.ambiguous=true
   local r={PlayerId=42,ProductId=123,PurchaseId="receipt-C"}
   assert(Marketplace.ProcessReceipt(r)=="pending");assert(Data:Get(Player)==nil)
   assert(Store.records.player_42.Data.Scrap==500)
   Store.ambiguous=false;Store.failAfterCommit=false
   Data:Load(Player);assert(Data:Get(Player).Scrap==500);Data:Get(Player).Scrap=510;assert(Data:Commit(Player));assert(Data:Get(Player).Scrap==510)
   assert(Marketplace.ProcessReceipt(r)=="granted");assert(Data:Get(Player).Scrap==510)''')
 def test_unknown_schema_is_not_replaced(self):
  lua=runtime();lua.execute('Data:Load(Player);Data:Release(Player);Store.records.player_42.Data.SchemaVersion=999;assert(Data:Load(Player)==nil);assert(Store.records.player_42.Data.SchemaVersion==999)')

if __name__=='__main__': unittest.main(verbosity=2)
