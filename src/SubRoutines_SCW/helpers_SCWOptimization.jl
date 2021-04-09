using Roots, NLsolve
include("AnimalWelfareModel.jl")

## First need to calibrate prices (via relative and total consumption of meat in our 2020 period)
#Parameters nested within CES aggregator of meats
#epsilon = -1.22   #elasticity of substitution parameter
epsilon  = 1-(1/1.22)
theta_c = .43  #coefficient within CES on chicken
theta_b = .50
theta_p = .07

# Total utility parameters
eta = 1.45     	  # As in Nordhaus
xi  = 3.17 	  # From aggregate meat consumption growth vs normal consumption growth
alpha = .025 	  # linear coefficient on meat part of utility function

#### Now using aggregate data, estimate P (aggregate price)
temp = create_AnimalWelfare()
run(temp)
TwentyTwenty = 2020-1764
TotC 	 	= temp[:neteconomy, :C][TwentyTwenty]
Beef     	= temp[:farm, :Beef][TwentyTwenty]
Pork		= temp[:farm, :Pork][TwentyTwenty]
Poultry 	= temp[:farm, :Poultry][TwentyTwenty]
Pop 		= 1e6*temp[:welfare, :l][TwentyTwenty]
#All per cap from now on
Ytilde		= 1e12*TotC/Pop 	#Per capita total consumption to split between meat and other
PerCapChicken 	= Poultry/Pop
PerCapBeef    	= Beef/Pop
PerCapPork 		= Pork/Pop
#rho 			= -1.22 #(epsilon-1)/epsilon
m 				= ((theta_c*PerCapChicken^epsilon + theta_b*PerCapBeef^epsilon + theta_p*PerCapPork^epsilon)^(1/epsilon)) #Per cap CES of Meat

### Non Linear Solver C
f(x) = alpha*m^(-xi+1)*x^eta + x - Ytilde
c = find_zero(f, (0, 11200), Bisection())

## Write my own solver for individual Ps
MeatExpenditure = Ytilde - c
expen = 0
global PBeef = 50

while expen < MeatExpenditure
    global PBeef = PBeef + .5
    global PPoultry= PBeef*(theta_c/theta_b)*((PerCapChicken/PerCapBeef)^(epsilon-1))
    global PPork = PBeef*(theta_p/theta_b)*((PerCapPork/PerCapBeef)^(epsilon-1))
    global expen   = PerCapBeef*PBeef + PerCapChicken*PPoultry + PerCapPork*PPork
end

function create_AnimalWelfareOpt()
m = create_AnimalWelfare()
include(joinpath("components", "AnimalWelfare", "OptimalPolicy", "neteconomy_component.jl"))
include(joinpath("components", "AnimalWelfare", "OptimalPolicy", "farm_component.jl"))
include(joinpath("components", "AnimalWelfare", "OptimalPolicy", "welfare_component.jl"))
replace!(m, :farm => farmforpolicy, reconnect=true)
set_param!(m, :farm, :theta_b, theta_b)
set_param!(m, :farm, :theta_c, theta_c)
set_param!(m, :farm, :theta_p, theta_p)
set_param!(m, :farm, :epsilon, epsilon)
set_param!(m, :farm, :PBeef, PBeef)
set_param!(m, :farm, :PPoultry, PPoultry)
set_param!(m, :farm, :PPork, PPork)
set_param!(m, :farm, :l, :lfarm, temp[:welfare, :l])
set_param!(m, :farm, :BeefReduc, 0.)
set_param!(m, :farm, :PorkReduc, 0.)
set_param!(m, :farm, :PoultryReduc, 0.)

replace!(m, :neteconomy => neteconomyforpolicy, reconnect=true)
connect_param!(m, :neteconomy, :MeatExp, :farm, :MeatCost)

replace!(m, :welfare => welfareforpolicy, reconnect=true)
set_param!(m, :welfare, :elasmeat, xi)
set_param!(m, :welfare, :alphameat, alpha)

connect_param!(m, :welfare, :MeatPC, :farm, :MeatPC)
return m
end

function veg_outcome(Veg, SufferingEquiv=1.0, alphaM=alpha)
	m = create_AnimalWelfareOpt()
	update_param!(m, :CowEquiv, SufferingEquiv)
	update_param!(m, :PigEquiv, SufferingEquiv)
	update_param!(m, :ChickenEquiv, SufferingEquiv)
	update_param!(m, :alphameat, alphaM)
	update_param!(m, :MeatReduc, Veg)	
	run(m)
	return m[:welfare, :UTILITY]
end

function ByAnimals_outcome(x::Array{Float64, 1}, SufferingEquiv=1.0)
	m 	= create_AnimalWelfareOpt()
	update_param!(m, :BeefReduc, x[1])
	update_param!(m, :PoultryReduc, x[2])
	update_param!(m, :PorkReduc, x[3])
	update_param!(m, :CowEquiv, SufferingEquiv)
	update_param!(m, :PigEquiv, SufferingEquiv)
	update_param!(m, :ChickenEquiv, SufferingEquiv)
	run(m)
	return m[:welfare, :UTILITY]
end

#---- Estimates TFP Parameters -------#
#m = create_dice_farm()
#run(m)
#DICEFARM_TFP = m[:grosseconomy, :AL][2015-1764:end]
#function TFPestimates(x, grad)
#	if length(grad)>0
#	grad[1] = 1000
#   grad[2] = 5
#	end
#    TFP    = ones(length(DICEFARM_TFP))
#   TFP[1] = 5.115
#    gA= ones(length(DICEFARM_TFP))
#    gA[1] = x[1]
#    for i = 2:length(gA)
#        gA[i] = exp(x[2]*(i-1))*gA[1]
#        TFP[i] = TFP[i-1]/(1-gA[i-1])
#    end
#	result = sum((DICEFARM_TFP - TFP).^2)
#	return result
#end
#opt = Opt(:LN_SBPLX, 2)
#opt.lower_bounds=[0.; -Inf]
#opt.upper_bounds=[.02; 0.]
#init = [.015; -.005]
#opt.xtol_rel = 1e-17
#opt.min_objective = TFPestimates
#sol2 = optimize(opt, init)[2]