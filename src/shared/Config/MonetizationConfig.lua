return {
 -- Enable only after private-server receipt and rejoin tests pass.
 Enabled = false,
 Passes = {
  {Key="DoubleScrap", Id=0, Name="2X SCRAP", Description="Double passive machine income. Forever."},
  {Key="ExtraSlots", Id=0, Name="+5 MACHINE SLOTS", Description="Five additional machine display slots."},
 },
 Products = {
  {Key="SmallScrap", Id=0, Name="500 SCRAP", Description="A fixed 500 Scrap top-up.", Scrap=500},
  {Key="MediumScrap", Id=0, Name="2,000 SCRAP", Description="A fixed 2,000 Scrap top-up.", Scrap=2000},
  {Key="LargeScrap", Id=0, Name="6,000 SCRAP", Description="A fixed 6,000 Scrap top-up.", Scrap=6000},
 },
 -- VIP, timed boosts, shields and paid luck are intentionally not offered yet.
}
