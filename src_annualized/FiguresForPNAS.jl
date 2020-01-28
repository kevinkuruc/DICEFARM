using Plots
include("ConsEquiv.jl")
include("DICEFARM_Annual.jl")
DICEFARM = create_dice_farm()
run(DICEFARM)
BaseTemp = DICEFARM[:co2_cycle, :T]
DICELength = length(DICEFARM[:farm, :Beef])

OrigBeef = DICEFARM[:farm, :Beef]
OrigDairy = DICEFARM[:farm, :Dairy]
OrigPork = DICEFARM[:farm, :Pork]
OrigPoultry = DICEFARM[:farm, :Poultry]
OrigEggs = DICEFARM[:farm, :Eggs]
OrigSheepGoat = DICEFARM[:farm, :SheepGoat]

VeganDICE = create_dice_farm()
set_param!(VeganDICE, :farm, :Beef, [OrigBeef[1:4]; zeros(DICELength-4)])
set_param!(VeganDICE, :farm, :Dairy, [OrigDairy[1:4]; zeros(DICELength-4)])
set_param!(VeganDICE, :farm, :Poultry, [OrigPoultry[1:4]; zeros(DICELength-4)])
set_param!(VeganDICE, :farm, :Pork, [OrigPork[1:4]; zeros(DICELength-4)])
set_param!(VeganDICE, :farm, :Eggs, [OrigEggs[1:4]; zeros(DICELength-4)])
set_param!(VeganDICE, :farm, :SheepGoat, [OrigSheepGoat[1:4]; zeros(DICELength-4)])
run(VeganDICE)
VeganTemp = VeganDICE[:co2_cycle, :T]
plotT = 2120
t = collect(2020:1:plotT)
TempDiff = BaseTemp[2020+length(t)-1765] - VeganTemp[2020+length(t)-1765]
println("Temp Diff is $TempDiff")
plot(t, [BaseTemp[2020-1765+1:2020+length(t)-1765] VeganTemp[2020-1765+1:2020+length(t)-1765]], linewidth=2, linecolor=[:black :green], label=["BAU" "Vegan"], legend=:topleft, linestyle=[:solid :dash])
savefig("VeganTemp.pdf")

BeefPulse = copy(OrigBeef)
DairyPulse = copy(OrigDairy)
PorkPulse = copy(OrigPork)
PoultryPulse = copy(OrigPoultry)
EggsPulse = copy(OrigEggs)
SheepGoatPulse = copy(OrigSheepGoat)

BeefPulse[4] = OrigBeef[4] + 1.2*(4.8) 
DairyPulse[4] = OrigDairy[4] + 1.2*(8)
PorkPulse[4] = OrigPork[4]  + 1.2*(2.7)
PoultryPulse[4] = OrigPoultry[4] + 1.2*(6.7)
EggsPulse[4] = OrigEggs[4]  + 1.2*(1.5)
SheepGoatPulse[4] = OrigSheepGoat[4] + 1.2*(.06)

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

##Model with Gasoline Pulse
GasPulse = create_dice_farm()
T = DICELength
pulse = zeros(T)
pulse[4] = 4.6*1e-9
set_param!(GasPulse, :emissions, :CO2Marg, pulse)
run(GasPulse)
GasIRF = GasPulse[:co2_cycle, :T] - BaseTemp
plot(t, [VeganIRF[2020-1765+1:2020+length(t)-1765] GasIRF[2020-1765+1:2020+length(t)-1765]], legend=:topright, label=["Diet IRF" "Driving IRF"], linewidth=2, linestyle=[:solid :dash], color=[:green :black])
savefig("VeganIRF.pdf")

###Social cost computation
#W0 = VeganPulse[:welfare, :UTILITY]
#Baseline = create_dice_farm()
#SCVeg = ConsEquiv(Baseline, W0)
#println("Starting SCs")
##Now do 1 Social Cost for each of Beef, Dairy, Pork, Poultry, Eggs, SheepGoat
#Meats = [:Beef, :Dairy, :Pork, :Poultry, :Eggs, :SheepGoat]
#Origs = [OrigBeef, OrigDairy, OrigPork, OrigPoultry, OrigEggs, OrigSheepGoat]
#SCs   = zeros(length(Meats))
#i = collect(1:1:length(Meats))
#for (meat, O, i) in zip(Meats, Origs, i)
#	tempModel = create_dice_farm();
#	Pulse = copy(O)
#	Pulse[5] = Pulse[5] + 1.0 #add 1 kg of protein
#	set_param!(tempModel, :farm, meat, Pulse)
#	run(tempModel)
#	W = tempModel[:welfare, :UTILITY]
#	Baseline = getcalibratedDICEFARM();
#	SCs[i] = .02*ConsEquiv(Baseline, W)
#end
#println("Done with SCs")


##Isocost curves
#include("CalibratingDICEFARM.jl")
#DICEFARM = getcalibratedDICEFARM()

#isotemps = [2 2.5 3]
#MReduc = collect(0:.01:1)
#EIndReduc = zeros(length(MReduc), length(isotemps))
#for MAXTEMP = 1:length(isotemps)
#	for j = 1:length(MReduc)
#		global CO2step = .005
#		global Co2Reduc = 1 + CO2step
#		maxtemp = 1.
#			while maxtemp<isotemps[MAXTEMP]
#			Co2Reduc = Co2Reduc - CO2step
#			m = getcalibratedDICEFARM();
#			set_param!(m, :farm, :MeatReduc, MReduc[j])
#			set_param!(m, :co2emissions, :EIndReduc, Co2Reduc)
#			run(m) 
#			temp = m[:climatedynamics, :TATM]
#			maxtemp = temp[22]  #temp in 2120 years
#			end
#	EIndReduc[j, MAXTEMP] = Co2Reduc
#	end
#end


#plot(MReduc, EIndReduc, color=[:black], lw=2, label=["2 Degrees" "2.5 Degrees" "3 Degrees"], xlabel="Percent Animal Reduction", ylabel="Percent Industrial Reduction", linestyle=[:solid :dash :dot])


