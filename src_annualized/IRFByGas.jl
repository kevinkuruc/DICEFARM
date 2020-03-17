using Plots
using Roots
include("DICEFARM_Annual.jl")
include("VegSocialCosts.jl")
DICEFARM = create_dice_farm()
run(DICEFARM)
BaseTemp = DICEFARM[:co2_cycle, :T]
W0			= DICEFARM[:welfare, :UTILITY]
BaseCo2		= DICEFARM[:emissions, :E]
BaseMeth 	= DICEFARM[:emissions, :MethE]
BaseN2o 	= DICEFARM[:emissions, :N2oE]
DICELength = length(DICEFARM[:farm, :Beef])
TwentyTwenty = 2020-1764

# ----- First get SCC since I'll need that ---- #
MargCons = create_dice_farm()
set_param!(MargCons, :neteconomy, :CEQ, 1e-9)  #drop cons by 1000 globally (1e-9 trillions)
run(MargCons)
W1 = MargCons[:welfare, :UTILITY]
dWdC = W0 - W1  #per thousand dollars

#hit with CO2 pulse of 1000 tonnes
MargCO2 = create_dice_farm()
pulse = 1e-6  #thousand tons is 1e-6 gigatonnes; period 6 is 2020 for this variable
set_param!(MargCO2, :emissions, :Co2Pulse, pulse)
run(MargCO2)
dWdE = W0 - MargCO2[:welfare, :UTILITY]
SCC = dWdE/dWdC

# ----- Plot against Vegan World ------ #
OrigBeef = DICEFARM[:farm, :Beef]
OrigDairy = DICEFARM[:farm, :Dairy]
OrigPork = DICEFARM[:farm, :Pork]
OrigPoultry = DICEFARM[:farm, :Poultry]
OrigEggs = DICEFARM[:farm, :Eggs]
OrigSheepGoat = DICEFARM[:farm, :SheepGoat]

BeefPulse = copy(OrigBeef)
DairyPulse = copy(OrigDairy)
PorkPulse = copy(OrigPork)
PoultryPulse = copy(OrigPoultry)
EggsPulse = copy(OrigEggs)
SheepGoatPulse = copy(OrigSheepGoat)

BeefPulse[6] = OrigBeef[6] + 1000*(4.5) 				#Add pulse to year 2020
DairyPulse[6] = OrigDairy[6] + 1000*(8)
PorkPulse[6] = OrigPork[6]  + 1000*(2.7)
PoultryPulse[6] = OrigPoultry[6] + 1000*(6.5)
EggsPulse[6] = OrigEggs[6]  + 1000*(1.6)
SheepGoatPulse[6] = OrigSheepGoat[6] + 1000*(.06)

#----- Model With Vegan Pulse ----------- #
#Model With Vegan Pulse
VeganPulse = create_dice_farm()
set_param!(VeganPulse, :farm, :Beef, BeefPulse)
set_param!(VeganPulse, :farm, :Dairy, DairyPulse)
set_param!(VeganPulse, :farm, :Poultry, PoultryPulse)
set_param!(VeganPulse, :farm, :Pork, PorkPulse)
set_param!(VeganPulse, :farm, :Eggs, EggsPulse)
set_param!(VeganPulse, :farm, :SheepGoat, SheepGoatPulse)
run(VeganPulse)
VeganIRF = VeganPulse[:co2_cycle, :T] - BaseTemp
Co2Pulse = VeganPulse[:emissions, :E][TwentyTwenty] - BaseCo2[TwentyTwenty]
MethPulse = VeganPulse[:emissions, :MethE][TwentyTwenty] - BaseMeth[TwentyTwenty]
N2oPulse = VeganPulse[:emissions, :N2oE][TwentyTwenty] - BaseN2o[TwentyTwenty]
GWP = 1e6*(Co2Pulse + MethPulse*1e-3*25 + N2oPulse*1e-3*298)
GWPcost = SCC*GWP
println("Our cost under GWP estimates: $GWPcost")


#----- Vegan Pulse CO2 Only ------------- #
VeganPulse_CO2 = create_dice_farm()
set_param!(VeganPulse_CO2, :emissions, :Co2Pulse, Co2Pulse)
run(VeganPulse_CO2)
VeganIRF_CO2 = VeganPulse_CO2[:co2_cycle, :T] - BaseTemp


# ----- Vegan Pulse Methane Only --------- #
VeganPulse_Meth = create_dice_farm()
set_param!(VeganPulse_Meth, :emissions, :MethPulse, MethPulse)
run(VeganPulse_Meth)
VeganIRF_Meth = VeganPulse_Meth[:co2_cycle, :T] - BaseTemp

# ----- Vegan Pulse N2O Only --------- #
VeganPulse_N2O = create_dice_farm()
set_param!(VeganPulse_N2O, :emissions, :N2oPulse, N2oPulse)
run(VeganPulse_N2O)
VeganIRF_N2O = VeganPulse_N2O[:co2_cycle, :T] - BaseTemp

plotT = 2120
t = collect(2020:1:plotT)
plot(t, [VeganIRF_CO2[TwentyTwenty:TwentyTwenty+length(t)-1] VeganIRF_Meth[TwentyTwenty:TwentyTwenty+length(t)-1] VeganIRF_N2O[TwentyTwenty:TwentyTwenty+length(t)-1]], legend=:topright, label=["CO2" "CH4" "N20"], linewidth=2, linestyle=[:dot :solid :dash], color=[:green :orange :black])

plot(t, [VeganIRF[TwentyTwenty:TwentyTwenty+length(t)-1]], legend=:topright, label=["Total"], linewidth=2, linestyle=[:solid], color=[:black])