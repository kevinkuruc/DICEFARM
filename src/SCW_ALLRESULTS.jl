using Plots, NLopt, DataFrames, CSV

directory = dirname(pwd())
subroutine_directory = joinpath(directory, "src", "SubRoutines_SCW")
output_directory = joinpath(directory, "Results", "SCW")

include(joinpath(subroutine_directory, "AnimalWelfareModel.jl"))
include(joinpath(subroutine_directory, "helpers_SCWOptimization.jl"))
DICEFARM = create_AnimalWelfare()
run(DICEFARM)
println("Ran once")
BaseWelfare = DICEFARM[:welfare, :UTILITY]
MargCons 	= create_AnimalWelfare()
update_param!(MargCons, :CEQ, 1e-9)  #dropping C by 1000 globally
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

BeefPulse[TwentyTwenty] = OrigBeef[TwentyTwenty] + 1000*(4.8) 				
PorkPulse[TwentyTwenty] = OrigPork[TwentyTwenty]  + 1000*(2.7)
PoultryPulse[TwentyTwenty] = OrigPoultry[TwentyTwenty] + 1000*(6.7)

VegPulse = create_AnimalWelfare()
update_param!(VegPulse, :Beef, BeefPulse)
update_param!(VegPulse, :Poultry, PoultryPulse)
update_param!(VegPulse, :Pork, PorkPulse)

run(VegPulse)
VegWelfare = VegPulse[:welfare, :UTILITY]
SCCVeg     = (BaseWelfare - VegWelfare)/(SCNumeraire)


# ------- Loop Over Values of Cons Equiv ------------------------- #
SufferingEquiv = collect(.9:.1:2.8)
BenefitOfVegetarian = zeros(length(SufferingEquiv))
for (i,S) in enumerate(SufferingEquiv)
	tempM = create_AnimalWelfare()
	update_param!(tempM, :CowEquiv, S)
	update_param!(tempM, :ChickenEquiv, S)
	update_param!(tempM, :PigEquiv, S)
	run(tempM)
	
	TempBaseWelfare = tempM[:welfare, :UTILITY]
	BeefPulse = copy(OrigBeef)
	PorkPulse = copy(OrigPork)
	PoultryPulse = copy(OrigPoultry)

	BeefPulse[TwentyTwenty] = OrigBeef[TwentyTwenty] + 1000*(4.8) 				#Add pulse to year 2020; pump up for Veg diets
	PorkPulse[TwentyTwenty] = OrigPork[TwentyTwenty]  + 1000*(2.7)
	PoultryPulse[TwentyTwenty] = OrigPoultry[TwentyTwenty] + 1000*(6.7)

	VegPulse = create_AnimalWelfare()
	update_param!(VegPulse, :CowEquiv, S)
	update_param!(VegPulse, :ChickenEquiv, S)
	update_param!(VegPulse, :PigEquiv, S)
	update_param!(VegPulse, :Beef, BeefPulse)
	update_param!(VegPulse, :Poultry, PoultryPulse)
	update_param!(VegPulse, :Pork, PorkPulse)
	run(VegPulse)
	VegWelfare = VegPulse[:welfare, :UTILITY]
	BenefitOfVegetarian[i] = (TempBaseWelfare - VegWelfare)/SCNumeraire
end
Basecost = BenefitOfVegetarian[2]

println("Costs of Non-Veg in Baseline are $Basecost")

plot(SufferingEquiv, 1e-3*BenefitOfVegetarian, color=[:red], lw=[1.2], ylabel="Social Costs of Non-Vegetarian Diet \n (Thousands \$)", xlabel="Farmed Animal Utility (\$ per Day-Human Utility)", legend=false)
savefig(joinpath(output_directory, "SocialCostofMeatEating.pdf"))

sufferingdf = DataFrame(uA = SufferingEquiv, SCMt = 1e-3*BenefitOfVegetarian)
CSV.write(joinpath(output_directory, "BySuffering.csv"), sufferingdf)

