using CSV, DataFrames, Plots, Roots

directory = dirname(pwd())
data_directory = joinpath(directory, "data")
subroutine_directory = joinpath(directory, "src//SubRoutines_EKM")
output_directory = joinpath(directory, "Results", "EKM")
mkpath(output_directory)

include("DICEFARM.jl")
include(joinpath(subroutine_directory, "DietsByCountry.jl"))
include(joinpath(subroutine_directory, "VegSocialCosts.jl"))
include(joinpath(subroutine_directory, "VegSocialCosts_EPA.jl"))
include(joinpath(subroutine_directory, "IsoquantPlot.jl"))
include(joinpath(subroutine_directory, "EPADamages.jl"))
include(joinpath(subroutine_directory, "Gen_PCGrowth.jl"))
DICEFARM = create_dice_farm()
run(DICEFARM)
BaseTemp = DICEFARM[:co2_cycle, :T]
BaseWelfare = DICEFARM[:welfare, :UTILITY]
DICELength = length(DICEFARM[:farm, :Beef])
pop 		= DICEFARM[:welfare, :l]
TwentyTwenty = 2020-1764
BaseCons  = DICEFARM[:neteconomy, :C][TwentyTwenty:end]

# ----- Plot against Vegan World: Figure 1A ------ #
OrigBeef = DICEFARM[:farm, :Beef]
OrigDairy = DICEFARM[:farm, :Dairy]
OrigPoultry = DICEFARM[:farm, :Poultry]
OrigPork = DICEFARM[:farm, :Pork]
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
TotalPlot = plot(t, [BaseTemp[TwentyTwenty:TwentyTwenty+length(t)-1] VeganTemp[TwentyTwenty:TwentyTwenty+length(t)-1]], linewidth=2, 
	linecolor=[:black :green], label=["BAU" "Vegan"], legend=:topleft, linestyle=[:solid :dash], grid=false,
	 ylabel="Temperature Increase (C Above Pre-Industrial)")
#savefig(joinpath(output_directory, "Fig1A.pdf"))
#savefig(joinpath(output_directory, "Fig1A.svg"))

# ------ Plot Vegan Pulse vs Gas Pulse: Figure 1B ------- #

BeefPulse = copy(OrigBeef)
DairyPulse = copy(OrigDairy)
PoultryPulse = copy(OrigPoultry)
PorkPulse = copy(OrigPork)
EggsPulse = copy(OrigEggs)
SheepGoatPulse = copy(OrigSheepGoat)

#USA Average Diets 2013
BeefPulse[6] = OrigBeef[6] + 1000*(4.5) 				
DairyPulse[6] = OrigDairy[6] + 1000*(8)
PoultryPulse[6] = OrigPoultry[6] + 1000*(6.5)
PorkPulse[6] = OrigPork[6]  + 1000*(2.7)
EggsPulse[6] = OrigEggs[6]  + 1000*(1.6)
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
VeganIRF = (VeganPulse[:co2_cycle, :T] - BaseTemp)/1000

##Model with Gasoline Pulse
GasPulse = create_dice_farm()
T = DICELength
pulse = 1000*4.6*1e-9
#From: https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references
set_param!(GasPulse, :emissions, :Co2Pulse, pulse)
run(GasPulse)
GasIRF = (GasPulse[:co2_cycle, :T] - BaseTemp)/1000
HHEnergyPulse = create_dice_farm()
T = DICELength
pulse = 1000*8.67/2.63*1e-9  
#8.67 from: https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references
#2.63 from: https://www.pewresearch.org/fact-tank/2019/10/01/the-number-of-people-in-the-average-u-s-household-is-going-up-for-the-first-time-in-over-160-years/
set_param!(HHEnergyPulse, :emissions, :Co2Pulse, pulse)
run(HHEnergyPulse)
HHEnergyIRF = (HHEnergyPulse[:co2_cycle, :T] - BaseTemp)/1000
PulsePlot = plot([2019;t], 1e12*[VeganIRF[TwentyTwenty-1:TwentyTwenty+length(t)-1] GasIRF[TwentyTwenty-1:TwentyTwenty+length(t)-1] HHEnergyIRF[TwentyTwenty-1:TwentyTwenty+length(t)-1]], legend=:topright,
 label=["Diet" "Passenger Vehicle" "Household Energy (Per Cap.)"], linewidth=2, linestyle=[:solid :dash :dashdot], color=[:green :black :orange],
  ylabel="Temperature Change (1e-15 C)", ylims=(0,3.5), grid=false)
#savefig(joinpath(output_directory, "Fig1B.pdf"))
#savefig(joinpath(output_directory, "Fig1B.svg"))

# -------- Total Social Costs --------------- #
GlobalVeganPulse = create_dice_farm()
GlobalVeganPulse_Stern = create_dice_farm()
GlobalBeefPulse = copy(OrigBeef)
GlobalDairyPulse = copy(OrigDairy)
GlobalPorkPulse = copy(OrigPork)
GlobalPoultryPulse = copy(OrigPoultry)
GlobalEggsPulse = copy(OrigEggs)
GlobalSheepGoatPulse = copy(OrigSheepGoat)

