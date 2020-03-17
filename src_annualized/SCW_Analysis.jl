using Plots
using NLopt
include("AnimalWelfareModel.jl")
DICEFARM = create_AnimalWelfare()
run(DICEFARM)
println("Ran once")
BaseWelfare = DICEFARM[:welfare, :UTILITY]
MargCons 	= create_AnimalWelfare()
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

BeefPulse[6] = OrigBeef[6] + 1000*(4.8) 				#Add pulse to year 2020; pump up for Veg diets
PorkPulse[6] = OrigPork[6]  + 1000*(2.7)
PoultryPulse[6] = OrigPoultry[6] + 1000*(6.7)

VegPulse = create_AnimalWelfare()
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
	tempM = create_AnimalWelfare()
	set_param!(tempM, :welfare, :CowEquiv, S)
	set_param!(tempM, :welfare, :ChickenEquiv, S)
	set_param!(tempM, :welfare, :PigEquiv, S)
	run(tempM)
	
	TempBaseWelfare = tempM[:welfare, :UTILITY]
	BeefPulse = copy(OrigBeef)
	PorkPulse = copy(OrigPork)
	PoultryPulse = copy(OrigPoultry)

	BeefPulse[6] = OrigBeef[6] + 1000*(4.8) 				#Add pulse to year 2020; pump up for Veg diets
	PorkPulse[6] = OrigPork[6]  + 1000*(2.7)
	PoultryPulse[6] = OrigPoultry[6] + 1000*(6.7)

	VegPulse = create_AnimalWelfare()
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
Basecost = BenefitOfVegetarian[2]

println("Costs of Non-Veg in Baseline are $Basecost")

plot(SufferingEquiv, 1e-3*BenefitOfVegetarian, color=[:red], lw=[1.2], ylabel="Social Costs of Non-Vegetarian Diet \n (Thousands \$)", xlabel="Farmed Animal Utility (\$ per Day-Human Utility)", legend=false)
savefig("Figures//SCW//SocialCostofMeatEating.pdf")


# --------- Loop over values of eta ----------------- #
# Note, need to reset SCNumeraire since this depends on eta
etas = collect(1.05:.05:1.85)
BenefitOfVegetarianEta = zeros(length(etas))
for (i,eta) in enumerate(etas)
	tempM = create_AnimalWelfare()
	set_param!(tempM, :welfare, :elasmu, eta)
	run(tempM)
	TempBaseWelfare = tempM[:welfare, :UTILITY]
	BeefPulse = copy(OrigBeef)
	PorkPulse = copy(OrigPork)
	PoultryPulse = copy(OrigPoultry)

	MargCons = create_AnimalWelfare()
	set_param!(MargCons, :welfare, :elasmu, eta)
	set_param!(MargCons, :neteconomy, :CEQ, 1e-9)
	run(MargCons)
	tempSCNumeraire = TempBaseWelfare - MargCons[:welfare, :UTILITY]

	BeefPulse[6] = OrigBeef[6] + 1000*(4.8) 				#Add pulse to year 2020; pump up for Veg diets
	PorkPulse[6] = OrigPork[6]  + 1000*(2.7)
	PoultryPulse[6] = OrigPoultry[6] + 1000*(6.7)

	VegPulse = create_AnimalWelfare()
	set_param!(VegPulse, :welfare, :elasmu, eta)
	set_param!(VegPulse, :farm, :Beef, BeefPulse)
	set_param!(VegPulse, :farm, :Poultry, PoultryPulse)
	set_param!(VegPulse, :farm, :Pork, PorkPulse)
	run(VegPulse)
	VegWelfare = VegPulse[:welfare, :UTILITY]
	BenefitOfVegetarianEta[i] = (TempBaseWelfare - VegWelfare)/tempSCNumeraire
end

plot(etas, 1e-3*BenefitOfVegetarianEta, color=[:red], lw=[1.2], ylabel="Social Costs of Non-Vegetarian Diet \n (Thousands \$)", xlabel="Elasticity of Marginal Utility of Consumption", legend=false)
savefig("Figures//SCW//RobustnessOverEta.pdf")

# --------- Now For Individual Products ------------- #
Meats = [:Beef, :Pork, :Poultry]
Origs = [OrigBeef, OrigPork, OrigPoultry]
SCs   = zeros(length(SufferingEquiv), length(Meats))
i = collect(1:1:length(Meats))
for (meat, O, i) in zip(Meats, Origs, i)
	for (j, S) in enumerate(SufferingEquiv)	
	tempM = create_AnimalWelfare()
	set_param!(tempM, :welfare, :CowEquiv, S)
	set_param!(tempM, :welfare, :ChickenEquiv, S)
	set_param!(tempM, :welfare, :PigEquiv, S)
	run(tempM)
	TempBaseWelfare = tempM[:welfare, :UTILITY]

	MPulse = copy(O)
	MPulse[6] = MPulse[6] + 1000*.02 				#Add pulse for 1000 20 protein gram meals

	M = create_AnimalWelfare()
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
savefig("Figures//SCW//ByAnimal.pdf")

## Utility Plot
x = collect(.365:.1:15)
CL = ((365*.0019) ^ (1 - 1.45) - 1) / (1 - 1.45)
y = ((x.^(1 - 1.45) - ones(length(x))) / (1 - 1.45)) - CL*ones(length(x))
plot(x, y, legend=false, lw=1.1, ylabel="Utility (Less Critical Level)", xlabel="Consumption (Thousands \$ Annually)")
hline!([0], linestyle=:dash, linecolor=:black)
savefig("Figures//SCW//UtilityPlot.pdf")


# --------- Optimal Policy ---------- # 
include("helpers_SCWOptimization.jl")
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
opt.xtol_rel = 1e-4
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
alphas 	= collect(.5*alpha: .25*alpha: 2*alpha)
uAs 	= collect(.9:.1:1.9)

DiffOpts = zeros(length(uAs), length(alphas))
for (i, alpha) in enumerate(alphas)
	for (j, Suffering) in enumerate(uAs)
	println("Starting again for heatmap")
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

#plot(alphas, uAs, DiffOpts, legend=false, seriestype=:wireframe, size=[800,500], xlabel="Animal Welfare", ylabel="Marginal Utility Shifter");
savefig("Figures//SCW//ThreeDRobustness.pdf")
alphas = .5:.25:2
plot(uAs, alphas, DiffOpts', seriestype=:heatmap, size=[800,500], xlabel="Animal Welfare (Human Eq. \$ per Day)", ylabel="Marginal Utility Shifter");
savefig("Figures//SCW//HeatMapRobustness.svg")


