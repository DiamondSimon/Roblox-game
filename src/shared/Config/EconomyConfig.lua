local Economy = {}
function Economy.upgradeCost(level) return math.floor(100 * 1.65 ^ level) end
function Economy.slotCost(level) return math.floor(250 * 1.8 ^ level) end
function Economy.income(base, level, doubleScrap)
 return base * (1 + 0.15 * level) * (doubleScrap and 2 or 1)
end
Economy.MaxIncomeLevel = 20
Economy.MaxSlotLevel = 7
Economy.CurrencyLimit = 1e12
return Economy
