local E={StartingScrap=0,StartingCores=0,IncomePerLevel=0.06,CurrencyLimit=1e15,
 MaxIncomeLevel=10,MaxSlotLevel=3,BaseSlots=8,SlotsPerLevel=8,ExpansionSlots=8,
 WalkSpeed=16,CarrySpeed=12,SpeedPerLevel=0.5,CarryPerLevel=0.5,MaxWalkSpeed=18,MaxCarrySpeed=14}
E.Upgrades={
 Income={Name="Income efficiency",Branch="OPERATIONS",Base=180000,Growth=2.1,Max=10,Description="+6% of base machine income per level."},
 Speed={Name="Walking speed",Branch="MOVEMENT",Base=360000,Growth=1.7,Max=4,Description="+0.5 stud/sec walking. Maximum 18."},
 Carry={Name="Carrying efficiency",Branch="MOVEMENT",Base=420000,Growth=1.75,Max=4,Description="+0.5 stud/sec carrying. Maximum 14."},
 Floors={Name="Additional floor",Branch="YARD",Base=3500000,Growth=3,Max=3,Description="Build a floor with eight additional machine spots and stairs."},
}
E.UpgradeOrder={"Income","Speed","Carry","Floors"}
function E.cost(key,level) local d=E.Upgrades[key];return d and math.floor(d.Base*d.Growth^level) end
function E.upgradeCost(level) return E.cost("Income",level) end
function E.slotCost(level) return E.cost("Floors",level) end
function E.income(base,level,double,rebirths) return base*(1+E.IncomePerLevel*level)*(1+math.min(rebirths or 0,10)*0.05)*(double and 2 or 1) end
function E.rebirthCost(count) return math.floor(25000000*2.5^math.min(count,10)) end
function E.speed(upgrades,carrying)
 return carrying and math.min(E.MaxCarrySpeed,E.CarrySpeed+upgrades.Carry*E.CarryPerLevel)
  or math.min(E.MaxWalkSpeed,E.WalkSpeed+upgrades.Speed*E.SpeedPerLevel)
end
return E
