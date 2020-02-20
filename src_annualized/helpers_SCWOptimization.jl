using Roots
using NLsolve
include(joinpath("AnimalWelfareModel.jl"))

## First need to calibrate prices (via relative and total consumption of meat in our 2020 period)
#Parameters nested within CES aggregator of meats
epsilon = 3.32   #elasticity of substitution parameter
theta_c = .3509  #coefficient within CES on chicken
theta_b = .2213
theta_p = .4279

# Total utility parameters
eta = 1.45     	  # As in Nordhaus
xi  = 2.8855 	  # From aggregate meat consumption growth vs normal consumption growth
alpha = .004 	  # linear coefficient on meat part of utility function

#### Now using aggregate data, estimate P (aggregate price)
temp = create_AnimalWelfare()
run(temp)
TwentyTwenty = 2020-1765
TotC 	 	= temp[:neteconomy, :C][TwentyTwenty]
Beef     	= temp[:farm, :Beef][6]
Pork		= temp[:farm, :Pork][6]
Poultry 	= temp[:farm, :Poultry][6]
Pop 		= 1e6*temp[:welfare, :l][6]
#All per cap from now on
Ytilde		= 1e12*TotC/Pop 	#Per capita total consumption to split between meat and other
PerCapChicken 	= Poultry/Pop
PerCapBeef    	= Beef/Pop
PerCapPork 		= Pork/Pop
rho 			= (epsilon-1)/epsilon
m 				= ((theta_c*PerCapChicken^rho + theta_b*PerCapBeef^rho + theta_p*PerCapPork^rho)^(1/rho)) #Per cap CES of Meat

### Non Linear Solver for P and C
f(x) = alpha*m^(-xi+1)*x^eta + x - Ytilde
c = find_zero(f, (0, 11200), Bisection())
P = alpha*m^(-xi)*c^(eta)

## --- Now need price of each individual product --- ## (right?)
function f!(F, x)
	F[1] 	= (x[2]/x[1])^epsilon * (theta_c/theta_b)^epsilon - (PerCapChicken/PerCapBeef)
	F[2]	= (x[3]/x[1])^epsilon * (theta_p/theta_b)^epsilon - (PerCapPork/PerCapBeef)
	F[3] 	= (x[1]^(1-epsilon)*theta_b^epsilon + x[2]^(1-epsilon)*theta_c^epsilon + x[3]^(1-epsilon)*theta_p^epsilon )^(1/(1-epsilon)) - P
end

sol = nlsolve(f!, [P; P; P])
PriceVect = sol.zero
PBeef 	  = PriceVect[1]
PPoultry  = PriceVect[2]
PPork 	  = PriceVect[3]


function create_AnimalWelfareOpt()
m = create_AnimalWelfare()
include(joinpath("components", "AnimalWelfare", "OptimalPolicy", "neteconomy_component.jl"))
include(joinpath("components", "AnimalWelfare", "OptimalPolicy", "farm_component.jl"))
include(joinpath("components", "AnimalWelfare", "OptimalPolicy", "welfare_component.jl"))
replace_comp!(m, farmforpolicy, :farm, reconnect=true)
set_param!(m, :farm, :theta_b, theta_b)
set_param!(m, :farm, :theta_c, theta_c)
set_param!(m, :farm, :theta_p, theta_c)
set_param!(m, :farm, :epsilon, epsilon)
set_param!(m, :farm, :PBeef, PBeef)
set_param!(m, :farm, :PPoultry, PPoultry)
set_param!(m, :farm, :PPork, PPork)
set_param!(m, :farm, :BeefReduc, 0.)
set_param!(m, :farm, :PorkReduc, 0.)
set_param!(m, :farm, :PoultryReduc, 0.)

replace_comp!(m, neteconomyforpolicy, :neteconomy, reconnect=true)
connect_param!(m, :neteconomy, :MeatExp, :farm, :MeatCost)

replace_comp!(m, welfareforpolicy, :welfare, reconnect=true)
set_param!(m, :welfare, :elasmeat, xi)
set_param!(m, :welfare, :alphameat, alpha)

connect_param!(m, :welfare, :Meat, :farm, :Meat)
return m
end

function veg_outcome(Veg, SufferingEquiv=1.0, alphaM = .004)
	m = create_AnimalWelfareOpt()
	set_param!(m, :welfare, :CowEquiv, SufferingEquiv)
	set_param!(m, :welfare, :PigEquiv, SufferingEquiv)
	set_param!(m, :welfare, :ChickenEquiv, SufferingEquiv)
	set_param!(m, :welfare, :alphameat, alphaM)
	set_param!(m, :farm, :MeatReduc, Veg)
	run(m)
	return m[:welfare, :UTILITY]
end

function ByAnimals_outcome(x::Array{Float64, 1}, SufferingEquiv=1.0)
	m 	= create_AnimalWelfareOpt()
	set_param!(m, :farm, :BeefReduc, x[1])
	set_param!(m, :farm, :PoultryReduc, x[2])
	set_param!(m, :farm, :PorkReduc, x[3])
	set_param!(m, :welfare, :CowEquiv, SufferingEquiv)
	set_param!(m, :welfare, :PigEquiv, SufferingEquiv)
	set_param!(m, :welfare, :ChickenEquiv, SufferingEquiv)
	run(m)
	return m[:welfare, :UTILITY]
end