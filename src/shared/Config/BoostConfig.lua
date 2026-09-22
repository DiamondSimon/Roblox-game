local B={VIPIncome=1.15,VIPDailyCores=5,LuckWeight=1.5,MaxLuck=2,Order={"Income","Luck","ServerLuck","ServerIncome"}}
B.Items={
 Income={Name="2X INCOME • 15 MIN",Cost=30,Seconds=900,Scope="Personal",Multiplier=2,Description="Double your passive Scrap. Stacks with Earnings and VIP."},
 Luck={Name="LUCK • 15 MIN",Cost=25,Seconds=900,Scope="Personal",Multiplier=1.5,Description="Improve eligible salvage weighting on your sponsored belt rolls. Shared junk stays contested."},
 ServerLuck={Name="SERVER LUCK • 15 MIN",Cost=80,Seconds=900,Scope="Server",Multiplier=1.5,Description="Improve uncommon+ weighting on the shared belt for everyone. Rebirth locks remain."},
 ServerIncome={Name="SERVER SCRAP • 15 MIN",Cost=100,Seconds=900,Scope="Server",Multiplier=1.25,Description="Everyone earns +25%. Uses the stronger of this and Scrap Rush; they do not multiply."},
}
function B.active(d,key,now) return d.Boosts and (d.Boosts[key] or 0)>(now or os.time()) end
function B.income(d,vip,serverMultiplier,rushMultiplier,now)
 return (vip and B.VIPIncome or 1)*(B.active(d,"Income",now) and 2 or 1)*math.max(serverMultiplier or 1,rushMultiplier or 1)
end
return B
