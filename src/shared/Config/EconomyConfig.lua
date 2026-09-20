local E={StartingScrap=0,StartingCores=0,IncomePerLevel=0.12,CurrencyLimit=1e12,
 MaxIncomeLevel=10,MaxSlotLevel=4,BaseSlots=4,SlotsPerLevel=2,ExpansionSlots=2,
 WalkSpeed=16,CarrySpeed=12,SpeedPerLevel=1,CarryPerLevel=1,MaxWalkSpeed=20,MaxCarrySpeed=16}
E.Upgrades={
 Income={Name="Income efficiency",Branch="OPERATIONS",Base=240,Growth=2.1,Max=10,Description="+12% of base machine income per level."},
 Slots={Name="Machine capacity",Branch="OPERATIONS",Base=520,Growth=2.0,Max=4,Description="Two additional display positions."},
 Speed={Name="Walking speed",Branch="MOVEMENT",Base=360,Growth=1.7,Max=4,Description="+1 stud/sec while walking. Maximum 20."},
 Carry={Name="Carrying efficiency",Branch="MOVEMENT",Base=420,Growth=1.75,Max=4,Description="+1 stud/sec while carrying. Maximum 16."},
 Expansion={Name="Yard expansion",Branch="YARD",Base=9000,Growth=4.0,Max=3,Description="Open an annex and add two machine positions."},
}
E.UpgradeOrder={"Income","Speed","Carry","Slots","Expansion"}
function E.cost(key,level) local d=E.Upgrades[key];return d and math.floor(d.Base*d.Growth^level) end
function E.upgradeCost(level) return E.cost("Income",level) end
function E.slotCost(level) return E.cost("Slots",level) end
function E.income(base,level,double) return base*(1+E.IncomePerLevel*level)*(double and 2 or 1) end
function E.speed(upgrades,carrying)
 return carrying and math.min(E.MaxCarrySpeed,E.CarrySpeed+upgrades.Carry*E.CarryPerLevel)
  or math.min(E.MaxWalkSpeed,E.WalkSpeed+upgrades.Speed*E.SpeedPerLevel)
end
return E