GlobalBeefPulse[6] = 0
GlobalDairyPulse[6] = 0
GlobalPorkPulse[6] = 0
GlobalPoultryPulse[6] = 0
GlobalEggsPulse[6] = 0
GlobalSheepGoatPulse[6] = 0

set_param!(GlobalVeganPulse, :farm, :Beef, GlobalBeefPulse)
set_param!(GlobalVeganPulse, :farm, :Dairy, GlobalDairyPulse)
set_param!(GlobalVeganPulse, :farm, :Poultry, GlobalPoultryPulse)
set_param!(GlobalVeganPulse, :farm, :Pork, GlobalPorkPulse)
set_param!(GlobalVeganPulse, :farm, :Eggs, GlobalEggsPulse)
set_param!(GlobalVeganPulse, :farm, :SheepGoat, GlobalSheepGoatPulse)

set_param!(GlobalVeganPulse_Stern, :farm, :Beef, GlobalBeefPulse)
set_param!(GlobalVeganPulse_Stern, :farm, :Dairy, GlobalDairyPulse)
set_param!(GlobalVeganPulse_Stern, :farm, :Poultry, GlobalPoultryPulse)
set_param!(GlobalVeganPulse_Stern, :farm, :Pork, GlobalPorkPulse)
set_param!(GlobalVeganPulse_Stern, :farm, :Eggs, GlobalEggsPulse)
set_param!(GlobalVeganPulse_Stern, :farm, :SheepGoat, GlobalSheepGoatPulse)
set_param!(GlobalVeganPulse_Stern, :welfare, :rho, .001)

run(GlobalVeganPulse)
run(GlobalVeganPulse_Stern)
WGlobalPulse = GlobalVeganPulse[:welfare, :UTILITY]
WGlobalPulse_Stern = GlobalVeganPulse_Stern[:welfare, :UTILITY]

NewBaseline = create_dice_farm()

function ConsEquiv(m, W, discount=.015)
	function f(x)
		set_param!(m, :neteconomy, :CEQ, x)
		set_param!(m, :welfare, :rho, discount)
		run(m)
		diff = m[:welfare, :UTILITY] - W
		return diff
	end
CEQ = find_zero(f, (-1, 1), Bisection())
CEQ = CEQ
return CEQ
end

GlobalPulseCost = -1000*ConsEquiv(NewBaseline, WGlobalPulse) #convert from trillions to billions
println("Total Social Costs of 1 year of meat production are $GlobalPulseCost Billion dollars")
GlobalPulseCost_Stern = -1000*ConsEquiv(NewBaseline, WGlobalPulse_Stern, .001)
Table1_Col1 = [GlobalPulseCost; GlobalPulseCost_Stern]

# -------- EPA Discount Method -------------- #
VeganCons = GlobalVeganPulse[:neteconomy, :C][TwentyTwenty:end]
GlobalCosts_EPA = zeros(3)
EPA_discounts = [.025; .03; .05]
	for (i, rho) in enumerate(EPA_discounts)
		globalcosts = EPADamages(VeganCons, BaseCons, rho) 
		GlobalCosts_EPA[i] = -1e3*globalcosts #In billions
	end
Table1_Col1 = [Table1_Col1; GlobalCosts_EPA[1];GlobalCosts_EPA[2]; GlobalCosts_EPA[3]]

# -------- Social Costs (Baseline) ---------- #
Diets = [4.5; 8; 6.5; 2.7; 1.6; .06];
Intensities = [65.1 6.5 .22; 14.6 2.1 .22; 25.6 .02 .02; 25.1 .70 .03; 20.1 .07 .03; 20 4.5 .02];
BaselineSCs = VegSocialCosts(Diets, Intensities)
BaselineSCs_Stern = VegSocialCosts(Diets, Intensities, .001)
EPAEsts     = VegSocialCosts_EPA(Diets, Intensities, EPA_discounts)

#--------- Collect and Make Table 1 ----------------------#
Table1 = zeros(5, 9)
Table1[:,1] = Table1_Col1
Table1[1,2:end] = BaselineSCs[:,2]
Table1[2,2:end] = BaselineSCs_Stern[:,2]
Table1[3:end, 2:end] = EPAEsts
Table1[:,3] = Table1[:,2]-Table1[:,3]
Table1_df = DataFrame(Run = ["Base"; "Stern"; "2.5%"; "3%"; "5%"], Global = Table1[:,1], SAD = Table1[:,2], Vegetarian=Table1[:,3], Beef=Table1[:,4], Dairy=Table1[:,5], Poultry=Table1[:,6], Pork=Table1[:,7], Eggs=Table1[:,8], SheepGoat=Table1[:,9])
CSV.write(joinpath(output_directory, "TableS2.csv"), Table1_df)

