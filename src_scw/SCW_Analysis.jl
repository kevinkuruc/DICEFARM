using Plots
include("DICEFARM_Annual.jl")
DICEFARM = create_dice_farm()
run(DICEFARM)
BaseWelfare = DICEFARM[:welfare, :UTILITY]
MargCons 	= create_dice_farm()
set_param!(MargCons, :neteconomy, :CEQ, 1e-9)  #dropping C by 1000 total (something weird)
run(MargCons)
MargConsWelfare = MargCons[:welfare, :UTILITY]
SCNumeraire 	= BaseWelfare - MargConsWelfare

SocialCosts = zeros(4) # Vegetarian; then each of 3 animal products

# ----- Need original amount consumed -------- #
OrigBeef = DICEFARM[:farm, :Beef]
OrigPork = DICEFARM[:farm, :Pork]
OrigPoultry = DICEFARM[:farm, :Poultry]

# ------ Add Vegetarian average pulse ------------------- #
BeefPulse = copy(OrigBeef)
PorkPulse = copy(OrigPork)
PoultryPulse = copy(OrigPoultry)

BeefPulse[6] = OrigBeef[6] + 1000*1.2*(4.8) 				#Add pulse to year 2020; pump up for Veg diets
PorkPulse[6] = OrigPork[6]  + 1000*1.2*(2.7)
PoultryPulse[6] = OrigPoultry[6] + 1000*1.2*(6.7)

VegPulse = create_dice_farm()
set_param!(VegPulse, :farm, :Beef, BeefPulse)
set_param!(VegPulse, :farm, :Poultry, PoultryPulse)
set_param!(VegPulse, :farm, :Pork, PorkPulse)

run(VegPulse)
VegWelfare = VegPulse[:welfare, :UTILITY]
SCCVeg     = (BaseWelfare - VegWelfare)/(SCNumeraire)