# --------- Loop over values of eta ----------------- #
# Note, need to reset SCNumeraire since this depends on eta
etas = collect(1.05:.05:1.85)
BenefitOfVegetarianEta = zeros(length(etas))
for (i,eta) in enumerate(etas)
	tempM = create_AnimalWelfare()
	update_param!(tempM, :elasmu, eta)
	run(tempM)
	TempBaseWelfare = tempM[:welfare, :UTILITY]
	BeefPulse = copy(OrigBeef)
	PorkPulse = copy(OrigPork)
	PoultryPulse = copy(OrigPoultry)

	MargCons = create_AnimalWelfare()
	update_param!(MargCons, :elasmu, eta)
	update_param!(MargCons, :CEQ, 1e-9)
	run(MargCons)
	tempSCNumeraire = TempBaseWelfare - MargCons[:welfare, :UTILITY]

	BeefPulse[TwentyTwenty] = OrigBeef[TwentyTwenty] + 1000*(4.8) 				
	PorkPulse[TwentyTwenty] = OrigPork[TwentyTwenty]  + 1000*(2.7)
	PoultryPulse[TwentyTwenty] = OrigPoultry[TwentyTwenty] + 1000*(6.7)

	VegPulse = create_AnimalWelfare()
	update_param!(VegPulse, :elasmu, eta)
	update_param!(VegPulse, :Beef, BeefPulse)
	update_param!(VegPulse, :Poultry, PoultryPulse)
	update_param!(VegPulse, :Pork, PorkPulse)
	run(VegPulse)
	VegWelfare = VegPulse[:welfare, :UTILITY]
	BenefitOfVegetarianEta[i] = (TempBaseWelfare - VegWelfare)/tempSCNumeraire
end

plot(etas, 1e-3*BenefitOfVegetarianEta, color=[:red], lw=[1.2], ylabel="Social Costs of Non-Vegetarian Diet \n (Thousands \$)", xlabel="Elasticity of Marginal Utility of Consumption", legend=false)
savefig(joinpath(output_directory, "RobustnessOverEta.pdf"))

# --------- Now For Individual Products ------------- #
Meats = [:Beef, :Pork, :Poultry]
Origs = [OrigBeef, OrigPork, OrigPoultry]
SCs   = zeros(length(SufferingEquiv), length(Meats))
i = collect(1:1:length(Meats))
for (meat, O, i) in zip(Meats, Origs, i)
	for (j, S) in enumerate(SufferingEquiv)	
	tempM = create_AnimalWelfare()
	update_param!(tempM, :CowEquiv, S)
	update_param!(tempM, :ChickenEquiv, S)
	update_param!(tempM, :PigEquiv, S)
	run(tempM)
	TempBaseWelfare = tempM[:welfare, :UTILITY]

	MPulse = copy(O)
	MPulse[TwentyTwenty] = MPulse[TwentyTwenty] + 1000*.02 				

	M = create_AnimalWelfare()
	update_param!(M, :CowEquiv, S)
	update_param!(M, :ChickenEquiv, S)
	update_param!(M, :PigEquiv, S)
	update_param!(M, meat, MPulse)
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

EnvironmentalBeefCost = SCs[11,1]  #11th spot is where animal lives are neutral
EnvironmentalPorkCost = SCs[11,2]
EnvironmentalPoultryCost = SCs[11,3]

AnWelfareCosts_Beef = SCs[2,1] - SCs[11,1]
AnWelfareCosts_Pork = SCs[2,2] - SCs[11,2]
AnWelfareCosts_Poultry = SCs[2,3] - SCs[11,3]

Table2 = zeros(3, 4)
Table2[1,1] = BenefitOfVegetarian[2]
Table2[2,1] = BenefitOfVegetarian[11]
Table2[3,1] = BenefitOfVegetarian[2] - BenefitOfVegetarian[11]
Table2[1,2:4] = [Beefcost Porkcost Poultrycost]
Table2[2,2:4] = [EnvironmentalBeefCost EnvironmentalPorkCost EnvironmentalPoultryCost]
Table2[3,2:4] = [AnWelfareCosts_Beef AnWelfareCosts_Pork AnWelfareCosts_Poultry]
Table2_df = DataFrame(NonVeg = Table2[:,1], Beef=Table2[:,2], Pork=Table2[:,3], Chicken=Table2[:,4])
CSV.write(joinpath(output_directory, "Table2.csv"), Table2_df)

