using Plots
include("CalibratingDICEFARM.jl")
DICEFARM = getcalibratedDICEFARM()
run(DICEFARM)
OurTemp = DICEFARM[:climatedynamics, :TATM]
#OurForc = DICEFARM[:forcing, :FN2o] + DICEFARM[:forcing, :FMeth] + DICEFARM[:forcing, :FMixed] + DICEFARM[:forcing, :FTrop] + DICEFARM[:forcing, :FStrat] + DICEFARM[:forcing, :FSolar] + 3*DICEFARM[:forcing, :FBC] + DICEFARM[:forcing, :FAero] + DICEFARM[:forcing, :FWater]

NoAnimals = getcalibratedDICEFARM()
T = length(OurTemp)
set_param!(NoAnimals, :farm, :Beef, zeros(T))
set_param!(NoAnimals, :farm, :Dairy, zeros(T))
set_param!(NoAnimals, :farm, :Poultry, zeros(T))
set_param!(NoAnimals, :farm, :Pork, zeros(T))
run(NoAnimals)
NoAnimalsTemp = NoAnimals[:climatedynamics, :TATM]

include("MimiDICE2016.jl")
MimiDICE = getdiceexcel()
set_param!(MimiDICE, :radiativeforcing, :fex0, 1.5)
set_param!(MimiDICE, :radiativeforcing, :fex1, 0.95)
run(MimiDICE)
DICEtemp = MimiDICE[:climatedynamics, :TATM]
#DICEForc = MimiDICE[:radiativeforcing, :FORCOTH]


t = collect(2015:5:2200)
plot(t, [OurTemp[1:length(t)] DICEtemp[1:length(t)] NoAnimalsTemp[1:length(t)]], label=["Our Model" "DICE2016" "Vegan World"], linewidth=[2.5 1 2.5], linestyle=[:solid :dash :solid], color=[:red :black :green], legend=:topleft, ylabel="Temp. Increase (C)")
#plot(t, [OurForc[1:length(t)] DICEForc[1:length(t)]], label=["Our Model" "DICE2016"], linewidth=[2.5 2.5], linestyle=[:solid :dash], legend=:topleft)


##Try Changing just other-forcings
#MimiDICENewForc = getdiceexcel()
#set_param!(MimiDICENewForc, :radiativeforcing, :fex0, 1.5)
#set_param!(MimiDICENewForc, :radiativeforcing, :fex1, 0.95)
#run(MimiDICENewForc)
#DICEtemp = MimiDICENewForc[:climatedynamics, :TATM]
#DICEForc = MimiDICENewForc[:radiativeforcing, :FORCOTH]

#plot(t, [OurTemp[1:length(t)] DICEtemp[1:length(t)]], label=["Our Model" "DICE2016"], linewidth=[2.5 2.5], linestyle=[:solid :dash], legend=:topleft)
#plot(t, [OurForc[1:length(t)] DICEForc[1:length(t)]], label=["Our Model" "DICE2016"], linewidth=[2.5 2.5], linestyle=[:solid :dash], legend=:topleft)


#plot(t, Diff[1:length(t)], label=["Temp Error Through 2100"], linewidth=[2.5], color=[:red])