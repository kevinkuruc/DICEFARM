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

BeefPulse[6] = OrigBeef[6] + 1000*1.1*(4.8) 				#Add pulse to year 2020; pump up for Veg diets
PorkPulse[6] = OrigPork[6]  + 1000*1.1*(2.7)
PoultryPulse[6] = OrigPoultry[6] + 1000*1.1*(6.7)

VegPulse = create_dice_farm()
set_param!(VegPulse, :farm, :Beef, BeefPulse)
set_param!(VegPulse, :farm, :Poultry, PoultryPulse)
set_param!(VegPulse, :farm, :Pork, PorkPulse)

run(VegPulse)
VegWelfare = VegPulse[:welfare, :UTILITY]
SCCVeg     = (BaseWelfare - VegWelfare)/(SCNumeraire)

# ------- Loop Over Values of Cons Equiv ------------------------- #
SufferingEquiv = collect(.9:.1:2.8)
BenefitOfVegetarian = zeros(length(SufferingEquiv))
for (i,S) in enumerate(SufferingEquiv)
	tempM = create_dice_farm()
	set_param!(tempM, :welfare, :CowEquiv, S)
	set_param!(tempM, :welfare, :ChickenEquiv, S)
	set_param!(tempM, :welfare, :PigEquiv, S)
	run(tempM)
	
	TempBaseWelfare = tempM[:welfare, :UTILITY]
	BeefPulse = copy(OrigBeef)
	PorkPulse = copy(OrigPork)
	PoultryPulse = copy(OrigPoultry)

	BeefPulse[6] = OrigBeef[6] + 1000*1.1*(4.8) 				#Add pulse to year 2020; pump up for Veg diets
	PorkPulse[6] = OrigPork[6]  + 1000*1.1*(2.7)
	PoultryPulse[6] = OrigPoultry[6] + 1000*1.1*(6.7)

	VegPulse = create_dice_farm()
	set_param!(VegPulse, :welfare, :CowEquiv, S)
	set_param!(VegPulse, :welfare, :ChickenEquiv, S)
	set_param!(VegPulse, :welfare, :PigEquiv, S)
	set_param!(VegPulse, :farm, :Beef, BeefPulse)
	set_param!(VegPulse, :farm, :Poultry, PoultryPulse)
	set_param!(VegPulse, :farm, :Pork, PorkPulse)
	run(VegPulse)
	VegWelfare = VegPulse[:welfare, :UTILITY]
	BenefitOfVegetarian[i] = (TempBaseWelfare - VegWelfare)/SCNumeraire
end

println("Costs of Non-Veg in Baseline are $BenefitOfVegetarian[2]")

plot(SufferingEquiv, 1e-3*BenefitOfVegetarian, color=[:red], lw=[1.1], ylabel="Social Costs of Non-Vegetarian Diet \n (Thousands(!) \$)", xlabel="Farmed Animal Utility (\$ per Day-Human Utility)", legend=false)
savefig("SocialCostofMeatEating.pdf")

# --------- Now For Individual Products ------------- #
Meats = [:Beef, :Pork, :Poultry]
Origs = [OrigBeef, OrigPork, OrigPoultry]
SCs   = zeros(length(SufferingEquiv), length(Meats))
i = collect(1:1:length(Meats))
for (meat, O, i) in zip(Meats, Origs, i)
	for (j, S) in enumerate(SufferingEquiv)	
	tempM = create_dice_farm()
	set_param!(tempM, :welfare, :CowEquiv, S)
	set_param!(tempM, :welfare, :ChickenEquiv, S)
	set_param!(tempM, :welfare, :PigEquiv, S)
	run(tempM)
	TempBaseWelfare = tempM[:welfare, :UTILITY]

	MPulse = copy(O)
	MPulse[6] = MPulse[6] + 1000*.02 				#Add pulse for 1000 20 protein gram meals

	M = create_dice_farm()
	set_param!(M, :welfare, :CowEquiv, S)
	set_param!(M, :welfare, :ChickenEquiv, S)
	set_param!(M, :welfare, :PigEquiv, S)
	set_param!(M, :farm, meat, MPulse)
	run(M)
	MWelfare = M[:welfare, :UTILITY]
	SCs[j, i] = (TempBaseWelfare - MWelfare)/SCNumeraire
	end
end

Beefcost = SCs[2,1]
Porkcost = SCs[2,2]
Poultrycost = SCs[2,3]
println("Costs of Beef in Baseline are $Beefcost")
println("Costs of Pork in Baseline are $Porkcost")
println("Costs of Poultry in Baseline are $Poultrycost")

plot(SufferingEquiv, SCs, color=[:brown :red :gold], label=["Beef" "Pork" "Poultry"], lw=[1.1], ylabel="Social Costs of Marginal Consumption (\$)", xlabel="Farmed Animal Utility (\$ per Day-Human Utility)")
savefig("ByAnimal.pdf")

## Utility Plot
x = collect(.365:.1:15)
CL = ((365*.0019) ^ (1 - 1.45) - 1) / (1 - 1.45)
y = ((x.^(1 - 1.45) - ones(length(x))) / (1 - 1.45)) - CL*ones(length(x))
plot(x, y, legend=false, lw=1.1, ylabel="Utility (Less Critical Level)", xlabel="Consumption (Thousands \$ Annually)")
hline!([0], linestyle=:dash, linecolor=:black)
savefig("UtilityPlot.pdf")

