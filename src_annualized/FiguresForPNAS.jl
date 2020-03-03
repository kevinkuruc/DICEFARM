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
## STERN SOCIAL COSTS SOLVED BY TEMPORARILY CHANGING THE VegSocialCosts FUNCTION

##Isocost curves
isotemps = [2 2.5 3]
MReduc1 = collect(0:.05:1)
EIndReduc1 = zeros(length(MReduc1), length(isotemps))
#for MAXTEMP = 1:length(isotemps)
#	for j = 1:length(MReduc1)
#		global CO2step = .005
#		global Co2Reduc = 1 + CO2step
#		maxtemp = 1.
#			while maxtemp<isotemps[MAXTEMP]
#			Co2Reduc = Co2Reduc - CO2step
#			m = create_dice_farm();
#			set_param!(m, :farm, :MeatReduc, MReduc1[j])
#			set_param!(m, :emissions, :EIndReduc, Co2Reduc)
#			run(m) 
#			temp = m[:co2_cycle, :T]
#			maxtemp = maximum(temp[TwentyTwenty:TwentyTwenty+200])  #temp in next 200 years
#			end
#	EIndReduc1[j, MAXTEMP] = Co2Reduc
#	end
#end

#M1 = 100*(ones(length(MReduc1)) - MReduc1)
#E1 = 100*(ones(size(EIndReduc1)[1], length(isotemps)) - EIndReduc1)

#plot(E1, M1, label=["2 Deg." "2.5 Deg" "3 Deg"], color=:black, linestyle=[:solid :dash :dashdot], linewidth=2, ylabel="Agricultural Emissions \n (% of Projected)", xlabel="Industrial Emissions \n (% of Projected)", xlims=(0, 100), xticks=0:10:100, yticks=0:10:100)
savefig("Figures//PNAS//Isoquants.pdf")


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
ESEA_Intensities 	= [49.9 8.85 .266	; 19.92 2.17 .069	; 35.7 .031 .049; 26.7 .81 .053	; 26.9 0.05 .039; 30.0 4.36 .13]
EEU_Intensities  	= [29.9 2.11 .07	; 10.1 1.84 .03		; 14.4 .02 .02	; 25.1 .35 .03	; 8.2 .02 .03	; 14.3 1.84 .05]
LatAm_Intensities 	= [141.84 7.89 .24	; 13.15 2.9 .24		; 25.44 .02 .02	; 27.4 .62 0.04	; 16.9 .17 .02	; 12.46 6.29 .13]
MidEast_Intensities = [16.04 5.62 .43	; 14.9 3.48 .25		; 27.34 .02 .03	; 39.9 0.65 .04	; 14.2 .1 .02	; 24.3 5.32 .4]
NO_Intensities 		= [14.08 3.67 .14	; 14.4 1.44 .02		; 14.35 .02 .02	; 15.24 .61 .02	; 7.57 .12 .02	; 22.3 4.17 .18]
Oceania_Intensities = [21.7 4.39 .22	; 15.02 2.93 .10	; 28.4 .02 .02	; 25.02 2.01 .02; 12.8 .05 .02	; 16.25 2.93 .10]
Russia_Intensities 	= [27.0 2.08 .06	; 8.8 1.23 .03		; 17.9  .02 .01	; 20.8  .28  .03; 9.08 .02  .01	; 13.06 4.14 .12]
SAS_Intensities		= [58.46 12.7 .32	; 25.14 3.31 .10	; 21.5 1.52 .05	; 24.3 .02 .04	; 14.03 .07 .03	; 36.6 6.94 .16]
SSA_Intensities 	= [5.9 11.3 .41		; 5.6 5.23 .16		; 28.5 .04 .03	; 13.3 1.17 .04	; 10.8 .08 .04	; 6.28 7.28 .20]
WEU_Intensities		= [26.4 2.6 .12		; 12.2 0.99 .04		; 23.9 .02 .02	; 27.2 .46 .04	; 15.2 .02 .02	; 18.9 2.44 .09]

ESEA_Diets 		= [.67	; 1.1	; 1.5; 4.0	; 2.1 ; .40] #China
EEU_Diets  		= [.61	; 5.3	; 3.4; 4.0	; 1.6 ; .02] #Hungary
LatAm_Diets 	= [5.3	; 4.6	; 4.5; 1.2	; .84 ; .08] #Brazil
MidEast_Diets 	= [1.6	; 5.2	; 2.3; 0	; .81 ; .5]  #Turkey
NO_Diets 		= [4.7	; 8.0	; 6.7; 2.7	; 1.5 ; .06] #USA
Oceania_Diets 	= [5.2	; 7.2	; 5.1; 1.9	; .067; 1.2] #Australia
Russia_Diets 	= [2.5	; 6.3	; 2.8; 2.2	; 1.6 ; .02] #Russia
SAS_Diets		= [.19	; 2.8   ; .23; .03	; .25 ; 0.1] #India
SSA_Diets 		= [1.7	; 3.0	; .08; .03	; .08 ; .30] #Kenya
WEU_Diets		= [3.7	; 8.3	; 3.2; 3.3	; 1.5 ; .42] #France


ESEA_Socialcosts = VegSocialCosts(ESEA_Intensities, ESEA_Diets)
EEU_Socialcosts = VegSocialCosts(EEU_Intensities, EEU_Diets)
LatAm_Socialcosts = VegSocialCosts(LatAm_Intensities, LatAm_Diets)
MidEast_Socialcosts = VegSocialCosts(MidEast_Intensities, MidEast_Diets)
NO_Socialcosts = VegSocialCosts(NO_Intensities, NO_Diets)
Oceania_Socialcosts = VegSocialCosts(Oceania_Intensities, Oceania_Diets)
Russia_Socialcosts = VegSocialCosts(Russia_Intensities, Russia_Diets)
SAS_Socialcosts = VegSocialCosts(SAS_Intensities, SAS_Diets)
SSA_Socialcosts = VegSocialCosts(SSA_Intensities, SSA_Diets)
WEU_Socialcosts = VegSocialCosts(WEU_Intensities, WEU_Diets)