plot(SufferingEquiv, SCs, color=[:brown :red :gold], label=["Beef" "Pork" "Poultry"], lw=[1.1], ylabel="Social Costs of Marginal Consumption (\$)", xlabel="Farmed Animal Utility (\$ per Day-Human Utility)")
savefig(joinpath(output_directory, "ByAnimal.pdf"))

## Utility Plot
x = collect(.365:.1:15)
CL = ((365*.0019) ^ (1 - 1.45) - 1) / (1 - 1.45)
y = ((x.^(1 - 1.45) - ones(length(x))) / (1 - 1.45)) - CL*ones(length(x))
plot(x, y, legend=false, lw=1.1, ylabel="Utility (Less Critical Level)", xlabel="Consumption (Thousands \$ Annually)")
hline!([0], linestyle=:dash, linecolor=:black)
savefig(joinpath(output_directory, "UtilityPlot.pdf"))


# --------- Optimal Policy ---------- # 
m = create_AnimalWelfareOpt()
function optveg(x, grad)
	if length(grad)>0
	grad[1] = 1000
	end
    result = veg_outcome(x[1])
	return result
end

opt = Opt(:LN_SBPLX, 1)
opt.lower_bounds=[-1.0]
opt.upper_bounds=[.9999999999]
init = [.5]
opt.xtol_rel = 1e-5
opt.max_objective = optveg
sol = optimize(opt, init)[2]
println("Optimal Vegetarian Reduction is $sol")


function optanimals(x, grad)
	if length(grad)>0
	grad[1] = 1
	end
	result = ByAnimals_outcome(x)
	return result
end
opt = Opt(:LN_SBPLX, 3)
opt.lower_bounds=-1*ones(3)
opt.upper_bounds=ones(3)
init = .75*ones(3)
opt.xtol_rel = 1e-6
opt.max_objective = optanimals
sol2 = optimize(opt, init)[2]
BeefReduc = sol2[1]
ChickenReduc = sol2[2]
PorkReduc = sol2[3]
println("Reduce Beef by $BeefReduc")
println("Reduce Chicken by $ChickenReduc")
println("Reduce Pork by $PorkReduc")

# --------- Optimal Policy with 2 dimensional robustness -------- #
alpha   = .025
alphas 	= [alpha 1.1*alpha]
uAs 	= collect(.9:.05:1.9)

DiffOpts = zeros(length(uAs), length(alphas))
for (i, alpha) in enumerate(alphas)
	for (j, Suffering) in enumerate(uAs)
	m = create_AnimalWelfareOpt()
	function optveg(x, grad)
		if length(grad)>0
		grad[1] = 1000
		end
    	result = veg_outcome(x[1], Suffering, alpha)
		return result
	end

	opt = Opt(:LN_SBPLX, 1)
	opt.lower_bounds=[-1.0]
	opt.upper_bounds=[1.0]
	init = [.5]
	opt.xtol_rel = 1e-4
	opt.max_objective = optveg
	sol = optimize(opt, init)[2]
	DiffOpts[j, i] = sol[1]
	end
end

plot(uAs, DiffOpts, linecolor=:red, lw=1.7, linestyle=[:solid :dashdot], label=["Baseline" "Increased Meat Utility"], xlabel="Animal Welfare", ylabel="Optimal Reduction", grid=false);
savefig(joinpath(output_directory, "OneDimensionalRobustness.pdf"))
Figure4 = DataFrame(column1 = uAs, column2 =DiffOpts[:,1], column3 = DiffOpts[:,2])
CSV.write(joinpath(output_directory, "Figure4.csv"), Figure4)


