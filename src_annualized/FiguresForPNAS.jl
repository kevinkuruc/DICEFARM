using Plots
include("DICEFARM_Annual.jl")
include("VegSocialCosts.jl")
DICEFARM = create_dice_farm()
run(DICEFARM)
BaseTemp = DICEFARM[:co2_cycle, :T]
BaseWelfare = DICEFARM[:welfare, :UTILITY]
DICELength = length(DICEFARM[:farm, :Beef])
TwentyTwenty = 2020-1764

# ----- Plot against Vegan World ------ #
OrigBeef = DICEFARM[:farm, :Beef]
OrigDairy = DICEFARM[:farm, :Dairy]
OrigPork = DICEFARM[:farm, :Pork]
OrigPoultry = DICEFARM[:farm, :Poultry]
OrigEggs = DICEFARM[:farm, :Eggs]
OrigSheepGoat = DICEFARM[:farm, :SheepGoat]

VeganDICE = create_dice_farm()
set_param!(VeganDICE, :farm, :Beef, [OrigBeef[1:5]; zeros(DICELength-5)])  			#Keep 2015-2019 consumption
set_param!(VeganDICE, :farm, :Dairy, [OrigDairy[1:5]; zeros(DICELength-5)])
set_param!(VeganDICE, :farm, :Poultry, [OrigPoultry[1:5]; zeros(DICELength-5)])
set_param!(VeganDICE, :farm, :Pork, [OrigPork[1:5]; zeros(DICELength-5)])
set_param!(VeganDICE, :farm, :Eggs, [OrigEggs[1:5]; zeros(DICELength-5)])
set_param!(VeganDICE, :farm, :SheepGoat, [OrigSheepGoat[1:5]; zeros(DICELength-5)])
run(VeganDICE)
VeganTemp = VeganDICE[:co2_cycle, :T]
plotT = 2120
t = collect(2020:1:plotT)
TempDiff = BaseTemp[TwentyTwenty + length(t)] - VeganTemp[TwentyTwenty+length(t)]
println("Temp Diff is $TempDiff")
plot(t, [BaseTemp[TwentyTwenty:TwentyTwenty+length(t)-1] VeganTemp[TwentyTwenty:TwentyTwenty+length(t)-1]], linewidth=2, linecolor=[:black :green], label=["BAU" "Vegan"], legend=:topleft, linestyle=[:solid :dash])
savefig("Figures//PNAS//VeganTemp.pdf")

# ------ Plot Vegan Pulse vs Gas Pulse ------- #

BeefPulse = copy(OrigBeef)
DairyPulse = copy(OrigDairy)
PorkPulse = copy(OrigPork)
PoultryPulse = copy(OrigPoultry)
EggsPulse = copy(OrigEggs)
SheepGoatPulse = copy(OrigSheepGoat)

BeefPulse[6] = OrigBeef[6] + 1000*(4.8) 				#Add pulse to year 2020
DairyPulse[6] = OrigDairy[6] + 1000*(8)
PorkPulse[6] = OrigPork[6]  + 1000*(2.7)
PoultryPulse[6] = OrigPoultry[6] + 1000*(6.7)
EggsPulse[6] = OrigEggs[6]  + 1000*(1.5)
SheepGoatPulse[6] = OrigSheepGoat[6] + 1000*(.06)

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
plot(t, [VeganIRF[TwentyTwenty:TwentyTwenty+length(t)-1] GasIRF[TwentyTwenty:TwentyTwenty+length(t)-1]], legend=:topright, label=["Diet IRF" "Driving IRF"], linewidth=2, linestyle=[:solid :dash], color=[:green :black])
savefig("Figures//PNAS//VeganIRF.pdf")

# -------- Social Costs (Baseline) ---------- #
Diets = [4.8; 8; 2.7; 6.7; 1.5; .06];
Intensities = [65.1 6.5 .22; 14.6 2.1 .22; 25.6 .02 .02; 25.1 .70 .03; 20.1 .07 .03; 20 4.5 .016];
BaselineSCs = VegSocialCosts(Intensities, Diets)

#Need to refinalize this
##Isocost curves
isotemps = [2 2.5 3]
MReduc1 = collect(0:.05:1)
EIndReduc1 = zeros(length(MReduc1), length(isotemps))
for MAXTEMP = 1:length(isotemps)
	for j = 1:length(MReduc1)
		global CO2step = .005
		global Co2Reduc = 1 + CO2step
		maxtemp = 1.
			while maxtemp<isotemps[MAXTEMP]
			Co2Reduc = Co2Reduc - CO2step
			m = create_dice_farm();
			set_param!(m, :farm, :MeatReduc, MReduc1[j])
			set_param!(m, :emissions, :EIndReduc, Co2Reduc)
			run(m) 
			temp = m[:co2_cycle, :T]
			maxtemp = maximum(temp[TwentyTwenty:TwentyTwenty+200])  #temp in next 200 years
			end
	EIndReduc1[j, MAXTEMP] = Co2Reduc
	end
end

M1 = 100*(ones(length(MReduc1)) - MReduc1)
E1 = 100*(ones(size(EIndReduc1)[1], length(isotemps)) - EIndReduc1)

plot(E1, M1, label=["2 Deg." "2.5 Deg" "3 Deg"], color=:black, linestyle=[:solid :dash :dashdot], linewidth=2, ylabel="Agricultural Emissions \n (% of Projected)", xlabel="Industrial Emissions \n (% of Projected)",
 xlims=(0, 100), xticks=0:10:100, yticks=0:10:100)



### Julia Contour  (Dont think this makes the cut)
#MReduc2 = collect(0:.1:1)
#EIndReduc2 = collect(0:.1:1)
#MaxTemps = zeros(length(MReduc2), length(EIndReduc))
#for i = 1:length(EIndReduc2)
#	for j = 1:length(MReduc2)
#			m = create_dice_farm();
#			set_param!(m, :farm, :MeatReduc, MReduc[j])
#			set_param!(m, :emissions, :EIndReduc, EIndReduc[i])
#			run(m) 
#			temp = m[:co2_cycle, :T]
#			maxtemp = maximum(temp[TwentyTwenty:TwentyTwenty+200])  #temp in next 100 years
#			MaxTemps[j, i] = maxtemp
#	end
#end

#contour(MReduc, EIndReduc, MaxTemps, xlabel="Percent Industrial Reduction", ylabel="Percent Animal Ag. Reduction")

#--------- Loop Social Costs Over Region ---------------- #
ESEA_Intensities = [49.9]
_Socialcosts
