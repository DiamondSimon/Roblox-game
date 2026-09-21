return {
 Enabled=false,
 Passes={
  {Key="DoubleScrap",Id=0,Name="2X SCRAP",Description="PERMANENT • Double passive machine income."},
  {Key="ExtraSlots",Id=0,Name="+8 MACHINE SLOTS",Description="PERMANENT • Eight extra display positions."},
 },
 Products={
  {Key="Cores80",Id=0,Name="80 CORES",Description="80 Cores for exact-price yard cosmetics.",Currency="Cores",Amount=80},
  {Key="Cores250",Id=0,Name="250 CORES",Description="250 Cores. Also earn Cores from daily quests.",Currency="Cores",Amount=250},
  {Key="Cores600",Id=0,Name="600 CORES",Description="600 Cores. Cosmetic catalog will expand.",Currency="Cores",Amount=600,Hidden=true},
  {Key="Cores1400",Id=0,Name="1,400 CORES",Description="Future catalog pack; hidden until more useful sinks exist.",Currency="Cores",Amount=1400,Hidden=true},
  {Key="Cores3000",Id=0,Name="3,000 CORES",Description="Future catalog pack; hidden until more useful sinks exist.",Currency="Cores",Amount=3000,Hidden=true},
 },
 -- Preserve fulfillment if real legacy IDs were ever configured; never reuse them for Cores.
 LegacyProducts={
  {Key="SmallScrap",Id=0,Currency="Scrap",Amount=500000},
  {Key="MediumScrap",Id=0,Currency="Scrap",Amount=2000000},
  {Key="LargeScrap",Id=0,Currency="Scrap",Amount=6000000},
 },
}
