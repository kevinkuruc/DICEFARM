using Plots
include("ConsEquiv.jl")
include("DICEFARM_Annual.jl")
DICEFARM = create_dice_farm()
run(DICEFARM)
BaseTemp = DICEFARM[:co2_cycle, :T]
BaseWelfare = DICEFARM[:welfare, :UTILITY]
DICELength = length(DICEFARM[:farm, :Beef])
NowIndex = 2020-1765 + 1


OrigBeef = DICEFARM[:farm, :Beef]
OrigDairy = DICEFARM[:farm, :Dairy]
OrigPork = DICEFARM[:farm, :Pork]
OrigPoultry = DICEFARM[:farm, :Poultry]
OrigEggs = DICEFARM[:farm, :Eggs]
OrigSheepGoat = DICEFARM[:farm, :SheepGoat]

VeganDICE = create_dice_farm()
set_param!(VeganDICE, :farm, :Beef, [OrigBeef[1:6]; zeros(DICELength-6)])  			#Keep 2015-2019 consumption
set_param!(VeganDICE, :farm, :Dairy, [OrigDairy[1:6]; zeros(DICELength-6)])
set_param!(VeganDICE, :farm, :Poultry, [OrigPoultry[1:6]; zeros(DICELength-6)])
set_param!(VeganDICE, :farm, :Pork, [OrigPork[1:6]; zeros(DICELength-6)])
set_param!(VeganDICE, :farm, :Eggs, [OrigEggs[1:6]; zeros(DICELength-6)])
set_param!(VeganDICE, :farm, :SheepGoat, [OrigSheepGoat[1:6]; zeros(DICELength-6)])
run(VeganDICE)
VeganTemp = VeganDICE[:co2_cycle, :T]
plotT = 2120
t = collect(2020:1:plotT)
TempDiff = BaseTemp[NowIndex + length(t)] - VeganTemp[NowIndex+length(t)]
println("Temp Diff is $TempDiff")
plot(t, [BaseTemp[NowIndex:NowIndex+length(t)-1] VeganTemp[NowIndex:NowIndex+length(t)-1]], linewidth=2, linecolor=[:black :green], label=["BAU" "Vegan"], legend=:topleft, linestyle=[:solid :dash])
savefig("VeganTemp.pdf")

BeefPulse = copy(OrigBeef)
DairyPulse = copy(OrigDairy)
PorkPulse = copy(OrigPork)
PoultryPulse = copy(OrigPoultry)
EggsPulse = copy(OrigEggs)
SheepGoatPulse = copy(OrigSheepGoat)

BeefPulse[6] = OrigBeef[6] + 1000*1.2*(4.8) 				#Add pulse to year 2020; pump up for Veg diets
DairyPulse[6] = OrigDairy[6] + 1000*1.2*(8)
PorkPulse[6] = OrigPork[6]  + 1000*1.2*(2.7)
PoultryPulse[6] = OrigPoultry[6] + 1000*1.2*(6.7)
EggsPulse[6] = OrigEggs[6]  + 1000*1.2*(1.5)
SheepGoatPulse[6] = OrigSheepGoat[6] + 1000*1.2*(.06)

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
pulse[6] = 1000*4.6*1e-9
set_param!(GasPulse, :emissions, :CO2Marg, pulse)
run(GasPulse)
GasIRF = GasPulse[:co2_cycle, :T] - BaseTemp
plot(t, [VeganIRF[NowIndex:NowIndex+length(t)-1] GasIRF[NowIndex:NowIndex+length(t)-1]], legend=:topright, label=["Diet IRF" "Driving IRF"], linewidth=2, linestyle=[:solid :dash], color=[:green :black])
savefig("VeganIRF.pdf")

###Social cost computations
VegWelfare = VeganPulse[:welfare, :UTILITY]
MargCons = create_dice_farm()
set_param!(MargCons, :neteconomy, :CEQ, 1e-9)  #dropping C by 1000 total 
run(MargCons)
MargConsWelfare = MargCons[:welfare, :UTILITY]
SCCVeg = (BaseWelfare - VegWelfare)/(BaseWelfare - MargConsWelfare)
println("Starting SCs")
##Now do 1 Social Cost for each of Beef, Dairy, Pork, Poultry, Eggs, SheepGoat
Meats = [:Beef, :Dairy, :Pork, :Poultry, :Eggs, :SheepGoat]
Origs = [OrigBeef, OrigDairy, OrigPork, OrigPoultry, OrigEggs, OrigSheepGoat]
SCs   = zeros(length(Meats))
i = collect(1:1:length(Meats))
for (meat, O, i) in zip(Meats, Origs, i)
	tempModel = create_dice_farm();
	Pulse = copy(O)
	Pulse[6] = Pulse[6] + 20.0 #add 20 kg of protein (or 20000 grams)
	set_param!(tempModel, :farm, meat, Pulse)
	run(tempModel)
	W = tempModel[:welfare, :UTILITY]
	SCs[i] = (BaseWelfare - W)/(BaseWelfare - MargConsWelfare) #how many thousands of dollars to reduce 1000 hamburgers produced
end
#SCTable= [Meats', SCs']

######################## TO DO ####################################################################################################
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


