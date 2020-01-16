using Plots
include("CalibratingDICEFARM.jl")
DICEFARM = getcalibratedDICEFARM()
run(DICEFARM)
BaselineTemp = DICEFARM[:climatedynamics, :TATM]
#OurForc = DICEFARM[:forcing, :FN2o] + DICEFARM[:forcing, :FMeth] + DICEFARM[:forcing, :FMixed] + DICEFARM[:forcing, :FTrop] + DICEFARM[:forcing, :FStrat] + DICEFARM[:forcing, :FSolar] + 3*DICEFARM[:forcing, :FBC] + DICEFARM[:forcing, :FAero] + DICEFARM[:forcing, :FWater]

NoAnimals = getcalibratedDICEFARM()
T = length(BaselineTemp)
set_param!(NoAnimals, :farm, :Beef, zeros(T))
set_param!(NoAnimals, :farm, :Dairy, zeros(T))
set_param!(NoAnimals, :farm, :Poultry, zeros(T))
set_param!(NoAnimals, :farm, :Pork, zeros(T))
run(NoAnimals)
NoAnimalsTemp = NoAnimals[:climatedynamics, :TATM]

NoIndustry = getcalibratedDICEFARM()
set_param!(NoIndustry, :co2emissions, :EIndReduc, 1.0)
run(NoIndustry)
NoIndustryTemp = NoIndustry[:climatedynamics, :TATM]

t = collect(2015:5:2115)
tempT = length(t)

plot(t, [BaselineTemp[1:tempT] NoAnimalsTemp[1:tempT] NoIndustryTemp[1:tempT]], label=["Base" "Vegan" "NoIndustry"], color=[:red :green :black], linewidth=[1.3 1.3 1.3], legend=:topleft)