#-------- Table S1: Split Table 1 Base case by product -- #
TableS1 = DataFrame()
TableS1[:Beef] = [50*Diets[1]*Table1[1,4]] #1 kg is 50 20g servings
TableS1[:Dairy] = [50*Diets[2]*Table1[1,5]]
TableS1[:Poultry] = [50*Diets[3]*Table1[1,6]]
TableS1[:Pork] = [50*Diets[4]*Table1[1,7]]
TableS1[:Eggs] = [50*Diets[5]*Table1[1,8]]
TableS1[:SheepGoat] = [50*Diets[6]*Table1[1,9]]
#CSV.write(joinpath(output_directory, "TableS1.csv"), TableS1)

#-------- Figure 2 -------------------------------------- #
#Isoquants()

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

# We dont actually use these in final paper... but still need them as place holders for Region_Socialcosts() function
ESEA_Diets 		= [.67	; 1.1	; 1.5; 4.0	; 2.1 ; .40] #China
EEU_Diets  		= [.61	; 5.3	; 3.4; 4.0	; 1.6 ; .02] #Hungary
LatAm_Diets 	= [5.3	; 4.6	; 4.5; 1.2	; .84 ; .08] #Brazil
MidEast_Diets 	= [1.6	; 5.2	; 2.3; 0	; .81 ; .5]  #Turkey
NO_Diets 		= [4.7	; 8.0	; 6.7; 2.7	; 1.5 ; .06] #USA
Oceania_Diets 	= [5.2	; 7.2	; 5.1; 1.9	; .067; 1.2] #Australia
Russia_Diets 	= [2.5	; 6.3	; 2.8; 2.2	; 1.6 ; .02] #Russia
SAS_Diets		= [.19	; 2.8  	; .23; .03	; .25 ; 0.1] #India
SSA_Diets 		= [1.7	; 3.0	; .08; .03	; .08 ; .30] #Kenya
WEU_Diets		= [3.7	; 8.3	; 3.2; 3.3	; 1.5 ; .42] #France

ESEA_Socialcosts = VegSocialCosts(ESEA_Diets, ESEA_Intensities)
EEU_Socialcosts = VegSocialCosts(EEU_Diets, EEU_Intensities)
LatAm_Socialcosts = VegSocialCosts(LatAm_Diets, LatAm_Intensities)
MidEast_Socialcosts = VegSocialCosts(MidEast_Diets, MidEast_Intensities)
NO_Socialcosts = VegSocialCosts(NO_Diets, NO_Intensities)
Oceania_Socialcosts = VegSocialCosts(Oceania_Diets, Oceania_Intensities)
Russia_Socialcosts = VegSocialCosts(Russia_Diets, Russia_Intensities)
SAS_Socialcosts = VegSocialCosts(SAS_Diets, SAS_Intensities)
SSA_Socialcosts = VegSocialCosts(SSA_Diets, SSA_Intensities)
WEU_Socialcosts = VegSocialCosts(WEU_Diets, WEU_Intensities)

# -------- Figure 3B ---------------#
using StatsPlots
Region = repeat(["Africa", "East\nAsia", "East\nEurope", "Lat\nAm.", "Mid\nEast", "North\nAm.", "Oceania", "Russia", "South\nAsia", "West\nEurope"], outer=6)
Product = repeat(["Beef", "Dairy", "Poultry", "Pork", "Eggs", "Sheep/Goat"], inner=10)
BarData = [SSA_Socialcosts[3:end,2] ESEA_Socialcosts[3:end,2] EEU_Socialcosts[3:end,2] LatAm_Socialcosts[3:end,2] MidEast_Socialcosts[3:end,2] NO_Socialcosts[3:end,2] Oceania_Socialcosts[3:end,2] Russia_Socialcosts[3:end,2] SAS_Socialcosts[3:end,2] WEU_Socialcosts[3:end,2]]'
groupedbar(Region, BarData, group=Product, grid=false, color=[:black :blue :yellow :pink :red :brown],
foreground_color_legend = nothing, background_color_legend=nothing, legendfontsize=6, ylabel="Cost per 20 g protein serving (\$)")
#savefig(joinpath(output_directory, "Fig3B.pdf"))
#savefig(joinpath(output_directory, "Fig3B.svg"))

#------- Figure 3A -----------------#
#df = DietaryCostsByCountry()
#CSV.write(joinpath(output_directory, "CostsByCountry.csv"), df)


#---- Appendix Figures: Increased PC Meat Cons ----- #
#Without_growth = create_dice_farm() 
#Gen_PCGrowth(Without_growth)
#To obtain these: Go into "annual_parameters.jl" and unblock line 76 (PCGrowth = ones(T));
#this line turns OFF per capita growth and so it should be ignored for these figures. 
#Then simply re-run the master file and you will get updates. The model will obnoxiously tell you 
#that you are running the model this way so that you don't forget to change back annual_parameters.jl

#---- Appendix Table 2 ------------------------------#
#redo analysis changing the input of create_dice_farm(TCR=1.6, ECS=2.75)






