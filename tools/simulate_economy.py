"""V3 planning scenarios, not Roblox playtest measurements. Uses shipped Lua configs."""
from pathlib import Path
import random,statistics,json
from lupa import LuaRuntime
ROOT=Path(__file__).resolve().parents[1]
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute('Color3={fromRGB=function() return {} end}')
E=lua.execute((ROOT/'src/shared/Config/EconomyConfig.lua').read_text())
M=lua.execute((ROOT/'src/shared/Config/MachineConfig.lua').read_text())
S=lua.execute((ROOT/'src/shared/Config/SpinConfig.lua').read_text())
ids=list(M.Order.values());weights=[M.ById[x].SpawnWeight for x in ids]
incomes={id:M.ById[id].BaseIncome for id in ids}
profiles={'New':(90,100,1),'Average':(65,75,3),'Efficient':(50,55,6)}
plan=['Income','Speed','Carry','Floors','Income','Speed','Carry']
def simulate(profile,double,seed,loss=0):
 first,interval,choices=profiles[profile];rng=random.Random(seed)
 balance=0.;inventory=[];levels={k:0 for k in E.UpgradeOrder.values()};purchases=[];cursor=0;rebirth=None
 for t in range(1,3601):
  balance+=E.income(sum(incomes[x] for x in inventory),levels['Income'],double,0)
  if t>=first and (t-first)%interval==0:
   candidates=rng.choices(ids,weights=weights,k=choices)
   item=max(candidates,key=lambda x:incomes[x])
   if rng.random()>=loss:
    capacity=8*(1+levels['Floors'])
    if len(inventory)<capacity:inventory.append(item)
    else:
     index=min(range(len(inventory)),key=lambda i:incomes[inventory[i]])
     if incomes[item]>incomes[inventory[index]]:inventory[index]=item
   if cursor<len(plan):
    key=plan[cursor];cost=E.cost(key,levels[key])
    if balance>=cost:balance-=cost;levels[key]+=1;purchases.append((t,key));cursor+=1
   elif balance>=E.rebirthCost(0) and rebirth is None:rebirth=t
 return {'FirstUpgrade':purchases[0][0] if purchases else None,'FirstFloor':next((t for t,k in purchases if k=='Floors'),None),'RebirthEligible':rebirth,'Scrap60m':round(balance,2),'Machines':len(inventory)}
results={};lines=['# V0.3 economy scenarios','','Generated from current Lua configs with 200 seeded runs per scenario over 60 minutes. These are synthetic planning cases, not retention or observed players.','','Fresh inventory and balances are empty. New / Average / Efficient first deliveries: 90 / 65 / 50 seconds; later deliveries every 100 / 75 / 55 seconds, selecting among 1 / 3 / 6 weighted samples. Capacity fills then weakest items are replaced. One upgrade per delivery using this policy: '+', '.join(plan)+', then save for rebirth. Shop visits are folded into the assumed intervals; no additional teleport delay is modeled. Movement upgrade benefits are not modeled. No machine sale income, paid Core income, or protected starter. Free spin adds only Cores. Rebirth eligibility is recorded without actually resetting the run.','','Eight-player scarcity and PvP are not engine-simulated. The loss stress case discards 25% of attempted deliveries; it does not model a PvP equilibrium. Selection can overestimate contested-server income.','','| Scenario | First upgrade median | First floor median | Rebirth eligible median | Rebirth reached within hour |','|---|---:|---:|---:|---:|']
for name in profiles:
 for double in [False,True]:
  losses=[0,.25] if name=='Average' else [0]
  for loss in losses:
   key=f'{name} / {"2X" if double else "free"} / {int(loss*100)}% loss'
   runs=[simulate(name,double,seed,loss) for seed in range(200)]
   summary={field:statistics.median([r[field] if r[field] is not None else 3601 for r in runs]) for field in runs[0]}
   summary['RebirthReached']=sum(r['RebirthEligible'] is not None for r in runs)
   results[key]=summary
   times=[('>60 min' if summary[f]>3600 else f'{summary[f]/60:.1f} min') for f in ['FirstUpgrade','FirstFloor','RebirthEligible']]
   lines.append(f'| {key} | '+ ' | '.join(times)+f' | {summary["RebirthReached"]}/200 |')
lines+=['','## Exact tuning','','Income = sum(base machine income) × (1 + 0.06 × income level) × (1 + 0.05 × rebirth count) × pass multiplier. Rebirth capped at 10; pass multiplier 1 or 2. No starter income. Walking 16 → 18, carrying 12 → 14 in +0.5 increments. Eight ground spots; each of three floor upgrades adds eight; the extra-space pass adds a whole eight-slot floor, maximum 40 slots.','','| Upgrade | Base Scrap | Price growth | Max levels |','|---|---:|---:|---:|']
for key in E.UpgradeOrder.values():
 d=E.Upgrades[key];lines.append(f'| {key} | {d.Base} | {d.Growth} | {d.Max} |')
spin_mean=sum(reward.Cores*reward.Weight/100 for reward in S.Rewards.values())
lines+=['',f'Free UTC daily spin: 5 Cores (60%), 10 (30%), 20 (10%); expected reward {spin_mean:g} Cores/day. Four daily quests still offer up to 40/day, so max 60/day and expected 48/day with all contracts. Cosmetics cost 30, 70 and 120 (220 total); average-budget estimate ~4.6 full daily sets, not a guarantee of random outcomes. No paid rerolls.','','Selling: one-time Scrap = base income × 20, forfeiting passive production. Without multipliers, keeping the machine earns the same amount in 20 seconds; selling is for liquidating unwanted inventory, not an income upgrade. Values are configured in MachineConfig.','','First rebirth requires 25,000 unspent Scrap; next cost floor(25,000 × 2.5^rebirths). Rebirth resets run progress as documented in V0.3_FEATURES.md. These initial costs need real playtest tuning; no promised optimal pacing.','']
(ROOT/'docs/ECONOMY_V3.md').write_text('\n'.join(lines))
(ROOT/'docs/economy-simulation.json').write_text(json.dumps(results,indent=2)+'\n')
for key,value in results.items():print(key,value)
