"""Seeded planning scenarios, not measured retention. Independent runs at each rebirth level."""
from pathlib import Path
import random,statistics,json
from lupa import LuaRuntime
ROOT=Path(__file__).resolve().parents[1]
lua=LuaRuntime();lua.execute('Color3={fromRGB=function() return {} end}')
def config(name):return lua.execute((ROOT/f'src/shared/Config/{name}.lua').read_text())
E=config('EconomyConfig');M=config('MachineConfig');B=config('BoostConfig');R=config('RewardsConfig')
ids=list(M.Order.values());income={x:M.ById[x].BaseIncome for x in ids};gate={x:M.ById[x].RequiredRebirths for x in ids};raw={x:M.ById[x].SpawnWeight for x in ids};rarity={x:M.ById[x].Rarity for x in ids}
scenarios=[('FREE',1,False,0,False,False,False),('2X',2,False,0,False,False,False),('VIP',1,True,0,False,False,False),('2X + VIP',2,True,0,False,False,False),('2X + VIP + best pet',2,True,.2,False,False,False),('Paid + pet + 15m income',2,True,.2,True,False,False),('Maximum sustained stress',2,True,.2,True,True,True)]
plan=['Income','Speed','Carry','Floors','Income','Speed','Carry'];prices={k:[E.cost(k,n) for n in range(4)] for k in set(plan)}
rows=[]
for name,paid,vip,pet,temp,sustained,extras in scenarios:
 for rebirth in range(10):
  weights=[raw[x]*(2 if extras and rarity[x]!='Common' and gate[x]<=rebirth else 1) for x in ids]
  samples=[];target=E.rebirthCost(rebirth)
  for seed in range(100):
   rng=random.Random(seed);balance=0;inventory=[];levels=dict.fromkeys(plan,0);cursor=0;first=floor=None;reached=False;rate=0
   for tick in range(1,1441):
    t=tick*15
    event=max(R.RushMultiplier if t%R.RushPeriod>=R.RushPeriod-R.RushDuration else 1,1.25 if extras else 1)
    multiplier=paid*(B.VIPIncome if vip else 1)*(1+pet)*(1+.05*rebirth)*(2 if temp and (sustained or t<=900) else 1)*event
    rate=sum(income[x] for x in inventory)*(1+.06*levels['Income'])*multiplier
    balance+=rate*15
    if t>=75 and (t-75)%75==0:
     candidates=[x for x in rng.choices(ids,weights=weights,k=3) if gate[x]<=rebirth]
     if candidates:
      item=max(candidates,key=income.get)
      if len(inventory)<8*(1+levels['Floors']+int(extras)):inventory.append(item)
      else:
       worst=min(inventory,key=income.get)
       if income[item]>income[worst]:inventory.remove(worst);inventory.append(item)
     if cursor<len(plan):
      key=plan[cursor];cost=prices[key][levels[key]]
      if balance>=cost:
       balance-=cost;levels[key]+=1;cursor+=1
       if first is None:first=t
       if key=='Floors':floor=t
     elif balance>=target:reached=True;break
   samples.append((first or 21615,floor or 21615,t if reached else 21615,rate))
  rows.append({'Scenario':name,'RebirthFrom':rebirth,'FirstUpgradeMinutes':statistics.median(x[0] for x in samples)/60,'FirstFloorMinutes':statistics.median(x[1] for x in samples)/60,'RebirthMinutes':statistics.median(x[2] for x in samples)/60,'ScrapPerSecondAtEnd':round(statistics.median(x[3] for x in samples)), 'RebirthCost':target})
(ROOT/'docs/monetization-simulation.json').write_text(json.dumps(rows,indent=2)+'\n')
lines=['# 0.3.5 monetization stress test','','100 seeds per scenario per rebirth level. Independent fresh runs at each level; levels 1–9 include the permanent rebirth bonus. No inherited Scrap or junk. First delivery 75 seconds, then every 75 seconds, best of three weighted candidates with eligibility checks. One purchase per delivery: Income, Speed, Carry, Floors, Income, Speed, Carry, then save. Maximum six-hour horizon. Pets are assumed already owned (not purchased during the run). These are scenario estimates, not real retention or optimal strategies.','','Temporary boost lasts 15 minutes; expires offline in the actual game. Sustained stress deliberately assumes unlimited Core funding for continuous boosts, best pet, all passes, +8 slots, continuous server income, and maximum 2× eligible rare weighting on every roll. Real multiplayer luck sponsorship is round-robin, so this is optimistic. Event and server income use max(), not multiplication; personal luck pass and temporary luck do not stack, and combined personal/server luck caps at 2×. No paid item bypasses rarity requirements.','','| Scenario | First upgrade | First floor | First rebirth | Scrap/sec at first rebirth |','|---|---:|---:|---:|---:|']
for row in rows:
 if row['RebirthFrom']==0:lines.append(f"| {row['Scenario']} | {row['FirstUpgradeMinutes']:.1f}m | {row['FirstFloorMinutes']:.1f}m | {row['RebirthMinutes']:.1f}m | {row['ScrapPerSecondAtEnd']:,} |")
lines+=['','## Subsequent run medians','','| Starting rebirth | Free run | Sustained maximum run | Cost |','|---|---:|---:|---:|']
for level in range(10):
 free=next(r for r in rows if r['Scenario']=='FREE' and r['RebirthFrom']==level);top=next(r for r in rows if r['Scenario']=='Maximum sustained stress' and r['RebirthFrom']==level)
 lines.append(f"| {level} | {free['RebirthMinutes']:.1f}m | {top['RebirthMinutes']:.1f}m | {free['RebirthCost']:,} |")
lines+=['','Summing independent medians is only a rough full-progression indicator, not a median of complete player histories. Free estimate: %.1f hours; sustained maximum: %.1f hours.'%(sum(r['RebirthMinutes'] for r in rows if r['Scenario']=='FREE')/60,sum(r['RebirthMinutes'] for r in rows if r['Scenario']=='Maximum sustained stress')/60),'','The formula-only maximum at rebirth 10 is 2 × 1.15 × 1.20 × 1.50 × 2 × 1.25 = 10.35 times unupgraded base production, before the +60% income-upgrade cap. Capacity and luck advantages alter the inventory separately. First-run maximum without a rebirth bonus is 6.9× before income upgrades. No five-minute complete-progression result in these scenarios. This does not prove an optimized live strategy cannot outperform the model.','']
(ROOT/'docs/ECONOMY_0.3.5.md').write_text('\n'.join(lines))
print('\n'.join(lines))
