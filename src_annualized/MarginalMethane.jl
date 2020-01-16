

using Plots
include("DICEFARM.jl")

T=100
MargEmissMeth = zeros(T)
MargEmissMeth[2] = 100*1e9 #add 10 megatons of methane for next 5 years

MargEmissCo2 = zeros(T)
MargEmissCo2[2] = 1  #Add a Gigaton of Carbon 

Orig = getDICEFARM()
run(Orig)
OrigTemps = Orig[:climatedynamics, :TATM]

NewMethane = Orig[:concentrations, :MethERCP] + MargEmissMeth
NewCo2 	   = Orig[:co2emissions, :Co2EFarm] + MargEmissCo2

MargModelMeth = getDICEFARM()
set_param!(MargModelMeth, :concentrations, :MethERCP, NewMethane)
run(MargModelMeth)

NewTempsMeth = MargModelMeth[:climatedynamics, :TATM]
TempDiffMeth = NewTempsMeth-OrigTemps

MargModelCo2 = getDICEFARM()
set_param!(MargModelCo2, :co2emissions, :Co2EFarm, NewCo2)
run(MargModelCo2)

NewTempsCo2 = MargModelCo2[:climatedynamics, :TATM]
TempDiffCo2 = NewTempsCo2-OrigTemps

TforPlot = 2200
t = collect(2020:5:TforPlot)

plot(t, [TempDiffMeth[2:length(t)+1] TempDiffCo2[2:length(t)+1]], label=["Methane Pulse" "CO2 Pulse"], linewidth=[2 2], linestyle=[:solid :dash], color=[:green :black], ylabel="Temperature Increase (C)")
savefig("MethaneVsCo2Pulse.pdf")