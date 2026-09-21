"""Independent run estimates by rebirth level; not observed retention or multiplayer simulation."""
from pathlib import Path
import random,statistics,json
from lupa import LuaRuntime
ROOT=Path(__file__).resolve().parents[1]
lua=LuaRuntime();lua.execute('Color3={fromRGB=function() return {} end}')
E=lua.execute((ROOT/'src/shared/Config/EconomyConfig.lua').read_text());M=lua.execute((ROOT/'src/shared/Config/MachineConfig.lua').read_text())
ids=list(M.Order.values());weights=[M.ById[x].SpawnWeight for x in ids];income={x:M.ById[x].BaseIncome for x in ids};gate={x:M.ById[x].RequiredRebirths for x in ids}
plan=['Income','Speed','Carry','Floors','Income','Speed','Carry']
results=[]
for level in range(10):
 times=[]
 for seed in range(200):
  rng=random.Random(seed);balance=0;inv=[];levels=dict.fromkeys(plan,0);cursor=0;cost=E.rebirthCost(level)
  for tick in range(1,1441):
   t=tick*15
   balance+=sum(income[x] for x in inv)*(1+.06*levels['Income'])*(1+.05*level)*(1.25 if t%600>=480 else 1)*15
   if t>=75 and (t-75)%75==0:
    choices=[x for x in rng.choices(ids,weights=weights,k=3) if gate[x]<=level]
    if choices:
     item=max(choices,key=income.get)
     if len(inv)<8*(1+levels['Floors']):inv.append(item)
     else:
      worst=min(inv,key=income.get)
      if income[item]>income[worst]:inv.remove(worst);inv.append(item)
    if cursor<len(plan):
     k=plan[cursor];price=E.cost(k,levels[k])
     if balance>=price:balance-=price;levels[k]+=1;cursor+=1
    elif balance>=cost:break
  times.append(t if balance>=cost and cursor==len(plan) else 21615)
 results.append({'RebirthFrom':level,'Cost':E.rebirthCost(level),'MedianMinutes':statistics.median(times)/60,'P10Minutes':sorted(times)[19]/60,'P90Minutes':sorted(times)[179]/60,'ReachedWithin6h':sum(t<=21600 for t in times)})
print(json.dumps(results,indent=2))
(ROOT/'docs/rebirth-simulation.json').write_text(json.dumps(results,indent=2)+'\n')
